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
    const string FALLBACK_ICON = "application-default-icon";

    const string KEY_NAME = KeyFileDesktop.KEY_NAME;
    const string KEY_COMMAND = KeyFileDesktop.KEY_EXEC;
    const string KEY_COMMENT = KeyFileDesktop.KEY_COMMENT;
    const string KEY_ICON = KeyFileDesktop.KEY_ICON;
    const string KEY_ACTIVE = "X-GNOME-Autostart-enabled";
    const string KEY_TYPE = KeyFileDesktop.KEY_TYPE;
    const string KEY_NO_DISPLAY = KeyFileDesktop.KEY_NO_DISPLAY;
    const string KEY_HIDDEN = KeyFileDesktop.KEY_HIDDEN;
    const string KEY_NOT_SHOW_IN = KeyFileDesktop.KEY_NOT_SHOW_IN;
    const string KEY_ONLY_SHOW_IN = KeyFileDesktop.KEY_ONLY_SHOW_IN;

    public string name {
        owned get { return keyfile_get_locale_string (KEY_NAME); }
    }

    public string command {
        owned get { return keyfile_get_string (KEY_COMMAND); }
    }

    public string comment {
        owned get { return keyfile_get_locale_string (KEY_COMMENT); }
    }

    public string icon {
        owned get { return keyfile_get_string (KEY_ICON); }
    }

    public bool active {
        get { return get_bool_key (KEY_ACTIVE); }
        set {
            var as_string = value ? "true" : "false";
            keyfile.set_string (KeyFileDesktop.GROUP, KEY_ACTIVE, as_string);
        }
    }

    public bool show {
        get {
            if (get_bool_key (KEY_NO_DISPLAY) || get_bool_key (KEY_HIDDEN)) {
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
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KEY_NAME, preferred_language, ("Custom Command"));
        keyfile.set_locale_string (KeyFileDesktop.GROUP, KEY_COMMENT, preferred_language, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KEY_COMMAND, command);
        keyfile.set_string (KeyFileDesktop.GROUP, KEY_ICON, FALLBACK_ICON);
        this.active = true;

        keyfile.set_string (KeyFileDesktop.GROUP, KEY_TYPE, KeyFileDesktop.TYPE_APPLICATION);

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

    public void delete_file () {
        GLib.FileUtils.remove (path);
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

    private bool get_bool_key (string key) {
        var as_string = keyfile_get_string (key);
        return as_string == "true";
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
        var only_show_in = keyfile_get_string (KEY_ONLY_SHOW_IN).down ();
        var not_show_in = keyfile_get_string (KEY_NOT_SHOW_IN).down ();

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
