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

public interface Startup.Port.Monitor : Object {

    public signal void file_created (string path);
    public signal void file_deleted (string path);
    public signal void file_edited (string path);
}

public class Startup.Backend.Monitor : Object, Port.Monitor {

    FileMonitor monitor;

    public Monitor () {
        setup ();
    }

    void setup () {
        var startup_dir = Utils.get_user_startup_dir ();
        var file = File.new_for_path (startup_dir);
        try {
            monitor = file.monitor (FileMonitorFlags.NONE);
            monitor.changed.connect (on_change_occurred);
        } catch (Error e) {
            warning (@"Failed monitoring startup directory $startup_dir");
            warning (e.message);
        }
    }

    void on_change_occurred (File file, File? dest, FileMonitorEvent event) {
        var path = file.get_path ();

        if (Utils.is_desktop_file (path) == false) {
            return;
        }

        switch (event) {
            case FileMonitorEvent.CREATED:
                file_created (path);
                break;
            case FileMonitorEvent.DELETED:
                file_deleted (path);
                break;
            case FileMonitorEvent.CHANGED:
                file_edited (path);
                break;
        }
    }
}
