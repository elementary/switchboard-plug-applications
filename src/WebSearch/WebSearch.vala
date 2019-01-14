/*
* Copyright (c) 2011-2019 elementary LLC. (https://elementary.io)
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
* Authored by: Matthew Olenik <olenikm@gmail.com>
*/


public class WebSearch.Plug : Gtk.Grid {
    class Choice {
        public string text;
        public int sort_id;
    }

    private Settings gsettings = new Settings ("io.elementary.desktop.wingpanel.applications-menu");
    private static Gee.HashMap<string, Choice> search_engine_choices;

    private Gtk.Entry custom_search_url_entry;
    private Gtk.Label custom_error_label;
    private Gtk.ComboBox engine_choice;
    private Gtk.ListStore store;
    private Gtk.Switch enabled_switch;
    private Gtk.Grid search_selector_grid;
    private Gtk.Grid custom_box;

    private const string DEFAULT_ENGINE_ID = "duckduckgo";
    private const string CUSTOM_ENGINE_ID = "custom";
    private const string STRAWBERRY = "#c6262e";  // From elementary human interface guidelines
    private const int CUSTOM_URL_WIDTH = 55;
    private Regex url_valid_regex;

    construct {
        try {
            url_valid_regex = new Regex("""https?:\/\/.*\{query\}""");
        } catch (RegexError e) {
            error (e.message);
        }
        /*
        * sort_id is used to pre-sort the items. We want alphabetical except for the default (placed at the top),
        * and custom (placed at the bottom). The reasoning being that it "feels right" to have the default option
        * most visible at the top, and custom, being the least likely to be used, at the bottom.
        */
        search_engine_choices = new Gee.HashMap<string, Choice> ();
        search_engine_choices["duckduckgo"] = new Choice () { sort_id = 0, text = _("DuckDuckGo (default)") };
        search_engine_choices["baidu"] = new Choice () { sort_id = 1, text = _("Baidu") };
        search_engine_choices["bing"] = new Choice () { sort_id = 2, text = _("Bing") };
        search_engine_choices["google"] = new Choice () { sort_id = 3, text = _("Google") };
        search_engine_choices["yahoo"] = new Choice () { sort_id = 4, text = _("Yahoo!") };
        search_engine_choices["yandex"] = new Choice () { sort_id = 5, text = _("Yandex") };
        search_engine_choices[CUSTOM_ENGINE_ID] = new Choice () { sort_id = 6, text = _("Custom") };

        halign = Gtk.Align.CENTER;
        row_spacing = 24;
        margin = 24;
        margin_top = 48;

        /* Container that groups custom URL label, entry, and error label widgets. */
        custom_box = new Gtk.Grid () {
            row_spacing = 5,
            column_spacing = 10,
            visible = false,
            no_show_all = true
        };
        custom_search_url_entry = new Gtk.Entry () {
            placeholder_text = _("https://example.com/?q={query}"),
            width_chars = CUSTOM_URL_WIDTH,
            max_width_chars = CUSTOM_URL_WIDTH
        };
        var error_text =
            _("The search URL must be a valid URL containing <b>{query}</b> wherever the search terms should appear, e.g. https://example.com/?q={query}");
        custom_error_label = new Gtk.Label (error_text) {
            use_markup = true,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            width_chars = CUSTOM_URL_WIDTH,
            max_width_chars = CUSTOM_URL_WIDTH,
            halign = Gtk.Align.START,
            no_show_all = true,
            visible = false
        };
        custom_error_label.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);
        var custom_search_label = new Gtk.Label (_("Custom search URL:")) {
            halign = Gtk.Align.START,
            hexpand = false
        };
        custom_box.attach (custom_search_label, 0, 0, 1, 1);
        custom_box.attach (custom_search_url_entry, 1, 0, 1, 1);
        custom_box.attach (custom_error_label, 1, 1, 1, 1);

