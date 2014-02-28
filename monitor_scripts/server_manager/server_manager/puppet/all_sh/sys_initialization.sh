#!/bin/sh
basedir=/root/server_manager/package/sys_initialization
install_tmp=/root/Tmp
mkdir -p /root/Tmp

cd $basedir
rpm -ivh lrzsz-0.12.20-22.1.x86_64.rpm 
rpm -ivh ntp-4.2.2p1-9.el5.centos.2.x86_64.rpm
ntpdate 192.168.111.17

#unzip linux-1.9.20b_1.50.13.zip 
#cd Server/Linux/Driver/
#tar zxf netxtreme2-5.0.17.tar.gz 
#cd netxtreme2-5.0.17
#make && make install
#cd /root/soft

cd $basedir
tar zxf sysstat-9.0.2.tar.gz -C $install_tmp
cd $install_tmp/sysstat-9.0.2
./configure
make && make install


cd $basedir
rpm -ivh lm_sensors-2.10.7-4.el5.x86_64.rpm lm_sensors-devel-2.10.7-4.el5.x86_64.rpm net-snmp-libs-5.3.2.2-7.el5.x86_64.rpm net-snmp-5.3.2.2-7.el5.x86_64.rpm
\cp snmpd.conf /etc/snmp/
service snmpd start
chkconfig snmpd on
chkconfig --list |grep snmpd

cd $basedir
#rpm -ivh openssl-devel-0.9.8e-22.el5_8.1.x86_64.rpm openssl-0.9.8e-22.el5_8.1.x86_64.rpm
tar xf nagiosinstall.tar.gz -C $install_tmp
cd $install_tmp/nagiosinstall
chmod 755 install.sh
chmod 755 check_traffic.sh
./install.sh
sed -i 's/127.0.0.1/127.0.0.1,192.168.219.47/g' /usr/local/nagios/etc/nrpe.cfg
killall -9 nrpe
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d

#close prot:22 open port:5044
#sed -i 's/#Port 22/Port 5044/;s/#PermitRootLogin yes/PermitRootLogin no/;s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
#service sshd restart


# service 

#
#route add -net 192.168.8.0 netmask 255.255.255.0 gw 192.168.219.254

########
#crontab -e
#30 5 * * * cd /usr/sbin;./ntpdate 192.168.219.58>/dev/null
#*/1 * * * * /usr/local/lib/sa/sa1 -S DISK 10 6 &

#modprobe ip_tables
#modprobe iptable_filter
#modprobe ip_conntrack hashsize=131072
#modprobe ip_conntrack_ftp
#modprobe ipt_state
#modprobe iptable_nat
#modprobe ip_nat_ftp
#modprobe ipt_MASQUERADE
#modprobe ipt_LOG
#modprobe ipt_REJECT
#echo 1048576 > /proc/sys/net/core/somaxconn
#echo 1048576 > /proc/sys/net/ipv4/ip_conntrack_max
#echo "1024 64000" > /proc/sys/net/ipv4/ip_local_port_range
#echo 131072 > /proc/sys/fs/file-max
#echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
#echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
#echo 262144 > /proc/sys/net/ipv4/tcp_max_orphans
#echo 262144 > /proc/sys/net/ipv4/tcp_max_syn_backlog
#echo 3 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_time_wait
#echo 30 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_syn_recv
#echo 524288 > /proc/sys/net/ipv4/tcp_max_tw_buckets
#echo 5 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_close_wait
#echo 18000 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established
#echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
#echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
#echo 1 > /proc/sys/net/ipv4/tcp_syncookies
#echo 0 > /proc/sys/net/ipv4/tcp_retrans_collapse
#echo 0 >/proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_loose
#echo 262144 > /proc/sys/net/core/wmem_max
#echo 65536 > /proc/sys/net/core/wmem_default
#echo 262144 > /proc/sys/net/core/rmem_max
#echo 65536 > /proc/sys/net/core/rmem_default
#echo "8096 65536 262144" >/proc/sys/net/ipv4/tcp_wmem
#echo "8096 65536 262144" >/proc/sys/net/ipv4/tcp_rmem
#route add -net 192.168.8.0 netmask 255.255.255.0 gw 192.168.219.254

#echo "*.*                                                     @192.168.219.110" >> /etc/syslog.conf 
#service syslog restart

