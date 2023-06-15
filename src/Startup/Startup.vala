/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2013-2023 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Akshay Shekher <voldyman666@gmail.com>
 *              Julien Spautz <spautz.julien@gmail.com>
 */

public class Startup.Plug : Granite.SimpleSettingsPage {
    private Controller controller;
    private Gtk.ListBox list;
    private Widgets.AppChooser app_chooser;

    private enum Target {
        URI_LIST
    }

    private const Gtk.TargetEntry[] TARGET_LIST = {
        { "text/uri-list", 0, Target.URI_LIST }
    };

    public Plug () {
        Object (
            title: _("Startup"),
            icon_name: "preferences-desktop"
        );
    }

    construct {
        Backend.KeyFileFactory.init ();

        var empty_alert = new Granite.Widgets.AlertView (
            _("Launch Apps on Startup"),
            _("Add apps to the Startup list by clicking the icon in the toolbar below."),
            "system-restart"
        );
        empty_alert.show_all ();

        list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.set_placeholder (empty_alert);
        list.set_sort_func (sort_function);

        Gtk.drag_dest_set (list, Gtk.DestDefaults.ALL, TARGET_LIST, Gdk.DragAction.COPY);

        var scrolled = new Gtk.ScrolledWindow (null, null) {
            child = list
        };

        var add_button = new Gtk.Button.from_icon_name ("application-add-symbolic") {
            tooltip_text = _("Add Startup App…")
        };

        var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic") {
            tooltip_text = _("Remove Selected Startup App"),
            sensitive = false
        };

        var actionbar = new Gtk.ActionBar ();
        actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        actionbar.pack_start (add_button);
        actionbar.pack_start (remove_button);

        var box = new Gtk.Box (VERTICAL, 0);
        box.add (scrolled);
        box.add (actionbar);

        var frame = new Gtk.Frame (null) {
            child = box
        };

        content_area.add (frame);

        app_chooser = new Widgets.AppChooser () {
            modal = true
        };

        var monitor = new Backend.Monitor ();
        controller = new Controller (this);

        add_button.clicked.connect (() => {
            // Parent is set here because at construct toplevel is the plug not the window
            app_chooser.transient_for = (Gtk.Window) get_toplevel ();
            app_chooser.present ();
        });

        app_chooser.app_chosen.connect ((path) => {
            create_file (path);
        });

        app_chooser.custom_command_chosen.connect ((command) => {
            add_app (new Backend.KeyFile.from_command (command));
        });

        list.drag_data_received.connect (on_drag_data_received);
        list.row_selected.connect ((row) => {
            remove_button.sensitive = (row != null);
        });

        monitor.file_created.connect ((path) => {
            add_app (Backend.KeyFileFactory.get_or_create (path));
        });

        monitor.file_deleted.connect ((path) => {
            remove_app_from_path (path);
        });

        remove_button.clicked.connect (() => {
            remove_selected_app ();
        });
    }

    public void add_app (Backend.KeyFile key_file) {
        var app_info = key_file.create_app_info ();
        foreach (unowned Gtk.Widget app_row in list.get_children ()) {
            if (((Widgets.AppRow) app_row).app_info.equal (app_info)) {
                return;
            }
        }

        var row = new Widgets.AppRow (app_info);
        list.add (row);

        row.active_changed.connect ((active) => {
            key_file.active = active;
            key_file.write_to_file ();
        });
    }

    public void remove_app_from_path (string path) {
        foreach (unowned Gtk.Widget app_row in list.get_children ()) {
            if (((Widgets.AppRow) app_row).app_info.path == path) {
                list.remove (app_row);
            }
        }
    }

    public void init_app_chooser (Gee.Collection <Entity.AppInfo?> app_infos) {
        app_chooser.init_list (app_infos);
    }

    private void create_file (string path) {
        var key_file = Backend.KeyFileFactory.get_or_create (path);
        key_file.active = true;
        key_file.copy_to_local ();

        add_app (key_file);
    }

    private void remove_selected_app () {
        var row = list.get_selected_row ();
        if (row == null) {
            return;
        }

        list.remove (row);

        GLib.FileUtils.remove (((Widgets.AppRow)row).app_info.path);
    }

    private string? get_path_from_uri (string uri) {
        if (uri.has_prefix ("#") || uri.strip () == "")
            return null;

        try {
            return GLib.Filename.from_uri (uri);
        } catch (Error e) {
            warning ("Could not convert URI of dropped item to filename");
            warning (e.message);
        }

        return null;
    }

    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var name_1 = ((Widgets.AppRow) row1).app_info.name;
        var name_2 = ((Widgets.AppRow) row2).app_info.name;

        return name_1.collate (name_2);
    }

    private void on_drag_data_received (Gdk.DragContext context, int x, int y,
                                Gtk.SelectionData selection_data,
                                uint info, uint time_) {

        if (info != Target.URI_LIST) {
            return;
        }

        var uris = (string) selection_data.get_data ();
        foreach (unowned string uri in uris.split ("\r\n")) {
            var path = get_path_from_uri (uri);
            if (path != null) {
                create_file (path);
            }
        }
    }
}
