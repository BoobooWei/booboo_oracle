#!/usr/bin/env bash

cat /proc/version

groupadd  dba && groupadd oinstall && useradd -g oinstall -G dba oracle
echo zyadmin | passwd --stdin oracle

groupadd  dba && groupadd oinstall && useradd -g oinstall -G dba oracle
echo zyadmin | passwd --stdin oracle

mkdir -p /alidata/install
mkdir -p /alidata/app/oracle/product/11.2.0/
chmod -R 755 /alidata/ && chown -R oracle:oinstall /alidata/

cat >> /etc/security/limits.conf << ENDF
oracle        soft        nproc        2047
oracle        hard        nproc        16384
oracle        soft        nofile  1024
oracle        hard        nofile  65536
ENDF

cat >> /etc/sysctl.conf << ENDF
kernel.shmmax = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 )
kernel.shmmni = 4096
kernel.shmall = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 / `getconf PAGESIZE`)
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048576
fs.aio-max-nr = 1048576
fs.file-max = 6815744
ENDF
 
cat >> /etc/pam.d/login << ENDF
session  required  /lib/security/pam_limits.so
session  required  pam_limits.so
ENDF

sysctl -p

cat >> /home/oracle/.bash_profile << ENDF
export TMPDIR=/tmp
export TEMP=/tmp
export ORACLE_BASE=/alidata/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/dbhome_1/
export ORACLE_SID=ORCL
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=\$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
umask 022
ENDF
su - oracle -c "source /home/oracle/.bash_profile"

SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracle11204.tar.gz"
PKG_NAME=`basename $SRC_URI`
cd /alidata/install
if [ ! -s $PKG_NAME ]; then
    curl -O $SRC_URI
fi
tar zxvfP ${PKG_NAME}

wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-37.el5_8.1.i386.rpm && yum install pdksh-5.2.14-37.el5_8.1.i386.rpm -y

su - oracle
LISTENERIP=$(ifconfig | grep "inet addr:" | grep -vP "`curl icanhazip.com 2>/dev/null`|127.0.0.1" |awk -F "[ :]*" '{print $4}')
sed -i "s/LISTENERIP/${LISTENERIP}/" /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
lsnrctl status
lsnrctl start
