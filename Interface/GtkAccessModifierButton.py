#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

access_mods = ["+", "-", "#"]

class GtkAccessModifierButton(gtk.Button):

	def __init__(self, ac = 0):
		super(GtkAccessModifierButton, self).__init__()
	
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self._ac = 0
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.set_relief(gtk.RELIEF_NONE)
		self._ac = ac
		self.set_label(access_mods[ac])
		self.connect("clicked", self._acButtonClicked)
		self.connect("enter", lambda widget: True)
		
		## End of the initialization code
		
	def _acButtonClicked(self, widget):
		self._ac = (self._ac + 1) % len(access_mods)
		self.set_label(access_mods[self._ac])	
		
		return False
