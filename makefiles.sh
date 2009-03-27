#!/bin/bash

flex -o python2.c python2.flex
flex -o java.c java.flex
gcc -o python2 python2.c -lfl
gcc -o java java.c -lfl
