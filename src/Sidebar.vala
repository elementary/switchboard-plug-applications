/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 elementary, Inc. (https://elementary.io)
 */

public class Applications.Sidebar : Gtk.Box {
    public Gtk.Stack stack { get; construct; }

    private Gtk.SearchEntry search_entry;

    class construct {
        set_css_name ("settingssidebar");
    }

    public Sidebar (Gtk.Stack stack) {
        Object (stack: stack);
    }

    construct {
        var defaults_row = new SimpleSidebarRow (
            _("Defaults"), Plug.DEFAULTS
        );

        var startup_row = new SimpleSidebarRow (
            _("Startup"), Plug.STARTUP
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
        listbox.set_filter_func (filter_function);
        listbox.set_header_func (header_func);
        listbox.set_sort_func (sort_func);
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

        append (toolbarview);
        add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        Permissions.Backend.AppManager.get_default ().apps.foreach ((id, app) => {
            var app_entry = new Permissions.SidebarRow (app);
            listbox.append (app_entry);
        });

        listbox.row_selected.connect ((row) => {
            if (row == null) {
                return;
            }

            if (row is Permissions.SidebarRow) {
                stack.visible_child_name = Plug.PERMISSIONS;
                ((Permissions.Widgets.AppSettingsView) stack.visible_child).selected_app = ((Permissions.SidebarRow)row).app;
            } else if (row is SimpleSidebarRow) {
                stack.visible_child_name = ((SimpleSidebarRow) row).icon_name;
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

    private void header_func (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        if (row is SimpleSidebarRow && !(before is SimpleSidebarRow)) {
            row.set_header (new Granite.HeaderLabel (_("System")));
            return;
        }

        if (row is Permissions.SidebarRow && before is SimpleSidebarRow) {
            row.set_header (new Granite.HeaderLabel (_("Apps")));
            return;
        }

        row.set_header (null);
    }

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
            var image = new Gtk.Image.from_icon_name (icon_name) {
                icon_size = LARGE
            };

            var title_label = new Gtk.Label (label) {
                ellipsize = END,
                xalign = 0
            };
            title_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            var box = new Gtk.Box (HORIZONTAL, 6);
            box.append (image);
            box.append (title_label);

            accessible_role = TAB;
            child = box;
            update_property (Gtk.AccessibleProperty.LABEL, label, -1);
        }
    }
}
