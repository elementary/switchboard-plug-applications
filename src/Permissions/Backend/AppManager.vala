/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*           2020 Martin Abente Lahaye
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

public class Permissions.Backend.AppManager : GLib.Object {
    public string selected_app { get; set; }
    public HashTable<string, Backend.App> apps { get; private set; }

    private static AppManager? instance;
    public static AppManager get_default () {
        if (instance == null) {
            instance = new AppManager ();
        }

        return instance;
    }

    construct {
        apps = new HashTable<string, Backend.App> (str_hash, str_equal);

        try {
            var installation = new Flatpak.Installation.user ();
            get_app_for_installation (installation);
        } catch (Error e) {
            critical ("Unable to get flatpak user installation : %s", e.message);
        }

        try {
            var installation = new Flatpak.Installation.system ();
            get_app_for_installation (installation);
        } catch (Error e) {
            critical ("Unable to get flatpak system installation : %s", e.message);
        }
    }

    private void get_app_for_installation (Flatpak.Installation installation) {
        try {
            installation.list_installed_refs_by_kind (Flatpak.RefKind.APP).foreach ((installed_ref) => {
                var id = installed_ref.get_name ();
                if (apps[id] == null) {
                    apps.insert (id, new Backend.App (id));
                }
            });
        } catch (Error e) {
            critical ("Unable to get installed flatpaks: %s", e.message);
        }
    }

    public static string get_user_installation_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            GLib.Environment.get_home_dir (),
            ".local",
            "share",
            "flatpak"
        );
    }

    private static string get_user_application_path () {
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

    private static string get_system_application_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            "var",
            "lib",
            "flatpak",
            "app"
        );
    }

    public static GenericArray<Backend.Permission> get_permissions_for_path (string path) {
        var array = new GenericArray<Backend.Permission> ();
        const string GROUP = "Context";

        try {
            var key_file = new GLib.KeyFile ();
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

                    array.add (new Backend.Permission ("%s=%s".printf (key, value)));
                }
            }
        } catch (GLib.KeyFileError e) {
            GLib.warning (e.message);
        } catch (GLib.FileError e) {
            GLib.warning (path);
            GLib.warning (e.message);
        }

        return array;
    }
}
