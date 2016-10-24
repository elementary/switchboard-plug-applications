/*
* Copyright (c) 2013-2016 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
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
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*              Julien Spautz <spautz.julien@gmail.com>
*/

public class Startup.Plug {

    Controller controller;

    public Plug () {
        Backend.KeyFileFactory.init ();
    }

    public  Gtk.Widget get_widget () {
        if (controller == null) {
            var monitor = new Backend.Monitor ();
            var view = new Widgets.Scrolled ();
            view.show_all ();
            controller = new Controller (view, monitor);
        }
        
        return controller.view as Gtk.Widget;
    }

    public async Gee.TreeMap <string, string> search (string search) {
        return new Gee.TreeMap <string, string> (null, null);
    }
}
