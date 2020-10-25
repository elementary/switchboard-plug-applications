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

public class Permissions.Backend.FlatpakManager : GLib.Object {
    public string user_installation_path { get; private set; }

    private static FlatpakManager? instance;
    public static FlatpakManager get_default () {
        if (instance == null) {
            instance = new FlatpakManager ();
        }

        return instance;
    }

    construct {
        try {
            var installation = new Flatpak.Installation.user ();
            user_installation_path = installation.get_path ().get_path ();
        } catch (Error e) {
            critical ("Unable to get flatpak user installation : %s", e.message);
        }
    }
}
