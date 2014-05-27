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

public class Startup.Widgets.AppRow : Gtk.Box {

    Gtk.Button delete_button;
    Gtk.Label label;
    Gtk.Switch active_switch;
    Gtk.Image image;

    public Entity.AppInfo app_info { get; construct; }

    public signal void deleted ();
    public signal void active_changed (bool active);

    public AppRow (Entity.AppInfo app_info) {
        Object (app_info: app_info);
        setup ();
        connect_signals ();
        on_active_changed ();
    }

    void setup () {
        orientation = Gtk.Orientation.HORIZONTAL;

        var markup = Utils.create_markup (app_info);
        var icon = Utils.create_icon (app_info);

        margin = 6;
        spacing = 12;

        active_switch = new Gtk.Switch ();
        active_switch.active = app_info.active;
        add (active_switch);

        image = new Gtk.Image.from_pixbuf (icon);
        add (image);

        label = new Gtk.Label (markup);
        label.expand = true;
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.ellipsize = Pango.EllipsizeMode.END;
        add (label);

        delete_button = new Gtk.Button.with_label (_("Delete"));
        delete_button.get_style_context ().add_class ("destructive-action");
        delete_button.no_show_all = true;
        delete_button.vexpand = false;
        var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        button_box.add (delete_button);
        add (button_box);

        show_all ();
    }

    void connect_signals () {
        delete_button.clicked.connect (on_delete_clicked);
        active_switch.notify["active"].connect (on_active_changed);
    }

    void on_delete_clicked () {
        deleted ();
    }

    void on_active_changed () {
        active_changed (active_switch.active);
    }

    public void show_delete (bool show) {
        delete_button.no_show_all = !show;
        delete_button.visible = show;
    }
}