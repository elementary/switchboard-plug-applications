/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
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

public class Permissions.Widgets.BooleanSetting : Gtk.Box {
    public string title { get; set; }
    public string option { get; set; }
    public bool enabled { get; set; }

    public BooleanSetting (string title, string option, bool enabled) {
        Object(
            title: title,
            option: option,
            enabled: enabled
        );

        orientation = Gtk.Orientation.HORIZONTAL;
        hexpand = true;
        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        title_label.halign = Gtk.Align.START;
        vbox.pack_start (title_label, true, true, 0);

        var option_label = new Gtk.Label (option);
        option_label.halign = Gtk.Align.START;
        vbox.pack_end (option_label, true, true, 0);

        pack_start (vbox, false, false, 0);

        var s = new Gtk.Switch ();
        s.state = enabled;
        pack_end (s, false, false, 0);
    }
}
