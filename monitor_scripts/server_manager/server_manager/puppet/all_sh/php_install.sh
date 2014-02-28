#!/bin/sh
mkdir /root/Tmp
basedir=/root/server_manager/package/php
install_tmp=/root/Tmp
phpize=/usr/local/php5.3/bin/phpize
phpconfig=/usr/local/php5.3/bin/php-config

#### php_install.sh  2012.04.25 16:36 change ####
#### mysql client install
cd $basedir
rpm -ivh MySQL-shared-compat-5.0.27-0.rhel4.x86_64.rpm
rpm -ivh MySQL-shared-standard-5.0.27-0.rhel4.x86_64.rpm
rpm -ivh perl-DBI-1.32-5.i386.rpm
rpm -ivh MySQL-client-5.0.27-0.glibc23.x86_64.rpm
rpm -ivh MySQL-devel-standard-5.0.27-0.rhel4.x86_64.rpm
\cp -rp /usr/lib64/libmysqlclient.so.15.0.0 /usr/lib/libmysqlclient.so

#### php install
cd $basedir
rpm -ivh curl-7.15.5-2.1.el5_3.5.x86_64.rpm
rpm -ivh curl-devel-7.15.5-2.1.el5_3.5.x86_64.rpm
rpm -ivh libpng-1.2.10-7.1.el5_3.2.x86_64.rpm
rpm -ivh libpng-devel-1.2.10-7.1.el5_3.2.x86_64.rpm
rpm -ivh freetype-2.2.1-21.el5_3.x86_64.rpm
rpm -ivh freetype-devel-2.2.1-21.el5_3.x86_64.rpm
rpm -ivh gmp-4.1.4-10.el5.x86_64.rpm
rpm -ivh gmp-devel-4.1.4-10.el5.x86_64.rpm
rpm -ivh libjpeg-6b-37.x86_64.rpm
rpm -ivh libjpeg-devel-6b-37.x86_64.rpm
rpm -ivh libtool-ltdl-1.5.22-6.1.x86_64.rpm
rpm -ivh libtool-ltdl-devel-1.5.22-6.1.x86_64.rpm
rpm -ivh libxml2-2.6.26-2.1.2.8.x86_64.rpm
rpm -ivh libxml2-devel-2.6.26-2.1.2.8.x86_64.rpm
rpm -ivh openldap-2.3.43-3.el5.x86_64.rpm
rpm -ivh openldap-clients-2.3.43-3.el5.x86_64.rpm
rpm -ivh openldap-devel-2.3.43-3.el5.x86_64.rpm
rpm -ivh openldap-servers-2.3.43-3.el5.x86_64.rpm
rpm -ivh openldap-servers-overlays-2.3.43-3.el5.x86_64.rpm
rpm -ivh openldap-servers-sql-2.3.43-3.el5.x86_64.rpm
rpm -ivh unixODBC-2.2.11-7.1.x86_64.rpm
rpm -ivh unixODBC-devel-2.2.11-7.1.x86_64.rpm

Libiconv_Function(){
cd $basedir
File=`ls -1 |grep -i ^libiconv*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure --prefix=/usr/local/www/libiconv
make && make install
if [ $? != 0 ];then
echo "$File  Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Autoconf_Function(){
cd $basedir
File=`ls -1 |grep -i ^Autoconf*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure --prefix=/usr/local/www/autoconf
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Libmemcached_Function(){
cd $basedir
File=`ls -1 |grep -i ^Libmemcached*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Libmcrypt_Function(){
cd $basedir
File=`ls -1 |grep -i ^Libmcrypt*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure
make && make install
if [ $? !=0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}


Php_Function(){
cd $basedir
File=`ls -1 |grep -i ^Php-5.3.11.tar.bz2`
tar jxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure  --prefix=/usr/local/php5.3 --with-openssl --with-pcre-regex --with-zlib --enable-bcmath --with-zlib --with-curl --enable-exif --enable-ftp --with-gd --with-gettext --with-gmp --with-mhash --with-ldap --with-mcrypt --with-mysql --with-mysql-sock --enable-sockets --enable-zip --enable-fpm --with-pdo-mysql --enable-mbstring --with-jpeg-dir=/usr --with-png-dir=/usr --with-gmp=/usr --with-iconv-dir=/usr/local/www/libiconv
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Xcache_Function(){
cd $basedir
File=`ls -1 |grep -i ^Xcache*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
$phpize
./configure --enable-xcache --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Mongo_Function(){
cd $basedir
File=`ls -1 |grep -i ^Mongo-1.2.6*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tgz*}
$phpize
./configure --enable-mongo --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Memcached_Function(){
cd $basedir
File=`ls -1 |grep -i ^Memcached-1.0.2*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tgz*}
$phpize
./configure --enable-memcached --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Memcache_Function(){
cd $basedir
File=`ls -1 |grep -i ^Memcache-2.2.6*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tgz*}
$phpize
./configure --enable-memcache --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Phpiredis_Function(){
cd $basedir
File=`ls -1 |grep -i seppo0010-phpiredis-c3b6f2c.tar.gz`
tar zxf $File -C $install_tmp
cp -rf hiredis $install_tmp/${File%.tar*}/lib/
cd $install_tmp/${File%.tar*}
$phpize
./configure --enable-phpiredis-c3b6f2c --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Mhash_Function(){
cd $basedir
File=`ls -1 |grep -i ^Mhash*`
tar zxf $File -C $install_tmp
cd $install_tmp/${File%.tar*}
./configure
make && make install
if [ $? != 0 ];then
echo "$File Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Curl_Function(){
cd $basedir
File=`ls -1 |grep -i ^Php-5.3.11.tar.bz2`
cd $install_tmp/${File%.tar*}/ext/curl
$phpize
./configure --with-curl --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "Curl Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Ldap_Function(){
cd $basedir
File=`ls -1 |grep -i ^Php-5.3.11.tar.bz2`
cd $install_tmp/${File%.tar*}/ext/ldap
$phpize
./configure --with-ldap --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "Ldap Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Bcmath_Function(){
cd $basedir
File=`ls -1 |grep -i ^Php-5.3.11.tar.bz2`
cd $install_tmp/${File%.tar*}/ext/bcmath
$phpize
./configure --with-bcmath --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "Bcmath Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Mcrypt_Function(){
cd $basedir
File=`ls -1 |grep -i ^Php-5.3.11.tar.bz2`
cd $install_tmp/${File%.tar*}/ext/mcrypt
$phpize
./configure --with-mcrypt --with-php-config=$phpconfig
make && make install
if [ $? != 0 ];then
echo "Mcrypt Error !!!!!!!!!!!" >> $install_tmp/error_install.log
exit 10
fi
}

Libiconv_Function
Autoconf_Function
Libmemcached_Function
Libmcrypt_Function
Php_Function
Xcache_Function
Mongo_Function
Memcached_Function
Memcache_Function
Phpiredis_Function
Mhash_Function
Curl_Function
Ldap_Function
Bcmath_Function
Mcrypt_Function
