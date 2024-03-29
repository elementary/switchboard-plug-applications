/*
* Copyright 2020-2024 elementary, Inc. (https://elementary.io)
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

public class Permissions.Widgets.AppSettingsView : Switchboard.SettingsPage {
    public Backend.App? selected_app { get; set; default = null; }

    private Gtk.ListBox list_box;
    private Gtk.Button reset_button;

    construct {
        notify["selected-app"].connect (update_view);

        list_box = new Gtk.ListBox () {
            hexpand = true,
            valign = START,
            selection_mode = NONE
        };
        list_box.add_css_class ("boxed-list");
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        child = list_box;

        reset_button = add_button (_("Reset to Defaults"));

        update_view ();

        reset_button.clicked.connect (() => {
            if (selected_app != null) {
                selected_app.reset_settings_to_standard ();
                update_view ();
            }
        });
    }

    private void update_view () {
        list_box.remove_all ();

        if (selected_app == null) {
            reset_button.sensitive = false;
            return;
        }

        var should_enable_reset = false;
        selected_app.settings.foreach ((settings) => {
            string description = "Unknown";
            string icon_name = "image-missing";

            switch (settings.context) {
                case "filesystems=home":
                    description = _("Access your entire Home folder, including any hidden folders.");
                    icon_name = "user-home";
                    break;
                case "filesystems=host":
                    description = _("Access system folders, not including the operating system or system internals. This includes users' Home folders.");
                    icon_name = "drive-harddisk";
                    break;
                case "devices=all":
                    description = _("Access all devices, such as webcams, microphones, and connected USB devices.");
                    icon_name = "camera-web";
                    break;
                case "shared=network":
                    description = _("Access the Internet and local networks.");
                    icon_name = "preferences-system-network";
                    break;
                case "features=bluetooth":
                    description = _("Manage Bluetooth devices including pairing, unpairing, and discovery.");
                    icon_name = "bluetooth";
                    break;
                case "sockets=cups":
                    description = _("Access printers.");
                    icon_name = "printer";
                    break;
                case "sockets=ssh-auth":
                    description = _("Access other devices on the network via SSH.");
                    icon_name = "utilities-terminal";
                    break;
                case "devices=dri":
                    description = _("Accelerate graphical output.");
                    icon_name = "application-x-firmware";
                    break;
            }

            var override_row = new PermissionSettingsWidget (
                Plug.permission_names[settings.context],
                description,
                icon_name
            );

            settings.bind_property ("enabled", override_row, "active", SYNC_CREATE | BIDIRECTIONAL);
            settings.notify["enabled"].connect (() => {
                    change_permission_settings (settings);
            });

            if (settings.enabled != settings.standard) {
                should_enable_reset = true;
            }

            list_box.append (override_row);
        });

        reset_button.sensitive = should_enable_reset;

        update_property (Gtk.AccessibleProperty.LABEL, _("%s permissions").printf (selected_app.name), -1);
        title = selected_app.name;
        icon = selected_app.icon;
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
