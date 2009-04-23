#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

# Other external libraries
import math
import time
from copy import copy

# Helpers
from shared_utils import *

# Custom Gtk Widgets
from GtkUmlClassWidget import GtkUmlClassWidget

"""
A layout derived widget that allows widgets to be dragged around and zoomed in and out
"""

class GtkUmlLayout(gtk.Layout):

	__gsignals__ = {
			'class-added' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gobject.TYPE_OBJECT, gobject.TYPE_STRING,  gobject.TYPE_STRING,)),
			'size-changed' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gobject.TYPE_INT,  gobject.TYPE_INT, gobject.TYPE_INT,  gobject.TYPE_INT,))
	}

	# Class appearance properties
	_background_color = (1,1,1,1)
	_line_color = (0,0,0,0.5)
	_drag_handle = None
	_border_padding = 10
	_inter_widget_padding = 20
	_inter_widget_push_innertia = 50
	_row_separation = 200
	_column_separation = 200

	def __init__(self):
		super(GtkUmlLayout, self).__gobject_init__()
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self.class_grid = [[]]
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		# Lets make the background the right color:
		bg = map(lambda c: abs(c*65535),self._background_color)
		self.modify_bg(gtk.STATE_NORMAL, gdk.Color(red=bg[0], green=bg[1], blue=bg[2]))
		
		# Some important events are masked out in gtk.Layout, we need to reactivate such events so that we might connect our handlers to trap them. 
		self.add_events(gdk.BUTTON_RELEASE_MASK | gdk.POINTER_MOTION_MASK)
		
		# Connect some events
		by_ref_handler = []
		by_ref_handler.append(self.connect("expose_event", self._on_first_expose, by_ref_handler)) # Black magic! ;)
		self.connect("expose_event", self._on_expose)
		self.connect("size-allocate", self._on_size_allocate)
		#self.connect("scroll-event", self._on_scroll) # NO SCALING FOR YOU!
		self.connect("button-press-event", self._on_button_press)
		self.connect("button-release-event", self._on_button_release)
		
		## End of the initialization code
		
	def _on_first_expose(self, widget, event, own_handler):
		next_y = self._border_padding
		for row in self.class_grid:
			next_x = self._border_padding
			max_row_height = 0
			for w in row:
				self.move(w, next_x, next_y)
				rect = w.get_allocation()
				next_x += self._column_separation + rect.width	
				max_row_height = max(max_row_height, rect.height)
			next_y += self._row_separation + max_row_height
		self._first_expose_happened = True 
		self.disconnect(own_handler[0])
		
		return False
		
	def _on_expose(self, widget, event):
		# Resize
		rect = self.get_allocation()
		x0 = x = rect.width
		y0 = y = rect.height
		for child in widget.get_children():
			rect = child.get_allocation()
			x = max(x, rect.x + rect.width + self._border_padding)
			y = max(y, rect.y + rect.height + self._border_padding)
		if not (x0 == x and y == y0):
			self.set_size_request(x,y)
	
		# And redraw
		context = widget.bin_window.cairo_create()
		context.rectangle(event.area.x, event.area.y, event.area.width, event.area.height)
		context.clip()

		self._draw(context)
 
		return False		
	
	# To ensure the border and contained elements are redrawn when the widget is resized	
	def _on_size_allocate(self, widget, allocation):
		self.queue_draw() # Will send an "expose_event" as soon as reasonable, will perhaps do some other things. 
 
		return False	
		
	def _draw_arrow(self, context, start, end):
		make_current_color(context, self._line_color)
		
		context.move_to(end['x'],end['y'])
		context.rel_line_to(-5,10)
		context.rel_line_to(10,0)
		context.close_path()
		context.fill()
		
		context.move_to(start['x'],start['y'])
		context.line_to(end['x'],end['y'] + 10)
		context.stroke()	
	
	def _draw(self, context):
	
		# Draw a white area (where "white := self.background_color")
		# No longer needed, thanks to gtk.Layout.modify_bg
		"""rect = self.get_allocation()
		make_current_color(context, self._background_color)
		context.rectangle(rect.x, rect.y, rect.width, rect.height)
		context.fill()"""
		
		# Draw the lines between clases
		for widget in self.get_children():
			s_class = widget.classSuperClass
			if (s_class == None):
				continue
			rect_w = widget.get_allocation()
			rect_s = s_class.get_allocation()
			start = {}
			end = {}
			start['x'] = rect_w.x + (rect_w.width / 2)
			start['y'] = rect_w.y
			end['x'] = rect_s.x + (rect_s.width / 2)
			end['y'] = rect_s.y + rect_s.height
			self._draw_arrow(context, start, end)
		
	def _on_button_press(self, widget, event):
		x = event.x
		y = event.y
		for child in widget.get_children():
			rect = child.get_allocation()
			if (x < rect.x) or (x > (rect.x + rect.width)):
				continue
			if (y < rect.y) or (y > (rect.y + rect.height)):
				continue
			x_adj = rect.x - x
			y_adj = rect.y - y
			self._drag_handle = self.connect("motion-notify-event", self._on_dragging_child, child, x_adj, y_adj, rect.width, rect.height)
			break	
		
		return True	 # We return True in order to mask the event from all but the innermost GtkUmlLayout involved, funky stuff happens otherwise
		
	def _on_button_release(self, widget, event):
		if(self._drag_handle != None):
			self.disconnect(self._drag_handle)
		self._drag_handle = None
		
		return True  # We return True in order to mask the event from all but the innermost GtkUmlLayout involved, funky stuff happens otherwise
		
	def _rect_intersect(self, rect1, rect2):
		if(rect1[0] > rect2[2]):
			return False
		if(rect1[2] < rect2[0]):
			return False
		if(rect1[1] > rect2[3]):
			return False
		if(rect1[3] < rect2[1]):
			return False
		return True		 
	
	def _try_move(self, child, x, y):
		original = child.get_allocation()
		
		# Moving outside the left border is simulated by moving every other widget to the right
		if(x < self._border_padding):
			displ_x = self._border_padding - x
			x = self._border_padding
			for c in self.get_children():
				if (c == child):
					continue
				rect = c.get_allocation()	
				self.move(c, rect.x + displ_x, rect.y)	
			
		# Similarly for the top		
		if(y < self._border_padding):
			displ_y = self._border_padding - y
			y = self._border_padding
			for c in self.get_children():
				if (c == child):
					continue
				rect = c.get_allocation()	
				self.move(c, rect.x, rect.y + displ_y)
		
		# Lets make the widgets push each others:
		# THIS CODE IS UGLY AS SIN, REFACTOR AS SOON AS REASONABLE
		last_x = x + original.width
		last_y = y + original.height
		for c in self.get_children():
			if (c == child):
				continue
			rect = c.get_allocation()
			rect_last_x = rect.x + rect.width
			rect_last_y = rect.y + rect.height
			if self._rect_intersect((x,y,last_x,last_y),(rect.x - self._inter_widget_padding, rect.y - self._inter_widget_padding, rect_last_x + self._inter_widget_padding, rect_last_y + self._inter_widget_padding)):
				if((last_x > rect.x) and (rect_last_x > x)):
					if(y > rect.y):
						self._try_move(c, rect.x, y - self._inter_widget_padding - rect.height - self._inter_widget_push_innertia)
					else:
						self._try_move(c, rect.x, last_y + self._inter_widget_padding + self._inter_widget_push_innertia)	
				else:	
					if(x > rect.x):
						self._try_move(c, x - self._inter_widget_padding - rect.width - self._inter_widget_push_innertia, rect.y)
					else:
						self._try_move(c, last_x + self._inter_widget_padding + self._inter_widget_push_innertia, rect.y)		
			
		self.move(child, x, y)
	
	def _on_dragging_child(self, widget, event, child, x_adj, y_adj, width, height):
		self._try_move(child, event.x + x_adj, event.y + y_adj)
		
		return False		
		
	def _on_child_size_allocate(self, widget, allocation):
		current_size = (allocation.width, allocation.height)
		
		# We avoid repositioning if it's the first time the widget is allocated an area for drawing. The checks in add_class and on_first_expose should position it well and this only messes things up. A LOT. So please don't delete the next if ;)
		if (widget.in_layout_last_size == (0,0)):
			widget.in_layout_last_size = current_size
			return False
			
		if (widget.in_layout_last_size != current_size):
			widget.in_layout_last_size = current_size
			self._try_move(widget, allocation.x, allocation.y)
		
		return False
		
	def add_class(self, widget, super_class = None, outer_class = None):
		#print widget.className, " super:", super_class, "inside:", outer_class
	
		self.emit("class-added", widget, super_class, outer_class)
		
		if(outer_class != None):
			for w in self.get_children():
				w.add_subclass(widget, super_class, outer_class)
			return
			
		grid = self.class_grid
		row = grid[0]
		next_y = self._border_padding
		next_x = self._border_padding
		
		if(super_class != None):
			for r in range(0,len(grid)):
				row1 = grid[r]
				for w in row1:
					if(w.className == super_class):
						row_bottom = 0
						widget.classSuperClass = w
						for w1 in row1:
							rect = w1.get_allocation()
							row_bottom = max(row_bottom, rect.y + rect.height)
						if(r + 1 == len(grid)):
							grid.append([])
						row = grid[r+1]							
		
		# If the class has no super class and is not an inner class, put it at the top, next to the last such class
		if(len(row) > 0):
			prev = row[-1]
			rect_prev = prev.get_allocation()
			next_x += rect_prev.x + rect_prev.width
		self.put(widget, next_x, next_y)	
		row.append(widget)
		widget.show()
		
		widget.in_layout_last_size = (0,0)
		widget.connect("size-allocate", self._on_child_size_allocate)
		
