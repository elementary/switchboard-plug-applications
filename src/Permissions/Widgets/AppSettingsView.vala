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

public class Permissions.Widgets.AppSettingsView : Gtk.Grid {
    public Backend.App? selected_app { get; set; default = null; }

    private Gtk.ListBox list_box;
    private Gtk.Button reset_button;

    construct {
        notify["selected-app"].connect (update_view);

        var homefolder_widget = new PermissionSettingsWidget (
            Plug.permission_names["filesystems=home"],
            _("Access your entire Home folder, including any hidden folders."),
            "user-home",
            new Backend.PermissionSettings ("filesystems=home")
        );

        var sysfolders_widget = new PermissionSettingsWidget (
            Plug.permission_names["filesystems=host"],
            _("Access system folders, not including the operating system or system internals. This includes users' Home folders."),
            "drive-harddisk",
            new Backend.PermissionSettings ("filesystems=host")
        );

        var devices_widget = new PermissionSettingsWidget (
            Plug.permission_names["devices=all"],
            _("Access all devices, such as webcams, microphones, and connected USB devices."),
            "camera-web",
            new Backend.PermissionSettings ("devices=all")
        );

        var network_widget = new PermissionSettingsWidget (
            Plug.permission_names["shared=network"],
            _("Access the Internet and local networks."),
            "preferences-system-network",
            new Backend.PermissionSettings ("shared=network")
        );

        var bluetooth_widget = new PermissionSettingsWidget (
            Plug.permission_names["features=bluetooth"],
            _("Manage Bluetooth devices including pairing, unpairing, and discovery."),
            "bluetooth",
            new Backend.PermissionSettings ("features=bluetooth")
        );

        var printing_widget = new PermissionSettingsWidget (
            Plug.permission_names["sockets=cups"],
            _("Access printers."),
            "printer",
            new Backend.PermissionSettings ("sockets=cups")
        );

        var ssh_widget = new PermissionSettingsWidget (
            Plug.permission_names["sockets=ssh-auth"],
            _("Access other devices on the network via SSH."),
            "utilities-terminal",
            new Backend.PermissionSettings ("sockets=ssh-auth")
        );

        var gpu_widget = new PermissionSettingsWidget (
            Plug.permission_names["devices=dri"],
            _("Accelerate graphical output."),
            "application-x-firmware",
            new Backend.PermissionSettings ("devices=dri")
        );

        list_box = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        list_box.append (homefolder_widget);
        list_box.append (sysfolders_widget);
        list_box.append (devices_widget);
        list_box.append (network_widget);
        list_box.append (bluetooth_widget);
        list_box.append (printing_widget);
        list_box.append (ssh_widget);
        list_box.append (gpu_widget);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_box
        };

        var frame = new Gtk.Frame (null) {
            child = scrolled_window
        };
        frame.add_css_class (Granite.STYLE_CLASS_VIEW);

        reset_button = new Gtk.Button.with_label (_("Reset to Defaults")) {
            halign = Gtk.Align.END
        };

        row_spacing = 24;
        attach (frame, 0, 0);
        attach (reset_button, 0, 1);

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
        var children = list_box.observe_children ();
        for (var iter = 0; iter < children.get_n_items (); iter++) {
            if (children.get_item (iter) is PermissionSettingsWidget) {
                var widget = (PermissionSettingsWidget) children.get_item (iter);
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
            list_box.sensitive = false;
            reset_button.sensitive = false;
            return;
        }

        var should_enable_reset = false;
        selected_app.settings.foreach ((settings) => {
            var children = list_box.observe_children ();
            for (var iter = 0; iter < children.get_n_items (); iter++) {
                if (children.get_item (iter) is PermissionSettingsWidget) {
                    var widget = (PermissionSettingsWidget) children.get_item (iter);
                    if (widget.settings.context == settings.context) {
                        widget.do_notify = false;
                        widget.settings.standard = settings.standard;
                        widget.settings.enabled = settings.enabled;
                        widget.do_notify = true;

                        if (settings.enabled != settings.standard) {
                            should_enable_reset = true;
                        }
                    }
                }
            }

            list_box.sensitive = true;
            reset_button.sensitive = should_enable_reset;
        });

        update_property (Gtk.AccessibleProperty.LABEL, _("%s permissions").printf (selected_app.name), -1);
    }

    private void change_permission_settings (Backend.PermissionSettings settings) {
        if (selected_app == null) {
            return;
        }

        var should_enable_reset = false;
        for (var i = 0; i < selected_app.settings.length; i++) {
            var s = selected_app.settings.get (i);
            if (s.context == settings.context) {
                s.enabled = settings.enabled;

                if (settings.enabled != settings.standard) {
                    should_enable_reset = true;
                }

                break;
            }
        }

        selected_app.save_overrides ();

        reset_button.sensitive = should_enable_reset;
    }
}
