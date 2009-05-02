#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject
import pango

class GtkAutoresizableEntry(gtk.Entry):

	def __init__(self, char_padding = 2):
		super(GtkAutoresizableEntry, self).__init__()
		
		self._char_padding = char_padding
		self.connect("changed", self._insertHandle)	

	def _insertHandle(self, widget):
		self.set_width_chars(len(widget.get_text()) + self._char_padding)
		
		return False
