'''
Created on Apr 29, 2009

@author: carlos
'''

import commands


def searchext(path,extention):
    com= "find ./xml -type f -name \*"+extention
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
    if extention ==".java":
        commands.getstatusoutput(pathexec+" < "+filename)
    
