/***
    Copyright (C) 2013 Julien Spautz <spautz.julien@gmail.com>
	              2014 Akshay Shekher <voldymann666@gmail.com>

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.
***/

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
