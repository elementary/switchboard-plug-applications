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
    public GLib.HashTable <unowned string, unowned string> permissions { get; private set; }

    private static PermissionManager? instance;
    public static PermissionManager get_default () {
        if (instance == null) {
            instance = new PermissionManager ();
        }

        return instance;
    }

    private PermissionManager () {
        permissions = new GLib.HashTable <unowned string, unowned string> (str_hash, str_equal);
        permissions["filesystems=home"] = _("Home Folder");
        permissions["filesystems=host"] = _("System Folders");
        permissions["devices=all"] = _("Devices");
        permissions["shared=network"] = _("Network");
        permissions["features=bluetooth"] = _("Bluetooth");
        permissions["sockets=cups"] = _("Printing");
        permissions["sockets=ssh-auth"] = _("Secure Shell Agent");
        permissions["devices=dri"] = _("GPU Acceleration");
    }
}
