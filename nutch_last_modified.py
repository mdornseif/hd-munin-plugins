#!/usr/bin/env python
# encoding: utf-8

import sys
import httplib2
import re
import datetime


if len(sys.argv) == 2 and sys.argv[1] == "config":
    print """graph_title Last Modified
graph_vlabel lastmodified
lastmodified.label lastmodified"""
    exit()

h = httplib2.Http()
resp, content = h.request("http://nutch.hudora.biz/statistics.jsp")

lines = content.split("\n")
for line in lines:
    if line.strip().startswith("<li>lastModified: <strong>"):
        
        date_modified = re.findall(r"<strong>(?P<number>.+)</strong>", line)[0]
        date_modified_tshift = date_modified[-8:]
        date_now = datetime.datetime.now()
        date_modified = datetime.datetime.strptime(date_modified, "%Y-%m-%dT%H:%M:%S."+date_modified_tshift)
        date_diff = date_now - date_modified
        print "lastmodified.value %s" %  int(date_diff.seconds/60)
        exit()

