/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2013-2023 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Akshay Shekher <voldyman666@gmail.com>
 *              Julien Spautz <spautz.julien@gmail.com>
 */

public class Startup.Plug : Switchboard.SettingsPage {
    private Controller controller;
    private Gtk.ListBox list;
    private Widgets.AppChooser app_chooser;

    public Plug () {
        Object (
            title: _("Startup"),
            icon: new ThemedIcon ("preferences-desktop-startup")
        );
    }

    construct {
        Backend.KeyFileFactory.init ();

        var empty_alert = new Granite.Placeholder (_("Launch Apps on Startup")) {
            description = _("Add apps to the Startup list by clicking the icon in the toolbar below.")
        };

        list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        list.set_placeholder (empty_alert);
        list.set_sort_func (sort_function);

        var drop_target = new Gtk.DropTarget (typeof (Gdk.FileList), Gdk.DragAction.COPY);
        list.add_controller (drop_target);

        var scrolled = new Gtk.ScrolledWindow () {
            child = list
        };

        var add_button_box = new Gtk.Box (HORIZONTAL, 0);
        add_button_box.append (new Gtk.Image.from_icon_name ("application-add-symbolic"));
        add_button_box.append (new Gtk.Label (_("Add Startup App…")));

        var add_button = new Gtk.Button () {
            child = add_button_box,
            margin_top = 3,
            margin_bottom = 3
        };
        add_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var actionbar = new Gtk.ActionBar ();
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        actionbar.pack_start (add_button);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (scrolled);
        box.append (actionbar);

        var frame = new Gtk.Frame (null) {
            child = box
        };

        child = frame;
        show_end_title_buttons = true;

        app_chooser = new Widgets.AppChooser () {
            modal = true
        };

        var monitor = new Backend.Monitor ();
        controller = new Controller (this);

        add_button.clicked.connect (() => {
            // Parent is set here because at construct toplevel is the plug not the window
            app_chooser.transient_for = (Gtk.Window) get_root ();
            app_chooser.present ();
        });

        app_chooser.app_chosen.connect ((path) => {
            create_file (path);
        });

        app_chooser.custom_command_chosen.connect ((command) => {
            add_app (new Backend.KeyFile.from_command (command));
        });

        drop_target.drop.connect (on_drag_data_received);

        monitor.file_created.connect ((path) => {
            add_app (Backend.KeyFileFactory.get_or_create (path));
        });

        monitor.file_deleted.connect ((path) => {
            remove_app_from_path (path);
        });
    }

    public void add_app (Backend.KeyFile key_file) {
        var app_info = key_file.create_app_info ();

        unowned var child = list.get_first_child ();
        while (child != null) {
            if (child is Widgets.AppRow && ((Widgets.AppRow) child).app_info.equal (app_info)) {
                return;
            }

            child = child.get_next_sibling ();
        }

        var row = new Widgets.AppRow (app_info);
        list.append (row);

        row.active_changed.connect ((active) => {
            key_file.active = active;
            key_file.write_to_file ();
        });
    }

    public void remove_app_from_path (string path) {
        unowned var child = list.get_first_child ();
        while (child != null) {
            if (child is Widgets.AppRow && ((Widgets.AppRow) child).app_info.path == path) {
                list.remove ((Widgets.AppRow) child);
                return;
            }

            child = child.get_next_sibling ();
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

    private bool on_drag_data_received (Gtk.DropTarget drop_target, Value val, double x, double y) {
        var file_list = (Gdk.FileList) val;
        var files = file_list.get_files ();

        foreach (var file in files) {
            var path = file.get_path ();
            if (path != null) {
                create_file (path);
            }
        }

        return false;
    }
}