def load(umlWidget, xml):
	# Class, method and attribute loading example. Currently it's all hardcoded, please modify to have all the data loaded from the project's xml format
	
	# Create a Class: GtkUmlClassWidget(ClassName)
	umlClassWidget = GtkUmlClassWidget("My Class")
	
	# Add an attribute: my_class.add_attribute(accessModifier, type, name)
	# Where accessModifier can be: UmlAttributeAccess["public" | "private" | "protected"]
	umlClassWidget.add_attribute(UmlAttributeAccess["public"],"int","id")
	umlClassWidget.add_attribute(UmlAttributeAccess["public"],"String","nombre")
	umlClassWidget.add_attribute(UmlAttributeAccess["protected"],"long","version_interna")
	
	# Add a method: my_class.add_method(accessModifier, type, name, params)
	# Where params is a python list of tuples containing the type and name: [(parameter_type, parameter_name),...] or []
	umlClassWidget.add_method(UmlAttributeAccess["public"],"int","suma",[("int","sumandoA"),("int","sumandoB")])
	umlClassWidget.add_method(UmlAttributeAccess["public"],"float","suma",[("float","sumandoA"),("float","sumandoB")])
	
	# Finally, we must add our recently created class to the TOPMOST GtkUmlLayout widget.
	# This will be passed as a parameter, together with the xml
	umlWidget.add_class(umlClassWidget)
	
	# More examples follow:
	umlClassWidget = GtkUmlClassWidget("My Class 2")
	umlWidget.add_class(umlClassWidget)
	
	# IMPORTANT - Adding a class with a super class (The super class MUST be added first)
	# EG. My Class 3 is a subclass of My Class
	umlClassWidget = GtkUmlClassWidget("My Class 3")
	umlWidget.add_class(umlClassWidget,super_class="My Class")
	
	umlClassWidget = GtkUmlClassWidget("My Class 7")
	umlWidget.add_class(umlClassWidget,super_class="My Class")
	
	# IMPORTANT - Adding a class with an outer class (The outer class MUST be added first)
	# EG. My Class 4 is an inner class of My Class 2
	umlClassWidget = GtkUmlClassWidget("My Class 4")
	umlWidget.add_class(umlClassWidget,outer_class="My Class 2")
	
	umlClassWidget = GtkUmlClassWidget("My Class 5")
	umlWidget.add_class(umlClassWidget,super_class="My Class 3")
	
	# Two examples with both, super and outer clases
	umlClassWidget = GtkUmlClassWidget("My Class 6")
	umlWidget.add_class(umlClassWidget,super_class="My Class 4",outer_class="My Class 2")
	umlClassWidget = GtkUmlClassWidget("My Class 8")
	umlWidget.add_class(umlClassWidget,super_class="My Class 4",outer_class="My Class 2")
		
def main():
	window = gtk.Window()
	window.set_size_request(600,600)
	sc = gtk.ScrolledWindow()
	sc.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

	
	umlWidget = GtkUmlLayout()
	
	load(umlWidget, "")
 
 	sc.add_with_viewport(umlWidget)
	window.add(sc)
	window.connect("destroy", gtk.main_quit)
	window.show_all()
	
	gtk.main()		
	
if __name__ == "__main__":
    main()			
