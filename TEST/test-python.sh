#!/bin/bash

# Moving to the PYTHON bin folder
cd ../PYTHON

# Executing compilation
chmod 777 makefile.sh
sh ./makefile.sh

# Copy binaries to this folder
cd ../TEST
cp ../PYTHON/py2xml py2xml
cp ../PYTHON/xml2py xml2py

# Do the test
./py2xml prueba.py < prueba.py
./xml2py prueba.py.xml < prueba.py.xml

./py2xml prueba2.py < prueba2.py
./xml2py prueba2.py.xml < prueba2.py.xml

# Delete binaries
rm py2xml
rm xml2py
