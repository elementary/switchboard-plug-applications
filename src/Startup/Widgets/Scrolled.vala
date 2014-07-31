/***
    Copyright (C) 2013 Julien Spautz <spautz.julien@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

/**
 * Main widget, handels drag and drop.
 */
public class Startup.Widgets.Scrolled : Gtk.Grid {
    public signal void app_added (string path);
    public signal void app_added_from_command (string command);
    public signal void app_removed (string path);
    public signal void app_active_changed (string path, bool active);

    public Widgets.List list { get; private set; }
    public Dialogs.AppChooser app_chooser;

    public Scrolled () {
        orientation = Gtk.Orientation.VERTICAL;
        margin = 12;
        margin_top = 0;

        list = new Widgets.List ();
        list.expand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.shadow_type = Gtk.ShadowType.IN;
        scrolled.add (list);

        var toolbar = new Gtk.Toolbar ();
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        toolbar.icon_size = Gtk.IconSize.SMALL_TOOLBAR;

        var add_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON), null);
        add_button.tooltip_text = _("Add Startup App…");
        add_button.clicked.connect (() => {app_chooser.show_all ();});

        var remove_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON), null);
        remove_button.tooltip_text = _("Remove Selected Startup App");
        remove_button.clicked.connect (() => {list.remove_selected_app ();});
        remove_button.sensitive = false;

        toolbar.add (add_button);
        toolbar.add (remove_button);

        add (scrolled);
        add (toolbar);

        app_chooser = new Dialogs.AppChooser (add_button);
        app_chooser.modal = true;

        app_chooser.app_chosen.connect ((p) => app_added (p));
        app_chooser.custom_command_chosen.connect ((c) => app_added_from_command (c));

        list.app_removed.connect ((p) => {
            app_removed (p);
            if (list.get_children ().length () <= 0) {
                remove_button.sensitive = false;
            }
        });
        list.app_added.connect ((p) => app_added (p));
        list.row_selected.connect ((row) => {remove_button.sensitive = true;});
        list.app_active_changed.connect ((p,a) => app_active_changed (p,a));
    }

    public void add_app (Entity.AppInfo app_info) {
        list.add_app (app_info);
    }

    public void remove_app_from_path (string path) {
        list.remove_app_from_path (path);
    }

    public void reload_app_from_path (string path) {
        list.reload_app_from_path (path);
    }

    public void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos) {
        app_chooser.init_list (app_infos);
    }
}