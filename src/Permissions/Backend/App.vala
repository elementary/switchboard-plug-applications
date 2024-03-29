/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*           2020 Martin Abente Lahaye
*           2021 Justin Haygood (jhaygood86@gmail.com)
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
    public Icon icon { get; private set; }
    public GenericArray<Backend.PermissionSettings> settings;

    public static GLib.HashTable <unowned string, unowned string> permission_names { get; private set; }

    private const string GROUP = "Context";

    public App (Flatpak.InstalledRef installed_ref) {
        Object (installed_ref: installed_ref);
    }

    static construct {
        permission_names = new GLib.HashTable <unowned string, unowned string> (str_hash, str_equal);
        permission_names["filesystems=home"] = _("Home Folder");
        permission_names["filesystems=host"] = _("System Folders");
        permission_names["devices=all"] = _("Devices");
        permission_names["shared=network"] = _("Network");
        permission_names["features=bluetooth"] = _("Bluetooth");
        permission_names["sockets=cups"] = _("Printing");
        permission_names["sockets=ssh-auth"] = _("Secure Shell Agent");
        permission_names["devices=dri"] = _("GPU Acceleration");
    }

    construct {
        id = installed_ref.get_name ();

        var appinfo = new GLib.DesktopAppInfo (id + ".desktop");
        if (appinfo != null) {
            name = appinfo.get_name ();
            icon = appinfo.get_icon () ?? new ThemedIcon ("application-default-icon");
        } else {
            icon = new ThemedIcon ("application-default-icon");
            name = id;
        }

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

        permission_names.foreach ((key) => {
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

            var s = new Backend.PermissionSettings (key, standard) {
                enabled = enabled
            };

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

    private bool is_permission_overridden (GenericArray<string> overrides, string permission) {
        var negated_permission = permission.contains ("=!") ?
                                 permission.replace ("=!", "=") :
                                 permission.replace ("=", "=!");

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

        var overrides_path = get_overrides_path ();

        var key_file = new GLib.KeyFile ();

        try {
            key_file.load_from_file (overrides_path, GLib.KeyFileFlags.NONE);
        } catch (GLib.KeyFileError e) {
            debug ("Couldn't create overrides keyfile: %s", e.message);
        } catch (GLib.FileError e) {
            debug ("Couldn't load overrides file: %s", e.message);
        }

        try {
            for (var i = 0; i < settings.length; i++) {
                var setting = settings.get (i);

                var key_value_pair = setting.context.split ("=");
                var key = key_value_pair[0];

                if (key_file.has_group (GROUP) && key_file.has_key (GROUP, key)) {
                    key_file.remove_key (GROUP, key);
                }
            }

            key_file.save_to_file (overrides_path);
        } catch (GLib.KeyFileError e) {
            debug ("Couldn't remove key from overrides keyfile: %s", e.message);
        } catch (GLib.FileError e) {
            debug (e.message);
        }
    }

    public void save_overrides () {
        try {
            var overrides_path = get_overrides_path ();

            var key_file = new GLib.KeyFile ();

            try {
                key_file.load_from_file (overrides_path, GLib.KeyFileFlags.NONE);
            } catch (GLib.KeyFileError e) {
                debug ("Couldn't create overrides keyfile: %s", e.message);
            } catch (GLib.FileError e) {
                debug ("Couldn't load overrides file: %s", e.message);
            }

            for (var i = 0; i < settings.length; i++) {
                var setting = settings.get (i);

                var key_value_pair = setting.context.split ("=");
                var key = key_value_pair[0];

                var value = key_value_pair[1];

                if (key_file.has_group (GROUP) && key_file.has_key (GROUP, key)) {
                    try {
                        var existing_value = key_file.get_value (GROUP, key);

                        var existing_values = existing_value.split (";");
                        var values_list = new Gee.HashSet<string> ();

                        foreach (var existing_value_entry in existing_values) {
                            if (existing_value_entry.length > 0) {
                                values_list.add (existing_value_entry);
                            }
                        }

                        if (values_list.contains (value) && setting.enabled == setting.standard) {
                            values_list.remove (value);
                        } else if (!values_list.contains (value) && setting.enabled != setting.standard) {
                            values_list.add (value);
                        }

                        var new_values = values_list.to_array ();
                        var new_value = string.joinv (";", new_values);

                        if (new_value.length > 0) {
                            key_file.set_value (GROUP, key, new_value);
                        } else {
                            key_file.remove_key (GROUP, key);

                            if (key_file.get_keys (GROUP).length == 0) {
                                key_file.remove_group (GROUP);
                            }
                        }
                    } catch (GLib.KeyFileError e) {
                        debug (e.message);
                    }
                } else {
                    if (setting.enabled != setting.standard) {
                        key_file.set_value (GROUP, key, value);
                    }
                }
            }

            key_file.save_to_file (overrides_path);
        } catch (GLib.KeyFileError e) {
            debug ("Couldn't save overrides keyfile: %s", e.message);
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
