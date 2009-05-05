#!/bin/bash

flex -o py2xml.c code2xml.flex
flex -o xml2py.c xml2code.flex
gcc -o py2xml py2xml.c -lfl
gcc -o xml2py xml2py.c -lfl
