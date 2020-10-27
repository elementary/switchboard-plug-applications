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

public class Startup.Controller : Object {
    public Startup.Plug view { get; construct; }

    private const string APPLICATION_DIRS = "applications";

    public Controller (Startup.Plug view) {
        Object (view: view);
    }

    construct {
        foreach (unowned string path in get_auto_start_files ()) {
            var key_file = Backend.KeyFileFactory.get_or_create (path);
            if (key_file.show) {
                view.add_app (key_file);
            }
        }

        var app_infos = new Gee.ArrayList <Entity.AppInfo?> ();
        foreach (unowned string path in get_application_files ()) {
            var key_file = Backend.KeyFileFactory.get_or_create (path);
            if (key_file.show) {
                app_infos.add (key_file.create_app_info ());
            }
        }

        view.init_app_chooser (app_infos);
    }

    private string[] get_application_files () {
        string[] app_dirs = {};

        var data_dirs = Environment.get_system_data_dirs ();
        data_dirs += Environment.get_user_data_dir ();
        foreach (unowned string data_dir in data_dirs) {
            var app_dir = Path.build_filename (data_dir, APPLICATION_DIRS);
            if (FileUtils.test (app_dir, FileTest.EXISTS)) {
                app_dirs += app_dir;
            }
        }

        if (app_dirs.length == 0) {
            warning ("No application directories found");
        }

        var enumerator = new Backend.DesktopFileEnumerator (app_dirs);
        return enumerator.get_desktop_files ();
    }

    private string[] get_auto_start_files () {
        var startup_dir = Utils.get_user_startup_dir ();
        var enumerator = new Backend.DesktopFileEnumerator ({ startup_dir });
        return enumerator.get_desktop_files ();
    }
}
