#!/usr/bin/env python
#-*- coding: utf-8 -*-
#=============================================================================
#     FileName:
#         Desc:
#       Author: 苦咖啡
#        Email: voilet@qq.com
#     HomePage: http://blog.kukafei520.net
#      Version: 0.0.1
#   LastChange: 2013-02-20 14:52:11
#      History:
#=============================================================================
# -*- coding: utf-8 -*-

import re,time

def _read_cpu_usage():
    """Read the current system cpu usage from /proc/stat"""
    statfile = "/proc/stat"
    cpulist = []
    try:
        f = open(statfile, 'r')
        lines = f.readlines()
    except:
        print "error:无法打开文件%s，系统无法继续运行。" % (statfile)
        return []
    for line in lines:
        tmplist = line.split()
        if len(tmplist) < 5:
            continue
        for b in tmplist:
            m = re.search(r'cpu\d+',b)
            if m is not None:
                cpulist.append(tmplist)
    f.close()
    return cpulist

def get_cpu_usage():
    cpuusage = {}
    cpustart = {}
    cpuend = {}
    linestart = _read_cpu_usage()
    if not linestart:
        return 0
    for cpustr in linestart:
        usni=long(cpustr[1])+long(cpustr[2])+long(cpustr[3])+long(cpustr[5])+long(cpustr[6])+long(cpustr[7])+long(cpustr[4])
        usn=long(cpustr[1])+long(cpustr[2])+long(cpustr[3])
        cpustart[cpustr[0]] = str(usni)+":"+str(usn)
    sleep = 2
    time.sleep(sleep)
    lineend = _read_cpu_usage()
    if not lineend:
        return 0
    for cpustr in lineend:
        usni=long(cpustr[1])+long(cpustr[2])+long(cpustr[3])+long(cpustr[5])+long(cpustr[6])+long(cpustr[7])+long(cpustr[4])
        usn=long(cpustr[1])+long(cpustr[2])+long(cpustr[3])
        cpuend[cpustr[0]] = str(usni)+":"+str(usn)
    for line in cpustart:
        start = cpustart[line].split(':')
        usni1,usn1 = float(start[0]),float(start[1])
        end = cpuend[line].split(':')
        usni2,usn2 = float(end[0]),float(end[1])
        cpuper=(usn2-usn1)/(usni2-usni1)
        cpuusage[line] = int(100*cpuper)

    return cpuusage

if __name__ == '__main__':
    cpu = get_cpu_usage()
    print cpu
    str_res = "" ''
    for id in cpu.keys():
        if cpu[id] > 80:
            str_res += '%s %s %s | ' % ("Critical -",id,cpu[id])
        else:
            str_res = "OK - cpu is ok"
    if str_res !=0:
        print str_res
    else:
        print "OK -cpu is ok"
