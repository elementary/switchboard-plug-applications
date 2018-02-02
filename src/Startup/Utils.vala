/*
* Copyright (c) 2013-2017 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
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
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

using Startup;
namespace Startup.Utils {

    const string AUTOSTART_DIR = "autostart";
    const string APPLICATION_DIRS = "applications";

    string[] get_application_files () {
        var app_dirs = Utils.get_application_dirs ();
        var enumerator = new Backend.DesktopFileEnumerator (app_dirs);
        return enumerator.get_desktop_files ();
    }

    string[] get_auto_start_files () {
        var startup_dir = Utils.get_user_startup_dir ();
        var enumerator = new Backend.DesktopFileEnumerator ({ startup_dir });
        return enumerator.get_desktop_files ();
    }

    string[] get_application_dirs () {
        string[] result = {};

        var data_dirs = Environment.get_system_data_dirs ();
        foreach (var data_dir in data_dirs) {
            var app_dir = Path.build_filename (data_dir, APPLICATION_DIRS);
            if (FileUtils.test (app_dir, FileTest.EXISTS))
                result += app_dir;
        }

        if (result.length == 0)
            warning ("No application directories found");
            
        return result;
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
    
    const string FALLBACK_ICON = "application-default-icon";

    string create_icon (Entity.AppInfo app_info) {
        var icon_theme = Gtk.IconTheme.get_default ();

        if (icon_theme.has_icon (app_info.icon)) {
            return app_info.icon;
        } else {
            return FALLBACK_ICON;
        }
    }
}
