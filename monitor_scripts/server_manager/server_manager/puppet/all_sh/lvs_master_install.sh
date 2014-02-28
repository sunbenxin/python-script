#!/bin/sh
basedir=/root/server_manager/package/lvs
base_config_dir=/root/server_manager/puppet/all_config
install_tmp=/root/Tmp

ln -s /usr/src/kernels/2.6.18-164.el5-x86_64 /usr/src/linux

cd $basedir
tar zxf ipvsadm-1.24.tar.gz -C $install_tmp
cd $install_tmp/ipvsadm-1.24
make && make install

cd $basedir
tar zxf keepalived-1.1.17.tar.gz -C $install_tmp
cd $install_tmp/keepalived-1.1.17
./configure && make && make install

\cp $base_config_dir/master_keepalived.conf /usr/local/etc/keepalived/keepalived.conf
\cp $base_config_dir/lvs_firewall /etc/rc.d/firewall
\cp $base_config_dir/lvs_rc.local /etc/rc.d/rc.local

