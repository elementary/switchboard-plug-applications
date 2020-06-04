/*
 * Copyright 2011-2020 elementary, Inc (https://elementary.io)
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

        insert ("shared=network", new PermissionDescription (
            _("Network"),
            _("App may be able to access other devices on the network"),
            "preferences-system-network"
        ));
        insert ("shared=ipc", new PermissionDescription (
            _("Communication between apps"),
            _("App may be able to talk to, control and read information from other apps or system components"),
            "internet-chat"
        ));
        insert ("sockets=x11", new PermissionDescription (
            _("Graphical output"),
            _("App may be able to show graphical windows"),
            "video-display"
        ));
        //  insert ("sockets=fallback-x11", new PermissionDescription (
        //      _("Access X11 windowing system (as fallback)"),
        //      _("App is able to show graphical windows"),
        //      "video-display"
        //  ));
        //  insert ("sockets=wayland", new PermissionDescription (
        //      _("Access Wayland windowing system"),
        //      _("App is able to show graphical windows"),
        //      "video-display"
        //  ));
        insert ("sockets=pulseaudio", new PermissionDescription (
            _("Sounds"),
            _("App may be able to play sounds"),
            "preferences-desktop-sound"
        ));
        insert ("sockets=system-bus", new PermissionDescription (
            _("D-Bus system bus"),
            _("App may be able to talk to, control and read information from system components via D-Bus"),
            "internet-chat"
        ));
        insert ("sockets=session-bus", new PermissionDescription (
            _("D-Bus session bus"),
            _("App may be able to talk to, control and read information from other apps via D-Bus"),
            "internet-chat"
        ));
        insert ("sockets=ssh-auth", new PermissionDescription (
            _("Secure Shell agent"),
            _("App may be able to access other devices on the network via SSH"),
            "utilities-terminal"
        ));
        insert ("sockets=cups", new PermissionDescription (
            _("Print"),
            _("App may be able to access printers"),
            "printer-printing"
        ));
        insert ("devices=dri", new PermissionDescription (
            _("GPU acceleration"),
            _("App may be able to accelerate graphical output"),
            "applications-graphics"
        ));
        insert ("devices=all", new PermissionDescription (
            _("Devices"),
            _("App may be able to access devices like webcams"),
            "accessories-camera"
        ));
        insert ("filesystems=host", new PermissionDescription (
            _("System directories"),
            _("App may be able to access system directories"),
            "drive-harddisk"
        ));
        insert ("filesystems=home", new PermissionDescription (
            _("Home directory"),
            _("App may be able to access your home directory"),
            "user-home"
        ));
        insert ("features=bluetooth", new PermissionDescription (
            _("Bluetooth"),
            _("App may be able to access devices via Bluetooth"),
            "preferences-bluetooth"
        ));
        insert ("features=devel", new PermissionDescription (
            _("System calls"),
            _("App may be able to access other syscalls (e.g. ptrace)"),
            "system-run"
        ));
        insert ("features=multiarch", new PermissionDescription (
            _("Multiarch"),
            _("App may be able to access programs from other architectures"),
            "system-run"
        ));
        insert ("filesystems=custom", new PermissionDescription (
            _("Other directories"),
            _("App may be able to access custom directories"),
            "system-file-manager"
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
