/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.Backend.PermissionManager {
    private static PermissionManager? instance;
    private GenericArray<string> _keys;
    private GenericArray<string> _values;

    public static PermissionManager get_default () {
        if (instance == null) {
            instance = new PermissionManager ();
        }

        return instance;
    }

    private PermissionManager () {
        _keys = new GenericArray<string> ();
        _values = new GenericArray<string> ();

        insert ("filesystems=home", _("Home Folder"));
        insert ("filesystems=host", _("System Folders"));
        insert ("devices=all", _("Devices"));
        insert ("shared=network", _("Network"));
        insert ("features=bluetooth", _("Bluetooth"));
        insert ("sockets=cups", _("Printing"));
        insert ("sockets=ssh-auth", _("Secure Shell Agent"));
        insert ("devices=dri", _("GPU Acceleration"));
    }

    private void insert (string key, string value) {
        _keys.add (key);
        _values.add (value);
    }

    public GenericArray<string> keys () {
        return _keys;
    }

    public string? get (string key) {
        for (var i = 0; i < _keys.length; i++) {
            if (_keys.get (i) == key) {
                return _values.get (i);
            }
        }

        return null;
    }
}
