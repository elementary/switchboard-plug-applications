/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.Widgets.PermissionSettingsWidget : Gtk.ListBoxRow {
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
        var icon = new Gtk.Image.from_icon_name (icon_name) {
            icon_size = LARGE,
            tooltip_text = settings.context
        };

        var name_label = new Gtk.Label (primary_text) {
            halign = Gtk.Align.START,
            hexpand = true
        };

        var description_label = new Gtk.Label (description) {
            wrap = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        description_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var allow_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER
        };

        var grid = new Gtk.Grid () {
            column_spacing = 12
        };
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0);
        grid.attach (description_label, 1, 1);
        grid.attach (allow_switch, 2, 0, 1, 2);

        child = grid;

        activate.connect (() => {
            allow_switch.activate ();
        });

        settings.bind_property ("enabled", allow_switch, "active", BindingFlags.BIDIRECTIONAL);

        settings.notify["enabled"].connect (() => {
            if (do_notify) {
                changed_permission_settings (settings);
            }
        });
    }
}
