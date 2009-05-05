#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk

# Helpers
from shared_utils import *

# Custom Gtk Widgets
from GtkMethodSelectorDialog import GtkMethodSelectorDialog
from GtkUmlTable import GtkUmlTable

class GtkUmlMethodTable(GtkUmlTable):

	def __init__(self):
		super(GtkUmlMethodTable, self).__init__("Métodos:")
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._dialog = GtkMethodSelectorDialog()
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.connect('add-clicked', self.on_add_clicked)
		
		## End of the initialization code
		
	def on_add_clicked(self, widget, button):
		result = self._dialog.run()
		if result[0]:
			item = result[1]
			self._add_item_dict(item)
	
	def get_methods(self):
		methods = []
		for (key,item) in self._items.items():
			methods.append({"name" : item["name"].split(" ")[0], "ac_mod" : item["ac_mod"], "type" : item["type"], "signature" : item["signature"], "params" : parse_method_sig_params(item["signature"])})
		return methods	
				
