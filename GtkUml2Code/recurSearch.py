'''
Created on Apr 29, 2009

@author: carlos
'''

import commands
from string import split

def gefilename(s):
	return split(s,"/")[-1]


def searchext(path,extention):
    com= "find "+path+" -type f -name \*"+extention
    #list= os.popen(pat+args).read
    list= commands.getstatusoutput(com)
    
    files=[]
    cad=""
    for c in list[1]:
        if c!='\n':
            cad=cad+c  
        else:
            files.append(cad)
            cad=""
    files.append(cad)
    return files

def executeParser(pathexec, filename ,extention):
    if extention ==".java" or extention ==".py":
	print "se ejecuto : "+pathexec+ " "+filename +" < "+filename
        commands.getstatusoutput(pathexec+ " "+filename +" < "+filename)
	nombre = gefilename(filename)
	print "el nombre es " + nombre
	commands.getstatusoutput("cp "+filename +".xml ./xml/"+nombre+".xml")
	commands.getstatusoutput("rm "+filename +".xml")
	print "Se copia " + filename +".xml  a  ./xml/"+nombre+".xml"
    
