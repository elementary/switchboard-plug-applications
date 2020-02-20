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

public class Permissions.Backend.FlatpakApplication : Permissions.Backend.Application {
    public FlatpakApplication (string id) {
        base (id);

        find_name ();
    }

    public string get_overrides_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            FlatpakManager.get_user_installation_path (),
            "overrides",
            id
        );
    }

    public string get_metadata_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            FlatpakManager.get_bundle_path_for_app (id),
            "metadata"
        );
    }

    public GenericArray<string> get_permissions () {
        return FlatpakManager.get_permissions_for_path (get_metadata_path ());
    }

    public GenericArray<string> get_overrides () {
        return FlatpakManager.get_permissions_for_path (get_overrides_path ());
    }

    public bool check_if_changed() {
        return GLib.File.new_for_path (get_overrides_path ()).query_exists ();
    }

    private void find_name () {
        var path = GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            FlatpakManager.get_bundle_path_for_app (id),
            "files",
            "share",
            "applications",
            id + ".desktop"
        );

        try {
            var key_file = new GLib.KeyFile();
            key_file.load_from_file (path, GLib.KeyFileFlags.NONE);

            name = key_file.get_string ("Desktop Entry", "Name");
        } catch (GLib.KeyFileError e) {
            GLib.error ("Error: %s\n", e.message);
        } catch (GLib.FileError e) {
            GLib.error ("Error: %s\n", e.message);
        }
    }
}
