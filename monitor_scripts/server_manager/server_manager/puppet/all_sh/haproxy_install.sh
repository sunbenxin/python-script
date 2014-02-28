#!/bin/sh
basedir=/root/server_manager/package/haproxy
base_config_dir=/root/server_manager/puppet/all_config
install_tmp=/root/Tmp

cd $basedir
tar zxf pcre-7.9.tar.gz -C $install_tmp
cd $install_tmp/pcre-7.9
./configure
make && make install

cd $basedir
tar zxf haproxy-1.4.15.tar.gz -C $install_tmp
cd $install_tmp/haproxy-1.4.15
make TARGET=linux26 USE_PCRE=1 && make install

cd $basedir
tar zxf socat-1.7.1.2.tar.gz -C $install_tmp
cd $install_tmp/socat-1.7.1.2
./configure --disable-fips
make && make install

cd $basedir
rpm -ivh syslog-ng-3.0.8-1.rhel4.i386.rpm

\cp $base_config_dir/haproxy.cfg /etc
\cp $base_config_dir/ha_syslog-ng.conf /opt/syslog-ng/etc/syslog-ng.conf
\cp $base_config_dir/ha_firewall /etc/rc.d/firewall
\cp $base_config_dir/ha_rc.local /etc/rc.d/rc.local
\cp $base_config_dir/ha_lvs /root

