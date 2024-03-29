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

    private Gtk.ListBox sandbox_box;
    private Gtk.ListBox permission_box;
    private Gtk.Button reset_button;
    private Gtk.Switch background_switch;

    construct {
        notify["selected-app"].connect (update_view);

        var background_image = new Gtk.Image.from_icon_name ("permissions-background") {
            icon_size = LARGE
        };

        var background_label = new Gtk.Label (_("Background Activity")) {
            hexpand = true,
            xalign = 0
        };

        var background_description = new Gtk.Label (_("Perform tasks and use system resources while its window is closed.")) {
            xalign = 0,
            wrap = true
        };
        background_description.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        background_description.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        background_switch = new Gtk.Switch () {
            valign = CENTER
        };

        var background_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        background_grid.attach (background_image, 0, 0, 1, 2);
        background_grid.attach (background_label, 1, 0);
        background_grid.attach (background_description, 1, 1);
        background_grid.attach (background_switch, 2, 0, 1, 2);

        permission_box = new Gtk.ListBox () {
            hexpand = true,
            selection_mode = NONE
        };
        permission_box.add_css_class ("boxed-list");
        permission_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        permission_box.append (background_grid);

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

        background_switch.notify["active"].connect (() => {
            string[] permissions;
            if (background_switch.active) {
                permissions += "yes";
            } else {
                permissions += "no";
            }

            try {
                PermissionStore.get_default ().dbus.set_permission.begin (BACKGROUND_TABLE, true, BACKGROUND_ID, selected_app.id, permissions);
            } catch (Error e) {
                critical (e.message);
                var dialog = new Granite.MessageDialog (
                    _("Couldn't set background activity permission"),
                    e.message,
                    new ThemedIcon ("preferences-system")
                ) {
                    badge_icon = new ThemedIcon ("dialog-error"),
                    modal = true,
                    transient_for = (Gtk.Window) get_root ()
                };
                dialog.present ();
                dialog.response.connect (dialog.destroy);
            }
        });

        reset_button.clicked.connect (() => {
            if (selected_app != null) {
                selected_app.reset_settings_to_standard ();
                update_view ();
            }
        });
    }

    private void update_view () {
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

            sandbox_box.append (override_row);
        });

        update_permissions ();
        var permission_store = PermissionStore.get_default ();
        permission_store.notify["dbus"].connect (update_permissions);
        permission_store.changed.connect (update_permissions);

        sensitive = true;
        reset_button.sensitive = should_enable_reset;

        update_property (Gtk.AccessibleProperty.LABEL, _("%s permissions").printf (selected_app.name), -1);
        title = selected_app.name;
        icon = selected_app.icon;
    }

    private void update_permissions () {
        var permission_store = PermissionStore.get_default ();
        if (permission_store.dbus == null) {
            permission_box.sensitive = false;
            return;
        }

        permission_box.sensitive = true;

        permission_store.dbus.get_permission.begin (BACKGROUND_TABLE, BACKGROUND_ID, selected_app.id, (obj, res) => {
            try {
                var background_permission = permission_store.dbus.get_permission.end (res);

                // A lack of explicit permission is considered permission
                // to allow pre-emptive opt-out
                background_switch.active = background_permission[0] != "no";
            } catch (Error e) {
                critical (e.message);
                var dialog = new Granite.MessageDialog (
                    _("Couldn't get background activity permission"),
                    e.message,
                    new ThemedIcon ("preferences-system")
                ) {
                    badge_icon = new ThemedIcon ("dialog-error"),
                    modal = true,
                    transient_for = (Gtk.Window) get_root ()
                };
                dialog.present ();
                dialog.response.connect (dialog.destroy);
            }
        });
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
