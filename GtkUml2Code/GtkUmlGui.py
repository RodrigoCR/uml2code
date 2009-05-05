#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import glade

# Helpers
from shared_utils import *
from loadWriteSource import *
from recurSearch import *
from xmlUtil import *

# Custom Gtk Widgets
from GtkNewClassDialog import GtkNewClassDialog
from GtkUmlLayout import GtkUmlLayout

class GtkUmlGui:

	def __init__(self):
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		self.glade = glade.XML("GtkUmlGui.glade", "mainWindow")
		self._window = self.glade.get_widget("mainWindow")
		self._vbox = self.glade.get_widget("vbox1")
		self.glade.signal_autoconnect(self)
		
		## End of the initialization code
		
	def clear(self):
		self.umlLayout.hide_all()
		self.viewport.remove(self.umlLayout)
		self.umlLayout = GtkUmlLayout()
		self.viewport.add(self.umlLayout)
		self.sc.show_all()				
		
	def run(self):
		self._window.set_size_request(600,600)
		self.sc = gtk.ScrolledWindow()
		self.sc.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		self.umlLayout = GtkUmlLayout()
		#loadSourceFiles("./bin",".",".py")
		load(self.umlLayout, "")
		self.viewport = gtk.Viewport()
		self.viewport.add(self.umlLayout)
	 	self.sc.add(self.viewport)
		self._vbox.add(self.sc)
		self._window.connect("destroy", gtk.main_quit)
		self._window.show_all()
		gtk.main()
		
	def on_addClassMenuItem_activate(self, widget):
		result = GtkNewClassDialog().run()
		if result[0]:
			item = result[1]
			self.umlLayout.add_new_class(item["name"],item["parent"])
			
	def on_newUmlMenuItem_activate(self, widget):
		clear()
		
	def on_loadJavaMenuItem_activate(self, widget):
		dialog = gtk.FileChooserDialog("Selecciona el directorio raíz del proyecto de Java a cargar", self._window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
		response = dialog.run()
		dialog.hide_all()
		if (response == gtk.RESPONSE_ACCEPT):
			loadSourceFiles("./bin/scanner_codeJava",dialog.get_filename(),".java" )
			self.clear()
	  		load(self.umlLayout, "")
	  		
	def on_loadPythonMenuItem_activate(self, widget):
		dialog = gtk.FileChooserDialog("Selecciona el directorio raíz del proyecto de Python a cargar", self._window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT, gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
		response = dialog.run()
		dialog.hide_all()
		if (response == gtk.RESPONSE_ACCEPT):
			loadSourceFiles("./bin/scanner_codepy",dialog.get_filename(),".py" )
			self.clear()
	  		load(self.umlLayout, "") 		
		
	def on_quitMenuItem_activate(self, widget):
		gtk.main_quit()	
