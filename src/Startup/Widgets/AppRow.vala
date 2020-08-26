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
    public signal void app_info_changed (Entity.AppInfo new_info);

    public Entity.AppInfo app_info { get; construct; }
    public Gtk.Image image { get; set construct; }
    public Gtk.Label app_name { get; set construct; }
    public Gtk.Label app_comment { get; set construct; }

    public bool can_edit { get; set; default = false; }

    private Gtk.Switch active_switch;

    public AppRow (Entity.AppInfo app_info) {
        Object (app_info: app_info);
    }

    construct {
        image = Utils.create_icon (app_info, Gtk.IconSize.DIALOG);

        app_name = new Gtk.Label (app_info.name);
        app_name.get_style_context ().add_class ("h3");
        app_name.xalign = 0;

        app_comment = new Gtk.Label (app_info.comment);
        app_comment.ellipsize = Pango.EllipsizeMode.END;
        app_comment.hexpand = true;
        app_comment.xalign = 0;

        can_edit = app_info.is_custom ||
                   app_info.name == Backend.KeyFile.FALLBACK_CUSTOM_NAME ||
                   app_info.icon == Backend.KeyFile.FALLBACK_ICON; //FIXME is there a better way of identifying pre-existing custom commands?

        active_switch = new Gtk.Switch ();
        active_switch.tooltip_text = _("Launch %s on startup").printf (app_info.name);
        active_switch.valign = Gtk.Align.CENTER;
        active_switch.active = app_info.active;
        active_switch.notify["active"].connect (on_active_changed);

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 6;
        main_grid.column_spacing = 12;
        main_grid.attach (image, 0, 0, 1, 2);
        main_grid.attach (app_name, 1, 0, 1, 1);
        main_grid.attach (app_comment, 1, 1, 1, 1);
        main_grid.attach (active_switch, 2, 0, 1, 2);

        add (main_grid);
        show_all ();
        on_active_changed ();
    }

    private void on_active_changed () {
        active_changed (active_switch.active);
    }

    public void update_row_from_info (Entity.AppInfo new_info) {
        image.set_from_icon_name (new_info.icon, (Gtk.IconSize)(image.icon_size));
        app_name.label = new_info.name;
        app_comment.label = new_info.comment;
    }
}
