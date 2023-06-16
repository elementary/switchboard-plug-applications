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

    private Gtk.Box box;
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
            code_name: "io.elementary.switchboard.applications",
            description: _("Manage default apps, startup apps, and app permissions"),
            display_name: _("Applications"),
            icon: "io.elementary.settings.applications",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (box == null) {
            var app_settings_view = new Permissions.Widgets.AppSettingsView ();

            stack = new Gtk.Stack () {
                hexpand = true,
                vexpand = true
            };
            stack.add_named (new Defaults.Plug (), DEFAULTS);
            stack.add_named (new Startup.Plug (), STARTUP);
            stack.add_named (app_settings_view, PERMISSIONS);

            var defaults_row = new SimpleSidebarRow (
                _("Defaults"), "preferences-desktop-defaults"
            );

            var startup_row = new SimpleSidebarRow (
                _("Startup"), "preferences-desktop-startup"
            );

            var sidebar = new Gtk.ListBox () {
                vexpand = true,
                selection_mode = Gtk.SelectionMode.SINGLE
            };
            sidebar.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);
            sidebar.add (defaults_row);
            sidebar.add (startup_row);

            Permissions.Backend.AppManager.get_default ().apps.foreach ((id, app) => {
                var app_entry = new Permissions.SidebarRow (app);
                sidebar.add (app_entry);
            });

            var scrolled_window = new Gtk.ScrolledWindow (null, null) {
                child = sidebar,
                expand = true,
                hscrollbar_policy = Gtk.PolicyType.NEVER
            };

            var clamp = new Hdy.Clamp () {
                child = stack
            };

            var paned = new Gtk.Paned (HORIZONTAL) {
                position = 200
            };
            paned.pack1 (scrolled_window, false, false);
            paned.pack2 (clamp, true, false);

            box = new Gtk.Box (VERTICAL, 0);
            box.add (paned);
            box.show_all ();

            sidebar.row_selected.connect ((row) => {
                if (row == null) {
                    return;
                }

                if (row is Permissions.SidebarRow) {
                    stack.visible_child = app_settings_view;
                    app_settings_view.selected_app = ((Permissions.SidebarRow)row).app;
                } else if (row is SimpleSidebarRow) {
                    if (((SimpleSidebarRow) row).icon_name == "preferences-desktop-defaults") {
                        stack.visible_child_name = DEFAULTS;
                    } else if (((SimpleSidebarRow) row).icon_name == "preferences-desktop-startup") {
                        stack.visible_child_name = STARTUP;
                    }

                }
            });
        }

        return box;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    [CCode (instance_pos = -1)]
    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        if (row1 is Permissions.SidebarRow && row2 is Permissions.SidebarRow) {
            return ((Permissions.SidebarRow) row1).app.name.collate (((Permissions.SidebarRow) row2).app.name);
        }

        return 0;
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

    private class SimpleSidebarRow : Gtk.ListBoxRow {
        public string label { get; construct; }
        public string icon_name { get; construct; }

        public SimpleSidebarRow (string label, string icon_name) {
            Object (
                label: label,
                icon_name: icon_name
            );
        }

        construct {
            var image = new Gtk.Image.from_icon_name ("application-default-icon", Gtk.IconSize.DND) {
                pixel_size = 32
            };

            var title_label = new Gtk.Label (label) {
                ellipsize = Pango.EllipsizeMode.END,
                xalign = 0
            };
            title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            var grid = new Gtk.Grid () {
                column_spacing = 6,
                margin_top = 6,
                margin_end = 6,
                margin_bottom = 6,
                margin_start = 6
            };
            grid.attach (image, 0, 0);
            grid.attach (title_label, 1, 0);

            hexpand = true;
            child = grid;
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    return new ApplicationsPlug ();
}
