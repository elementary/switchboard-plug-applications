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

        var permission_manager = Backend.PermissionManager.get_default ();
        permission_manager.keys().foreach ((key) => {
            var widget = new PermissionSettingsWidget (new Backend.PermissionSettings (key, false));
            add_settings (widget);
            widget.changed_permission_settings.connect (change_permission_settings);
        });

        add (grid);

        update_view ();
    }

    private void add_settings (PermissionSettingsWidget widget) {
        grid.add (widget);
    }

    private void reset_settings () {
        grid.@foreach ((child) => {
            var widget = (PermissionSettingsWidget) child;
            widget.do_notify = false;
            widget.settings.standard = false;
            widget.settings.enabled = false;
            widget.do_notify = true;
        });
    }

    private void set_settings (Backend.PermissionSettings settings) {
        grid.@foreach ((child) => {
            var widget = (PermissionSettingsWidget) child;
            if (widget.settings.context == settings.context) {
                widget.do_notify = false;
                widget.settings.standard = settings.standard;
                widget.settings.enabled = settings.enabled;
                widget.do_notify = true;
            }
        });
    }

    private void update_view () {
        selected_app = Backend.AppManager.get_default ().selected_app;
        reset_settings ();

        var app = Backend.AppManager.get_default ().apps.get (selected_app);
        app.settings.foreach ((setting) => {
            set_settings (setting);
        });
    }

    private void change_permission_settings (Backend.PermissionSettings settings) {
        GLib.warning ("[%s] change_permission_settings: %s - %s - %s", selected_app, settings.context, settings.standard ? "true" : "false", settings.enabled ? "true" : "false");

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
