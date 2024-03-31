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

    private const string BACKGROUND_TABLE = "background";
    private const string BACKGROUND_ID = "background";
    private const string LOCATION_TABLE = "location";
    private const string LOCATION_ID = "location";
    private const string WALLPAPER_TABLE = "wallpaper";
    private const string WALLPAPER_ID = "wallpaper";

    private string location_timestamp = "0";

    private Gtk.ListBox sandbox_box;
    private Gtk.ListBox permission_box;
    private Gtk.Button reset_button;
    private PermissionSettingsWidget background_row;
    private PermissionSettingsWidget location_row;
    private PermissionSettingsWidget wallpaper_row;

    construct {
        notify["selected-app"].connect (update_view);

        permission_box = new Gtk.ListBox () {
            hexpand = true,
            selection_mode = NONE
        };
        permission_box.add_css_class ("boxed-list");
        permission_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        sandbox_box = new Gtk.ListBox () {
            hexpand = true,
            selection_mode = NONE
        };
        sandbox_box.add_css_class ("boxed-list");
        sandbox_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var box = new Gtk.Box (VERTICAL, 24);
        box.append (permission_box);
        box.append (sandbox_box);

        child = box;

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
        permission_box.remove_all ();
        sandbox_box.remove_all ();

        if (selected_app == null) {
            sensitive = false;
            return;
        }

        var should_enable_reset = false;
        selected_app.settings.foreach ((settings) => {
            string description = "Unknown";
            string icon_name = "image-missing";

            switch (settings.context) {
                case "filesystems=home":
                    description = _("Including all documents, downloads, music, pictures, videos, and any hidden folders.");
                    icon_name = "user-home";
                    break;
                case "filesystems=host":
                    description = _("Including everyone's Home folders, but not including system internals.");
                    icon_name = "drive-harddisk";
                    break;
                case "devices=all":
                    description = _("Manage all connected devices, such as webcams, microphones, and USB devices.");
                    icon_name = "camera-web";
                    break;
                case "shared=network":
                    description = _("Connect to the Internet and local networks.");
                    icon_name = "preferences-system-network";
                    break;
                case "features=bluetooth":
                    description = _("Manage Bluetooth devices including pairing, unpairing, and discovery.");
                    icon_name = "bluetooth";
                    break;
                case "sockets=cups":
                    description = _("Manage printers and see the print queue.");
                    icon_name = "printer";
                    break;
                case "sockets=ssh-auth":
                    description = _("Connect to other devices on the network via SSH.");
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

            sandbox_box.append (override_row);
        });

        var permission_store = PermissionStore.get_default ();

        background_row = new PermissionSettingsWidget (
            _("Background Activity"),
            _("Perform tasks and use system resources while its window is closed."),
            "permissions-background"
        );

        background_row.notify["active"].connect (() => {
            string[] permissions = { background_row.active ? "yes" : "no" };
            permission_store.set_permission (BACKGROUND_TABLE, BACKGROUND_ID, selected_app.id, permissions);
        });

        location_row = new PermissionSettingsWidget (
            _("Location Services"),
            _("Determine the location of this device."),
            "preferences-system-privacy-location"
        );

        location_row.notify["active"].connect (() => {
            string[] permissions = {
                location_row.active ? "EXACT" : "NONE",
                location_timestamp
            };
            permission_store.set_permission (LOCATION_TABLE, LOCATION_ID, selected_app.id, permissions);
        });

        wallpaper_row = new PermissionSettingsWidget (
            _("Wallpaper"),
            _("Set the wallpaper on the desktop and lock screen."),
            "preferences-desktop-wallpaper"
        );

        wallpaper_row.notify["active"].connect (() => {
            string[] permissions = { wallpaper_row.active ? "yes" : "no" };
            permission_store.set_permission (WALLPAPER_TABLE, WALLPAPER_ID, selected_app.id, permissions);
        });

        update_permissions.begin ();
        permission_store.notify["dbus"].connect (update_permissions);
        permission_store.changed.connect (update_permissions);

        sensitive = true;
        reset_button.sensitive = should_enable_reset;

        update_property (Gtk.AccessibleProperty.LABEL, _("%s permissions").printf (selected_app.name), -1);
        title = selected_app.name;
        icon = selected_app.icon;
    }

    private async void update_permissions () {
        var permission_store = PermissionStore.get_default ();
        if (permission_store.dbus == null) {
            permission_box.sensitive = false;
            return;
        }

        permission_box.sensitive = true;

        var background_permission = yield permission_store.get_permission (BACKGROUND_TABLE, BACKGROUND_ID, selected_app.id);
        if (background_permission[0] != null) {
            background_row.active = background_permission[0] == "yes";

            if (background_row.parent == null) {
                permission_box.append (background_row);
            }
        }

        var location_permission = yield permission_store.get_permission (LOCATION_TABLE, LOCATION_ID, selected_app.id);
        if (location_permission[0] != null) {
            // Values are usually EXACT or NONE, but safer to assume anything but NONE is active
            location_row.active = location_permission[0] != "NONE";
            location_timestamp = location_permission[1];

            if (location_row.parent == null) {
                permission_box.append (location_row);
            }
        }

        var wallpaper_permission = yield permission_store.get_permission (WALLPAPER_TABLE, WALLPAPER_ID, selected_app.id);
        if (wallpaper_permission[0] != null) {
            wallpaper_row.active = wallpaper_permission[0] == "yes";

            if (wallpaper_row.parent == null) {
                permission_box.append (wallpaper_row);
            }
        }

        permission_box.visible = permission_box.get_row_at_index (0) != null;
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
