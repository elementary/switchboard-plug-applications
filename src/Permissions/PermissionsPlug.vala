/*
* Copyright (c) 2011-2020 elementary LLC. (https://elementary.io)
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
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.Plug : Gtk.Paned {
    construct {
        var sidebar = new Widgets.Sidebar ();

        var app_settings_view = new Widgets.AppSettingsView ();
        app_settings_view.show_all ();

        pack1 (sidebar, true, false);
        pack2 (app_settings_view, true, false);
        set_position (240);

        show_all ();
    }
}
