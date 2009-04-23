#!/usr/bin/python
# -*- coding: utf8 -*-

# GNOME Stack libraries 
import gtk
from gtk import gdk
import gobject

# Custom Gtk Widgets
from GtkAccessModifierButton import GtkAccessModifierButton
from GtkAutoresizableEntry import GtkAutoresizableEntry

class GtkUmlTable(gtk.VBox):

	__gsignals__ = {
			'item-added' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gobject.TYPE_STRING, gobject.TYPE_STRING,  gobject.TYPE_STRING,  gobject.TYPE_STRING,  gobject.TYPE_INT,)),
			'item-deleted' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gobject.TYPE_STRING, gobject.TYPE_STRING,  gobject.TYPE_STRING,  gobject.TYPE_STRING,  gobject.TYPE_INT,)),
			'add-clicked' : (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, (gtk.Widget,))
	}

	def __init__(self, label):
		
		# super().__gobject_init__() required instead of super().__init__() because of self defined signals
		super(GtkUmlTable, self).__gobject_init__()
		
		## We declare and initialize all of the class's instance properties
		# It's important to do this in the constructor and not in the main body of the class. Otherwise those of the which are references will get SHARED AMONG INSTANCES!
		
		self.title_label = gtk.Label()
		self._inner_table = gtk.Table(rows=1, columns=4, homogeneous=False)
		self._add_link = gtk.Button()
		self._items = {}
		self._internal_rebuild = 0 # When > 0, don't propagate item-added or item-deleted signals, it's just internal reordering after all, no one needs to know. Is an integer to allow nested methods to state they are doing an internal rebuild 
		
		## End of instance properties 
		
		## Start of actual initialization code
		
		# Some packing and structure
		hbox = gtk.HBox()
		self.pack_start(hbox, False, False, 0)
		self.title_label.set_markup("<b>" + label + "</b>")
		hbox.pack_start(self.title_label, False, False, 0)
		self.pack_start(self._inner_table, True, True)
		hbox = gtk.HBox()
		self.pack_start(hbox, False, False, 0)
		self._add_link.set_relief(gtk.RELIEF_NONE)
		add_button_label = gtk.Label()
		add_button_label.set_markup("<span color=\"blue\"> Añadir </span>")
		self._add_link.add(add_button_label)
		hbox.pack_end(self._add_link, False, False, 0)
		
		self._add_link.connect('clicked', lambda w : self.emit('add-clicked', w))
		
		## End of the initialization code
	
	def _add_item_dict(self, item):
		# item_name must be unique
		if item["name"] in self._items:
			return False	
	
		# Add the new item to our item list
		self._items[item["name"]] = item
		item["index"] = len(self._items)
		
		# Resize the internal table
		self._inner_table.resize(len(self._items), 4)
		
		# Add the Access Modifier button for the new item
		self._inner_table.attach(GtkAccessModifierButton(item["ac_mod"]), 0, 1, len(self._items) - 1, len(self._items), xoptions=gtk.FILL, yoptions=gtk.FILL)
		
		# Add the type of the item
		type_entry = GtkAutoresizableEntry()
		type_entry.set_text(item["type"])
		type_entry.set_has_frame(False)
		self._inner_table.attach(type_entry, 1, 2, len(self._items) - 1, len(self._items))
		type_entry.connect("changed", self._entry_changed_cb, item["name"], "type")
		
		# Add the signature of the item
		sig_entry = GtkAutoresizableEntry()
		sig_entry.set_text(item["signature"])
		sig_entry.set_has_frame(False)
		self._inner_table.attach(sig_entry, 2, 3, len(self._items) - 1, len(self._items))
		type_entry.connect("changed", self._entry_changed_cb, item["name"], "signature")
		
		# Add delete button
		del_button = gtk.Button()
		del_button.set_relief(gtk.RELIEF_NONE)
		del_button.add(gtk.image_new_from_stock(gtk.STOCK_STOP, gtk.ICON_SIZE_MENU))
		self._inner_table.attach(del_button, 3, 4, len(self._items) - 1, len(self._items), xoptions=gtk.FILL, yoptions=gtk.FILL)
		del_button.connect("clicked", lambda w: self._delete_item(item["name"]))
		
		self._inner_table.show_all()
		
		# We signal that the item was added
		if (self._internal_rebuild == 0):
			self.emit('item-added', item["name"], item["ac_mod"], item["type"], item["signature"], item["index"])	
		
		return True	
		
	def _add_item(self, ac_mod, item_name, item_type, item_signature):
		# Create the item dictionary
		item = {"name" : item_name, "ac_mod" : ac_mod, "type" : item_type, "signature" : item_signature, "index" : -1}	
	
		return self._add_item_dict(item)
	
	def _refresh_table(self):
	
		# Internal rebuild, add_item()'s are not real add_item()'s
		self._internal_rebuild += 1
		
		temp = self._items
		self._items = {}
		self._inner_table.foreach(lambda w : self._inner_table.remove(w))
		self._inner_table.resize(1,4)
		for i in temp:
			self._add_item_dict(temp[i])
		
		# End of internal rebuild	
		self._internal_rebuild -= 1
	
	def _delete_item(self, item_name):
		
		# We save the item to report it via an 'item-deleted' signal
		deleted_item = self._items[item_name]
		
		# We delete the item and rebuild the items table
		del self._items[item_name]
		self._refresh_table()
		
		# We signal that the item was deleted
		if (self._internal_rebuild == 0):
			self.emit('item-deleted', deleted_item["name"], deleted_item["ac_mod"], deleted_item["type"], deleted_item["signature"], deleted_item["index"])	
		
	def _entry_changed_cb(self, widget, item_name, prop_key):
		self._items[item_name][prop_key] = widget.get_text()
		
