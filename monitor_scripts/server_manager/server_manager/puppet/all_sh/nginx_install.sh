#!/bin/sh

basedir=/root/server_manager/package/nginx
install_tmp=/root/Tmp

Pcre_Function(){
cd $basedir
File=`ls -1 |grep -i ^Pcre*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure
make && make install
if [ $? != 0 ] ;then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Nginx_Function(){
cd $basedir
File=`ls -1 |grep -i ^nginx-1.2.0.tar.gz*`
tar zxf $File -C $install_tmp
cd $install_tmp/nginx-1.2.0
./configure --prefix=/usr/local/nginx --with-ipv6 --with-http_realip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_stub_status_module --with-pcre
make && make install
if [ $? != 0 ] ;then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Pcre_Function
Nginx_Function
