#!/usr/bin/env python
# encoding: utf-8

# Created 2009 by Olaf Wozniak for Hudora

import sys
import httplib2
import re

if len(sys.argv) == 2 and sys.argv[1] == "config":
    print """graph_title Number of Docs
graph_vlabel docs
docs.label docs"""
    exit()

h = httplib2.Http()
resp, content = h.request("http://nutch.hudora.biz/statistics.jsp")

lines = content.split("\n")
for line in lines:
    if line.strip().startswith("<li>numDocs: <strong>"):
        
        num_docs = re.findall(r"<strong>(?P<number>\d+)</strong>", line)[0]
        print "docs.value %s" % num_docs
        exit()
