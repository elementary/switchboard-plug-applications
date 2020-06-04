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

public class Permissions.Widgets.PermissionSettingsWidget : Gtk.Grid {
    public Backend.PermissionSettings settings { get; construct set; }
    public signal void changed_permission_settings (Backend.PermissionSettings settings);
    public bool do_notify { get; set; default = true; }

    public PermissionSettingsWidget (Backend.PermissionSettings settings) {
        GLib.Object (
            settings: settings
        );

        orientation = Gtk.Orientation.HORIZONTAL;
        hexpand = true;
        column_spacing = 12;

        var permission_description = Backend.PermissionManager.get_default ().get (settings.context);

        var icon = new Gtk.Image.from_icon_name (permission_description.icon, Gtk.IconSize.DND);
        icon.pixel_size = 32;
        attach (icon, 0, 0);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.set_tooltip_text (settings.context);

        var name_label = new Gtk.Label (permission_description.name);
        name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        name_label.halign = Gtk.Align.START;
        name_label.hexpand = true;
        box.pack_start (name_label, false, false);

        var description_label = new Gtk.Label (permission_description.description);
        description_label.halign = Gtk.Align.START;
        description_label.hexpand = true;
        description_label.wrap = true;
        description_label.xalign = 0;
        box.pack_start (description_label, false, false);

        attach (box, 1, 0);

        var s = new Gtk.Switch ();
        s.valign = Gtk.Align.CENTER;
        settings.bind_property ("enabled", s, "active", BindingFlags.BIDIRECTIONAL);
        attach (s, 2, 0);

        settings.notify["enabled"].connect (() => {
            if (do_notify) {
                changed_permission_settings (settings);
            }
        });
    }
}
