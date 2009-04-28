#!/usr/bin/python
# -*- coding: utf8 -*-

import sys
from xml.dom.minidom  import Document

class Widget2xml():
	def writexml(umlayout,filename):
		doc=Document()
		for clas in umlayout.get_clases():
			print "clase: "+clas["name"]+ " subclass of "+ clas["super_class"]
			for att in clas[attributes]:
				print  att["name"]+att["ac_mod"]+att["type"]+att["signature"]
			for met in clas["methods"]:
				print "metodo: "+ met["name"]+met["ac_mod"]+met["type"]+met["signature"]
				for par in met["param"]:
					print "con para metro: " +par["type"]+par["name"]
