/***
    Copyright (C) 2013 Julien Spautz <spautz.julien@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/
using Startup;
namespace Startup.Utils {

    const string AUTOSTART_DIR = "autostart";


    string[] get_application_files () {
        var app_dir = Utils.get_application_dir ();
        var enumerator = new Backend.DesktopFileEnumerator (app_dir);
        return enumerator.get_desktop_files ();
    }

    string[] get_auto_start_files () {
        var startup_dir = Utils.get_user_startup_dir ();
        var enumerator = new Backend.DesktopFileEnumerator (startup_dir);
        return enumerator.get_desktop_files ();
    }
    
    string get_application_dir () {
        var app_dir = "/usr/share/applications/";
        
        if (FileUtils.test (app_dir, FileTest.EXISTS))
            return app_dir;
            
        warning (@"Application directory '$app_dir' does not exist");
        return "";
    }

    string get_user_startup_dir () {
        var config_dir = Environment.get_user_config_dir ();
        var startup_dir = Path.build_filename (config_dir, AUTOSTART_DIR);

        if (FileUtils.test (startup_dir, FileTest.EXISTS) == false) {
            var file = File.new_for_path (startup_dir);
            
            try { file.make_directory_with_parents (); }
            catch (Error e) { warning (e.message); }
        }

        return startup_dir;
    }
    
    bool is_desktop_file (string name) {
        return !name.contains ("~") && name.has_suffix (".desktop");
    }
    
    const int ICON_SIZE = 48;
    const string FALLBACK_ICON = "application-default-icon";

    string create_markup (Entity.AppInfo app_info) {
        var escaped_name = Markup.escape_text (app_info.name);
        var escaped_comment = Markup.escape_text (app_info.comment);

        return @"<span font_weight=\"bold\" size=\"large\">$escaped_name</span>\n$escaped_comment";
    }

    Gdk.Pixbuf create_icon (Entity.AppInfo app_info, int size = ICON_SIZE) {
        var icon_theme = Gtk.IconTheme.get_default ();
        var lookup_flags = Gtk.IconLookupFlags.GENERIC_FALLBACK;

        try {
            if (icon_theme.has_icon (app_info.icon))
                return icon_theme.load_icon (app_info.icon, size, lookup_flags);
            else
                return icon_theme.load_icon (FALLBACK_ICON, size, lookup_flags);
        } catch (Error e) {
            warning (e.message);
        }

        return (Gdk.Pixbuf) null;
    }
}