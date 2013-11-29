#!/usr/local/bin/python

import sys,re,urllib,argparse

parser = argparse.ArgumentParser(description='nginx status')
parser.add_argument('host',help='host to test')
parser.add_argument('--location',default='/status')

args = parser.parse_args()

theurl = 'http://%s%s' %(args.host, args.location)


stats = {
	'active':0,
	'accepts':0, 'handled':0, 'requests':0,\
	'reading':0, 'writing':0, 'waiting':0
	}

r1 = re.compile(r'(\d+)')
r2 = re.compile(r'(\d+)\s+(\d+)\s+(\d+)')
r3 = re.compile(r'Reading:\s+(\d+)\s+Writing:\s+(\d+)\s+Waiting:\s+(\d+)')
try:
    f = urllib.urlopen(theurl)
    lines = f.readlines()
    stats['active'] = r1.search(lines[0]).groups()[0]
    stats['accepts'], stats['handled'], stats['requests'] = r2.search(lines[2]).groups()
    stats['reading'], stats['writing'], stats['waiting'] = r3.search(lines[3]).groups()
except IOError,e:
    print e
    sys.exit(1)

for stat, count in stats.iteritems():
    print "%s:%s" % (stat, count),
