/*
* Copyright (c) 2014-2017 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*/

public class ApplicationsPlug : Switchboard.Plug {

    private const string DEFAULTS = "defaults";
    private const string STARTUP = "startup"; 

    private Gtk.Grid grid;
    private Gtk.Stack stack;

    public ApplicationsPlug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("applications", null);
        settings.set ("applications/defaults", DEFAULTS);
        settings.set ("applications/startup", STARTUP);
        Object (category: Category.PERSONAL,
                code_name: "personal-pantheon-applications",
                display_name: _("Applications"),
                description: _("Manage default and startup applications"),
                icon: "preferences-desktop-applications",
                supported_settings: settings);
    }

    public override Gtk.Widget get_widget () {
        if (grid != null) {
            return grid;
        }

        var defaults_plug = new Defaults.Plug ();
        var startup_plug = new Startup.Plug ();

        stack = new Gtk.Stack ();
        stack.expand = true;

        stack.add_titled (defaults_plug, DEFAULTS, _("Default"));
        stack.add_titled (startup_plug, STARTUP, _("Startup"));

        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.halign = Gtk.Align.CENTER;
        stack_switcher.homogeneous = true;
        stack_switcher.margin_top = 12;
        stack_switcher.stack = stack;

        grid = new Gtk.Grid ();
        grid.margin_top = 1;
        grid.row_spacing = 24;

        grid.attach (stack_switcher, 0, 0, 1, 1);
        grid.attach (stack, 0, 1, 1, 1);

        grid.show_all ();
        return grid;
    }

    public override void shown () {
    
    }

    public override void hidden () {
    
    }

    public override void search_callback (string location) {
        switch (location) {
            case STARTUP:
            case DEFAULTS:
                stack.set_visible_child_name (location);
                break;
            default:
                stack.set_visible_child_name (DEFAULTS);
                break;
        }
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        search_results.set ("%s → %s".printf (display_name, _("Startup")), STARTUP);
        search_results.set ("%s → %s".printf (display_name, _("Default Apps")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Application")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Web Browser")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Music Player")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Email Client")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Text Editor")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default File Browser")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Video Player")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Default Calendar")), DEFAULTS);
        return search_results;
    }

}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Applications plug");
    var plug = new ApplicationsPlug ();
    return plug;
}
