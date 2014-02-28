#!/bin/sh
basedir=/root/server_manager/package/redis
base_config_dir=/root/server_manager/puppet/all_config
install_tmp=/root/Tmp
mkdir -p /root/Tmp

cd $basedir
tar zxf redis-2.4.11.tar.gz -C $install_tmp
cd $install_tmp/redis-2.4.11
make PREFIX=/usr/local/redis install
mkdir -p /usr/local/redis/etc
mkdir -p /usr/local/redis/data
mkdir -p /usr/local/redis/log
