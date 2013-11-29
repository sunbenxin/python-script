#!/usr/local/bin/python
import sys, re, redis,argparse

parser = argparse.ArgumentParser(description='redis status')
parser.add_argument('host',help='host of redis')
parser.add_argument('--port',default=6379)
parser.add_argument('--db',default=0)
parser.add_argument('--password',default='')
args = parser.parse_args()

r = redis.Redis(host=args.host, port=int(args.port), db=args.db, password=args.password)

redis_info = r.info()


for k, v in redis_info.iteritems():
    print "%s:%s" % (k, v),
