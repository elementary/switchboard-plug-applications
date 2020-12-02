/*
* Copyright 2013-2020 elementary, Inc. (https://elementary.io)
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

/**
 * Stores information about an app found in it's .desktop file
 * and allows us to modify it.
 * http://standards.freedesktop.org/desktop-entry-spec/latest/index.html
 */
public class Startup.Backend.KeyFile : GLib.Object {
    private const string FALLBACK_ICON = "application-default-icon";
    private const string KEY_ACTIVE = "X-GNOME-Autostart-enabled";

    public bool active {
        get {
            return keyfile_get_bool (KEY_ACTIVE);
        }
        set {
            keyfile.set_boolean (KeyFileDesktop.GROUP, KEY_ACTIVE, value);
        }
    }

    public bool show {
        get {
            if (keyfile_get_bool (KeyFileDesktop.KEY_NO_DISPLAY) || keyfile_get_bool (KeyFileDesktop.KEY_HIDDEN)) {
                return false;
            }

            var session = Environment.get_variable ("DESKTOP_SESSION").down ();
            var not_show_in = keyfile_get_string (KeyFileDesktop.KEY_NOT_SHOW_IN).down ();
            if (session in not_show_in) {
                return false;
            }

            var only_show_in = keyfile_get_string (KeyFileDesktop.KEY_ONLY_SHOW_IN).down ();
            if (only_show_in == "" || session in only_show_in) {
                return true;
            }

            return false;
        }
    }

    public string path { get; set; }

    private GLib.KeyFile keyfile;
    private static string[] languages;
    private static string preferred_language;

    static construct {
        languages = Intl.get_language_names ();
        preferred_language = languages [0];
    }

    public KeyFile (string path) {
        Object (path: path);
        keyfile = new GLib.KeyFile ();

        try {
            keyfile.load_from_file (path, GLib.KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (Error e) {
            warning ("Failed to load contents of file '%s'", path);
            warning (e.message);
        }
    }

    public KeyFile.from_command (string command) {
        keyfile = new GLib.KeyFile ();
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language, _("Custom Command"));
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON, FALLBACK_ICON);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TYPE, KeyFileDesktop.TYPE_APPLICATION);

        active = true;
        path = create_path_for_custom_command ();

        write_to_file ();
    }

    private string create_path_for_custom_command () {
        var startup_dir = Utils.get_user_startup_dir ();

        for (int i = 0; i < 100; i++) {
            var filename = Path.build_filename (startup_dir, @"custom-command$i.desktop");
            if (FileUtils.test (filename, FileTest.EXISTS) == false) {
                return filename;
            }

        }

        return "";
    }

    public void write_to_file () {
        try {
            GLib.FileUtils.set_contents (path, keyfile.to_data ());
        } catch (Error e) {
            warning ("Could not write to file %s", path);
            warning (e.message);
        }

        debug ("-- Saving to %s --", path);
        debug ("Name:    %s", keyfile_get_locale_string (KeyFileDesktop.KEY_NAME));
        debug ("Comment: %s", keyfile_get_locale_string (KeyFileDesktop.KEY_COMMENT));
        debug ("Command: %s", keyfile_get_string (KeyFileDesktop.KEY_EXEC));
        debug ("Icon:    %s", keyfile_get_string (KeyFileDesktop.KEY_ICON));
        debug ("Active:  %s", active.to_string ());
        debug ("-- Done --");
    }

    private bool keyfile_get_bool (string key) {
        try {
            return keyfile.get_boolean (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            critical (e.message);
        }

        return false;
    }

    private string keyfile_get_string (string key) {
        try {
            return keyfile.get_string (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            critical (e.message);
        }

        return "";
    }

    private string keyfile_get_locale_string (string key) {
        foreach (string lang in languages) {
            try {
                return keyfile.get_locale_string (KeyFileDesktop.GROUP, key, lang);
            } catch (KeyFileError e) {
                critical (e.message);
            }
        }

        return "";
    }

    public void copy_to_local () requires (path != null) {
        var basename = Path.get_basename (path);
        var startup_dir = Utils.get_user_startup_dir ();
        path = Path.build_filename (startup_dir, basename);
        write_to_file ();
    }

    public Entity.AppInfo create_app_info () {
        return Entity.AppInfo () {
            name = keyfile_get_locale_string (KeyFileDesktop.KEY_NAME),
            comment = keyfile_get_locale_string (KeyFileDesktop.KEY_COMMENT),
            icon = keyfile_get_locale_string (KeyFileDesktop.KEY_ICON),
            active = active,
            path = path
        };
    }
}
