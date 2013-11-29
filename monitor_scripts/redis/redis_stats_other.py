#!/usr/local/bin/python
import sys, re
import redis
from optparse import OptionParser

stats = {
    'connected_clients': 0,
    'connected_slaves': 0,
    'total_connections_received': 0,
    
    'used_memory': 0,
    
    'changes_since_last_save': 0,

    'total_commands_processed': 0,

    'db0_keys': 0,
    'db0_expires': 0,
}

parser = OptionParser(usage="usage: %prog [-h] [-p PORT] [-d DB] [-a AUTH_PASSWORD ] HOSTNAME ...")
parser.set_defaults(port = "6379")
parser.add_option("-p", "--port", dest="port", metavar="PORT",
                  help="default redis port [default: 6379]")
parser.set_defaults(db = "db0")
parser.add_option("-d", "--db", dest="db", metavar="DB",
                  help="redis database [default: db0]")
parser.set_defaults(auth = "")
parser.add_option("-a", "--auth", dest="auth", metavar="AUTH",
                  help="auth password [default: '']")
(options, args) = parser.parse_args()

hosts = []
if (args):
    host=args[0]
else:
    parser.error("HOSTNAME is required.")
    sys.exit(1)

r = redis.Redis(host=host, port=int(options.port), db=0, password=options.auth)

####################################  add by zzz
try:
    redisinfo=r.info()
except:
    print "warning! can't read redis.info"
    sys.exit(1)
##############################################
redis_info = r.info()
#print redis_info

#if(not redis_info):
if len(redis_info) < 30:####  last word was used.this is wrote by zzz
    sys.exit()

for k, v in stats.iteritems():
    if(k in redis_info):
        v = int(redis_info[k])
    else:
        stats['db0_keys'] = redis_info['db0']['keys']
        stats['db0_expires'] = redis_info['db0']['expires']
    print "%s:%s" % (k, v),
