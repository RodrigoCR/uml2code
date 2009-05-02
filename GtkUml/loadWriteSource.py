'''
Created on Apr 30, 2009

@author: carlos
'''
import recurSearch

def loadSourceFiles(pathexecutable,dir,extention):#path es la direccion del ejecutable con todo y nombre que lee el codigo y lo convierte a xml
    for file in recurSearch.searchext(dir,extention):
        recurSearch.executeParser(pathexecutable,file, extention)
def xml2code(pathexecutable,dir,extention):#path es la direccion del ejecutable que lee xml y lo convierte a codigo
    for file in recurSearch.searchext(dir,extention):
        recurSearch.executeParser(pathexecutable,file, extention)#Extention es solo .java de momento para ejecutar el parser de ricchi
