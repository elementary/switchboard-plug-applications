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

public class Startup.Widgets.ListWrapper : Gtk.ListBox {

    Gee.List <AppRow> _rows;
    protected Gee.List <AppRow> rows {
        get {
            _rows = new Gee.ArrayList <AppRow> ();
            @foreach ((widget) => {
                var app_row = get_app_row_from_widget (widget);
                if (app_row != null)
                    _rows.add (app_row);
            });
            return _rows;
        }
    }

    protected void add_row (AppRow row) {
        prepend (row);
    }

    protected void remove_row (AppRow row) {
        remove (row.parent);
    }

    protected AppRow? get_app_row_from_widget (Gtk.Widget widget) {
        var list_box_row = widget as Gtk.ListBoxRow;
        if (list_box_row == null)
            return null;

        var app_row = list_box_row.get_child () as AppRow;
        if (app_row == null)
            return null;

        return app_row;
    }
}

public class Startup.Widgets.List : ListWrapper {

    public NewAppRow new_app_row { get; private set; }

    Gee.List <string> paths {
        owned get {
            var list = new Gee.ArrayList <string> ();
            foreach (var app_row in rows)
                list.add (app_row.app_info.path);
            return list;
        }
    }

    //public signal void app_added (string path);
    public signal void app_removed (string path);
    public signal void app_active_changed (string path, bool active);

    public List () {
        setup_gui ();
        connect_signals ();
    }

    void setup_gui () {
        add_new_app_row ();
        set_sort_func (sort_function);
    }

    void connect_signals () {
        row_selected.connect (show_delete_button_on_select);
    }

    void add_new_app_row () {
        new_app_row = new NewAppRow ();
        prepend (new_app_row);
    }

    void show_delete_button_on_select (Gtk.ListBoxRow? selected) {
        foreach (var app_row in rows)
            app_row.show_delete (false);

        if (selected == null)
            return;

        var selected_app_row = get_app_row_from_widget (selected);
        if (selected_app_row != null)
            selected_app_row.show_delete (true);
    }

    int sort_function (Gtk.ListBoxRow list_box_row_1,
                       Gtk.ListBoxRow list_box_row_2) {
        var row_1 = list_box_row_1.get_child ();
        var row_2 = list_box_row_2.get_child ();

        if (row_1 is NewAppRow)
            return +1;
        if (row_2 is NewAppRow)
            return -1;

        var name_1 = (row_1 as AppRow).app_info.name;
        var name_2 = (row_2 as AppRow).app_info.name;
        return name_1.collate (name_2);
    }

    public void reload_app_from_path (string path) {
        // TODO
    }

    public void remove_app_from_path (string path) {
        foreach (var app_row in rows)
            if (app_row.app_info.path == path)
                remove_row (app_row);
    }

    public void add_app (Entity.AppInfo app_info) {
        if (app_info.path in paths)
            return;
        var row = new AppRow (app_info);
        add_row (row);
        connect_row_signals (row);
    }

    void connect_row_signals (AppRow row) {
        row.deleted.connect (() => {
            app_removed (row.app_info.path);
            remove (row.parent);
        });

        row.active_changed.connect ((active) => {
            app_active_changed (row.app_info.path, active);
        });
    }
}