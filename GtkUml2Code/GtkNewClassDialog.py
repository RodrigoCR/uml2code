#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import glade

# Helpers
from shared_utils import *

class GtkNewClassDialog:

	def __init__(self):
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._result = (False, {})
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.glade = glade.XML("GtkNewClassDialog.glade", "new_class_dialog")
		self._window = self.glade.get_widget("new_class_dialog")
		self.glade.signal_autoconnect(self)
		
		self.glade.get_widget("class_parent_entry").connect("activate", lambda w : self.validate_to_accept())
		self.glade.get_widget("class_name_entry").connect("activate", lambda w : self.validate_to_accept())
		
		## End of the initialization code
		
	def on_add_button_clicked(self, widget):
		self.validate_to_accept()
		
		return False	

	def validate_to_accept(self):
		well_formed = True
		item_name = self.glade.get_widget("class_name_entry").get_text()
		if (item_name == ""):
			well_formed = False
		item_parent = self.glade.get_widget("class_parent_entry").get_text()
		if ((item_parent == "") or (item_parent == "None") or (item_parent == "none")):
			item_parent = None
		item = {"name" : item_name, "parent" : item_parent}	
		self._result = (well_formed, item)
		
		self._window.response(1)
		
		return False
	
	def on_cancel_button_clicked(self, widget):
		self._result = _result = (False, {})
		
		self._window.response(0)
		
		return False
		
	def run(self):
		self.glade.get_widget("class_name_entry").set_text("")
		self.glade.get_widget("class_parent_entry").set_text("None")
		self._window.show_all()
		self._window.run()
		self._window.hide_all()
		return self._result
			
