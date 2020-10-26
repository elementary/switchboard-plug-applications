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

public class Permissions.Backend.App : GLib.Object {
    public Flatpak.InstalledRef installed_ref { get; construct; }
    public string id { get; private set; }
    public string name { get; private set; }
    public GenericArray<Backend.PermissionSettings> settings;

    private const string GROUP = "Context";

    public App (Flatpak.InstalledRef installed_ref) {
        Object (installed_ref: installed_ref);
    }

    construct {
        id = installed_ref.get_name ();
        name = installed_ref.get_appdata_name () ?? id;

        settings = new GenericArray<Backend.PermissionSettings> ();

        var permissions = new GenericArray<string> ();
        try {
            var metadata = installed_ref.load_metadata ();
            try {
                var key_file = new GLib.KeyFile ();
                key_file.load_from_bytes (metadata, GLib.KeyFileFlags.NONE);

                permissions = get_permissions_for_keyfile (key_file);
            } catch (GLib.KeyFileError e) {
                debug ("Couldn't create permissions keyfile: %s", e.message);
            } catch (GLib.FileError e) {
                debug ("Couldn't load permissions file: %s", e.message);
            }
        } catch (Error e) {
            critical ("Couldn't load metadata: %s", e.message);
        }

        var overrides = new GenericArray<string> ();
        try {
            var key_file = new GLib.KeyFile ();
            key_file.load_from_file (get_overrides_path (), GLib.KeyFileFlags.NONE);

            overrides = get_permissions_for_keyfile (key_file);
        } catch (GLib.KeyFileError e) {
            debug ("Couldn't create overrides keyfile: %s", e.message);
        } catch (GLib.FileError e) {
            debug ("Couldn't load overrides file: %s", e.message);
        }

        var current_permissions = new GenericArray<string> ();

        for (var i = 0; i < permissions.length; i++) {
            var permission = permissions.get (i);
            if (is_permission_overridden (overrides, permission)) {
                continue;
            }

            current_permissions.add (permission);
        }

        for (var i = 0; i < overrides.length; i++) {
            var permission = overrides.get (i);
            if (permission.contains ("=!")) {
                continue;
            }

            current_permissions.add (permission);
        }

        Plug.permission_names.foreach ((key) => {
            bool standard = false;
            bool enabled = false;

            for (var i = 0; i < permissions.length; i++) {
                var permission = permissions.get (i);
                if (key == permission) {
                    standard = true;
                    break;
                }
            }

            for (var i = 0; i < current_permissions.length; i++) {
                var permission = current_permissions.get (i);
                if (key == permission) {
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

    private string get_overrides_path () {
        var overrides_folder_path = GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            FlatpakManager.get_default ().user_installation_path,
            "overrides"
        );

        var overrides_folder = File.new_for_path (overrides_folder_path);
        if (!overrides_folder.query_exists ()) {
            try {
                overrides_folder.make_directory ();
            } catch (Error e) {
                critical ("Couldn't create overrides folder: %s", e.message);
            }
        }

        return GLib.Path.build_path (
            GLib.Path.DIR_SEPARATOR_S,
            overrides_folder_path,
            id
        );
    }

    private string negate_permission (string permission) {
        var new_permission = permission;

        if (new_permission.contains ("=!")) {
            new_permission = new_permission.replace ("=!", "=");
            return new_permission;
        }

        new_permission = new_permission.replace ("=", "=!");
        return new_permission;
    }

    private bool is_permission_overridden (GenericArray<string> overrides, string permission) {
        var negated_permission = negate_permission (permission);

        for (var i = 0; i < overrides.length; i++) {
            var o = overrides.get (i);
            if (o == negated_permission) {
                return true;
            }
        }

        return false;
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
        try {
            var key_file = new GLib.KeyFile ();

            for (var i = 0; i < settings.length; i++) {
                var setting = settings.get (i);
                if (setting.enabled != setting.standard) {
                    var key_value_pair = setting.context.split ("=");
                    var key = key_value_pair[0];

                    var value = key_value_pair[1];
                    if (!setting.enabled) {
                        value = "!%s".printf (value);
                    }

                    if (key_file.has_group (GROUP)) {
                        try {
                            value = "%s;%s".printf (key_file.get_value (GROUP, key), value);
                        } catch (GLib.KeyFileError e) {
                            debug (e.message);
                        }
                    }

                    key_file.set_value (GROUP, key, value);
                }
            }

            key_file.save_to_file (get_overrides_path ());
        } catch (GLib.FileError e) {
            debug (e.message);
        }
    }

    private GenericArray<string> get_permissions_for_keyfile (GLib.KeyFile key_file) {
        var permissions = new GenericArray<string> ();

        if (!key_file.has_group (GROUP)) {
            return permissions;
        }

        try {
            var keys = key_file.get_keys (GROUP);

            foreach (unowned string key in keys) {
                var values = key_file.get_string_list (GROUP, key);
                foreach (unowned string value in values) {
                    if (value.length == 0) {
                        break;
                    }

                    permissions.add ("%s=%s".printf (key, value));
                }
            }
        } catch (Error e) {
            critical (e.message);
        }

        return permissions;
    }
}
