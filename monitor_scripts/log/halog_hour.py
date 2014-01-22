# /usr/bin/env python
# --*-- coding:utf-8 --*--
#每分钟的统计结果处理成每小时的结果 
from datetime import datetime,timedelta

#根据当前时间计算上一小时时间
now = datetime.now()
one_hour_ago = now + timedelta(hours=-1)


#确定上一小时文件目录
file_dir = "/tmp/"
log_src = "%s13"%file_dir



