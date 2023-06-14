/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2011-2023 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Akshay Shekher <voldyman666@gmail.com>
 *              Chris Triantafillis <christriant1995@gmail.com>
 */

public class Defaults.Plug : Gtk.Box {
    construct {
        var browser_setting = new SettingsChild (
            _("Web Browser"),
            "x-scheme-handler/https",
            "web_browser"
        );

        var email_setting = new SettingsChild (
            _("Email Client"),
            "x-scheme-handler/mailto",
            "email_client"
        );

        var calendar_setting = new SettingsChild (
            _("Calendar"),
            "text/calendar",
            "calendar"
        );

        var videos_setting = new SettingsChild (
            _("Video Player"),
            "video/x-ogm+ogg",
            "video_player"
        );

        var music_setting = new SettingsChild (
            _("Music Player"),
            "audio/x-vorbis+ogg",
            "music_player"
        );

        var images_setting = new SettingsChild (
            _("Image Viewer"),
            "image/jpeg",
            "image_viewer"
        );

        var text_setting = new SettingsChild (
            _("Text Editor"),
            "text/plain",
            "text_editor"
        );

        var files_setting = new SettingsChild (
            _("File Browser"),
            "inode/directory",
            "file_browser"
        );

        var flowbox = new Gtk.FlowBox () {
            homogeneous = true,
            column_spacing = 24,
            row_spacing = 12,
            max_children_per_line = 2,
            valign = START
        };
        flowbox.add (browser_setting);
        flowbox.add (music_setting);
        flowbox.add (email_setting);
        flowbox.add (images_setting);
        flowbox.add (calendar_setting);
        flowbox.add (text_setting);
        flowbox.add (videos_setting);
        flowbox.add (files_setting);

        var clamp = new Hdy.Clamp () {
            child = flowbox
        };

        add (clamp);

        show_all ();
    }

    private class SettingsChild : Gtk.FlowBoxChild {
        public string label { get; construct; }
        public string content_type { get; construct; }
        public string item_type { get; construct; }

        private static Gtk.SizeGroup size_group;

        public SettingsChild (string label, string content_type, string item_type) {
            Object (
                label: label,
                content_type: content_type,
                item_type: item_type
            );
        }

        static construct {
            size_group = new Gtk.SizeGroup (HORIZONTAL);
        }

        construct {
            var setting_label = new Granite.HeaderLabel (label);

            var app_chooser = new Gtk.AppChooserButton (content_type) {
                hexpand = true,
                show_default_item = true
            };

            var box = new Gtk.Box (VERTICAL, 0);
            box.add (setting_label);
            box.add (app_chooser);

            can_focus = false;
            child = box;

            size_group.add_widget (setting_label);

            app_chooser.changed.connect (() => run_in_thread (() => {
                change_default (app_chooser.get_app_info (), item_type);
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

        private void change_default (GLib.AppInfo new_app, string item_type) {
            map_types_to_app (get_types_for_app (item_type), new_app);
        }
    }
}
