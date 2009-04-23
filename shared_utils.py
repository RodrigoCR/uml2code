#!/usr/bin/python
# -*- coding: utf8 -*-

import math

### UML constants and dictionaries
UmlAttributeAccess = {"public":0,"private":1,"protected":2}

### Cairo context and operation shared functions:

def make_current_color(context, color):
	if (len(color) == 4):
		(r, g, b, a) = color
		context.set_source_rgba(r, g, b, a)
	else:
		if (len(color) == 3):
			(r, g, b) = color
			context.set_source_rgb(r, g, b)
		else:
			print "WARNING: make_current_color() was called with an invalid color descriptor, the current color for the submitted context will default to (1,1,1) [solid white]"
			context.set_source_rgb(1,1,1)
			
### Other graphical functions

def dist(p1, p2):
	(x1,y1) = map(lambda x: x*1.0, p1)
	(x2,y2) = map(lambda x: x*1.0, p2)
	return math.sqrt((x1-x2)**2+(y1-y2)**2)
	

def line_intersect(l1, l2):
	(x1,y1,x2,y2) = map(lambda x: x*1.0, l1)
	(x3,y3,x4,y4) = map(lambda x: x*1.0, l2)
	if(((x1 == x2) and (y1 == y2)) or ((x3 == x4) and (y3 == y4))):
		return (-1,-1)
	a = (y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1)
	if(a == 0):
		return (-1,-1)	
	m1 = ((x4 - x3)*(y1 - y3) - (y4 - y3)*(x1 - x3)) / a
	m2 = ((x2 - x1)*(y1 - y3) - (y2 - y1)*(x1 - x3)) / a
	
	if((m1 < 0) or (m1 > 1) or (m2 < 0) or (m2 > 1)):
		return (-1,-1)
	
	return (x1 + m1*(x2 - x1), y1 + m1*(y2 - y1))
	

def rect_intersect(line, rect):
	t_lines = []
	s_point = line[0:2]
	r_points = []
	t_lines.append((rect.x, rect.y, rect.x, rect.y + rect.height))
	t_lines.append((rect.x, rect.y, rect.x + rect.width, rect.y))
	t_lines.append((rect.x, rect.y + rect.height, rect.x + rect.width, rect.y + rect.height))
	t_lines.append((rect.x + rect.width, rect.y, rect.x + rect.width, rect.y + rect.height))
	for l in t_lines:
		p = line_intersect(line,l)
		if (p != (-1,-1)):
			r_points.append(p)
	if(dist(s_point,r_points[0]) > dist(s_point,r_points[1])):
		p1 = r_points[1]
		p2 = r_points[0]
	else:
		p1 = r_points[0]
		p2 = r_points[1]
	return (p1,p2)	
	
				
