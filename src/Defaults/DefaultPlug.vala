/*
* Copyright 2011-2018 elementary, Inc. (https://elementary.io)
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
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*              Chris Triantafillis <christriant1995@gmail.com>
*/

public class Defaults.Plug : Gtk.Grid {
    Gtk.AppChooserButton wb_chooser;
    Gtk.AppChooserButton ec_chooser;
    Gtk.AppChooserButton c_chooser;
    Gtk.AppChooserButton vp_chooser;
    Gtk.AppChooserButton mp_chooser;
    Gtk.AppChooserButton iv_chooser;
    Gtk.AppChooserButton te_chooser;
    Gtk.AppChooserButton fb_chooser;

    construct {
        column_spacing = 12;
        row_spacing = 12;
        halign = Gtk.Align.CENTER;
        margin_bottom = 24;
        margin_start = 24;
        margin_end = 24;
        margin_top = 64;

        var wb_label = new SettingsLabel (_("Web Browser:"));
        wb_chooser = new Gtk.AppChooserButton ("x-scheme-handler/https") {
            show_default_item = true
        };

        var ec_label = new SettingsLabel (_("Email Client:"));
        ec_chooser = new Gtk.AppChooserButton ("x-scheme-handler/mailto") {
            show_default_item = true
        };

        var c_label = new SettingsLabel (_("Calendar:"));
        c_chooser = new Gtk.AppChooserButton ("text/calendar") {
            show_default_item = true
        };

        var vp_label = new SettingsLabel (_("Video Player:"));
        vp_chooser = new Gtk.AppChooserButton ("video/x-ogm+ogg") {
            show_default_item = true
        };

        int margin_columns = 32;

        var mp_label = new SettingsLabel (_("Music Player:")) {
            margin_start = margin_columns
        };
        mp_chooser = new Gtk.AppChooserButton ("audio/x-vorbis+ogg") {
            show_default_item = true
        };

        var iv_label = new SettingsLabel (_("Image Viewer:")) {
            margin_start = margin_columns
        };
        iv_chooser = new Gtk.AppChooserButton ("image/jpeg") {
            show_default_item = true
        };

        var te_label = new SettingsLabel (_("Text Editor:")) {
            margin_start = margin_columns
        };
        te_chooser = new Gtk.AppChooserButton ("text/plain") {
            show_default_item = true
        };

        var fb_label = new SettingsLabel (_("File Browser:")) {
            margin_start = margin_columns
        };
        fb_chooser = new Gtk.AppChooserButton ("inode/directory") {
            show_default_item = true
        };

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
        size_group.add_widget (wb_chooser);
        size_group.add_widget (ec_chooser);
        size_group.add_widget (c_chooser);
        size_group.add_widget (vp_chooser);
        size_group.add_widget (mp_chooser);
        size_group.add_widget (iv_chooser);
        size_group.add_widget (te_chooser);
        size_group.add_widget (fb_chooser);

        attach (wb_label, 0, 0, 1, 1);
        attach (wb_chooser, 1, 0, 1, 1);
        attach (ec_label, 0, 1, 1, 1);
        attach (ec_chooser, 1, 1, 1, 1);
        attach (c_label, 0, 2, 1, 1);
        attach (c_chooser, 1, 2, 1, 1);
        attach (vp_label, 0, 3, 1, 1);
        attach (vp_chooser, 1, 3, 1, 1);
        attach (mp_label, 2, 0, 1, 1);
        attach (mp_chooser, 3, 0, 1, 1);
        attach (iv_label, 2, 1, 1, 1);
        attach (iv_chooser, 3, 1, 1, 1);
        attach (te_label, 2, 2, 1, 1);
        attach (te_chooser, 3, 2, 1, 1);
        attach (fb_label, 2, 3, 1, 1);
        attach (fb_chooser, 3, 3, 1, 1);

        wb_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (wb_chooser.get_app_info (), "web_browser");
            return null;
        }));

        ec_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (ec_chooser.get_app_info (), "email_client");
            return null;
        }));

        c_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (c_chooser.get_app_info (), "calendar");
            return null;
        }));

        vp_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (vp_chooser.get_app_info (), "video_player");
            return null;
        }));

        mp_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (mp_chooser.get_app_info (), "music_player");
            return null;
        }));

        iv_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (iv_chooser.get_app_info (), "image_viewer");
            return null;
        }));

        te_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (te_chooser.get_app_info (), "text_editor");
            return null;
        }));

        fb_chooser.changed.connect (() => run_in_thread ( () => {
            change_default (fb_chooser.get_app_info (), "file_browser");
            return null;
        }));

    }

    private void run_in_thread (owned ThreadFunc<void*> func) {
        try {
            new Thread<void*>.try (null, (owned) func);
        } catch (Error e) {
            warning ("Could not create a new thread: %s", e.message);
        }
    }
    public void change_default (GLib.AppInfo new_app, string item_type) {
        map_types_to_app (get_types_for_app (item_type), new_app);
    }

    private class SettingsLabel : Gtk.Widget {
        private Gtk.Label main_widget;
        public string label { get; construct; }

        public SettingsLabel (string label) {
            Object (label: label);
        }

        static construct {
            set_layout_manager_type (typeof (Gtk.BinLayout));
        }

        construct {
            main_widget = new Gtk.Label (label) {
                halign = Gtk.Align.END
            };
        }

        ~SettingsLabel () {
            while (this.get_last_child () != null) {
                this.get_last_child ().unparent ();
            }
        }
    }
}
