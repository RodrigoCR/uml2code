#!/usr/bin/python
# -*- coding: utf8 -*-

import sys
from xml.dom.minidom  import parse, parseString
from xml.dom.minidom  import Document
from WriteXml import *

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
import Widget2xml


from GtkUmlLayout import  GtkUmlLayout


class clase():
    def _init_ (self,name,accesmod,Lvar ,Lmethod,innerclass,extends ):
        self.name=name
        self.accesmod=accesmod
        self.Lvar=Lvar
        self.Lmethod=Lmethod
        self.Linnerclass=innerclass
	self.extends=extends
class method():
    def _init_ (self,name,accesmod,ret, Largument):
        self.name=name
        self.accesmod=accesmod
        self.ret=ret
        self.Largument=Largument
class variable():
    def _init_(self, name, accesmod, vtype):
        self.name=name
        self. accesmode=accesmod
        self.vtype=vtype
class argument():
    def _init_(self,type,name):
        self.type=type
        self.name=name


def argumentHandle(node):
    m=[]
    l=argument()
    for child in node.childNodes:
        if child.firstChild != None:
            print child.firstChild.nodeValue
            if child.nodeName=='type':
                l.type=child.firstChild.nodeValue
            if child.nodeName=='name':
                l.name=child.firstChild.nodeValue
    m.append(l)
    return l

def methodHandle(node):
    m=[]
    l=method()
    Larg=[]
    for child in node.childNodes:
        if child.firstChild != None:
            print child.firstChild.nodeValue
            if child.nodeName=='accesmod':
                l.accesmod=child.firstChild.nodeValue
            if child.nodeName=='name':
                l.name=child.firstChild.nodeValue
            if child.nodeName=='return':
                l.ret=child.firstChild.nodeValue
            if child.nodeName=='argument':
                Larg.append(argumentHandle(child))
    m.append(l)
    l.Largument=Larg
    return l
  
def varHandle(node):
    v=[]
    l=variable()
    for child in node.childNodes:
        if child.firstChild != None:
            print child.firstChild.nodeValue
            if child.nodeName=='name':
                l.name=child.firstChild.nodeValue
            if child.nodeName=='accesmod':
                l.accesmod=child.firstChild.nodeValue
            if child.nodeName=='type':
                l.vtype=child.firstChild.nodeValue
    v.append(l)
    return l

def classHandle(node):
    Lvar=[]
    Lmethod=[]
    Lclases=[]
    Linner=[]
    c=clase()
    c.accesmod=None
    c.Linnerclass=None
    c.Lmethod=None
    c.Lvar=None
    c.name=None
    c.extends=None
    for child in node.childNodes:
        if child.firstChild != None:
            print child.firstChild.nodeValue
            if child.nodeName=='class':
                Linner= classHandle(child)
                c.Linnerclass=Linner
            if child.nodeName=='accesmod':
                c.accesmod=child.firstChild.nodeValue
            if child.nodeName=='var':
                Lvar.append( varHandle(child))
                c.Lvar=Lvar
            if child.nodeName=='method':
                Lmethod.append(methodHandle(child))
                c.Lmethod=Lmethod     
            if child.nodeName=='extends':
                c.extends=child.firstChild.nodeValue 
            if child.nodeName =='name':
                c.name=child.firstChild.nodeValue
    Lclases.append(c)
    return Lclases


def loadxml(umlW,xml):
	dom=parse(xml)
	for child in dom.childNodes :
		if child.tagName=='class':
			return classHandle(child)



def loadclass(widget, lista,outer):
    for c in lista :
        clas=clase()
        clas=c
	cw=GtkUmlClassWidget(clas.name)
	if clas.Lmethod!=None:
	        for m in clas.Lmethod:
	            mm=method()
	            mm=m
	            
	            
	            print mm.accesmod
	            print mm.name
	            print mm.ret
	            listtuples=[]
	            for arg in mm.Largument:
			a=argument()
			a=arg
			listtuples.append((a.type,a.name))
			print a.name
			print a.type
	            cw.add_method(UmlAttributeAccess[mm.accesmod],mm.ret,mm.name,listtuples)

	if clas.Lvar!=None:
	        for v in clas.Lvar:
	            vv=variable()
	            vv=v
	            cw.add_attribute(UmlAttributeAccess[vv.accesmod],vv.vtype,vv.name)
	            print vv.accesmod
	            print vv.name
	            print vv.vtype
	if outer==None:
		widget.add_class(cw,super_class=clas.extends )	#Superclases added first
	if outer!=None:
		widget.add_class(cw,super_class=clas.extends,outer_class=outer )	#Superclases added first		
        if clas.Linnerclass!=None:
            		loadclass( widget,clas.Linnerclass,clas.name)
        print clas.accesmod
        print clas.name

def load(umlWidget, xml):
	lclass=[]
	lclass=loadxml(umlWidget,"algo1.xml")
	loadclass(umlWidget, lclass,None)

	lclass=[]
	lclass=loadxml(umlWidget,"algo2.xml")
	loadclass(umlWidget, lclass,None)


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
	writexml(umlWidget,"out.xml")
	gtk.main()		
	
	
if __name__ == "__main__":
    main()	
