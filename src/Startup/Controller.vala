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

    public Startup.Widgets.Scrolled view { get; construct; }
    public Port.Monitor monitor { get; construct; }

    public Controller (Startup.Widgets.Scrolled view, Port.Monitor monitor) {
        Object (view: view, monitor: monitor);
    }

    construct {
        foreach (var path in Utils.get_auto_start_files ()) {
            var key_file = get_key_file_from_path (path);
            if (key_file.show) {
                view.add_app (key_file.create_app_info ());
            }
        }

        var app_infos = new Gee.ArrayList <Entity.AppInfo?> ();
        foreach (var path in Utils.get_application_files ()) {
            var key_file = get_key_file_from_path (path);
            if (key_file.show) {
                app_infos.add (key_file.create_app_info ());
            }
        }

        view.init_app_chooser (app_infos);

        monitor.file_created.connect (add_app_to_view);
        monitor.file_deleted.connect (remove_app_from_view);
        monitor.file_edited.connect (edit_app_in_view);

        view.app_added.connect (create_file);
        view.app_added_from_command.connect (create_file_from_command);
        view.app_removed.connect (delete_file);
        view.app_active_changed.connect (edit_file);
    }

    void add_app_to_view (string path) {
        var key_file = get_key_file_from_path (path);
        var app_info = key_file.create_app_info ();
        view.add_app (app_info);
    }

    void remove_app_from_view (string path) {
        view.remove_app_from_path (path);
    }

    void edit_app_in_view (string path) {
        view.reload_app_from_path (path);
    }

    void delete_file (string path) {
        var key_file = get_key_file_from_path (path);
        key_file.delete_file ();
    }

    void edit_file (string path, bool active) {
        var key_file = get_key_file_from_path (path);
        key_file.active = active;
        key_file.write_to_file ();
    }

    void create_file (string path) {
        var key_file = get_key_file_from_path (path);
        key_file.active = true;
        key_file.copy_to_local ();
        var app_info = key_file.create_app_info ();
        view.add_app (app_info);
    }

    void create_file_from_command (string command) {
        var key_file = new Backend.KeyFile.from_command (command);
        var app_info = key_file.create_app_info ();
        view.add_app (app_info);
    }

    static Backend.KeyFile get_key_file_from_path (string path) {
        return Backend.KeyFileFactory.get_or_create (path);
    }
}
