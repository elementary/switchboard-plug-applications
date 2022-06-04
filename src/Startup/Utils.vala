/*
* Copyright 2013-2018 elementary, Inc. (https://elementary.io)
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
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

namespace Startup.Utils {
    private const string AUTOSTART_DIR = "autostart";

    public string get_user_startup_dir () {
        var config_dir = Environment.get_user_config_dir ();
        var startup_dir = Path.build_filename (config_dir, AUTOSTART_DIR);

        if (FileUtils.test (startup_dir, FileTest.EXISTS) == false) {
            var file = File.new_for_path (startup_dir);

            try {
                file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }

        return startup_dir;
    }

    public bool is_desktop_file (string name) {
        return !name.contains ("~") && name.has_suffix (".desktop");
    }

    private const string FALLBACK_ICON = "application-default-icon";

    public Gtk.Image create_icon (Entity.AppInfo app_info, Gtk.IconSize icon_size) {
        var icon = new ThemedIcon.with_default_fallbacks (app_info.icon);
        var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());

        int pixel_size;

        switch (icon_size) {
            case 48:
                pixel_size = 48;
                break;
            case 32:
                pixel_size = 32;
                break;
            default:
                pixel_size = 32;
                break;
        }

        var image = new Gtk.Image ();

        if (icon_theme.lookup_by_gicon (icon, pixel_size, 1, Gtk.TextDirection.NONE, Gtk.IconLookupFlags.PRELOAD) == null) {
            // PRELOAD is only used because USE_BUILTIN is dropped, will change later.
            try {
                var pixbuf = new Gdk.Pixbuf.from_file (app_info.icon)
                    .scale_simple (pixel_size, pixel_size, Gdk.InterpType.BILINEAR);
                image = new Gtk.Image.from_pixbuf (pixbuf);
            } catch (GLib.Error err) {
                icon = new ThemedIcon (FALLBACK_ICON);
                image = new Gtk.Image.from_gicon (icon) {
                    pixel_size = icon_size
                };
                debug (err.message);
            }
        } else {
            image = new Gtk.Image.from_gicon (icon) {
                pixel_size = icon_size
            };
        }

        image.pixel_size = pixel_size;

        return image;
    }
}
