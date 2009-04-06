#!/usr/bin/env python

import pygtk
pygtk.require("2.0")
import gtk

class ProyectospApp(object):
	def __init__(self):
		builder = gtk.Builder()
		builder.add_from_file("proyectosp.xml")
		builder.connect_signals({ "on_window_destroy" : gtk.main_quit })
		self.window = builder.get_object("window1")
		#print (self.window)
		self.window.show()
		
if __name__ == "__main__":
	app = ProyectospApp()
	gtk.main()
