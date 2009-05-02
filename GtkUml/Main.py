#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

# Custom Gtk Widgets
from GtkUmlGui import GtkUmlGui


def main():
	GtkUmlGui().run()	
	
	
if __name__ == "__main__":
    main()	
