#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import glade

# Helpers
from shared_utils import *

class GtkAttributeSelectorDialog:

	def __init__(self):
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._result = (False, {})
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.glade = glade.XML("GtkAttributeSelectorDialog.glade", "add_attribute_dialog")
		self._window = self.glade.get_widget("add_attribute_dialog")
		self.glade.get_widget("ac_modifier_selector").set_active(0)
		self.glade.signal_autoconnect(self)
		
		self.glade.get_widget("attribute_name_entry").connect("activate", lambda w : self.validate_to_accept())
		
		## End of the initialization code
		
	def on_add_button_clicked(self, widget):
		self.validate_to_accept()
		
		return False	

	def validate_to_accept(self):
		well_formed = True
		item_name = self.glade.get_widget("attribute_name_entry").get_text()
		if (item_name == ""):
			well_formed = False
		item_ac_mod = self.glade.get_widget("ac_modifier_selector").get_active()
		if not item_ac_mod in UmlAttributeAccess.values():
			well_formed = False
		item_type = self.glade.get_widget("attribute_type_entry").get_text()
		if (item_type == ""):
			well_formed = False
		item_signature = item_name
		item = {"name" : item_name, "ac_mod" : item_ac_mod, "type" : item_type, "signature" : item_signature, "index" : -1}	
		self._result = (well_formed, item)
		
		self._window.response(1)
		
		return False
	
	def on_cancel_button_clicked(self, widget):
		self._result = _result = (False, {})
		
		self._window.response(0)
		
		return False
		
	def run(self):
		self.glade.get_widget("attribute_name_entry").set_text("")
		self._window.show_all()
		self._window.run()
		self._window.hide_all()
		return self._result
			
