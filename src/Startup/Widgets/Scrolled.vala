/*
* Copyright 2013-2017 elementary, Inc. (https://elementary.io)
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
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

/**
 * Main widget, handels drag and drop.
 */

public class Startup.Widgets.Scrolled : Gtk.Grid {
    public signal void app_added (string path);
    public signal void app_added_from_command ();
    public signal void app_removed (string path);
    public signal void app_active_changed (string path, bool active);
    public signal void app_info_changed (Entity.AppInfo new_info);

    public List list { get; private set; }
    public AppChooser app_chooser;

    private Gtk.ScrolledWindow scrolled;
    private Gtk.Button add_button;
    private Gtk.Button edit_button;

    public Scrolled () {
        orientation = Gtk.Orientation.VERTICAL;
        margin = 12;
        margin_top = 0;

        list = new List ();
        list.expand = true;

        scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (list);

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

        add_button = new Gtk.Button.from_icon_name ("application-add-symbolic", Gtk.IconSize.BUTTON);
        add_button.tooltip_text = _("Add Startup App…");
        add_button.clicked.connect (() => {app_chooser.show_all ();});

        var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
        remove_button.tooltip_text = _("Remove Selected Startup App");
        remove_button.clicked.connect (() => {list.remove_selected_app ();});
        remove_button.sensitive = false;

        edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = _("Edit the selected Custom Command"),
            sensitive = false
        };

        edit_button.clicked.connect (() => {edit_selected_row ();});

        actionbar.add (add_button);
        actionbar.add (remove_button);
        actionbar.add (edit_button);

        var grid = new Gtk.Grid ();
        grid.attach (scrolled, 0, 0, 1, 1);
        grid.attach (actionbar, 0, 1, 1, 1);

        var frame = new Gtk.Frame (null);
        frame.add (grid);

        add (frame);

        app_chooser = new AppChooser (add_button);
        app_chooser.modal = true;

        app_chooser.app_chosen.connect ((p) => app_added (p));
        /* Chain signal up to Controller */
        app_chooser.custom_command_chosen.connect (() => {
            var custom_keyfile = new Startup.Backend.KeyFile.custom ();
            Idle.add (() => {
                edit_app_info (custom_keyfile.create_app_info (), add_button);
                return Source.REMOVE;
            });
        });

        list.app_removed.connect ((p) => app_removed (p));
        list.app_added.connect ((p) => app_added (p));
        list.row_selected.connect ((row) => {
            remove_button.sensitive = (row != null);
            edit_button.sensitive = (row != null) && ((AppRow)row).can_edit;
        });

        list.app_active_changed.connect ((p, a) => app_active_changed (p, a));
        list.app_info_changed.connect ((ai) => {
            /* Controller listens and handles creating/rewriting keyfile */
            app_info_changed (ai);
        });
    }

    public void add_app (Entity.AppInfo app_info, bool edit = false) {
        var added_row = list.add_app (app_info);
        if (added_row == null) { //The app is already in the list
            return;
        }
    }

    public void edit_selected_row () {
        var row = list.get_selected_row ();
        if (row == null) {
            return;
        }

        edit_app_info (((AppRow)(row)).app_info, edit_button);
    }

    public void edit_app_info (Entity.AppInfo old_info, Gtk.Widget relative_to) {
        var popover = new CustomCommandEditor (relative_to, old_info);
        popover.changed.connect ((new_info) => {
            app_info_changed (new_info);
        });

        popover.popup ();
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
