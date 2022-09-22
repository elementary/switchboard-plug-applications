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

    public Gtk.Image create_icon (Entity.AppInfo app_info) {
        var image = new Gtk.Image () {
            pixel_size = 32
        };

        var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        if (icon_theme.has_icon (app_info.icon)) {
            image.gicon = new ThemedIcon (app_info.icon);
        } else {
            image.gicon = new ThemedIcon ("application-default-icon");
        }

        return image;
    }
}
