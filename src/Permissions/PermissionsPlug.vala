/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.Plug : Gtk.Box {
    public static GLib.HashTable <unowned string, unowned string> permission_names { get; private set; }

    private Gtk.SearchEntry search_entry;
    private Gtk.ListBox app_list;
    private Widgets.AppSettingsView app_settings_view;

    static construct {
        permission_names = new GLib.HashTable <unowned string, unowned string> (str_hash, str_equal);
        permission_names["filesystems=home"] = _("Home Folder");
        permission_names["filesystems=host"] = _("System Folders");
        permission_names["devices=all"] = _("Devices");
        permission_names["shared=network"] = _("Network");
        permission_names["features=bluetooth"] = _("Bluetooth");
        permission_names["sockets=cups"] = _("Printing");
        permission_names["sockets=ssh-auth"] = _("Secure Shell Agent");
        permission_names["devices=dri"] = _("GPU Acceleration");
    }

    construct {
        var placeholder = new Granite.Placeholder (_("No Flatpak apps installed")) {
            icon = new ThemedIcon ("dialog-information"),
            description = _("Apps whose permissions can be adjusted will automatically appear here when installed")
        };
        placeholder.add_css_class (Granite.STYLE_CLASS_BACKGROUND);

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Applications")
        };

        var alert_view = new Granite.Placeholder ("") {
            icon = new ThemedIcon ("edit-find-symbolic"),
            description = _("Try changing search terms.")
        };

        app_list = new Gtk.ListBox () {
            vexpand = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };
        app_list.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        app_list.set_placeholder (alert_view);
        app_list.set_filter_func ((Gtk.ListBoxFilterFunc) filter_func);
        app_list.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);
        app_list.update_property (Gtk.AccessibleProperty.LABEL, _("Applications"), -1);


        var scrolled_window = new Gtk.ScrolledWindow () {
            child = app_list
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled_window
        };

        var sidebar = new Gtk.Box (VERTICAL, 12);
        sidebar.append (search_entry);
        sidebar.append (frame);

        var app_manager = Permissions.Backend.AppManager.get_default ();

        app_manager.apps.foreach ((id, app) => {
            var app_entry = new Permissions.SidebarRow (app);
            app_list.append (app_entry);
        });

        app_settings_view = new Widgets.AppSettingsView ();

        var first_child = app_list.get_first_child ();
        if (first_child != null && first_child is Gtk.ListBoxRow) {
            var row = (Gtk.ListBoxRow) first_child;

            app_list.select_row (row);
            show_row (row);
        }

        var grid = new Gtk.Grid () {
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12,
            column_spacing = 12
        };
        grid.attach (sidebar, 0, 0, 1, 1);
        grid.attach (app_settings_view, 1, 0, 2, 1);

        var placeholder_stack = new Gtk.Stack ();
        placeholder_stack.add_child (placeholder);
        placeholder_stack.add_child (grid);

        append (placeholder_stack);

        if (app_manager.apps.length > 0) {
            placeholder_stack.set_visible_child (grid);
        } else {
            placeholder_stack.set_visible_child (placeholder);
        }

        map.connect (() => search_entry.grab_focus ());
        search_entry.search_changed.connect (() => {
            app_list.invalidate_filter ();
            alert_view.title = _("No Results for “%s”").printf (search_entry.text);
        });

        app_list.row_selected.connect (show_row);
    }

    [CCode (instance_pos = -1)]
    private bool filter_func (SidebarRow row) {
        var should_show = search_entry.text.down ().strip () in row.app.name.down ();

        if (!should_show && app_list.get_selected_row () == row) {
            app_list.select_row (null);
        }

        return should_show;
    }

    [CCode (instance_pos = -1)]
    private int sort_func (SidebarRow row1, SidebarRow row2) {
        return row1.app.name.collate (row2.app.name);
    }

    private void show_row (Gtk.ListBoxRow? row) {
        if (row == null || !(row is Permissions.SidebarRow)) {
            app_settings_view.selected_app = null;
        } else {
            app_settings_view.selected_app = ((Permissions.SidebarRow)row).app;
        }
    }
}
