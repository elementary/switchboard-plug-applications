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
            add_setting (new BooleanSetting (permission_manager.get (key), key, false));
        });

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

    private void enable_option (Backend.Permission option) {
        grid.@foreach ((child) => {
            var setting = (BooleanSetting) child;
            if (setting.option == option.context) {
                setting.enabled = true;
            }
        });
    }

    private void update_view () {
        selected_app = Backend.AppManager.get_default ().selected_app;
        reset_settings ();

        var app = new Backend.FlatpakApplication (selected_app);
        var permissions = app.get_current_permissions ();
        permissions.foreach ((permission) => {
            enable_option (permission);
        });
    }
}
