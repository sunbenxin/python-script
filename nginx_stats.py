#!/usr/local/bin/python

import sys, re, argparse,urllib

stats = {
    'active':0,\
    'accepts':0, 'handled':0, 'requests':0,\
    'reading':0, 'writing':0, 'waiting':0
    }


parser = argparse.ArgumentParser()
parser.add_argument('host')
parser.add_argument('-l','--location',default='/status')
args = parser.parse_args()


host = args.host
location = args.location

url = 'http://%s%s' % (host,location)


#Active connections: 8
#server accepts handled requests
# 38263242 38263242 38263242
#Reading: 0 Writing: 8 Waiting: 0

r1 = re.compile(r'(\d+)')
r2 = re.compile(r'(\d+)\s+(\d+)\s+(\d+)')
r3 = re.compile(r'Reading:\s+(\d+)\s+Writing:\s+(\d+)\s+Waiting:\s+(\d+)')

try:
    f = urllib.urlopen(url)
    lines = f.readlines()
    stats['active'] = r1.search(lines[0]).groups()[0]
    stats['accepts'], stats['handled'], stats['requests'] = r2.search(lines[2]).groups()
    stats['reading'], stats['writing'], stats['waiting'] = r3.search(lines[3]).groups()
except IOError,e:
    print e
    sys.exit(1)

for key, value in stats.iteritems():
    print "%s:%s" % (key, value),
