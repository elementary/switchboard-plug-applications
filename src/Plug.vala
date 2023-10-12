/*
* Copyright 2014-2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
*              Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class ApplicationsPlug : Switchboard.Plug {
    private const string DEFAULTS = "defaults";
    private const string STARTUP = "startup";
    private const string PERMISSIONS = "permissions";

    private Gtk.Grid grid;
    private Gtk.Stack stack;

    public ApplicationsPlug () {
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");

        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("applications", null);
        settings.set ("applications/defaults", DEFAULTS);
        settings.set ("applications/startup", STARTUP);
        settings.set ("applications/permissions", PERMISSIONS);

        Object (
            category: Category.PERSONAL,
            code_name: "io.elementary.settings.applications",
            description: _("Manage default apps, startup apps, and app permissions"),
            display_name: _("Applications"),
            icon: "io.elementary.settings.applications",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (grid == null) {
            stack = new Gtk.Stack () {
                hexpand = true,
                vexpand = true
            };
            stack.add_titled (new Defaults.Plug (), DEFAULTS, _("Defaults"));
            stack.add_titled (new Startup.Plug (), STARTUP, _("Startup"));
            stack.add_titled (new Permissions.Plug (), PERMISSIONS, _("Permissions"));

            var stack_switcher = new Gtk.StackSwitcher () {
                halign = Gtk.Align.CENTER,
                stack = stack
            };

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            var widget = stack_switcher.get_first_child ();
            while (widget != null) {
                size_group.add_widget (widget);
                widget = widget.get_next_sibling ();
            }

            grid = new Gtk.Grid () {
                margin_top = 12,
                row_spacing = 24
            };
            grid.attach (stack_switcher, 0, 0);
            grid.attach (stack, 0, 1);
        }

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
            case PERMISSIONS:
                stack.set_visible_child_name (location);
                break;
            default:
                stack.set_visible_child_name (DEFAULTS);
                break;
        }
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );
        search_results.set ("%s → %s".printf (display_name, _("Startup")), STARTUP);
        search_results.set ("%s → %s".printf (display_name, _("Default Apps")), DEFAULTS);
        search_results.set ("%s → %s".printf (display_name, _("Permissions")), PERMISSIONS);
        search_results.set ("%s → %s".printf (display_name, _("Sandboxing")), PERMISSIONS);
        search_results.set ("%s → %s".printf (display_name, _("Confinement")), PERMISSIONS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Web Browser")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Email Client")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Calendar")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Video Player")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Music Player")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Text Editor")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("Image Viewer")), DEFAULTS);
        search_results.set ("%s → %s → %s".printf (display_name, _("Default"), _("File Browser")), DEFAULTS);
        return search_results;
    }

}

public Switchboard.Plug get_plug (Module module) {
    return new ApplicationsPlug ();
}
