/***
    Copyright (C) 2013 Julien Spautz <spautz.julien@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

public interface Startup.Port.List : Object {

    public signal void app_added (string path);
    public signal void app_added_from_command (string command);
    public signal void app_removed (string path);
    public signal void app_active_changed (string path, bool active);

    public abstract void add_app (Entity.AppInfo app_info);
    public abstract void remove_app_from_path (string path);
    public abstract void reload_app_from_path (string path);

    public abstract void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos);
}

/**
 * Main widget, handels drag and drop.
 */
public class Startup.Widgets.Scrolled : Gtk.ScrolledWindow, Port.List {

    public Widgets.List list { get; private set; }

    enum Target {
        URI_LIST
    }

    const Gtk.TargetEntry[] target_list = {
        { "text/uri-list", 0, Target.URI_LIST }
    };

    public Scrolled () {
        setup_gui ();
        connect_signals ();
    }

    void setup_gui () {
        list = new Widgets.List ();
		list.halign = Gtk.Align.CENTER;
        add (list);
        Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, target_list, Gdk.DragAction.COPY);
        drag_data_received.connect (on_drag_data_received);
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

    void connect_signals () {
        var app_chooser = list.new_app_row.app_chooser;
        
        app_chooser.app_chosen.connect ((p) => app_added (p));
        app_chooser.custom_command_chosen.connect ((c) => app_added_from_command (c));
        
        list.app_removed.connect ((p) => app_removed (p));
        list.app_active_changed.connect ((p,a) => app_active_changed (p,a));
    }

    public void add_app (Entity.AppInfo app_info) {
        list.add_app (app_info);
    }

    public void remove_app_from_path (string path) {
        list.remove_app_from_path (path);
    }

    public void reload_app_from_path (string path) {
        list.reload_app_from_path (path);
    }

    public void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos) {
        var app_chooser = list.new_app_row.app_chooser;
        app_chooser.init_list (app_infos);
    }
}