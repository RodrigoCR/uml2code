#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

# Helpers
from shared_utils import *

_default_lines_num = 1
_default_lines_width = 1
_default_lines_separation = 5
_default_line_color = (0,0,0,1)
_default_background_color = (1,1,1,1)

class GtkMultilineSeparatorWidget(gtk.DrawingArea):

	def __init__(self, num_lines = _default_lines_num, width = _default_lines_width, separation = _default_lines_separation, l_color = _default_line_color, b_color = _default_background_color):
		super(GtkMultilineSeparatorWidget, self).__init__()
		
		self.change_properties(num_lines, width, separation, l_color, b_color)
		self.connect("expose_event", self._expose)
	
	def set_num_lines(self, num):
		self._lines_num = num
		
	def get_num_lines(self):
		return self._lines_num		
		
	def set_lines_width(self, width):
		self._lines_width = width
		
	def get_lines_width(self):
		return self._lines_width	
		
	def set_lines_separation(self, separation):
		self._lines_separation = separation
		
	def get_lines_separation(self):
		return self._lines_separation
		
	def set_line_color(self, color):
		self._line_color = color
		
	def get_line_color(self):
		return self._line_color	
		
	def set_background_color(self, color):
		self._background_color = color
		
	def get_background_color(self):
		return self._background_color	
		
	def change_properties(self, num_lines = _default_lines_num, width = _default_lines_width, separation = _default_lines_separation, l_color = _default_line_color, b_color = _default_background_color):
		self.set_num_lines(num_lines)
		self.set_lines_width(width)
		self.set_lines_separation(separation)
		self.set_line_color(l_color)
		self.set_background_color(b_color)	
	
	def _expose(self, widget, event):
	
		# Calculate size
		full_separation = self.get_lines_separation() + self.get_lines_width()
		full_height = (self.get_num_lines() + 1) * full_separation
		
		# Resizing 
		self.set_size_request(0, full_height)
		
		# Get Cairo context for drawing
		context = widget.window.cairo_create()
		
		# Paint the background
		rect = self.get_allocation()
		make_current_color(context, self.get_background_color())
		context.rectangle(0, 0, rect.width, rect.height)
		context.fill()

		# Unpack line_color to the current cairo context
		make_current_color(context, self.get_line_color())
		
		# Set cairo line_width
		context.set_line_width(self.get_lines_width())	
		
		# Draw lines
		y = 0
		
		for line in range(0, self._lines_num):
			y += full_separation
			context.move_to(0,y)
			context.rel_line_to(rect.width,0)
			context.stroke()
 
		return False			
