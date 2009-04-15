#!/bin/bash

flex -o code2xml.c code2xml.flex
flex -o xml2code.c xml2code.flex
gcc -o scanner_code code2xml.c
gcc -o scanner_xml xml2code.c
