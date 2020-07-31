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

public class Startup.Widgets.CustomCommandEditor : Gtk.Popover {

    Gtk.Entry name_entry;
    Gtk.Entry comment_entry;
    Gtk.Entry command_entry;
    Gtk.Entry icon_entry;
    Gtk.Button apply_button;

    public Entity.AppInfo old_info { get; construct; }

    public signal void changed (Entity.AppInfo new_info);

    public CustomCommandEditor (Gtk.Widget widget, Entity.AppInfo old_info) {
        Object (
            relative_to: widget,
            old_info: old_info
        );

        name_entry.text = old_info.name;

    }

    construct {
        name_entry = new InfoEntry (old_info.name);
        comment_entry = new InfoEntry (old_info.comment);
        icon_entry = new InfoEntry (old_info.icon);
        command_entry = new InfoEntry (old_info.custom_exec);

        apply_button = new Gtk.Button.with_label (_("Apply")) { //TODO Styling
            hexpand = true
        };

        apply_button.clicked.connect (() => {
            var new_info = Entity.AppInfo () {
                name = name_entry.text,
                comment = comment_entry.text,
                icon = icon_entry.text,
                custom_exec = command_entry.text
            };

            changed (new_info);

            popdown ();
        });

        var cancel_button = new Gtk.Button.with_label (_("Cancel")) { hexpand = true };
        cancel_button.clicked.connect (() => { popdown (); });

        var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) { margin = 3 };
        button_box.add (cancel_button);
        button_box.add (apply_button);

        var name_label = new Gtk.Label (_("Name")) { margin = 3, halign = Gtk.Align.END };
        var comment_label = new Gtk.Label (_("Comment")) { margin = 3, halign = Gtk.Align.END };
        var icon_label = new Gtk.Label (_("Icon Name")) { margin = 3, halign = Gtk.Align.END };
        var command_label = new Gtk.Label (_("Command")) { margin = 3, halign = Gtk.Align.END };

        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.attach (name_label, 0, 0, 1, 1);
        grid.attach (comment_label, 0, 1, 1, 1);
        grid.attach (icon_label, 0, 2, 1, 1);
        grid.attach (command_label, 0, 3, 1, 1);
        grid.attach (name_entry, 1, 0, 1, 1);
        grid.attach (comment_entry, 1, 1, 1, 1);
        grid.attach (icon_entry, 1, 2, 1, 1);
        grid.attach (command_entry, 1, 3, 1, 1);
        grid.attach (button_box, 0, 4, 2, 1);

        add (grid);

        show_all ();
    }

    private class InfoEntry : Gtk.Entry {
        public string initial_text { get; construct; }

        //TODO Styling
        construct {
            margin_start = 12;
            margin_end = 12;
            margin_top = 2;
            margin_bottom = 2;
        }

        public InfoEntry (string initial_text) {
            Object (
                text: initial_text,
                initial_text: initial_text
            );
        }
    }

}
