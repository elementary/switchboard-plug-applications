/*
* Copyright (c) 2013-2016 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
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
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

namespace Startup.Dialogs {

    public class AppRow : Gtk.Box {

        public Entity.AppInfo app_info { get; construct; }

        public signal void deleted ();

        public AppRow (Entity.AppInfo app_info) {
            Object (app_info: app_info);
            setup ();
        }

        void setup () {
            orientation = Gtk.Orientation.HORIZONTAL;

            var markup = Utils.create_markup (app_info);
            var icon = Utils.create_icon (app_info);

            margin = 6;
            spacing = 12;

            var image = new Gtk.Image.from_icon_name (icon, Gtk.IconSize.DND);
            add (image);

            var label = new Gtk.Label (markup);
            label.use_markup = true;
            label.halign = Gtk.Align.START;
            label.ellipsize = Pango.EllipsizeMode.END;
            add (label);

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
            setup_gui ();
            connect_signals ();
        }

        void setup_gui () {
            var grid = new Gtk.Grid ();
            grid.margin = 12;
            grid.row_spacing = 6;

            search_entry = new Gtk.SearchEntry ();
            search_entry.placeholder_text = _("Search Applications");

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.height_request = 200;
            scrolled.width_request = 250;
            scrolled.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            scrolled.shadow_type = Gtk.ShadowType.IN;

            list = new Gtk.ListBox ();
            list.expand = true;
            list.height_request = 250;
            list.width_request = 200;
            list.set_sort_func (sort_function);
            list.set_filter_func (filter_function);
            scrolled.add (list);

            custom_entry = new Gtk.Entry();
            custom_entry.placeholder_text = _("Type in a custom command");
            custom_entry.primary_icon_name = "document-properties-symbolic";
            custom_entry.primary_icon_activatable = false;

            grid.attach (search_entry, 0, 0, 1, 1);
            grid.attach (scrolled, 0, 1, 1, 1);
            grid.attach (custom_entry, 0, 2, 1, 1);

            add (grid);
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

        void connect_signals () {
            list.row_activated.connect (on_app_selected);
            search_entry.search_changed.connect (apply_filter);
            custom_entry.activate.connect (on_custom_command_entered);
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
