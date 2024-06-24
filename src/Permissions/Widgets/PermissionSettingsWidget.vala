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
    public string description { get; construct; }
    public string icon_name { get; construct; }
    public string primary_text { get; construct; }

    public bool active { get; set; }

    public PermissionSettingsWidget (string primary_text, string description, string icon_name) {
        GLib.Object (
            description: description,
            icon_name: icon_name,
            primary_text: primary_text
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name) {
            icon_size = LARGE,
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
            focusable = false,
            valign = Gtk.Align.CENTER
        };

        var grid = new Gtk.Grid () {
            column_spacing = 6
        };
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (name_label, 1, 0);
        grid.attach (description_label, 1, 1);
        grid.attach (allow_switch, 2, 0, 1, 2);

        accessible_role = SWITCH;
        child = grid;

        update_property (
            Gtk.AccessibleProperty.LABEL, primary_text,
            Gtk.AccessibleProperty.DESCRIPTION, description,
            -1
        );

        bind_property ("active", allow_switch, "active", BIDIRECTIONAL);

        update_state (Gtk.AccessibleState.CHECKED, active, -1);
        notify["active"].connect (() => {
            update_state (Gtk.AccessibleState.CHECKED, active, -1);
        });
    }
}
