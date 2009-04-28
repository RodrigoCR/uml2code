#!/usr/bin/python
# -*- coding: utf8 -*-

## Example of how to load information into a GtkUmlLayout:

# Helpers
from shared_utils import *

# Custom Gtk Widgets
from GtkUmlClassWidget import GtkUmlClassWidget

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
