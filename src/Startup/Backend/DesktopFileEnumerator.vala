/*
* Copyright 2013-2018 elementary, Inc. (https://elementary.io)
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
 * This class lists all .desktop files in a given directory.
 */
class Startup.Backend.DesktopFileEnumerator : GLib.Object {

    string[] dirs;

    public DesktopFileEnumerator (string[] dirs) {
        this.dirs = dirs;
    }

    public string[] get_desktop_files () {
        string[] result = {};

        foreach (var dir in dirs) {
            try {
                foreach (var name in enumerate_children (dir)) {
                    if (Utils.is_desktop_file (name)) {
                        result += Path.build_filename (dir, name);
                    }
                }
            } catch (Error e) {
                warning (@"Error inside $dir: $(e.message)");
            }
        }

        return result;
    }

    string[] enumerate_children (string dir) throws Error {
        string[] result = {};
        FileInfo file_info;
        var enumerator = File.new_for_path (dir).enumerate_children (FileAttribute.STANDARD_NAME, 0);
        while ((file_info = enumerator.next_file ()) != null)
            result += file_info.get_name ();
        return result;
    }

}
