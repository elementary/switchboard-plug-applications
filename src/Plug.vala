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
    private Gtk.SearchEntry search_entry;
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

            search_entry = new Gtk.SearchEntry () {
                placeholder_text = _("Search Apps"),
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 6,
                margin_end = 6,
                hexpand = true
            };

            var search_revealer = new Gtk.Revealer () {
                child = search_entry
            };

            var search_toggle = new Gtk.ToggleButton () {
                icon_name = "edit-find-symbolic",
                tooltip_text = _("Search Apps")
            };

            var headerbar = new Adw.HeaderBar () {
                show_end_title_buttons = false,
                show_title = false
            };
            headerbar.pack_end (search_toggle);

            var listbox = new Gtk.ListBox () {
                vexpand = true,
                selection_mode = BROWSE
            };
            listbox.add_css_class (Granite.STYLE_CLASS_SIDEBAR);
            listbox.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);
            listbox.set_header_func ((row, before) => {
                if (row is SimpleSidebarRow && !(before is SimpleSidebarRow)) {
                    row.set_header (new Granite.HeaderLabel (_("System")));
                    return;
                }

                if (row is Permissions.SidebarRow && before is SimpleSidebarRow) {
                    row.set_header (new Granite.HeaderLabel (_("Apps")));
                    return;
                }

                row.set_header (null);
            });
            listbox.set_filter_func (filter_function);
            listbox.append (defaults_row);
            listbox.append (startup_row);

            var scrolled_window = new Gtk.ScrolledWindow () {
                child = listbox,
                hscrollbar_policy = NEVER
            };

            var toolbarview = new Adw.ToolbarView () {
                content = scrolled_window,
                top_bar_style = FLAT,
            };
            toolbarview.add_top_bar (headerbar);
            toolbarview.add_top_bar (search_revealer);

            var sidebar = new Sidebar ();
            sidebar.append (toolbarview);

            var paned = new Gtk.Paned (HORIZONTAL) {
                position = 200,
                start_child = sidebar,
                end_child = stack,
                shrink_start_child = false,
                shrink_end_child = false,
                resize_start_child = false
            };

            grid = new Gtk.Grid ();
            grid.attach (paned, 0, 0);

            Permissions.Backend.AppManager.get_default ().apps.foreach ((id, app) => {
                var app_entry = new Permissions.SidebarRow (app);
                listbox.append (app_entry);
            });

            listbox.row_selected.connect ((row) => {
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

            search_entry.search_changed.connect (() => {
                listbox.invalidate_filter ();
            });

            search_toggle.bind_property ("active", search_revealer, "reveal-child");

            search_revealer.notify["child-revealed"].connect (() => {
                if (search_revealer.child_revealed) {
                    search_entry.grab_focus ();
                } else {
                    search_entry.text = "";
                }
            });
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

    private bool filter_function (Gtk.ListBoxRow row) {
        if (search_entry.text != "") {
            if (row is SimpleSidebarRow) {
                return false;
            }

            var search_term = search_entry.text.down ();
            var row_name = ((Permissions.SidebarRow) row).app.name.down ();

            return search_term in row_name;
        }

        return true;
    }

    [CCode (instance_pos = -1)]
    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        if (row1 is Permissions.SidebarRow && row2 is Permissions.SidebarRow) {
            return ((Permissions.SidebarRow) row1).app.name.collate (((Permissions.SidebarRow) row2).app.name);
        }

        return 0;
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
            var image = new Gtk.Image.from_icon_name ("application-default-icon") {
                icon_size = LARGE
            };

            var title_label = new Gtk.Label (label) {
                ellipsize = END,
                xalign = 0
            };
            title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            var grid = new Gtk.Grid () {
                column_spacing = 6
            };
            grid.attach (image, 0, 0);
            grid.attach (title_label, 1, 0);

            hexpand = true;
            child = grid;
        }
    }

    // Workaround to set styles
    private class Sidebar : Gtk.Box {
        class construct {
            set_css_name ("settingssidebar");
        }

        construct {
            add_css_class (Granite.STYLE_CLASS_SIDEBAR);
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    return new ApplicationsPlug ();
}
