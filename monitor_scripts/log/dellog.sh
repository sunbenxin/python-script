#当home目录使用率超过%90时候删除/home/squid-log/access/access.log.1[0-9]
#!/bin/sh
home=`df -h |grep home |awk '{print $5}'|sed s/%//g`
if [ $home -ge 90 ];then
rm -rf /home/squid-log/access/access.log.1[0-9]
fi
