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

public class Permissions.Backend.App : GLib.Object {
    public string id { get; construct set; }
    public string name { get; construct set; }

    public App (string id) {
        GLib.Object(
            id: id
        );

        find_name ();
    }

    public string get_overrides_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            AppManager.get_user_installation_path (),
            "overrides",
            id
        );
    }

    public string get_metadata_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            AppManager.get_bundle_path_for_app (id),
            "metadata"
        );
    }

    public GenericArray<Backend.Permission> get_permissions () {
        return AppManager.get_permissions_for_path (get_metadata_path ());
    }

    public GenericArray<Backend.Permission> get_overrides () {
        return AppManager.get_permissions_for_path (get_overrides_path ());
    }

    public bool check_if_changed() {
        return GLib.File.new_for_path (get_overrides_path ()).query_exists ();
    }

    private void find_name () {
        var path = GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            AppManager.get_bundle_path_for_app (id),
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

    private bool real_is_overridden_path (GenericArray<Backend.Permission> overrides, Backend.Permission permission) {
        if (!permission.context.has_prefix ("filesystems=")) {
            return false;
        }

        // TODO: implement logic for overriden path

        return false;
    }

    private bool is_overridden_path (GenericArray<Backend.Permission> overrides, Backend.Permission permission) {
        return real_is_overridden_path (overrides, permission) ||
               real_is_overridden_path (overrides, negate_permission (permission));
    }

    private bool is_negated_permission (Backend.Permission permission) {
        return permission.context.contains ("=!");
    }

    private Backend.Permission negate_permission (Backend.Permission permission) {
        var new_permission = new Backend.Permission (permission.context);

        if (is_negated_permission (new_permission)) {
            new_permission.context = new_permission.context.replace ("=!", "=");
            return new_permission;
        }

        new_permission.context = new_permission.context.replace("=", "=!");
        return new_permission;
    }

    private bool is_permission_overridden (GenericArray<Backend.Permission> overrides, Backend.Permission permission) {
        var negated_permission = negate_permission (permission);

        for (var i = 0; i < overrides.length; i++) {
            var o = overrides.get (i);
            if (o.context == negated_permission.context) {
                return true;
            }
        }

        return false;
    }

    public GenericArray<Backend.Permission> get_current_permissions () {
        var permissions = get_permissions ();
        var overrides = get_overrides ();
        var current = new GenericArray<Backend.Permission> ();

        for (var i = 0; i < permissions.length; i++) {
            var permission = permissions.get (i);
            if (is_permission_overridden (overrides, permission)) {
                continue;
            }

            if (is_overridden_path (overrides, permission)) {
                continue;
            }

            current.add (permission);
        }

        for (var i = 0; i < overrides.length; i++) {
            var permission = overrides.get (i);
            if (is_negated_permission (permission)) {
                continue;
            }

            current.add (permission);
        }

        return current;
    }
}
