/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
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

public class Permissions.Widgets.AppSettingsView : Gtk.ScrolledWindow {
    construct {
        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.row_spacing = 32;
        grid.orientation = Gtk.Orientation.VERTICAL;

        {
            grid.add (new BooleanSetting (_("Access network"), "shared=network", false));
            grid.add (new BooleanSetting (_("Access inter-process communications"), "shared=ipc", false));
            grid.add (new BooleanSetting (_("Access X11 windowing system"), "sockets=x11", false));
            grid.add (new BooleanSetting (_("Access Wayland windowing system"), "sockets=wayland", false));
            grid.add (new BooleanSetting (_("Access PulseAudio sound server"), "sockets=pulseaudio", false));
            grid.add (new BooleanSetting (_("Access D-Bus system bus (unrestricted)"), "sockets=system-bus", false));
            grid.add (new BooleanSetting (_("Access D-Bus session bus (unrestricted)"), "sockets=session-bus", false));
            grid.add (new BooleanSetting (_("Access Secure Shell agent"), "sockets=ssh-auth", false));
            grid.add (new BooleanSetting (_("Access printing system"), "sockets=cups", false));
            grid.add (new BooleanSetting (_("Access GPU acceleration"), "devices=dri", false));
            grid.add (new BooleanSetting (_("Access all devices (e.g. webcam)"), "devices=all", false));
            grid.add (new BooleanSetting (_("Access all system directories (unrestricted)"), "filesystems=host", false));
            grid.add (new BooleanSetting (_("Access home directory (unrestricted)"), "filesystems=home", false));
            grid.add (new BooleanSetting (_("Access Bluetooth"), "features=bluetooth", false));
            grid.add (new BooleanSetting (_("Access other syscalls (e.g. ptrace)"), "features=devel", false));
            grid.add (new BooleanSetting (_("Access programs from other architectures"), "features=multiarch", false));
            //  grid.add (new BooleanSetting (_("Access other directories"), "filesystems=custom", false));
        }

        add (grid);
    }
}
