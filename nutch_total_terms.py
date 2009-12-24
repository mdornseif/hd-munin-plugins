#!/usr/bin/env python
# encoding: utf-8

# Created 2009 by Olaf Wozniak for Hudora

import sys
import httplib2
import re

if len(sys.argv) == 2 and sys.argv[1] == "config":
    print """graph_title Number of Terms
graph_vlabel terms
terms.label terms"""
    exit()

h = httplib2.Http()
resp, content = h.request("http://nutch.hudora.biz/statistics.jsp")

lines = content.split("\n")
for line in lines:
    if line.strip().startswith("<li>numTerms: <strong>"):
        
        num_terms = re.findall(r"<strong>(?P<number>\d+)</strong>", line)[0]
        print "terms.value %s" % num_terms
        exit()
