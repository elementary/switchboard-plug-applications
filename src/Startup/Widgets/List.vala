/*
* Copyright 2013-2017 elementary, Inc. (https://elementary.io)
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

public class Startup.Widgets.List : Gtk.ListBox {
    public signal void app_added (string path);
    public signal void app_removed (string path);
    public signal void app_active_changed (string path, bool active);

    enum Target {
        URI_LIST
    }

    const Gtk.TargetEntry[] TARGET_LIST = {
        { "text/uri-list", 0, Target.URI_LIST }
    };

    Gee.List <string> paths {
        owned get {
            var list = new Gee.ArrayList <string> ();
            foreach (var app_row in get_children ()) {
                list.add (((AppRow) app_row).app_info.path);
            }

            return list;
        }
    }

    public List () {
        set_sort_func (sort_function);

        Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, TARGET_LIST, Gdk.DragAction.COPY);
        drag_data_received.connect (on_drag_data_received);

        var empty_alert = new Granite.Widgets.AlertView (
            _("Launch Apps on Startup"),
            _("Add apps to the Startup list by clicking the icon in the toolbar below."),
            "system-restart"
        );
        empty_alert.show_all ();
        set_placeholder (empty_alert);
    }

    int sort_function (Gtk.ListBoxRow list_box_row_1,
                       Gtk.ListBoxRow list_box_row_2) {

        var name_1 = (list_box_row_1 as AppRow).app_info.name;
        var name_2 = (list_box_row_2 as AppRow).app_info.name;
        return name_1.collate (name_2);
    }

    public void reload_app_from_path (string path) {
        // TODO
    }

    public void remove_app_from_path (string path) {
        foreach (var app_row in get_children ())
            if (((AppRow) app_row).app_info.path == path)
                remove (app_row);
    }

    public void remove_selected_app () {
        var row = get_selected_row ();
        if (row == null)
            return;

        remove (row);
        app_removed (((AppRow)row).app_info.path);
    }

    public void edit_selected_row () {
        var row = get_selected_row ();
        if (row == null) {
            return;
        }

        ((AppRow)row).start_editing ();
    }

    public void add_app (Entity.AppInfo app_info) {
        if (app_info.path in paths)
            return;
        var row = new AppRow (app_info);
        add (row);
        connect_row_signals (row);
    }

    void connect_row_signals (AppRow row) {
        row.active_changed.connect ((active) => {
            app_active_changed (row.app_info.path, active);
        });
    }

    void on_drag_data_received (Gdk.DragContext context, int x, int y,
                                Gtk.SelectionData selection_data,
                                uint info, uint time_) {

        if (info != Target.URI_LIST)
            return;

        var uris = (string) selection_data.get_data ();
        add_uris_to_list (uris);
    }

    void add_uris_to_list (string uris) {
        foreach (var uri in uris.split ("\r\n"))
           add_uri_to_list (uri);
    }

    void add_uri_to_list (string uri) {
        var path = get_path_from_uri (uri);
        if (path != null)
            app_added (path);
    }

    string? get_path_from_uri (string uri) {
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
}
