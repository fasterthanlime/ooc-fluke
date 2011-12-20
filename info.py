#!/usr/bin/env python2
# coding: utf-8

from struct import unpack as unp
import sys

for fname in sys.argv[1:]:
    with open(fname, "rb") as f:
        print "HEADER: " + fname
        print unp("@3s", f.read(3))
        print "version: "+str(unp("@c", f.read(1)))
        print "header flage: "+str(unp("@c", f.read(1))) # 5
        print "header size: "+str(unp(">I", f.read(4)))
        print "??: "+str(unp(">i", f.read(4))) 
        print "metadata tag type: "+str(unp("@c", f.read(1))) # 14
        # wait, what? big endian and padding at the beginning??
        print "size of data-part: "+str(unp(">i", "\x00"+f.read(3)))
        print "time stamp: "+str(unp(">i", f.read(3)+"\x00")) # why zero?
        print "reserved: "+str(unp(">i", f.read(4)))
        # we expect an AMF string:

        print "AMF type: "+str(unp("c", f.read(1)))
        length = unp(">H", f.read(2))[0]
        print "AMF String: %s of length %s" % ((unp(">%ss" % length, f.read(length))), length)

        #mixed array (hash) with size and string/type/data tuples
        print "AMF type: "+str(unp("c", f.read(1)))
        print "metadataCount: "+str(unp(">i", f.read(4)))

        length = unp(">H", f.read(2))[0]
        print "AMF String: %s of length %s" % ((unp(">%ss" % length, f.read(length))), length)
        print "duration: "+str(unp(">d", f.read(8))) 
        


