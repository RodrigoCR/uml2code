#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import glade

# Helpers
from shared_utils import *

class GtkMethodSelectorDialog:

	def __init__(self):
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._result = (False, {})
		self._param_entries = []
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.glade = glade.XML("GtkMethodSelectorDialog.glade", "add_method_dialog")
		self._window = self.glade.get_widget("add_method_dialog")
		self._param_table = self.glade.get_widget("param_table")
		self.glade.get_widget("ac_modifier_selector").set_active(0)
		
		self.glade.signal_autoconnect(self)
		
		## End of the initialization code
		
	def validate_to_accept(self):	
		well_formed = True
		item_name = self.glade.get_widget("method_name_entry").get_text()
		if (item_name == ""):
			well_formed = False
		item_ac_mod = self.glade.get_widget("ac_modifier_selector").get_active()
		if not item_ac_mod in UmlAttributeAccess.values():
			well_formed = False
		item_type = self.glade.get_widget("method_type_entry").get_text()
		if (item_type == ""):
			well_formed = False
			
		# Unique name
		# A method's unique name is a combination of its name and the TYPES of its parameters, but not the parameter's names.
		item_unique_name = item_name	
		# The method's signature is its name followed by (, followed by the list of parameters, followed by )
		# Incorrect or incomplete parameters should be invalidated, but the method will still be considered well_formed. Its signature will be returned sans the invalid parameters.
		append_coma = False
		item_signature = item_name + "("
		for i in range(0,len(self._param_entries)):
			(param_e_type, param_e_name) = self._param_entries[i]
			param_type = param_e_type.get_text()
			param_name = param_e_name.get_text()
			if not (param_type == "" or param_name == ""):
				item_unique_name += " " + param_type
				if append_coma:
					item_signature += ", " + param_type + " " + param_name
				else:
					append_coma = True
					item_signature += param_type + " " + param_name
		item_signature += ")"
		
		item = {"name" : item_unique_name, "ac_mod" : item_ac_mod, "type" : item_type, "signature" : item_signature, "index" : -1}	
		self._result = (well_formed, item)
		
		self._window.response(1)

	def on_add_button_clicked(self, widget):
		self.validate_to_accept()
		
		return False
	
	def on_cancel_button_clicked(self, widget):
		self._result = _result = (False, {})
		
		self._window.response(0)
		
		return False
	
	def on_param_entry_changed(self, widget, idx):
		if idx == len(self._param_entries) - 1:
			self.add_param()
			
	def on_add_param_button_clicked(self, widget):
		self.add_param()
	
	def add_param(self):
		self._param_entries.append((gtk.Entry(), gtk.Entry()))
		i = len(self._param_entries) - 1
		self._param_table.resize(len(self._param_entries) + 1, 2)
		self._param_table.attach(self._param_entries[i][0], 0, 1, len(self._param_entries), len(self._param_entries) + 1, xpadding = 5, ypadding = 2)
		self._param_table.attach(self._param_entries[i][1], 1, 2, len(self._param_entries), len(self._param_entries) + 1, xpadding = 5, ypadding = 2)
		self._param_entries[i][1].connect("changed", self.on_param_entry_changed, i)
		for e in self._param_entries[i]: 
			e.set_has_frame(False)
			e.connect("activate", lambda w : self.validate_to_accept())
		self._param_table.show_all()
			
	def run(self):
		self._param_table.resize(1, 2)
		self.add_param()
		self._window.show_all()
		self._window.run()
		self._window.hide_all()
		self.glade.get_widget("method_name_entry").set_text("")
		for p in self._param_entries: 
			for e in p:
				self._param_table.remove(e)
		self._param_entries = []
		return self._result
			
