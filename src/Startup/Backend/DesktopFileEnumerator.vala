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

/**
 * This class lists all .desktop files in a given directory.
 */
class Startup.Backend.DesktopFileEnumerator : GLib.Object {

    string dir;

    public DesktopFileEnumerator (string dir) {
        this.dir = dir;
    }

    public string[] get_desktop_files () {
        try {
            return try_getting_desktop_files ();
        } catch (Error e) {
            warning (e.message);
        }

        return {};
    }
    
    string[] try_getting_desktop_files () throws Error {
        string[] result = {};

        if (!directory_exists ())
            return result;

        foreach (var name in enumerate_children ())
            if (Utils.is_desktop_file (name))
                result += create_path_from_name (name);

        return result;
    }

    bool directory_exists () throws Error {
        return FileUtils.test (dir, FileTest.EXISTS);
    }

    string[] enumerate_children () throws Error {
        string[] result = {};
        FileInfo file_info;
        var enumerator = File.new_for_path (dir).enumerate_children (FileAttribute.STANDARD_NAME, 0);
        while ((file_info = enumerator.next_file ()) != null)
            result += file_info.get_name ();
        return result;
    }

    string create_path_from_name (string name) {
        return GLib.Path.build_filename (dir, name);
    }
}