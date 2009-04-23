#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

class GtkPaddedSingleContainer(gtk.Table):

	def __init__(self, widget, padding):
		super(GtkPaddedSingleContainer, self).__init__(1, 1, True)
		self.attach(widget, 0, 1, 0, 1, xpadding=padding, ypadding=padding)
		
