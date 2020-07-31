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

    public const string FALLBACK_ICON = "application-default-icon";
    public const string FALLBACK_CUSTOM_NAME = N_("Custom Command");

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
    const string KEY_CUSTOM = "Custom-command";

    public string name {
        owned get { return get_key (KEY_NAME); }
        set { set_key (KEY_NAME, value); }
    }

    public string command {
        owned get { return get_key (KEY_COMMAND); }
        set { set_key (KEY_COMMAND, value); }
    }

    public string comment {
        owned get { return get_key (KEY_COMMENT); }
        set { set_key (KEY_COMMENT, value); }
    }

    public string icon {
        owned get { return get_key (KEY_ICON); }
        set { set_key (KEY_ICON, value); }
    }

    public bool active {
        get { return get_bool_key (KEY_ACTIVE); }
        set { set_bool_key (KEY_ACTIVE, value); }
    }

    public bool is_custom {
        get { return get_bool_key (KEY_CUSTOM); }
        set { set_bool_key (KEY_CUSTOM, value); }
    }

    public bool show {
        get {
            if (get_bool_key (KEY_NO_DISPLAY))
                return false;
            if (get_bool_key (KEY_HIDDEN))
                return false;
            return show_in_environment ();
        }
    }

    public string path { get; set; }

    GLib.KeyFile keyfile;
    static string[] languages;
    static string preferred_language;

    static construct {
        languages = Intl.get_language_names ();
        preferred_language = languages [0];
    }

    public KeyFile (string path) {
        Object (path: path);
        keyfile = new GLib.KeyFile ();
        load_from_file ();
    }

    public KeyFile.from_command (string command) {
        keyfile = new GLib.KeyFile ();

        this.path = create_path_for_custom_command ();
        this.name = _(FALLBACK_CUSTOM_NAME);
        this.comment = command;
        this.command = command;
        this.icon = FALLBACK_ICON;
        this.active = true;
        this.is_custom = true;

        set_key (KEY_TYPE, KeyFileDesktop.TYPE_APPLICATION);

        write_to_file ();
    }

    string create_path_for_custom_command () {
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

warning ("-- Saving to %s --", path);
        message ("-- Saving to %s --", path);
        message ("Name:    %s", name);
        message ("Comment: %s", comment);
        message ("Command: %s", command);
        message ("Icon:    %s", icon);
        message ("Active:  %s", active.to_string ());
        message ("Is Custom:  %s", is_custom.to_string ());
        message ("-- Done --");
    }

    void load_from_file () {
        try {
            keyfile.load_from_file (path, GLib.KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (Error e) {
            warning ("Failed to load contents of file '%s'", path);
            warning (e.message);
        }
    }

    void set_bool_key (string key, bool value) {
        var as_string = value ? "true" : "false";
        keyfile_set_string (key, as_string);
    }

    bool get_bool_key (string key) {
        var as_string = keyfile_get_string (key);
        return as_string == "true";
    }

    void set_key (string key, string value) {
        if (key_is_localized (key)) {
            keyfile_set_locale_string (key, value);
        } else {
            keyfile_set_string (key, value);
        }
    }

    string get_key (string key) {
        if (key_is_localized (key)) {
            return keyfile_get_locale_string (key);
        } else {
            return keyfile_get_string (key);
        }
    }

    bool key_is_localized (string key) {
        switch (key) {
            case KEY_NAME:
            case KEY_COMMENT:
                return true;

            case KEY_COMMAND:
            case KEY_ICON:
            case KEY_ACTIVE:
            case KEY_NO_DISPLAY:
            case KEY_TYPE:
            case KEY_ONLY_SHOW_IN:
            case KEY_NOT_SHOW_IN:
            case KEY_HIDDEN:
                return false;

            default:
                warn_if_reached ();
                return false;
        }
    }

    void keyfile_set_string (string key, string value) {
        keyfile.set_string (KeyFileDesktop.GROUP, key, value);
    }

    void keyfile_set_locale_string (string key, string value) {
        keyfile.set_locale_string (KeyFileDesktop.GROUP, key, preferred_language, value);
    }

    string keyfile_get_string (string key) {
        try {
            return keyfile.get_string (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) { }

        return "";
    }

    string keyfile_get_locale_string (string key) {
        foreach (string lang in languages) {
            try {
                return keyfile.get_locale_string (KeyFileDesktop.GROUP, key, lang);
            } catch (KeyFileError e) { }
        }

        return "";
    }

    bool show_in_environment () {
        var only_show_in = get_key (KEY_ONLY_SHOW_IN).down ();
        var not_show_in = get_key (KEY_NOT_SHOW_IN).down ();

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

    public string create_markup () {
        var escaped_name = Markup.escape_text (name);
        var escaped_comment = Markup.escape_text (comment);

        return @"<span font_weight=\"bold\" size=\"large\">$escaped_name</span>\n$escaped_comment";
    }

    public Entity.AppInfo create_app_info () {
        return Entity.AppInfo () {
            name = name,
            comment = comment,
            icon = icon,
            active = active,
            path = path,
            is_custom = is_custom,
            custom_exec = is_custom ? command : ""
        };
    }
}
