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
    public string id { get; construct; }
    public string name { get; private set; }
    public GenericArray<Backend.PermissionSettings> settings;

    public App (string id) {
        Object (id: id);
    }

    construct {
        find_name ();

        settings = new GenericArray<Backend.PermissionSettings> ();
        var permissions = get_permissions ();
        var current_permissions = get_current_permissions ();
        Backend.PermissionManager.get_default ().keys ().foreach ((key) => {
            bool standard = false;
            bool enabled = false;

            for (var i = 0; i < permissions.length; i++) {
                var permission = permissions.get (i);
                if (key == permission.context) {
                    standard = true;
                    break;
                }
            }

            for (var i = 0; i < current_permissions.length; i++) {
                var permission = current_permissions.get (i);
                if (key == permission.context) {
                    enabled = true;
                    break;
                }
            }

            var s = new Backend.PermissionSettings (key, standard);
            s.enabled = enabled;

            settings.add (s);
        });

        notify["settings"].connect (save_overrides);

        save_overrides ();
    }

    public string get_overrides_path () {
        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            AppManager.get_user_installation_path (),
            "overrides",
            id
        );
    }

    private GenericArray<Backend.Permission> get_permissions () {
        var metadata_path = GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            AppManager.get_bundle_path_for_app (id),
            "metadata"
        );

        return AppManager.get_permissions_for_path (metadata_path);
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
            var key_file = new GLib.KeyFile ();
            key_file.load_from_file (path, GLib.KeyFileFlags.NONE);

            name = key_file.get_string ("Desktop Entry", "Name");
        } catch (GLib.KeyFileError e) {
            GLib.error (e.message);
        } catch (GLib.FileError e) {
            GLib.error (e.message);
        }
    }

    private Backend.Permission negate_permission (Backend.Permission permission) {
        var new_permission = new Backend.Permission (permission.context);

        if (new_permission.context.contains ("=!")) {
            new_permission.context = new_permission.context.replace ("=!", "=");
            return new_permission;
        }

        new_permission.context = new_permission.context.replace ("=", "=!");
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
        var overrides = AppManager.get_permissions_for_path (get_overrides_path ());
        var current = new GenericArray<Backend.Permission> ();

        for (var i = 0; i < permissions.length; i++) {
            var permission = permissions.get (i);
            if (is_permission_overridden (overrides, permission)) {
                continue;
            }

            current.add (permission);
        }

        for (var i = 0; i < overrides.length; i++) {
            var permission = overrides.get (i);
            if (permission.context.contains ("=!")) {
                continue;
            }

            current.add (permission);
        }

        return current;
    }

    public void reset_settings_to_standard () {
        for (var i = 0; i < settings.length; i++) {
            var setting = settings.get (i);
            setting.enabled = setting.standard;
        }

        var file = GLib.File.new_for_path (get_overrides_path ());
        try {
            file.delete ();
        } catch (GLib.Error e) {
            GLib.warning (e.message);
        }
    }

    public void save_overrides () {
        const string GROUP = "Context";

        try {
            var key_file = new GLib.KeyFile ();

            for (var i = 0; i < settings.length; i++) {
                var setting = settings.get (i);
                if (setting.enabled != setting.standard) {
                    var kv = setting.context.split ("=");
                    var key = kv[0];
                    var value = "%s%s".printf (!setting.enabled ? "!" : "", kv[1]);

                    try {
                        var _value = key_file.get_value (GROUP, key);
                        value = "%s;%s".printf (_value, value);
                    } catch (GLib.KeyFileError e) {
                        GLib.warning (e.message);
                    }

                    key_file.set_value (GROUP, key, value);
                }
            }

            key_file.save_to_file (get_overrides_path ());
        } catch (GLib.FileError e) {
            GLib.warning (e.message);
        }
    }
}
