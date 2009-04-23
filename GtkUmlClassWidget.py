#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject
import pango

# Other external libraries
import math

# Helpers
from shared_utils import *

# Custom Gtk Widgets
from GtkMultilineSeparatorWidget import GtkMultilineSeparatorWidget
from GtkAutoresizableEntry import GtkAutoresizableEntry
from GtkPaddedSingleContainer import GtkPaddedSingleContainer
from GtkUmlAttributeTable import GtkUmlAttributeTable
from GtkUmlMethodTable import GtkUmlMethodTable


class GtkUmlClassWidget(gtk.HBox):

	__gsignals__ = {
			'class-changed' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gobject.TYPE_OBJECT,))
	}
	
	# Class appearance properties
	general_border = 5
	area_padding = 10
	multiline_lines = 3
	multiline_separation_distance = 5
	line_width = 1
	background_color = (1,1,1,1)
	border_color = (0,0,0,1)

	def __init__(self, class_name):
		super(GtkUmlClassWidget, self).__gobject_init__()
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		# Subwidgets
		self._inner_box = gtk.VBox()
		self._titleLabel = GtkAutoresizableEntry()
		self._attributesArea =  GtkUmlAttributeTable()
		self._methodsArea =  GtkUmlMethodTable()
		self.itemAreas = [self._attributesArea, self._methodsArea]
		self._all_subwidgets = [self._titleLabel, self._attributesArea, self._methodsArea] # Only functional widgets, not padding (inner_box), nor decoration (multilines)
		self._below_title_separator = GtkMultilineSeparatorWidget()
		self._between_attributes_methods_separator = GtkMultilineSeparatorWidget()
		self._between_methods_subclases_separator = None # Should be created only as subclases are added
		self._subclases_area = None
		self._all_separators = [self._below_title_separator, self._between_attributes_methods_separator, self._between_methods_subclases_separator]
		self._non_title_separators = [self._between_attributes_methods_separator, self._between_methods_subclases_separator]

		# Class logic properties
		self.className = class_name
		self.classSuperClass = None
		self.classAttributes = self._attributesArea._items
		self.classMethods = self._methodsArea._items
		self.hasSubclases = False
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		# Inner box for the widget border
		self.pack_start(self._inner_box, padding = self.general_border + 1)
		
		# Title label and its decorations
		self._titleLabel.set_text(self.className)
		self._titleLabel.set_has_frame(False)
		self._inner_box.pack_start(GtkPaddedSingleContainer(self._titleLabel, self.area_padding), False, padding = 0)
		self._below_title_separator.change_properties(self.multiline_lines, self.line_width, self.multiline_separation_distance, self.border_color, self.background_color)
		self._inner_box.pack_start(self._below_title_separator, False, padding = 0)
		
		# Attributes table and its decorations
		self._inner_box.pack_start(GtkPaddedSingleContainer(self._attributesArea, self.area_padding), padding = 0)
		self._between_attributes_methods_separator.change_properties(1, self.line_width, self.multiline_separation_distance, self.border_color, self.background_color)
		self._inner_box.pack_start(self._between_attributes_methods_separator, False, padding = 0)
		
		# Methods table and its decorations
		self._inner_box.pack_start(GtkPaddedSingleContainer(self._methodsArea, self.area_padding), padding = self.area_padding)
		
		# Connect some events
		self.connect("expose_event", self._on_expose)
		self.connect("size-allocate", self._on_size_allocate)
		for a in self.itemAreas:
			a.connect('item-added', lambda w, s1, s2, s3, s4, i1 : self.emit('class-changed', a))
			a.connect('item-deleted', lambda w, s1, s2, s3, s4, i1 : self.emit('class-changed', a))
		
		## End of the initialization code
		
	def _on_expose(self, widget, event):
		context = widget._inner_box.window.cairo_create()
		context.rectangle(event.area.x, event.area.y, event.area.width, event.area.height)
		context.clip()

		self._draw(context)
 
		return False		
	
	# To ensure the border and contained elements are redrawn when the widget is resized	
	def _on_size_allocate(self, widget, allocation):
		self.queue_draw() # Will send an "expose_event" as soon as reasonable, will perhaps do some other things. 
 
		return False		
	
	def _draw(self, context):
	
		# Cairo preparations
		context.set_line_width(self.line_width)				
		
		# Draw the outer rectangular border
		rect = self.get_allocation()
		make_current_color(context, self.background_color)
		context.rectangle(rect.x, rect.y, rect.width, rect.height)
		context.fill()
		sx = rect.x + self.general_border
		sy = rect.y + self.general_border
		ex = rect.width - 2*self.general_border
		ey = rect.height - 2*self.general_border
		make_current_color(context, self.border_color)
		context.rectangle(sx, sy, ex, ey)
		context.stroke()

	def add_subclass(self, widget, super_class = None, outer_class = None):
		if(self.hasSubclases == False):
			if(outer_class == self.className or outer_class == None):
				self.hasSubclases = True
				self._between_methods_subclases_separator = GtkMultilineSeparatorWidget()
				self._subclases_area = GtkUmlLayout()
				self._inner_box.pack_start(self._between_methods_subclases_separator, False, padding = 0)
				self._between_methods_subclases_separator.show()
				self._inner_box.pack_start(GtkPaddedSingleContainer(self._subclases_area, self.area_padding), padding = self.area_padding)	
				self._subclases_area.connect('class-added', lambda w1, w2, s1, s2 : self.emit('class-changed', self._subclases_area))
				self._subclases_area.add_class(widget, super_class)
				self._subclases_area.show_all()
			else:
				return	
		else:
			if(outer_class == self.className):
				self._subclases_area.add_class(widget, super_class, None)
			else:
				self._subclases_area.add_class(widget, super_class, outer_class)
			return
			
	def add_attribute(self, ac_mod, att_type, name):
		# Create the item dictionary
		attribute = {"name" : name, "ac_mod" : ac_mod, "type" : att_type, "signature" : name, "index" : -1}	
	
		return self._attributesArea._add_item_dict(attribute)	
		
	def add_method(self, ac_mod, method_type, name, params):
		# unique_name is a unique method identifier derived from the method's name and TYPEs (but not names) of its parameters.
		unique_name = name
		
		# The method's signature is its name followed by (, followed by the list of parameters, followed by )
		append_coma = False
		signature = name + "("
	
		# We unpack the parameters to construct the signature and methods unique_name
		for (t, n) in params:
			unique_name += " " + t
			if append_coma:
				signature += ", " + t + " " + n
			else:
				append_coma = True
				signature += t  + " " + n
		
		signature += ")"		
			
		# Create the item dictionary
		method = {"name" : unique_name, "ac_mod" : ac_mod, "type" : method_type, "signature" : signature, "index" : -1}	
	
		return self._methodsArea._add_item_dict(method)		
		
def main():
	window = gtk.Window()
	umlWidget = GtkUmlClassWidget("My Class")
 
	window.add(umlWidget)
	window.connect("destroy", gtk.main_quit)
	window.show_all()
	
	gtk.main()		
	
if __name__ == "__main__":
    main()	
    
from GtkUmlLayout import GtkUmlLayout    
