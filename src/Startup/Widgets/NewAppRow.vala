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

public class Startup.Widgets.NewAppRow : Gtk.Box {

    public Dialogs.AppChooser app_chooser;
    Gtk.Button add_button;

    public NewAppRow () {
        setup ();
        connect_signals ();
    }

    void setup () {
        orientation = Gtk.Orientation.HORIZONTAL;

        margin = 6;
        spacing = 12;

        var invisible_switch = new Gtk.Switch ();
        invisible_switch.opacity = 0.0;
        add (invisible_switch);

        add_button = new Gtk.Button.from_icon_name ("add", Gtk.IconSize.DIALOG);
        add_button.relief = Gtk.ReliefStyle.NONE;
        add (add_button);

        var label = new Gtk.Label ("<i>" + _("Add Startup App") + "</i>");
        label.expand = true;
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.ellipsize = Pango.EllipsizeMode.END;
        add (label);

        app_chooser = new Dialogs.AppChooser (add_button);
        app_chooser.modal = true;
    }

    void connect_signals () {
        add_button.clicked.connect (app_chooser.show_all);
    }
}