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
            "x-scheme-handler/https"
        );

        var email_setting = new SettingsChild (
            _("Email Client"),
            "x-scheme-handler/mailto"
        );

        var calendar_setting = new SettingsChild (
            _("Calendar"),
            "text/calendar"
        );

        var videos_setting = new SettingsChild (
            _("Video Player"),
            "video/x-ogm+ogg"
        );

        var music_setting = new SettingsChild (
            _("Music Player"),
            "audio/x-vorbis+ogg"
        );

        var images_setting = new SettingsChild (
            _("Image Viewer"),
            "image/jpeg"
        );

        var text_setting = new SettingsChild (
            _("Text Editor"),
            "text/plain"
        );

        var files_setting = new SettingsChild (
            _("File Browser"),
            "inode/directory"
        );

        var flowbox = new Gtk.FlowBox () {
            column_spacing = 24,
            row_spacing = 12,
            homogeneous = true,
            max_children_per_line = 2,
            selection_mode = NONE,
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
            child = flowbox,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12
        };

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            child = clamp
        };

        add (scrolled_window);

        show_all ();
    }

    private class SettingsChild : Gtk.FlowBoxChild {
        public string label { get; construct; }
        public string content_type { get; construct; }

        private static Gtk.SizeGroup size_group;

        public SettingsChild (string label, string content_type) {
            Object (
                label: label,
                content_type: content_type
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
                change_default (app_chooser.get_app_info (), content_type);
                return null;
            }));

            // TRANSLATORS: This is description for for screen reader. %s can be "Web Browser" or "Music Player" and so on.
            app_chooser.get_accessible ().accessible_name = _("Default %s").printf (label);
        }

        private void run_in_thread (owned ThreadFunc<void*> func) {
            try {
                new Thread<void*>.try (null, (owned) func);
            } catch (Error e) {
                warning ("Could not create a new thread: %s", e.message);
            }
        }

        private void change_default (AppInfo app, string content_type) {
            var types = get_types_for_app (content_type);
            var supported_types = app.get_supported_types ();

            foreach (unowned var type in types) {
                AppInfo.reset_type_associations (type);
                if (type in supported_types) {
                    try {
                        app.set_as_default_for_type (type);
                        debug ("%s now default for content type %s", app.get_name (), type);
                    } catch (Error e) {
                        critical ("Error setting default app: %s", e.message);
                    }
                } else {
                    critical ("%s does not support content type %s", app.get_name (), type);
                }
            }
        }

        private string[] get_types_for_app (string app) {
            switch (app) {
                case "x-scheme-handler/https":
                    return {
                        "x-scheme-handler/http",
                        "x-scheme-handler/https",
                        "text/html",
                        "application/xhtml+xml",
                    };

                case "x-scheme-handler/mailto":
                    return { "x-scheme-handler/mailto" };

                case "text/calendar":
                    return { "text/calendar" };

                case "video/x-ogm+ogg":
                    return {
                        "application/x-quicktimeplayer",
                        "application/vnd.rn-realmedia",
                        "application/asx",
                        "application/x-mplayer2",
                        "application/x-ms-wmv",
                        "video/quicktime",
                        "video/x-quicktime",
                        "video/vnd.rn-realvideo",
                        "video/x-ms-asf-plugin",
                        "video/x-msvideo",
                        "video/msvideo",
                        "video/x-ms-asf",
                        "video/x-ms-wm",
                        "video/x-ms-wmv",
                        "video/x-ms-wmp",
                        "video/x-ms-wvx",
                        "video/mpeg",
                        "video/x-mpeg",
                        "video/x-mpeg2",
                        "video/mp4",
                        "video/3gpp",
                        "video/fli",
                        "video/x-fli",
                        "video/x-flv",
                        "video/vnd.vivo",
                        "video/x-matroska",
                        "video/matroska",
                        "video/x-mng",
                        "video/webm",
                        "video/x-webm",
                        "video/mp2t",
                        "video/vnd.mpegurl",
                        "video/x-ogm+ogg"
                    };

                case "audio/x-vorbis+ogg":
                    return {
                        "audio/ogg",
                        "audio/mpeg",
                        "audio/mp4",
                        "audio/flac",
                        "application/x-musepack",
                        "application/musepack",
                        "application/x-ape",
                        "application/x-id3",
                        "application/ogg",
                        "application/x-ogg",
                        "application/x-vorbis+ogg",
                        "application/x-flac",
                        "application/vnd.rn-realaudio",
                        "application/x-nsv-vp3-mp3",
                        "audio/x-musepack",
                        "audio/musepack",
                        "audio/ape",
                        "audio/x-ape",
                        "audio/x-mp3",
                        "audio/mpeg",
                        "audio/x-mpeg",
                        "audio/x-mpeg-3",
                        "audio/mpeg3",
                        "audio/mp3",
                        "audio/mp4",
                        "audio/x-m4a",
                        "audio/mpc",
                        "audio/x-mpc",
                        "audio/mp",
                        "audio/x-mp",
                        "audio/x-vorbis+ogg",
                        "audio/vorbis",
                        "audio/x-vorbis",
                        "audio/ogg",
                        "audio/x-ogg",
                        "audio/x-flac",
                        "audio/flac",
                        "audio/x-s3m",
                        "audio/x-mod",
                        "audio/x-xm",
                        "audio/x-it",
                        "audio/x-pn-realaudio",
                        "audio/x-realaudio",
                        "audio/x-pn-realaudio-plugin",
                        "audio/x-ms-wmv",
                        "audio/x-ms-wax",
                        "audio/x-ms-wma",
                        "audio/wav",
                        "audio/x-wav",
                        "audio/mpeg2",
                        "audio/x-mpeg2",
                        "audio/x-mpeg3",
                        "audio/x-mpegurl",
                        "audio/basic",
                        "audio/x-basic",
                        "audio/midi",
                        "audio/x-scpls",
                        "audio/webm",
                        "audio/x-webm",
                        "x-content/audio-player"
                    };

                case "image/jpeg":
                    return {
                        "image/jpeg",
                        "image/jpg",
                        "image/pjpeg",
                        "image/png",
                        "image/tiff",
                        "image/x-3fr",
                        "image/x-adobe-dng",
                        "image/x-arw",
                        "image/x-bay",
                        "image/x-bmp",
                        "image/x-canon-cr2",
                        "image/x-canon-crw",
                        "image/x-cap",
                        "image/x-cr2",
                        "image/x-crw",
                        "image/x-dcr",
                        "image/x-dcraw",
                        "image/x-dcs",
                        "image/x-dng",
                        "image/x-drf",
                        "image/x-eip",
                        "image/x-erf",
                        "image/x-fff",
                        "image/x-fuji-raf",
                        "image/x-iiq",
                        "image/x-k25",
                        "image/x-kdc",
                        "image/x-mef",
                        "image/x-minolta-mrw",
                        "image/x-mos",
                        "image/x-mrw",
                        "image/x-nef",
                        "image/x-nikon-nef",
                        "image/x-nrw",
                        "image/x-olympus-orf",
                        "image/x-orf",
                        "image/x-panasonic-raw",
                        "image/x-pef",
                        "image/x-pentax-pef",
                        "image/x-png",
                        "image/x-ptx",
                        "image/x-pxn",
                        "image/x-r3d",
                        "image/x-raf",
                        "image/x-raw",
                        "image/x-raw",
                        "image/x-rw2",
                        "image/x-rwl",
                        "image/x-rwz",
                        "image/x-sigma-x3f",
                        "image/x-sony-arw",
                        "image/x-sony-sr2",
                        "image/x-sony-srf",
                        "image/x-sr2",
                        "image/x-srf",
                        "image/x-x3f"
                    };

                case "text/plain":
                    return {
                        "application/xml",
                        "application/x-perl",
                        "text/mathml",
                        "text/plain",
                        "text/xml",
                        "text/x-c++hdr",
                        "text/x-c++src",
                        "text/x-xsrc",
                        "text/x-chdr",
                        "text/x-csrc",
                        "text/x-dtd",
                        "text/x-java",
                        "text/x-python",
                        "text/x-sql"
                    };

                case "inode/directory":
                    return {
                        "inode/directory",
                        "x-directory/normal",
                        "x-directory/gnome-default-handler"
                    };

                default:
                    return {};
            }
        }
    }
}
