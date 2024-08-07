/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 elementary, Inc. (https://elementary.io)
 */

[DBus (name = "org.freedesktop.impl.portal.PermissionStore", timeout = 120000)]
public interface PermissionStoreDBus : GLib.Object {
    public signal void changed (string table, string id, bool deleted, GLib.Variant data, [DBus (signature = "a{sas}")] GLib.Variant permissions);
    public abstract async void set_permission (string table, bool create, string id, string app, string[] permissions) throws DBusError, IOError;
    public abstract async string[] get_permission (string table, string id, string app) throws DBusError, IOError;
}

public class Permissions.PermissionStore : GLib.Object {
    public signal void changed ();

    private const string DBUS_NAME = "org.freedesktop.impl.portal.PermissionStore";
    private const string DBUS_PATH = "/org/freedesktop/impl/portal/PermissionStore";
    private const uint RECONNECT_TIMEOUT = 5000U;

    private static PermissionStore? instance;
    public static unowned PermissionStore get_default () {
        if (instance == null) {
            instance = new PermissionStore ();
        }

        return instance;
    }

    public PermissionStoreDBus dbus { get; private set; default = null; }

    construct {
        Bus.watch_name (
            BusType.SESSION, DBUS_NAME, AUTO_START,
            () => try_connect (), name_vanished_callback
        );
    }

    private PermissionStore () { }

    private void try_connect () {
        Bus.get_proxy.begin<PermissionStoreDBus> (SESSION, DBUS_NAME, DBUS_PATH, 0, null, (obj, res) => {
            try {
                dbus = Bus.get_proxy.end (res);
                dbus.changed.connect (() => changed ());
            } catch (Error e) {
                critical (e.message);
                Timeout.add (RECONNECT_TIMEOUT, () => {
                    try_connect ();
                    return GLib.Source.REMOVE;
                });
            }
        });
    }

    private void name_vanished_callback (DBusConnection connection, string name) {
        dbus = null;
    }

    public void set_permission (string table, string id, string app, string[] permissions) {
        dbus.set_permission.begin (table, false, id, app, permissions, (obj, res) => {
            try {
                dbus.set_permission.end (res);
            } catch (Error e) {
                critical (e.message);
                var dialog = new Granite.MessageDialog (
                    _("Couldn't set permission"),
                    e.message,
                    new ThemedIcon ("preferences-system")
                ) {
                    badge_icon = new ThemedIcon ("dialog-error"),
                    modal = true,
                    transient_for = ((Gtk.Application) GLib.Application.get_default ()).active_window
                };
                dialog.present ();
                dialog.response.connect (dialog.destroy);
            }
        });
    }

    public async string[] get_permission (string table, string id, string app) {
        try {
            return yield dbus.get_permission (table, id, app);
        } catch (Error e) {
            // gets can fail if a table doesn't exist, so fail silently
            debug (e.message);
        }

        return { null };
    }
}
