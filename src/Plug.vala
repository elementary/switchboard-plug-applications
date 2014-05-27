/***
    BEGIN LICENSE

    Copyright (C) 2014 elementary Developers
    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>

    END LICENSE
    Written By: Akshay Shekher <voldyman666@gmail.com>

***/

public class ApplicationsPlug : Switchboard.Plug {

    private Defaults.Plug defaults_plug;
    private Startup.Plug startup_plug;

	private Gtk.Grid grid;

    public ApplicationsPlug () {
        Object (category: Category.PERSONAL,
                code_name: "personal-pantheon-applications",
                display_name: _("Applications"),
                description: _("Application Settings"),
                icon: "application-default-icon");

        defaults_plug = new Defaults.Plug ();
        startup_plug = new Startup.Plug ();
    }

    public override Gtk.Widget get_widget () {
		if (grid != null) {
			return grid;
		}

		var stack = new Gtk.Stack ();
		stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
		stack.set_transition_duration (500);
		stack.expand = true;

		stack.add_titled (defaults_plug.get_widget (), "defaults", _("Defaults"));
		stack.add_titled (startup_plug.get_widget (), "startup", _("Startup Apps"));

		var stack_switcher = new Gtk.StackSwitcher ();
		stack_switcher.set_halign (Gtk.Align.CENTER);
		stack_switcher.set_stack (stack);
		stack_switcher.margin_top = 12;

		grid = new Gtk.Grid ();
		grid.margin_top = 1;

		grid.attach (stack_switcher, 0, 0, 1, 1);
		grid.attach (stack, 0, 1, 1, 1);

		grid.show_all ();
		return grid;
    }

    public override void shown () {
    
    }

    public override void hidden () {
    
    }

    public override void search_callback (string location) {
    
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }

}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Applications plug");
    var plug = new ApplicationsPlug ();
    return plug;
}