import gtk
from gtk import gdk
import gobject
import pango

import math

UmlAttributeAccess = {"public":0,"private":1,"protected":2}

class UmlVariable:
	name = ""
	type = ""
	access = UmlAttributeAccess["public"]
	
	def __init__(self):
		pass

class UmlAttribute(UmlVariable):
	
	def __init__(self):
		UmlVariable.__init__(self)

class GtkUmlTestWidget(gtk.VBox):

	# Subwidgets
	_titleLabel = gtk.Entry()
	_attributesArea =  gtk.Table(rows=1, columns=3, homogeneous=False)
	_methodsArea =  gtk.Table(rows=1, columns=3, homogeneous=False)
	_all_subwidgets = [_titleLabel,_attributesArea,_methodsArea]

	# Class logic properties
	_className = ""
	_classAttributes = []
	_classMethods = []
	_hasSubclases = False
	
	# Class apearance properties (public for now)
	general_border = 5
	area_padding = 10
	multiline_separation_distance = 5
	line_width = 1
	background_color = (1,1,1,1)
	border_color = (0,0,0,1)
	min_height = 200
	min_width = 200
	title_label_extra_char_paddin = 5

	def __init__(self, class_name):
		super(GtkUmlTestWidget, self).__init__()
		
		# Connect some events
		self.connect("expose_event", self._expose)	
		
	def _expose(self, widget, event):
		context = widget.window.cairo_create()
		context.rectangle(event.area.x, event.area.y, event.area.width, event.area.height)
		context.clip()

		self._draw(context)
 
		return False			
	
	def _draw(self, context):
		# Cairo preparations
		context.set_line_width(self.line_width)
		
		def to_background_color(context):
			if (len(self.background_color) == 4):
				(r, g, b, a) = self.background_color
				context.set_source_rgba(r, g, b, a)
			else:
				if (len(self.background_color) == 3):
					(r, g, b) = self.background_color
					context.set_source_rgb(r, g, b)
				else:
					context.set_source_rgb(1, 1, 1)	
					
		def to_border_color(context):
			if (len(self.border_color) == 4):
				(r, g, b, a) = self.border_color
				context.set_source_rgba(r, g, b, a)
			else:
				if (len(self.border_color) == 3):
					(r, g, b) = self.border_color
					context.set_source_rgb(r, g, b)
				else:
					context.set_source_rgb(0, 0, 0)					
		
		# Draw the outer rectangular border
		rect = self.get_allocation()
		to_background_color(context)
		context.rectangle(rect.x, rect.y, rect.width, rect.height)
		context.fill()
		sx = rect.x + self.general_border
		sy = rect.y + self.general_border
		ex = rect.width - 2*self.general_border
		ey = rect.height - 2*self.general_border
		to_border_color(context)
		context.rectangle(sx, sy, ex, ey)
		context.stroke()
		
def main():
	window = gtk.Window()
	umlWidget = GtkUmlTestWidget("My Class")
 
	window.add(umlWidget)
	window.connect("destroy", gtk.main_quit)
	window.show_all()
	
	gtk.main()		
	
if __name__ == "__main__":
    main()	
