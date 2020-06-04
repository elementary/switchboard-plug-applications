/*
 * Copyright 2020 elementary, Inc (https://elementary.io)
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
 * Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
 * Boston, MA 02110-1301, USA.
 * 
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Permissions.Backend.PermissionManager {
    private static PermissionManager? instance;
    private GenericArray<string> _keys;
    private GenericArray<PermissionDescription> _values;

    public static PermissionManager get_default () {
        if (instance == null) {
            instance = new PermissionManager ();
        }

        return instance;
    }

    private PermissionManager () {
        _keys = new GenericArray<string> ();
        _values = new GenericArray<PermissionDescription> ();


        insert ("filesystems=home", new PermissionDescription (
            _("Home Folder"),
            _("Access your entire home folder"),
            "user-home"
        ));

        insert ("filesystems=host", new PermissionDescription (
            _("System Folders"),
            _("Access system folders, not including the operating system or system internals"),
            "drive-harddisk"
        ));

        insert ("devices=all", new PermissionDescription (
            _("Devices"),
            _("Access devices like webcams and microphones"),
            "accessories-camera"
        ));

        insert ("sockets=pulseaudio", new PermissionDescription (
            _("Sounds"),
            _("Play sounds"),
            "preferences-desktop-sound"
        ));

        insert ("shared=network", new PermissionDescription (
            _("Network"),
            _("Access the Internet and local networks"),
            "preferences-system-network"
        ));

        insert ("features=bluetooth", new PermissionDescription (
            _("Bluetooth"),
            _("Access devices via Bluetooth"),
            "bluetooth"
        ));

        insert ("sockets=cups", new PermissionDescription (
            _("Print"),
            _("Access printers"),
            "printer"
        ));

        insert ("sockets=ssh-auth", new PermissionDescription (
            _("Secure Shell Agent"),
            _("Access other devices on the network via SSH"),
            "utilities-terminal"
        ));

        insert ("devices=dri", new PermissionDescription (
            _("GPU Acceleration"),
            _("Accelerate graphical output"),
            "application-x-firmware"
        ));
    }

    private void insert (string key, PermissionDescription value) {
        _keys.add (key);
        _values.add (value);
    }

    public GenericArray<string> keys () {
        return _keys;
    }

    public PermissionDescription? get (string key) {
        for (var i = 0; i < _keys.length; i++) {
            if (_keys.get (i) == key) {
                return _values.get (i);
            }
        }

        return null;
    }
}
