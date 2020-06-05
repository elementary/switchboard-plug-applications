/*
 * Copyright 2020 elementary, Inc. (https://elementary.io)
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
    public signal void changed_permission_settings (Backend.PermissionSettings settings);

    public string description { get; construct set; }
    public string icon_name { get; construct set; }
    public string primary_text { get; construct set; }
    public Backend.PermissionSettings settings { get; construct set; }

    public bool do_notify { get; set; default = true; }

    public PermissionSettingsWidget (string primary_text, string description, string icon_name, Backend.PermissionSettings settings) {
        GLib.Object (
            description: description,
            icon_name: icon_name,
            primary_text: primary_text,
            settings: settings
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);
        icon.pixel_size = 32;
        icon.tooltip_text = settings.context;

        var name_label = new Gtk.Label (primary_text);
        name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        name_label.halign = Gtk.Align.START;
        name_label.hexpand = true;

        var description_label = new Gtk.Label (description);
        description_label.halign = Gtk.Align.START;
        description_label.hexpand = true;
        description_label.wrap = true;
        description_label.xalign = 0;

        var allow_switch = new Gtk.Switch ();
        allow_switch.valign = Gtk.Align.CENTER;

        hexpand = true;
        column_spacing = 12;
        attach (icon, 0, 0, 1, 2);
        attach (name_label, 1, 0);
        attach (description_label, 1, 1);
        attach (allow_switch, 2, 0, 1, 2);

        settings.bind_property ("enabled", allow_switch, "active", BindingFlags.BIDIRECTIONAL);

        settings.notify["enabled"].connect (() => {
            if (do_notify) {
                changed_permission_settings (settings);
            }
        });
    }
}
