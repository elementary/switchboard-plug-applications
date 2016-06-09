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

public class Startup.Widgets.AppRow : Gtk.ListBoxRow {
    public signal void active_changed (bool active);

    public Entity.AppInfo app_info { get; construct; }

    Gtk.Label label;
    Gtk.Switch active_switch;
    Gtk.Image image;
    Gtk.Grid main_grid;

    public AppRow (Entity.AppInfo app_info) {
        Object (app_info: app_info);

        main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.HORIZONTAL;

        var markup = Utils.create_markup (app_info);

        main_grid.margin = 6;
        main_grid.column_spacing = 12;

        var icon = Utils.create_icon (app_info);

        image = new Gtk.Image.from_icon_name (icon, Gtk.IconSize.DIALOG);
        main_grid.add (image);

        label = new Gtk.Label (markup);
        label.expand = true;
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.ellipsize = Pango.EllipsizeMode.END;
        main_grid.add (label);

        active_switch = new Gtk.Switch ();
        active_switch.valign = Gtk.Align.CENTER;
        active_switch.active = app_info.active;
        active_switch.notify["active"].connect (on_active_changed);
        main_grid.add (active_switch);

        add (main_grid);
        show_all ();
        on_active_changed ();
    }

    void on_active_changed () {
        active_changed (active_switch.active);
    }
}
