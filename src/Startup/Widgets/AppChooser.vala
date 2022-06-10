/*
* Copyright 2013-2020 elementary, Inc. (https://elementary.io)
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
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

public class Startup.Widgets.AppChooser : Gtk.Popover {
    public signal void app_chosen (string path);
    public signal void custom_command_chosen (string command);
    public Gtk.Widget relative_widget { get; construct; }

    private Gtk.ListBox list;
    private Gtk.SearchEntry search_entry;
    private Gtk.Entry custom_entry;

    public AppChooser (Gtk.Widget widget) {
        Object (relative_widget: widget);
    }

    construct {
        Gtk.Allocation allocation;
        relative_widget.get_allocation (out allocation);

        // pointing_to = allocation;

        search_entry = new Gtk.SearchEntry () {
            margin_end = 12,
            margin_start = 12,
            placeholder_text = _("Search Applications")
        };

        list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.set_sort_func (sort_function);
        list.set_filter_func (filter_function);

        var scrolled = new Gtk.ScrolledWindow () {
            height_request = 200,
            width_request = 500,
            child = list
        };

        custom_entry = new Gtk.Entry () {
            margin_end = 12,
            margin_start = 12,
            placeholder_text = _("Type in a custom command"),
            primary_icon_activatable = false,
            primary_icon_name = "utilities-terminal-symbolic"
        };

        var grid = new Gtk.Grid () {
            margin_bottom = 12,
            margin_top = 12,
            row_spacing = 6
        };
        grid.attach (search_entry, 0, 0);
        grid.attach (scrolled, 0, 1);
        grid.attach (custom_entry, 0, 2);

        child = grid;
        default_widget = grid;
        set_offset (250, -1);
        position = Gtk.PositionType.TOP;

        search_entry.grab_focus ();
        search_entry.search_changed.connect (() => {
            list.invalidate_filter ();
        });

        list.row_activated.connect (on_app_selected);
        custom_entry.activate.connect (on_custom_command_entered);
    }

    public void init_list (Gee.Collection <Entity.AppInfo?> app_infos) {
        foreach (var app_info in app_infos) {
            var app_row = new AppChooserRow (app_info);
            list.prepend (app_row);
        }
    }

    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        unowned AppChooserRow row_1 = (AppChooserRow) row1.get_child ();
        unowned AppChooserRow row_2 = (AppChooserRow) row2.get_child ();

        var name_1 = row_1.app_info.name;
        var name_2 = row_2.app_info.name;

        return name_1.collate (name_2);
    }

    private bool filter_function (Gtk.ListBoxRow list_box_row) {
        var app_row = list_box_row.get_child () as AppChooserRow;
        return search_entry.text.down () in app_row.app_info.name.down ()
            || search_entry.text.down () in app_row.app_info.comment.down ();
    }

    private void on_app_selected (Gtk.ListBoxRow list_box_row) {
        var app_row = list_box_row.get_child () as AppChooserRow;
        app_chosen (app_row.app_info.path);
        hide ();
    }

    private void on_custom_command_entered () {
        custom_command_chosen (custom_entry.text);
        hide ();
    }
}
