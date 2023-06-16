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

public class Permissions.Widgets.AppSettingsView : Granite.SimpleSettingsPage {
    public Backend.App? selected_app { get; set; default = null; }
    public static GLib.HashTable <unowned string, unowned string> permission_names { get; private set; }

    private Gtk.ListBox list_box;
    private Gtk.Button reset_button;

    static construct {
        permission_names = new GLib.HashTable <unowned string, unowned string> (str_hash, str_equal);
        permission_names["filesystems=home"] = _("Home Folder");
        permission_names["filesystems=host"] = _("System Folders");
        permission_names["devices=all"] = _("Devices");
        permission_names["shared=network"] = _("Network");
        permission_names["features=bluetooth"] = _("Bluetooth");
        permission_names["sockets=cups"] = _("Printing");
        permission_names["sockets=ssh-auth"] = _("Secure Shell Agent");
        permission_names["devices=dri"] = _("GPU Acceleration");
    }

    construct {
        notify["selected-app"].connect (update_view);

        var homefolder_widget = new PermissionSettingsWidget (
            permission_names["filesystems=home"],
            _("Access your entire Home folder, including any hidden folders."),
            "user-home",
            new Backend.PermissionSettings ("filesystems=home")
        );

        var sysfolders_widget = new PermissionSettingsWidget (
            permission_names["filesystems=host"],
            _("Access system folders, not including the operating system or system internals. This includes users' Home folders."),
            "drive-harddisk",
            new Backend.PermissionSettings ("filesystems=host")
        );

        var devices_widget = new PermissionSettingsWidget (
            permission_names["devices=all"],
            _("Access all devices, such as webcams, microphones, and connected USB devices."),
            "camera-web",
            new Backend.PermissionSettings ("devices=all")
        );

        var network_widget = new PermissionSettingsWidget (
            permission_names["shared=network"],
            _("Access the Internet and local networks."),
            "preferences-system-network",
            new Backend.PermissionSettings ("shared=network")
        );

        var bluetooth_widget = new PermissionSettingsWidget (
            permission_names["features=bluetooth"],
            _("Manage Bluetooth devices including pairing, unpairing, and discovery."),
            "bluetooth",
            new Backend.PermissionSettings ("features=bluetooth")
        );

        var printing_widget = new PermissionSettingsWidget (
            permission_names["sockets=cups"],
            _("Access printers."),
            "printer",
            new Backend.PermissionSettings ("sockets=cups")
        );

        var ssh_widget = new PermissionSettingsWidget (
            permission_names["sockets=ssh-auth"],
            _("Access other devices on the network via SSH."),
            "utilities-terminal",
            new Backend.PermissionSettings ("sockets=ssh-auth")
        );

        var gpu_widget = new PermissionSettingsWidget (
            permission_names["devices=dri"],
            _("Accelerate graphical output."),
            "application-x-firmware",
            new Backend.PermissionSettings ("devices=dri")
        );

        list_box = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list_box.add (homefolder_widget);
        list_box.add (sysfolders_widget);
        list_box.add (devices_widget);
        list_box.add (network_widget);
        list_box.add (bluetooth_widget);
        list_box.add (printing_widget);
        list_box.add (ssh_widget);
        list_box.add (gpu_widget);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            child = list_box
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled_window
        };
        frame.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        reset_button = new Gtk.Button.with_label (_("Reset to Defaults")) {
            halign = Gtk.Align.END
        };

        content_area.add (frame);
        action_area.add (reset_button);

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
            if (selected_app != null) {
                selected_app.reset_settings_to_standard ();
                update_view ();
            }
        });
    }

    private void initialize_settings_view () {
        foreach (unowned Gtk.Widget child in list_box.get_children ()) {
            if (child is PermissionSettingsWidget) {
                var widget = (PermissionSettingsWidget) child;
                widget.do_notify = false;
                widget.settings.standard = false;
                widget.settings.enabled = false;
                widget.do_notify = true;
            }
        }
    }

    private void update_view () {
        initialize_settings_view ();

        if (selected_app == null) {
            title = selected_app.name;

            list_box.sensitive = false;
            reset_button.sensitive = false;
            return;
        }

        selected_app.settings.foreach ((settings) => {
            foreach (unowned Gtk.Widget child in list_box.get_children ()) {
                if (child is PermissionSettingsWidget) {
                    var widget = (PermissionSettingsWidget) child;
                    if (widget.settings.context == settings.context) {
                        widget.do_notify = false;
                        widget.settings.standard = settings.standard;
                        widget.settings.enabled = settings.enabled;
                        widget.do_notify = true;
                    }
                }
            }

            list_box.sensitive = true;
            reset_button.sensitive = true;
        });
    }

    private void change_permission_settings (Backend.PermissionSettings settings) {
        if (selected_app == null) {
            return;
        }

        for (var i = 0; i < selected_app.settings.length; i++) {
            var s = selected_app.settings.get (i);
            if (s.context == settings.context) {
                s.enabled = settings.enabled;
                break;
            }
        }

        selected_app.save_overrides ();
    }
}
