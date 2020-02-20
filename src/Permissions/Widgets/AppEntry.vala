/*
 * Copyright (c) 2011-2020 elementary Developers
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

public class Permissions.Widgets.AppEntry : Gtk.ListBoxRow {
    public Permissions.Backend.App app { get; construct; }

    public AppEntry (Permissions.Backend.App app) {
        Object (app: app);
    }

    construct {
        var image = new Gtk.Image.from_gicon (new ThemedIcon (app.id), Gtk.IconSize.DND);
        image.pixel_size = 32;

        var title_label = new Gtk.Label (app.name);
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.xalign = 0;
        title_label.valign = Gtk.Align.END;

        var description_label = new Gtk.Label (app.id);
        description_label.use_markup = true;
        description_label.ellipsize = Pango.EllipsizeMode.END;
        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 6;
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0, 1, 1);
        grid.attach (description_label, 1, 1, 1, 1);

        this.add (grid);
    }
}
