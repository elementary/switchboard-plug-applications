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

public class Startup.Widgets.AppRow : Gtk.ListBoxRow {
    public signal void active_changed (bool active);

    public Entity.AppInfo app_info { get; construct; }

    public AppRow (Entity.AppInfo app_info) {
        Object (app_info: app_info);
    }

    construct {
        var image = Utils.create_icon (app_info, Gtk.IconSize.DIALOG);

        var app_name = new Gtk.Label (app_info.name) {
            xalign = 0
        };
        app_name.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var app_comment = new Gtk.Label (app_info.comment) {
            ellipsize = Pango.EllipsizeMode.END,
            hexpand = true,
            xalign = 0
        };

        var active_switch = new Gtk.Switch () {
            active = app_info.active,
            tooltip_text = _("Launch %s on startup").printf (app_info.name),
            valign = Gtk.Align.CENTER
        };

        var main_grid = new Gtk.Grid () {
            column_spacing = 12,
            margin = 6
        };
        main_grid.attach (image, 0, 0, 1, 2);
        main_grid.attach (app_name, 1, 0);
        main_grid.attach (app_comment, 1, 1);
        main_grid.attach (active_switch, 2, 0, 1, 2);

        add (main_grid);
        show_all ();

        active_switch.notify["active"].connect (() => {
            active_changed (active_switch.active);
        });
    }
}