        /* Container to hold label + combobox */
        search_selector_grid = new Gtk.Grid () {
            halign = Gtk.Align.START,
            column_spacing = 10
        };

        var summary_label = new Gtk.Label (_("When searching with the Applications Menu, show an option to launch a web search in your browser."));

        var choice_label = new Gtk.Label (_("Search the web with:"));
        search_selector_grid.attach (choice_label, 0, 0, 1, 1);

        /* This structure corresponds to the search_engine_choices map structure. */
        store = new Gtk.ListStore (3, typeof (string), typeof (string), typeof (int));
        store.set_sort_column_id (2, Gtk.SortType.ASCENDING);

        /* Populate combobox with vales from search_engine_choices structure. */
        Gtk.TreeIter iter;
        foreach (var choice in search_engine_choices.entries) {
            store.append (out iter);
            store.set (iter, 0, choice.key, 1, choice.value.text, 2, choice.value.sort_id);
        }

        engine_choice = new Gtk.ComboBox.with_model (store) {
            id_column = 0  // Make sure to sort according to the sort_id property
        };
        search_selector_grid.attach (engine_choice, 1, 0, 1, 1);
        var renderer = new Gtk.CellRendererText ();
        engine_choice.pack_start (renderer, true);
        engine_choice.add_attribute (renderer, "text", 1);

        gsettings.bind ("web-search-engine-id", engine_choice, "active_id", SettingsBindFlags.DEFAULT);
        gsettings.bind ("web-search-custom-url", custom_search_url_entry, "text", SettingsBindFlags.DEFAULT);

        /* Fall back to the default if a bad ID is found. This shouldn't happen unless the gsettings were tampered with. */
        if (engine_choice.active_id == null || engine_choice.active_id.chomp () == "") {
            engine_choice.active_id = DEFAULT_ENGINE_ID;
        }

        if (engine_choice.active_id == CUSTOM_ENGINE_ID) {
            widget_set_visible (custom_box, true);
        } else {
            widget_set_visible (custom_box, false);
        }

        engine_choice.changed.connect (() => {
            Gtk.TreeIter i;
            engine_choice.get_active_iter (out i);
            Value id;
            store.get_value (i, 0, out id);
            if ((string) id == CUSTOM_ENGINE_ID) {
                widget_set_visible (custom_box, true);
            } else {
                widget_set_visible (custom_box, false);
            }
        });

        custom_search_url_entry.changed.connect (check_custom_error);
        check_custom_error ();

        var enabled_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10) {
            halign = Gtk.Align.START
        };

        var enabled_label = new Gtk.Label (_("Enable Web Search:"));
        enabled_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        enabled_switch = new Gtk.Switch ();
        gsettings.bind ("web-search-enabled", enabled_switch, "active", SettingsBindFlags.DEFAULT);
        set_form_sensitive (enabled_switch.active);
        enabled_switch.state_set.connect (set_form_sensitive);

        enabled_box.pack_start (enabled_label, false, false, 0);
        enabled_box.pack_start (enabled_switch, false, false, 0);

        attach (enabled_box, 0, 0, 1, 1);
        attach (summary_label, 0, 1, 1, 1);
        attach (search_selector_grid, 0, 2, 1, 1);
        attach (custom_box, 0, 3, 1, 1);

        show_all ();
    }

    /* Gray out parts of the form when search is enabled or disabled */
    private bool set_form_sensitive (bool sensitive) {
        custom_box.sensitive = sensitive;
        search_selector_grid.sensitive = sensitive;
        return false;  // Do not block default handler
    }

    private void check_custom_error () {
        if (!url_valid_regex.match(custom_search_url_entry.text)) {
            widget_set_visible (custom_error_label, true);
        } else {
            widget_set_visible (custom_error_label, false);
        }
    }

    private static void widget_set_visible (Gtk.Widget w, bool visible) {
        w.no_show_all = !visible;
        w.visible = visible;
        if (visible) {
            w.show_all ();
        }
    }

    public Plug () {
    }
}
