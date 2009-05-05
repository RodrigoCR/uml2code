#!/bin/bash

# Moving to the JAVA bin folder
cd ../JAVA

# Executing compilation
chmod 777 makefile.sh
sh ./makefile.sh

# Copy binaries to this folder
cd ../TEST
cp ../JAVA/scanner_code scanner_code
cp ../JAVA/scanner_xml scanner_xml

# Do the test
./scanner_code < PGJConsultaEntryPoint.java
./scanner_xml < PGJ.java.xml
