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

    private enum Target {
        URI_LIST
    }

    private const Gtk.TargetEntry[] TARGET_LIST = {
        { "text/uri-list", 0, Target.URI_LIST }
    };

    construct {
        Backend.KeyFileFactory.init ();

        var empty_alert = new Granite.Widgets.AlertView (
            _("Launch Apps on Startup"),
            _("Add apps to the Startup list by clicking the icon in the toolbar below."),
            "system-restart"
        );
        empty_alert.show_all ();

        list = new Gtk.ListBox () {
            expand = true
        };
        list.set_placeholder (empty_alert);
        list.set_sort_func (sort_function);

        Gtk.drag_dest_set (list, Gtk.DestDefaults.ALL, TARGET_LIST, Gdk.DragAction.COPY);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (list);

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

        var add_button = new Gtk.Button.from_icon_name ("application-add-symbolic", Gtk.IconSize.BUTTON);
        add_button.tooltip_text = _("Add Startup App…");

        var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
        remove_button.tooltip_text = _("Remove Selected Startup App");
        remove_button.sensitive = false;

        actionbar.add (add_button);
        actionbar.add (remove_button);

        var grid = new Gtk.Grid ();
        grid.attach (scrolled, 0, 0, 1, 1);
        grid.attach (actionbar, 0, 1, 1, 1);

        var frame = new Gtk.Frame (null);
        frame.add (grid);

        orientation = Gtk.Orientation.VERTICAL;
        margin = 12;
        margin_top = 0;
        add (frame);

        app_chooser = new Widgets.AppChooser (add_button);
        app_chooser.modal = true;

        var monitor = new Backend.Monitor ();
        controller = new Controller (this);

        add_button.clicked.connect (() => {
            app_chooser.show_all ();
        });

        app_chooser.app_chosen.connect ((path) => {
            controller.create_file (path);
        });

        app_chooser.custom_command_chosen.connect ((command) => {
            controller.create_file_from_command (command);
        });

        list.drag_data_received.connect (on_drag_data_received);
        list.row_selected.connect ((row) => {
            remove_button.sensitive = (row != null);
        });

        monitor.file_created.connect ((path) => {
            var key_file = Controller.get_key_file_from_path (path);
            var app_info = key_file.create_app_info ();
            add_app (app_info);
        });

        monitor.file_deleted.connect ((path) => {
            remove_app_from_path (path);
        });

        remove_button.clicked.connect (() => {
            remove_selected_app ();
        });
    }

    public void add_app (Entity.AppInfo app_info) {
        foreach (unowned Gtk.Widget app_row in list.get_children ()) {
            if (((Widgets.AppRow) app_row).app_info.equal (app_info)) {
                return;
            }
        }

        var row = new Widgets.AppRow (app_info);
        list.add (row);

        row.active_changed.connect ((active) => {
            controller.edit_file (row.app_info.path, active);
        });
    }

    public void remove_app_from_path (string path) {
        foreach (unowned Gtk.Widget app_row in list.get_children ()) {
            if (((Widgets.AppRow) app_row).app_info.path == path) {
                list.remove (app_row);
            }
        }
    }

    public void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos) {
        app_chooser.init_list (app_infos);
    }

    private void remove_selected_app () {
        var row = list.get_selected_row ();
        if (row == null) {
            return;
        }

        list.remove (row);
        controller.delete_file (((Widgets.AppRow)row).app_info.path);
    }

    private string? get_path_from_uri (string uri) {
        if (uri.has_prefix ("#") || uri.strip () == "")
            return null;

        try {
            return GLib.Filename.from_uri (uri);
        } catch (Error e) {
            warning ("Could not convert URI of dropped item to filename");
            warning (e.message);
        }

        return null;
    }

    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var name_1 = ((Widgets.AppRow) row1).app_info.name;
        var name_2 = ((Widgets.AppRow) row2).app_info.name;

        return name_1.collate (name_2);
    }

    private void on_drag_data_received (Gdk.DragContext context, int x, int y,
                                Gtk.SelectionData selection_data,
                                uint info, uint time_) {

        if (info != Target.URI_LIST) {
            return;
        }

        var uris = (string) selection_data.get_data ();
        foreach (unowned string uri in uris.split ("\r\n")) {
            var path = get_path_from_uri (uri);
            if (path != null) {
                controller.create_file (path);
            }
        }
    }
}
