#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk

# Custom Gtk Widgets
from GtkAttributeSelectorDialog import GtkAttributeSelectorDialog
from GtkUmlTable import GtkUmlTable

class GtkUmlAttributeTable(GtkUmlTable):

	def __init__(self):
		super(GtkUmlAttributeTable, self).__init__("Atributos:")
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._dialog = GtkAttributeSelectorDialog()
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.connect('add-clicked', self.on_add_clicked)
		
		## End of the initialization code
		
	def on_add_clicked(self, widget, button):
		result = self._dialog.run()
		if result[0]:
			item = result[1]
			self._add_item_dict(item)
