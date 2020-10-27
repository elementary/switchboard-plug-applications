/*
* Copyright 2013-2017 elementary, Inc. (https://elementary.io)
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

    public string name {
        owned get { return keyfile_get_locale_string (KeyFileDesktop.KEY_NAME); }
    }

    public string command {
        owned get { return keyfile_get_string (KeyFileDesktop.KEY_EXEC); }
    }

    public string comment {
        owned get { return keyfile_get_locale_string (KeyFileDesktop.KEY_COMMENT); }
    }

    public string icon {
        owned get { return keyfile_get_string (KeyFileDesktop.KEY_ICON); }
    }

    public bool active {
        get {
            return keyfile_get_string (KEY_ACTIVE) == "true";
        }
        set {
            var as_string = value ? "true" : "false";
            keyfile.set_string (KeyFileDesktop.GROUP, KEY_ACTIVE, as_string);
        }
    }

    public bool show {
        get {
            if (keyfile_get_string (KeyFileDesktop.KEY_NO_DISPLAY) == "true" || keyfile_get_string (KeyFileDesktop.KEY_HIDDEN) == "true") {
                return false;
            }

            return show_in_environment ();
        }
    }

    public string path { get; set; }

    private GLib.KeyFile keyfile;
    static string[] languages;
    static string preferred_language;

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

        this.path = create_path_for_custom_command ();
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language, _("Custom Command"));
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON, FALLBACK_ICON);
        this.active = true;

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TYPE, KeyFileDesktop.TYPE_APPLICATION);

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

        message ("-- Saving to %s --", path);
        message ("Name:    %s", name);
        message ("Comment: %s", comment);
        message ("Command: %s", command);
        message ("Icon:    %s", icon);
        message ("Active:  %s", active.to_string ());
        message ("-- Done --");
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
            } catch (KeyFileError e) { }
        }

        return "";
    }

    private bool show_in_environment () {
        var only_show_in = keyfile_get_string (KeyFileDesktop.KEY_ONLY_SHOW_IN).down ();
        var not_show_in = keyfile_get_string (KeyFileDesktop.KEY_NOT_SHOW_IN).down ();

        var session = Environment.get_variable ("DESKTOP_SESSION").down ();

        if (session in not_show_in) {
            return false;
        }

        if (only_show_in == "" || session in only_show_in) {
            return true;
        }

        return false;
    }

    public void copy_to_local () requires (path != null) {
        var basename = Path.get_basename (path);
        var startup_dir = Utils.get_user_startup_dir ();
        path = Path.build_filename (startup_dir, basename);
        write_to_file ();
    }

    public Entity.AppInfo create_app_info () {
        return Entity.AppInfo () {
            name = name,
            comment = comment,
            icon = icon,
            active = active,
            path = path
        };
    }
}
