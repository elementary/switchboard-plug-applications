/*
* Copyright (c) 2011-2018 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
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
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*              Chris Triantafillis <christriant1995@gmail.com>
*/

public class DefaultsPage : Gtk.Grid {
    private class LLabel : Gtk.Label {
        public LLabel (string label) {
            this.halign = Gtk.Align.START;
            this.label = label;
        }
        
        public LLabel.indent (string label) {
            this (label);
            this.margin_start = 10;
        }

        public LLabel.markup (string label) {
            this (label);
            this.use_markup = true;
        }

        public LLabel.right (string label) {
            this.halign = Gtk.Align.END;
            this.label = label;
        }

        public LLabel.right_with_markup (string label) {
            this.halign = Gtk.Align.END;
            this.use_markup = true;
            this.label = label;
        }
    }    

    Gtk.AppChooserButton wb_chooser;
    Gtk.AppChooserButton ec_chooser;
    Gtk.AppChooserButton c_chooser;
    Gtk.AppChooserButton vp_chooser;
    Gtk.AppChooserButton mp_chooser;
    Gtk.AppChooserButton iv_chooser;
    Gtk.AppChooserButton te_chooser;
    Gtk.AppChooserButton fb_chooser;

    /* Cached AppInfo's used for switching types when default app is changed */
    GLib.AppInfo wb_old;
    GLib.AppInfo ec_old;
    GLib.AppInfo c_old;
    GLib.AppInfo vp_old;
    GLib.AppInfo mp_old;
    GLib.AppInfo iv_old;
    GLib.AppInfo te_old;
    GLib.AppInfo fb_old;

    construct {
        halign = Gtk.Align.CENTER;
        set_column_homogeneous (false);
        set_row_spacing (6);
        set_column_spacing (10);
        
        //space between the two columns
        const int margin_columns = 40;
        margin_start = margin_columns;
        margin_end = 30;
        margin_top = 64;

        var wb_label = new LLabel.right (_("Web Browser:"));
        wb_chooser = new Gtk.AppChooserButton ("x-scheme-handler/http");
        wb_chooser.show_default_item = true;

        var ec_label = new LLabel.right (_("Email Client:"));
        ec_chooser = new Gtk.AppChooserButton ("x-scheme-handler/mailto");
        ec_chooser.show_default_item = true;

        var c_label = new LLabel.right (_("Calendar:"));
        c_chooser = new Gtk.AppChooserButton ("text/calendar");
        c_chooser.show_default_item = true;

        var vp_label = new LLabel.right (_("Video Player:"));
        vp_chooser = new Gtk.AppChooserButton ("video/x-ogm+ogg");
        vp_chooser.show_default_item = true;

        var mp_label = new LLabel.right (_("Music Player:"));
        mp_chooser = new Gtk.AppChooserButton ("audio/x-vorbis+ogg");
        mp_chooser.show_default_item = true;
        mp_label.margin_start = margin_columns;

        var iv_label = new LLabel.right (_("Image Viewer:"));
        iv_chooser = new Gtk.AppChooserButton ("image/jpeg");
        iv_chooser.show_default_item = true;
        iv_label.margin_start = margin_columns;

        var te_label = new LLabel.right (_("Text Editor:"));
        te_chooser = new Gtk.AppChooserButton ("text/plain");
        te_chooser.show_default_item = true;
        te_label.margin_start = margin_columns;

        var fb_label = new LLabel.right (_("File Browser:"));
        fb_chooser = new Gtk.AppChooserButton ("inode/directory");
        fb_chooser.show_default_item = true;
        fb_label.margin_start = margin_columns;

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
        show_all ();

        cache_apps ();

        wb_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (wb_old, wb_chooser.get_app_info (), "web_browser");
            return null;
        }));

        ec_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (ec_old, ec_chooser.get_app_info (), "email_client");
            return null;
        }));

        c_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (c_old, c_chooser.get_app_info (), "calendar");
            return null;
        }));

        vp_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (vp_old, vp_chooser.get_app_info (), "video_player");
            return null;
        }));

        mp_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (mp_old, mp_chooser.get_app_info (), "music_player");
            return null;
        }));

        iv_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (iv_old, iv_chooser.get_app_info (), "image_viewer");
            return null;
        }));

        te_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (te_old, te_chooser.get_app_info (), "text_editor");
            return null;
        }));

        fb_chooser.changed.connect ( () => run_in_thread ( () => {
            change_default (fb_old, fb_chooser.get_app_info (), "file_browser");
            return null;
        }));
    }

    private static void run_in_thread (owned ThreadFunc<void*> func) {
        try {
            new Thread<void*>.try (null, func);
        } catch (Error e) {
            warning ("Could not create a new thread: %s", e.message);
        }
    }

    private void change_default (GLib.AppInfo old_app, GLib.AppInfo new_app, string item_type) {
        Defaults.map_types_to_app (Defaults.get_types_for_app (item_type), new_app);

        /*  the code below implements ->
            string[] old_types = old_app.get_supported_types ();
            map_types_to_app (old_types, new_app);
            The function AppInfo.get_supported_types () is not present in the current glib
            and will be used when we switch to the newer version.
        */
        var old_app_keyfile = new KeyFile ();
        try {
            old_app_keyfile.load_from_file (((DesktopAppInfo) old_app).filename, KeyFileFlags.NONE);
        } catch (Error e) {
            warning ("An error occured %s".printf (e.message));
        }
        string oldapp_types;
        try {
            oldapp_types = old_app_keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_MIME_TYPE);
        } catch (Error e) {
            warning ("An error occured %s".printf (e.message));
            oldapp_types = "";
        }
        // end block
        Defaults.map_types_to_app (oldapp_types.split (","), new_app);

        cache_apps ();
    }

    private void cache_apps () {
        /* Cache the AppInfo of the old default apps */
        wb_old = wb_chooser.get_app_info ();
        ec_old = ec_chooser.get_app_info ();
        c_old = c_chooser.get_app_info ();
        vp_old = vp_chooser.get_app_info ();
        mp_old = mp_chooser.get_app_info ();
        iv_old = iv_chooser.get_app_info ();
        te_old = te_chooser.get_app_info ();
        fb_old = fb_chooser.get_app_info ();
    }
}
