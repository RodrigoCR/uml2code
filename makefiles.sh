#!/bin/bash

flex -o modulitoPython.c python2.flex
flex -o modulitoJava.c java.flex
gcc -o python2 modulitoPython.c -lfl
gcc -o java modulitoJava.c -lfl
