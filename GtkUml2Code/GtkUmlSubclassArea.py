#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

from GtkUmlLayout import * 
from GtkNewClassDialog import GtkNewClassDialog 

class GtkUmlSubclassArea(gtk.VBox):


	def __init__(self, umllayout):
		
		# super().__gobject_init__() required instead of super().__init__() because of self defined signals
		super(GtkUmlSubclassArea, self).__init__()
		
		self.inner_area = umllayout
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._add_link = gtk.Button()
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		# Some packing and structure
		hbox = gtk.HBox()
		self.pack_start(hbox, False, False, 0)
		self.pack_start(self.inner_area, True, True)
		hbox = gtk.HBox()
		self.pack_start(hbox, False, False, 0)
		self._add_link.set_relief(gtk.RELIEF_NONE)
		add_button_label = gtk.Label()
		add_button_label.set_markup("<span color=\"blue\"> Añadir </span>")
		self._add_link.add(add_button_label)
		hbox.pack_end(self._add_link, False, False, 0)
		
		self._add_link.connect('clicked', self.on_add_clicked)
		
		## End of the initialization code
		
	def on_add_clicked(self, widget):
		result = GtkNewClassDialog().run()
		if result[0]:
			item = result[1]
			self.inner_area.add_new_class(item["name"],item["parent"])
