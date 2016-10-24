/***
    Copyright (C) 2013 Julien Spautz <spautz.julien@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

namespace Startup.Dialogs {

    public class AppRow : Gtk.Grid {

        public Entity.AppInfo app_info { get; construct; }

        public signal void deleted ();

        public AppRow (Entity.AppInfo app_info) {
            Object (app_info: app_info);
        }

        construct {
            var icon = Utils.create_icon (app_info);

            var image = new Gtk.Image.from_icon_name (icon, Gtk.IconSize.DND);
            image.pixel_size = 32;

            var app_name = new Gtk.Label (app_info.name);
            app_name.get_style_context ().add_class ("h3");
            app_name.xalign = 0;

            var app_comment = new Gtk.Label ("<span font_size='small'>" + app_info.comment + "</span>");
            app_comment.xalign = 0;
            app_comment.use_markup = true;

            margin = 6;
            margin_end = 12;
            margin_start = 10; // Account for icon position on the canvas
            column_spacing = 12;
            attach (image, 0, 0, 1, 2);
            attach (app_name, 1, 0, 1, 1);
            attach (app_comment, 1, 1, 1, 1);

            show_all ();
        }
    }

    public class AppChooser : Gtk.Popover {

        Gtk.ListBox list;
        Gtk.SearchEntry search_entry;
        Gtk.Entry custom_entry;

        public signal void app_chosen (string path);
        public signal void custom_command_chosen (string command);

        public AppChooser (Gtk.Widget widget) {
            Object (relative_to: widget);
        }

        construct {
            search_entry = new Gtk.SearchEntry ();
            search_entry.margin_end = 12;
            search_entry.margin_start = 12;
            search_entry.placeholder_text = _("Search Applications");

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.height_request = 200;
            scrolled.width_request = 250;
            scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;

            list = new Gtk.ListBox ();
            list.expand = true;
            list.set_sort_func (sort_function);
            list.set_filter_func (filter_function);
            scrolled.add (list);

            custom_entry = new Gtk.Entry();
            custom_entry.margin_end = 12;
            custom_entry.margin_start = 12;
            custom_entry.placeholder_text = _("Type in a custom command");
            custom_entry.primary_icon_name = "utilities-terminal-symbolic";
            custom_entry.primary_icon_activatable = false;

            var grid = new Gtk.Grid ();
            grid.margin_bottom = 12;
            grid.margin_top = 12;
            grid.row_spacing = 6;
            grid.attach (search_entry, 0, 0, 1, 1);
            grid.attach (scrolled, 0, 1, 1, 1);
            grid.attach (custom_entry, 0, 2, 1, 1);

            add (grid);

            search_entry.grab_focus ();
            list.row_activated.connect (on_app_selected);
            search_entry.search_changed.connect (apply_filter);
            custom_entry.activate.connect (on_custom_command_entered);
        }

        public void init_list (Gee.Collection <Entity.AppInfo?> app_infos) {
            foreach (var app_info in app_infos)
                append_item_from_app_info (app_info);
        }

        void append_item_from_app_info (Entity.AppInfo app_info) {
            var app_row = new AppRow (app_info);
            list.prepend (app_row);
        }

        int sort_function (Gtk.ListBoxRow list_box_row_1,
                           Gtk.ListBoxRow list_box_row_2) {
            var row_1 = list_box_row_1.get_child () as AppRow;
            var row_2 = list_box_row_2.get_child () as AppRow;

            var name_1 = row_1.app_info.name;
            var name_2 = row_2.app_info.name;

            return name_1.collate (name_2);
        }

        bool filter_function (Gtk.ListBoxRow list_box_row) {
            var app_row = list_box_row.get_child () as AppRow;
            return search_entry.text.down () in app_row.app_info.name.down ()
                || search_entry.text.down () in app_row.app_info.comment.down ();
        }

        void on_app_selected (Gtk.ListBoxRow list_box_row) {
            var app_row = list_box_row.get_child () as AppRow;
            app_chosen (app_row.app_info.path);
            hide ();
        }

        void apply_filter () {
            list.set_filter_func (filter_function);
        }

        void on_custom_command_entered () {
            custom_command_chosen (custom_entry.text);
            hide ();
        }
    }
}
