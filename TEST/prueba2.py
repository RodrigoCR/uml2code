#!/usr/bin/python
# -*- coding: utf8 -*-

class Persona(object):
	
	edad = 0
	estatura = 0
	amigos = 0
	
	def __init__(self):
		self.edad = 5
		self.estatura = 150
		self.amigos = 1
	
	def cambiaEdad(self,numero):
		self.edad = numero
		
	def imprimeme(self):
		print "Mi edad es: %s\nMi estatura es: %s\nTengo %s amigos" % (self.edad, self.estatura, self.amigos)

class Main:
	def __init__(self):
		rodrigo = Persona()
		rodrigo.cambiaEdad(10)
		rodrigo.imprimeme()
		
init = main()
