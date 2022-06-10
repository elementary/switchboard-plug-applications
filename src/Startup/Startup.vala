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
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*              Julien Spautz <spautz.julien@gmail.com>
*/

public class Startup.Plug : Gtk.Grid {
    private Controller controller;
    private Gtk.ListBox list;
    private Widgets.AppChooser app_chooser;

    construct {
        Backend.KeyFileFactory.init ();

        var empty_alert = new Granite.Placeholder (_("Launch Apps on Startup")) {
            description = _("Add apps to the Startup list by clicking the icon in the toolbar below."),
            icon = new ThemedIcon ("system-restart")
        };

        list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.set_placeholder (empty_alert);
        list.set_sort_func (sort_function);

        var drop_target = new Gtk.DropTarget (typeof (Gdk.FileList), Gdk.DragAction.COPY);
        list.add_controller (drop_target);

        var scrolled = new Gtk.ScrolledWindow () {
            child = list
        };

        var actionbar = new Gtk.ActionBar ();
        actionbar.add_css_class ("inline-toolbar");

        var add_button = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("application-add-symbolic") {
                pixel_size = 16
            },
            tooltip_text = _("Add Startup App…")
        };

        var remove_button = new Gtk.Button () {
            child = new Gtk.Image.from_icon_name ("list-remove-symbolic") {
                pixel_size = 16
            },
            tooltip_text = _("Remove Selected Startup App"),
            sensitive = false
        };

        actionbar.pack_start (add_button);
        actionbar.pack_start (remove_button);

        var grid = new Gtk.Grid ();
        grid.attach (scrolled, 0, 0, 1, 1);
        grid.attach (actionbar, 0, 1, 1, 1);

        var frame = new Gtk.Frame (null) {
            child = grid
        };

        orientation = Gtk.Orientation.VERTICAL;
        margin_start = 12;
        margin_end = 12;
        margin_bottom = 12;
        margin_top = 0;
        attach (frame, 0, 0);

        app_chooser = new Widgets.AppChooser (add_button) {
            autohide = true
        };
        app_chooser.set_parent (add_button);

        var monitor = new Backend.Monitor ();
        controller = new Controller (this);

        add_button.clicked.connect (() => {
            app_chooser.popup ();
        });

        app_chooser.app_chosen.connect ((path) => {
            create_file (path);
        });

        app_chooser.custom_command_chosen.connect ((command) => {
            add_app (new Backend.KeyFile.from_command (command));
        });

        drop_target.on_drop.connect (on_drag_data_received);
        list.row_selected.connect ((row) => {
            remove_button.sensitive = (row != null);
        });

        monitor.file_created.connect ((path) => {
            add_app (Backend.KeyFileFactory.get_or_create (path));
        });

        monitor.file_deleted.connect ((path) => {
            remove_app_from_path (path);
        });

        remove_button.clicked.connect (() => {
            remove_selected_app ();
        });
    }

    public void add_app (Backend.KeyFile key_file) {
        var app_info = key_file.create_app_info ();
        var children = list.observe_children ();
        for (var iter = 0; iter < children.get_n_items (); iter++) {
            if (((Widgets.AppRow) children.get_item (iter)).app_info.equal (app_info)) {
                return;
            }
        }

        var row = new Widgets.AppRow (app_info);
        list.append (row);

        row.active_changed.connect ((active) => {
            key_file.active = active;
            key_file.write_to_file ();
        });
    }

    public void remove_app_from_path (string path) {
        var children = list.observe_children ();
        for (var iter = 0; iter < children.get_n_items (); iter++) {
            if (((Widgets.AppRow) children.get_item (iter)).app_info.path == path) {
                list.remove ((Widgets.AppRow) children.get_item (iter));
            }
        }
    }

    public void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos) {
        app_chooser.init_list (app_infos);
    }

    private void create_file (string path) {
        var key_file = Backend.KeyFileFactory.get_or_create (path);
        key_file.active = true;
        key_file.copy_to_local ();

        add_app (key_file);
    }

    private void remove_selected_app () {
        var row = list.get_selected_row ();
        if (row == null) {
            return;
        }

        list.remove (row);

        GLib.FileUtils.remove (((Widgets.AppRow)row).app_info.path);
    }

    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var name_1 = ((Widgets.AppRow) row1).app_info.name;
        var name_2 = ((Widgets.AppRow) row2).app_info.name;

        return name_1.collate (name_2);
    }

    private bool on_drag_data_received (Gtk.DropTarget drop_target, Value val, double x, double y) {

        // if (val != Target.URI_LIST) {
        //     return;
        // }
        var file_list = (Gdk.FileList) val;
        var files = file_list.get_files ();

        foreach (var file in files) {
            var path = file.get_path ();
            if (path != null) {
                create_file (path);
            }
        }

        return false;
    }
}
