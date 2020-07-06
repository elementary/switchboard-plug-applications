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

public class Permissions.SidebarRow : Gtk.ListBoxRow {
    public Permissions.Backend.App app { get; construct; }
    private Gtk.Label description_label;

    public SidebarRow (Permissions.Backend.App app) {
        Object (app: app);
    }

    construct {
        var image = new Gtk.Image.from_icon_name (app.id, Gtk.IconSize.DND);
        image.pixel_size = 32;

        var title_label = new Gtk.Label (app.name) {
            ellipsize = Pango.EllipsizeMode.END,
            valign = Gtk.Align.END,
            xalign = 0
        };
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        description_label = new Gtk.Label ("") {
            ellipsize = Pango.EllipsizeMode.END,
            use_markup = true,
            valign = Gtk.Align.START,
            xalign = 0
        };

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            margin = 6
        };
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description_label);

        add (grid);

        for (var i = 0; i < app.settings.length; i++) {
            app.settings.get (i).notify.connect (update_description);
        }

        update_description ();
    }

    private void update_description () {
        var current_permissions = new GenericArray<string> ();
        for (var i = 0; i < app.settings.length; i++) {
            var settings = app.settings.get (i);
            if (settings.enabled) {
                current_permissions.add (Plug.permission_names[settings.context]);
            }
        }

        var description = string.joinv (", ", current_permissions.data);
        description_label.label = "<small>%s</small>".printf (description);
        set_tooltip_text (description);
    }
}
