/***
    BEGIN LICENSE

    Copyright (C) 2014 elementary Developers
    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>

    END LICENSE
    Written By: Akshay Shekher <voldyman666@gmail.com>

***/

public class ApplicationsPlug : Switchboard.Plug {

    private const string DEFAULTS = "defaults";
    private const string STARTUP = "startup"; 

    private Defaults.Plug defaults_plug;
    private Startup.Plug startup_plug;

    private Gtk.Grid grid;
    private Gtk.Stack stack;

    public ApplicationsPlug () {
        Object (category: Category.PERSONAL,
                code_name: "personal-pantheon-applications",
                display_name: _("Applications"),
                description: _("Manage default and startup applications"),
                icon: "preferences-desktop-applications");

        defaults_plug = new Defaults.Plug ();
        startup_plug = new Startup.Plug ();
    }

    public override Gtk.Widget get_widget () {
        if (grid != null) {
            return grid;
        }

        stack = new Gtk.Stack ();
        stack.expand = true;

        stack.add_titled (defaults_plug.get_widget (), DEFAULTS, _("Default"));
        stack.add_titled (startup_plug.get_widget (), STARTUP, _("Startup"));

        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.set_halign (Gtk.Align.CENTER);
        stack_switcher.set_stack (stack);
        stack_switcher.margin_top = 12;

        grid = new Gtk.Grid ();
        grid.margin_top = 1;
        grid.row_spacing = 20;

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
