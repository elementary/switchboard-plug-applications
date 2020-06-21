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
    public string user_installation_path { get; private set; }

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
            user_installation_path = installation.get_path ().get_path ();
            get_apps_for_installation (installation);
        } catch (Error e) {
            critical ("Unable to get flatpak user installation : %s", e.message);
        }

        try {
            var installation = new Flatpak.Installation.system ();
            get_apps_for_installation (installation);
        } catch (Error e) {
            critical ("Unable to get flatpak system installation : %s", e.message);
        }
    }

    private void get_apps_for_installation (Flatpak.Installation installation) {
        try {
            installation.list_installed_refs_by_kind (Flatpak.RefKind.APP).foreach ((installed_ref) => {
                unowned string id = installed_ref.get_name ();
                if (apps[id] == null) {
                    apps.insert (id, new Backend.App (installed_ref));
                }
            });
        } catch (Error e) {
            critical ("Unable to get installed flatpaks: %s", e.message);
        }
    }

    public static GenericArray<string> get_permissions_for_path (string path) {
        var array = new GenericArray<string> ();
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

                    array.add ("%s=%s".printf (key, value));
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
