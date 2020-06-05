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
    private Gtk.Grid grid;
    private string selected_app;

    construct {
        var reset_button = new Gtk.Button.with_label (_("Reset to Defaults"));
        reset_button.halign = Gtk.Align.END;

        Backend.AppManager.get_default ().notify["selected-app"].connect (update_view);

        var homefolder_widget = new PermissionSettingsWidget (
            _("Home Folder"),
            _("Access your entire home folder, including any hidden folders."),
            "user-home",
            new Backend.PermissionSettings ("filesystems=home", false)
        );

        var sysfolders_widget = new PermissionSettingsWidget (
            _("System Folders"),
            _("Access system folders, not including the operating system or system internals. This includes users' Home folders."),
            "drive-harddisk",
            new Backend.PermissionSettings ("filesystems=host", false)
        );

        var devices_widget = new PermissionSettingsWidget (
            _("Devices"),
            _("Access all devices, such as webcams, microphones, and connected USB devices."),
            "accessories-camera",
            new Backend.PermissionSettings ("devices=all", false)
        );

        var network_widget = new PermissionSettingsWidget (
            _("Network"),
            _("Access the Internet and local networks"),
            "preferences-system-network",
            new Backend.PermissionSettings ("shared=network", false)
        );

        var bluetooth_widget = new PermissionSettingsWidget (
            _("Bluetooth"),
            _("Manage bluetooth devices including pairing, unpairing, and discovery."),
            "bluetooth",
            new Backend.PermissionSettings ("features=bluetooth", false)
        );

        var printing_widget = new PermissionSettingsWidget (
            _("Printing"),
            _("Access printers"),
            "printer",
            new Backend.PermissionSettings ("sockets=cups", false)
        );

        var ssh_widget = new PermissionSettingsWidget (
            _("Secure Shell Agent"),
            _("Access other devices on the network via SSH."),
            "utilities-terminal",
            new Backend.PermissionSettings ("sockets=ssh-auth", false)
        );

        var gpu_widget = new PermissionSettingsWidget (
            _("GPU Acceleration"),
            _("Accelerate graphical output."),
            "application-x-firmware",
            new Backend.PermissionSettings ("devices=dri", false)
        );

        grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.row_spacing = 24;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (homefolder_widget);
        grid.add (sysfolders_widget);
        grid.add (devices_widget);
        grid.add (network_widget);
        grid.add (bluetooth_widget);
        grid.add (printing_widget);
        grid.add (ssh_widget);
        grid.add (gpu_widget);
        grid.add (reset_button);

        add (grid);

        update_view ();

        homefolder_widget.changed_permission_settings.connect (change_permission_settings);
        sysfolders_widget.changed_permission_settings.connect (change_permission_settings);
        devices_widget.changed_permission_settings.connect (change_permission_settings);
        network_widget.changed_permission_settings.connect (change_permission_settings);
        bluetooth_widget.changed_permission_settings.connect (change_permission_settings);
        printing_widget.changed_permission_settings.connect (change_permission_settings);
        ssh_widget.changed_permission_settings.connect (change_permission_settings);
        gpu_widget.changed_permission_settings.connect (change_permission_settings);

        reset_button.clicked.connect (() => {
            var app = Backend.AppManager.get_default ().apps.get (selected_app);
            app.reset_settings_to_standard ();
            update_view ();
        });
    }

    private void initialize_settings_view () {
        grid.@foreach ((child) => {
            if (child is PermissionSettingsWidget) {
                var widget = child as PermissionSettingsWidget;
                widget.do_notify = false;
                widget.settings.standard = false;
                widget.settings.enabled = false;
                widget.do_notify = true;
            }
        });
    }

    private void update_view () {
        selected_app = Backend.AppManager.get_default ().selected_app;
        initialize_settings_view ();

        var app = Backend.AppManager.get_default ().apps.get (selected_app);
        app.settings.foreach ((settings) => {
            grid.@foreach ((child) => {
                if (child is PermissionSettingsWidget) {
                    var widget = (PermissionSettingsWidget) child;
                    if (widget.settings.context == settings.context) {
                        widget.do_notify = false;
                        widget.settings.standard = settings.standard;
                        widget.settings.enabled = settings.enabled;
                        widget.do_notify = true;
                    }
                }
            });
        });
    }

    private void change_permission_settings (Backend.PermissionSettings settings) {
        var app = Backend.AppManager.get_default ().apps.get (selected_app);
        for (var i = 0; i < app.settings.length; i++) {
            var s = app.settings.get (i);
            if (s.context == settings.context) {
                s.enabled = settings.enabled;
                break;
            }
        }

        app.save_overrides ();
    }
}
