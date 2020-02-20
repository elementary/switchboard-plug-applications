/*
* Copyright (c) 2011-2020 elementary LLC. (https://elementary.io)
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
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.FlatpakManager {
    public static string get_user_installation_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            GLib.Environment.get_home_dir (),
            ".local",
            "share",
            "flatpak"
        );
    }

    public static string get_user_application_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            get_user_installation_path (),
            "app"
        );
    }

    public static string get_bundle_path_for_app (string id) {
        var path = GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            get_user_application_path (),
            id,
            "current",
            "active"
        );

        var file = GLib.File.new_for_path (path);
        if (file.query_exists ()) {
            return path;
        }

        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            get_system_application_path (),
            id,
            "current",
            "active"
        );
    }

    public static string get_system_installation_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            "var",
            "lib",
            "flatpak"
        );
    }

    public static string get_system_application_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            get_system_installation_path (),
            "app"
        );
    }

    public static GenericArray<string> get_permissions_for_path (string path) {
        var array = new GenericArray<string> ();
        string GROUP = "Context";

        try {
            var key_file = new GLib.KeyFile();
            key_file.load_from_file (path, GLib.KeyFileFlags.NONE);

            if (!key_file.has_group (GROUP)) {
                return array;
            }

            var keys = key_file.get_keys (GROUP);

            foreach (var key in keys ) {
                var values = key_file.get_value (GROUP, key).split (";");
                foreach (var value in values) {
                    if (value.length == 0) {
                        break;
                    }

                    array.add ("%s=%s".printf (key, value));
                }
            }
        } catch (GLib.KeyFileError e) {
            GLib.error ("Error: %s\n", e.message);
        } catch (GLib.FileError e) {
            GLib.error ("Error: %s\n", e.message);
        }

        return array;
    }

    public static GenericArray<Application> get_applications_for_path (string path) {
        var array = new GenericArray<Application> ();

        var directory = GLib.File.new_for_path (path);
        if (!directory.query_exists ()) {
            return array;
        }

        try {
            var enumerator = directory.enumerate_children ("*", GLib.FileQueryInfoFlags.NONE, null);
            var info = enumerator.next_file (null);

            while (info != null) {
                var file = enumerator.get_child (info);
                var app_id = GLib.Path.get_basename (file.get_path ());
                var active_path = GLib.Path.build_path (
                    GLib.Path.DIR_SEPARATOR_S,
                    file.get_path (),
                    "current",
                    "active"
                );

                if (!app_id.has_suffix (".BaseApp") && GLib.File.new_for_path (active_path).query_exists ()) {
                    array.add (new FlatpakApplication (app_id));
                }

                info = enumerator.next_file (null);
            }
        } catch (GLib.Error e) {
            GLib.error ("Error: %s\n", e.message);
        }

        return array;
    }

    public static GenericArray<Application> get_applications () {
        var array = get_applications_for_path (get_user_application_path ());

        get_applications_for_path (get_system_application_path ()).foreach ((app) => {
            if (!array.find (app)) {
                array.add (app);
            }
        });

        array.sort (strcmp);

        return array;
    }
}

