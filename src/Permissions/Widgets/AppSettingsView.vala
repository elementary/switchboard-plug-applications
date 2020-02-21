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

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var reset_button = new Gtk.Button.with_label (_("Reset"));
        reset_button.set_tooltip_text (_("Reset this application permissions"));
        reset_button.clicked.connect (() => {
            var app = Backend.AppManager.get_default ().apps.get (selected_app);
            app.reset_settings_to_standard ();
            update_view ();
        });
        box.pack_end (reset_button, false, false);
        grid.add (box);

        Backend.AppManager.get_default ().notify["selected-app"].connect (update_view);

        var permission_manager = Backend.PermissionManager.get_default ();
        permission_manager.keys ().foreach ((key) => {
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

    private void set_settings (Backend.PermissionSettings settings) {
        grid.@foreach ((child) => {
            if (child is PermissionSettingsWidget) {
                var widget = child as PermissionSettingsWidget;
                if (widget.settings.context == settings.context) {
                    widget.do_notify = false;
                    widget.settings.standard = settings.standard;
                    widget.settings.enabled = settings.enabled;
                    widget.do_notify = true;
                }
            }
        });
    }

    private void update_view () {
        selected_app = Backend.AppManager.get_default ().selected_app;
        initialize_settings_view ();

        var app = Backend.AppManager.get_default ().apps.get (selected_app);
        app.settings.foreach ((setting) => {
            set_settings (setting);
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
