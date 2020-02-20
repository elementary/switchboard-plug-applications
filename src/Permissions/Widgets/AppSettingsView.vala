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
    Gtk.Grid grid;
    private string selected_app;

    construct {
        grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.row_spacing = 32;
        grid.orientation = Gtk.Orientation.VERTICAL;

        Backend.AppManager.get_default ().notify["selected-app"].connect (update_view);

        {
            add_setting (new BooleanSetting (_("Access network"), "shared=network", false));
            add_setting (new BooleanSetting (_("Access inter-process communications"), "shared=ipc", false));
            add_setting (new BooleanSetting (_("Access X11 windowing system"), "sockets=x11", false));
            add_setting (new BooleanSetting (_("Access Wayland windowing system"), "sockets=wayland", false));
            add_setting (new BooleanSetting (_("Access PulseAudio sound server"), "sockets=pulseaudio", false));
            add_setting (new BooleanSetting (_("Access D-Bus system bus (unrestricted)"), "sockets=system-bus", false));
            add_setting (new BooleanSetting (_("Access D-Bus session bus (unrestricted)"), "sockets=session-bus", false));
            add_setting (new BooleanSetting (_("Access Secure Shell agent"), "sockets=ssh-auth", false));
            add_setting (new BooleanSetting (_("Access printing system"), "sockets=cups", false));
            add_setting (new BooleanSetting (_("Access GPU acceleration"), "devices=dri", false));
            add_setting (new BooleanSetting (_("Access all devices (e.g. webcam)"), "devices=all", false));
            add_setting (new BooleanSetting (_("Access all system directories (unrestricted)"), "filesystems=host", false));
            add_setting (new BooleanSetting (_("Access home directory (unrestricted)"), "filesystems=home", false));
            add_setting (new BooleanSetting (_("Access Bluetooth"), "features=bluetooth", false));
            add_setting (new BooleanSetting (_("Access other syscalls (e.g. ptrace)"), "features=devel", false));
            add_setting (new BooleanSetting (_("Access programs from other architectures"), "features=multiarch", false));
            //  add_setting (new BooleanSetting (_("Access other directories"), "filesystems=custom", false));
        }

        add (grid);

        update_view ();
    }

    private void add_setting (BooleanSetting setting) {
        grid.add (setting);
    }

    private void reset_settings () {
        grid.@foreach ((child) => {
            var setting = (BooleanSetting) child;
            setting.enabled = false;
        });
    }

    private void enable_option (string option) {
        grid.@foreach ((child) => {
            var setting = (BooleanSetting) child;
            if (setting.option == option) {
                setting.enabled = true;
            }
        });
    }

    private void update_view () {
        selected_app = Backend.AppManager.get_default ().selected_app;
        reset_settings ();

        var app = new Backend.FlatpakApplication (selected_app);
        var permissions = app.get_permissions ();
        permissions.foreach ((permission) => {
            enable_option (permission);
        });
    }
}
