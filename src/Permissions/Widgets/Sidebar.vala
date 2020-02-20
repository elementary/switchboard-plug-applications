/*
 * Copyright 2011-2020 elementary, Inc (https://elementary.io)
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
 * Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
 * Boston, MA 02110-1301, USA.
 * 
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Permissions.Widgets.Sidebar : Gtk.Grid {
    construct {
        var app_list = new Gtk.ListBox ();
        app_list.expand = true;
        app_list.selection_mode = Gtk.SelectionMode.SINGLE;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (app_list);

        orientation = Gtk.Orientation.VERTICAL;
        add (scrolled_window);

        app_list.row_selected.connect (show_row);

        Backend.FlatpakManager.get_applications ().@foreach ((app) => {
            AppEntry app_entry = new AppEntry (app);
            app_list.add (app_entry);
        });

        List<weak Gtk.Widget> children = app_list.get_children ();
        if (children.length () > 0) {
            Gtk.ListBoxRow row = ((Gtk.ListBoxRow)children.nth_data (0));

            app_list.select_row (row);
            show_row (row);
        }
    }

    private void show_row (Gtk.ListBoxRow? row) {
        if (row == null || !(row is AppEntry)) {
            return;
        }

        Backend.AppManager.get_default ().selected_app = ((AppEntry)row).app.id;
    }
}
