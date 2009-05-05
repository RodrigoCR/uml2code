#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import glade

# Helpers
from shared_utils import *

class GtkNewClassDialog:
	
	# Comentario de prueba
	''' 
	ParaVerSi
	Funciona
	'''
	def __init__(self):
		self.glade = glade.XML("GtkNewClassDialog.glade", "new_class_dialog")
		self._window = self.glade.get_widget("new_class_dialog")
		self.glade.signal_autoconnect(self)
		
		## End of the initialization code
		
	def on_add_button_clicked(self, widget):
		self.validate_to_accept()
		return False	

	def validate_to_accept(self):
		well_formed = True
		item_name = self.glade.get_widget("class_name_entry").get_text()
		if (item_name == ""):
			well_formed = False
		return False
	
	def on_cancel_button_clicked(self, widget):
		self._result = _result = (False, {})
		self._window.response(0)
		return False
		
	def run(self):
		self.glade.get_widget("class_name_entry").set_text("")
		self.glade.get_widget("class_parent_entry").set_text("None")
		return self._result
	
	class PruebaDeAnidacion:
	
		#Comentario en clase anidada
		
		def __init__(self):
			self.glade.get_widget("class_name_entry").set_text("")
			self.glade.get_widget("class_parent_entry").set_text("None")
			return self._result
		
		def juega(self,numero,numeral,jajaja):
			hazalgo(0)
			self.ror = 23
