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

public class Permissions.Plug : Gtk.Grid {
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
        var placeholder_title = new Granite.HeaderLabel (_("No Flatpak apps installed")) {
            xalign = 0
        };
        placeholder_title.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var placeholder_description = new Gtk.Label (_("Apps whose permissions can be adjusted will automatically appear here when installed")) {
            wrap = true,
            xalign = 0
        };

        var placeholder = new Gtk.Grid () {
            row_spacing = 3,
            hexpand = true,
            vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        placeholder.attach (placeholder_title, 0, 0);
        placeholder.attach (placeholder_description, 0, 1);
        placeholder.show_all ();

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Applications")
        };

        var alert_view = new Granite.Widgets.AlertView ("", _("Try changing search terms."), "edit-find-symbolic");
        alert_view.show_all ();

        app_list = new Gtk.ListBox () {
            vexpand = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };
        app_list.set_placeholder (alert_view);
        app_list.set_filter_func ((Gtk.ListBoxFilterFunc) filter_func);
        app_list.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);
        app_list.get_accessible ().accessible_name = _("Applications");

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            child = app_list
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled_window
        };

        var sidebar = new Gtk.Box (VERTICAL, 12);
        sidebar.add (search_entry);
        sidebar.add (frame);

        var app_manager = Permissions.Backend.AppManager.get_default ();

        app_manager.apps.foreach ((id, app) => {
            var app_entry = new Permissions.SidebarRow (app);
            app_list.add (app_entry);
        });

        app_settings_view = new Widgets.AppSettingsView ();

        List<weak Gtk.Widget> children = app_list.get_children ();
        if (children.length () > 0) {
            var row = ((Gtk.ListBoxRow)children.nth_data (0));

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
        placeholder_stack.add (placeholder);
        placeholder_stack.add (grid);

        add (placeholder_stack);
        show_all ();

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
