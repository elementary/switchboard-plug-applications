/* SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2013-2023 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Julien Spautz <spautz.julien@gmail.com>
 */

public class Startup.Widgets.AppChooserRow : Gtk.Grid {

    public Entity.AppInfo app_info { get; construct; }

    public signal void deleted ();

    public AppChooserRow (Entity.AppInfo app_info) {
        Object (app_info: app_info);
    }

    construct {
        var image = Utils.create_icon (app_info, Gtk.IconSize.DND);

        var app_name = new Gtk.Label (app_info.name) {
            xalign = 0,
            ellipsize = Pango.EllipsizeMode.END
        };

        var app_comment = new Gtk.Label (app_info.comment) {
            xalign = 0,
            ellipsize = Pango.EllipsizeMode.END
        };
        app_comment.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        margin_top = 6;
        margin_end = 6;
        margin_bottom = 6;
        margin_start = 6;
        column_spacing = 6;
        attach (image, 0, 0, 1, 2);
        attach (app_name, 1, 0);
        attach (app_comment, 1, 1);

        show_all ();
    }
}
