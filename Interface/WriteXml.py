'''
Created on Apr 27, 2009

@author: carlos
'''
from xml.dom.minidom  import Document


def getaccesmod(n):
    if n==0:
        return "public"
    if n==1:
        return "private"
    if n==2:
        return "protected"
    
def clasrec(clas):

        doc = Document()
        if clas["name"]!=None:
            print clas["name"] 
            c=doc.createElement("class")
            n=doc.createElement("name")
            cname=doc.createTextNode(clas["name"])
            n.appendChild(cname)
            c.appendChild(n)
            if clas["inner_clases"]!=[]:
                c=doc.createElement("class")
                for inn in clas["inner_clases"]:
                    ci=clasrec(inn)
                    c.appendChild(ci)
            if clas["super_class"]!=None:
                exten=doc.createElement("extends")
                exname=doc.createTextNode(clas["super_class"])
                exten.appendChild(exname)
                c.appendChild(exten)
                print clas["super_class"]
            if clas["attributes"] != None:
                for att in clas["attributes"]:
                    at=None
                    if att["name"]!=None:
                        at=doc.createElement("var")
                        nv=doc.createElement("name")
                        atname=doc.createTextNode(att["name"])
                        nv.appendChild(atname)
                        at.appendChild(nv)
                        c.appendChild(at)
                        print att ["name"]
                    if att["ac_mod"]!=None: 
                        modname=doc.createTextNode(getaccesmod(att["ac_mod"]))
                        mod=doc.createElement("accesmod")
                        mod.appendChild(modname)
                        at.appendChild(mod)
                        print att["ac_mod"]

                    if att["type"]!= None:
                        tyname=doc.createTextNode(att["type"])
                        typ=doc.createElement("type")
                        typ.appendChild(tyname)
                        at.appendChild(typ)
                        print att["type"]

                    if att["signature"]!= None:#quee
                        print att["signature"]

                if clas["methods"]!= None:
                    for met in clas["methods"]:
                        if  met["name"]!= None:
                            metods=doc.createElement("Method")
                            mname=doc.createTextNode(met["name"])
                            nam=doc.createElement("name")
                            nam.appendChild(mname)
                            metods.appendChild(nam)
                            c.appendChild(metods)
                            print met["name"]
                        if met["ac_mod"]!= None:
                            modname=doc.createTextNode(getaccesmod(met["ac_mod"]))
                            mod=doc.createElement("accesmod")
                            mod.appendChild(modname)
                            metods.appendChild(mod)
                            print met["ac_mod"]
                        if met["type"]!= None:
                            tyname=doc.createTextNode(met["type"])
                            typ=doc.createElement("type")
                            typ.appendChild(tyname)
                            metods.appendChild(typ)
                            print met["type"]
                        if met["signature"]!= None:#quee
                            print met["signature"]
                        for par in met["params"]:
                            if par["type"]!= None:
                                tyname=doc.createTextNode(met["type"])
                                typ=doc.createElement("type")
                                typ.appendChild(tyname)
                                pars.appendChild(typ)
                                print par["type"]
                            if par["name"]!= None:
                                mname=doc.createTextNode(met["name"])
                                pars=doc.createElement("name")
                                pars.appendChild(metods)
                                print par["name"]
            
            
            return c

def writexml(umlayout,filename):
    for clas in umlayout.get_clases():
        c=clasrec(clas)
        doc = Document()
        doc.appendChild(c)
        fp = open( clas["name"]+".xml","w")
        # writexml(self, writer, indent='', addindent='', newl='', encoding=None)
        doc.writexml(fp, "    ", "", "\n", "UTF-8")

