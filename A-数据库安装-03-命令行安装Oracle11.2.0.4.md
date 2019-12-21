# 命令行安装Oracle11.2.0.4


<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [命令行安装Oracle11.2.0.4](#命令行安装oracle11204)
	- [1. 查看操纵系统版本](#1-查看操纵系统版本)
	- [2. 建立用户和组](#2-建立用户和组)
	- [3. 创建目录并授权](#3-创建目录并授权)
	- [4. 修改系统参数并生效](#4-修改系统参数并生效)
	- [5. 设置Oracle用户的环境变量](#5-设置oracle用户的环境变量)
	- [6. 下载安装包并解压](#6-下载安装包并解压)
	- [7. 修改监听配置文件并启动](#7-修改监听配置文件并启动)

<!-- /TOC -->

## 1. 查看操纵系统版本

`cat /proc/version `

推荐以下系统：

* RedHat 5或6
* CentOS 5或6
* Oracle-Linux （课后补充）
* Suse（课后补充）

练习

```shell
[root@db ~]# cat /proc/version
Linux version 2.6.32-696.16.1.el6.x86_64 (mockbuild@c1bl.rdu2.centos.org) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-18) (GCC) ) #1 SMP Wed Nov 15 16:51:15 UTC 2017
```

## 2. 建立用户和组

```shell
groupadd  dba && groupadd oinstall && useradd -g oinstall -G dba oracle
echo zyadmin | passwd --stdin oracle
```

练习

```shell
[root@db ~]# groupadd  dba && groupadd oinstall && useradd -g oinstall -G dba oracle
[root@db ~]# echo zyadmin | passwd --stdin oracle
更改用户 oracle 的密码 。
passwd： 所有的身份验证令牌已经成功更新。
```

## 3. 创建目录并授权

路径的规范：
* Oracle家目录 `/alidata/app/oracle/product/11.2.0/`
* Oracle安装包 `/alidata/install/`
权限的规范：`chmod -R 755 /alidata/ && chown -R oracle:oinstall /alidata/`

```shell
mkdir -p /alidata/install
mkdir -p /alidata/app/oracle/product/11.2.0/
chmod -R 755 /alidata/ && chown -R oracle:oinstall /alidata/
```

练习

```shell
[root@db ~]# mkdir -p /alidata/install
[root@db ~]# mkdir -p /alidata/app/oracle/product/11.2.0/
[root@db ~]# chmod -R 755 /alidata/ && chown -R oracle:oinstall /alidata/
```

## 4. 修改系统参数并生效

kernel.shmmax = 内存大小/分页大小

```shell
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
```

练习

```shell
[root@db ~]# expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024
4153843712
[root@db ~]# expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 / `getconf PAGESIZE`
1014122

[root@db ~]# cat >> /etc/sysctl.conf << ENDF
> kernel.shmmax = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 )
> kernel.shmmni = 4096
> kernel.shmall = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 / `getconf PAGESIZE`)
> kernel.sem = 250 32000 100 128
> net.ipv4.ip_local_port_range = 9000 65500
> net.core.rmem_default=262144
> net.core.rmem_max=4194304
> net.core.wmem_default=262144
> net.core.wmem_max=1048576
> fs.aio-max-nr = 1048576
> fs.file-max = 6815744
> ENDF
[root@db ~]# cat /etc/sysctl.conf
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120

net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2

net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2

kernel.sysrq=1

kernel.shmmax = 4153843712
kernel.shmmni = 4096
kernel.shmall = 1014122
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048576
fs.aio-max-nr = 1048576
fs.file-max = 6815744


[root@db ~]# sysctl -p
```
## 5. 设置Oracle用户的环境变量

```shell
cat >> /home/oracle/.bash_profile << ENDF
export TMPDIR=/tmp
export TEMP=/tmp
export ORACLE_BASE=/alidata/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/dbhome_1/
export ORACLE_SID=BOOBOO
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=\$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
umask 022
ENDF
su - oracle -c "source /home/oracle/.bash_profile"
```

练习

```shell
[root@db ~]# cat >> /home/oracle/.bash_profile << ENDF
> export TMPDIR=/tmp
> export TEMP=/tmp
> export ORACLE_BASE=/alidata/app/oracle
> export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
> export ORACLE_SID=ORCL
> export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
> export PATH=$ORACLE_HOME/bin:$PATH
> export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
> umask 022
> ENDF
```

## 6. 下载安装包并解压

```shell
SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracle11204.tar.gz"
PKG_NAME=`basename $SRC_URI`
cd /alidata/install
if [ ! -s $PKG_NAME ]; then
    curl -O $SRC_URI
fi
tar zxvfP ${PKG_NAME}

wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-37.el5_8.1.i386.rpm && yum install pdksh-5.2.14-37.el5_8.1.i386.rpm -y
bash /alidata/app/oraInventory/orainstRoot.sh
bash /alidata/app/oracle/product/11.2.0/dbhome_1/root.sh
```

练习

```shell
[root@db ~]# SRC_URI="http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracle11204.tar.gz"
[root@db ~]# PKG_NAME=`basename $SRC_URI`
[root@db ~]# cd /alidata/install
[root@db install]# if [ ! -s $PKG_NAME ]; then
>     curl -O $SRC_URI
> fi
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 2293M  100 2293M    0     0  12.0M      0  0:03:10  0:03:10 --:--:-- 12.5M
[root@db install]# tar zxvfP ${PKG_NAME}
/alidata/
/alidata/app/
/alidata/app/oracle/
/alidata/app/oracle/diag/
/alidata/app/oracle/diag/asm/
/alidata/app/oracle/diag/netcman/
/alidata/app/oracle/diag/lsnrctl/
…省略
[root@db install]# wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-37.el5_8.1.i386.rpm && yum install pdksh-5.2.14-37.el5_8.1.i386.rpm -y
--2019-04-08 18:09:06--  http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-37.el5_8.1.i386.rpm
正在解析主机 zy-res.oss-cn-hangzhou.aliyuncs.com... 47.110.23.108
正在连接 zy-res.oss-cn-hangzhou.aliyuncs.com|47.110.23.108|:80... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度：202853 (198K) [application/x-rpm]
正在保存至: “pdksh-5.2.14-37.el5_8.1.i386.rpm.1”

100%[=======================================>] 202,853     --.-K/s   in 0.03s   

2019-04-08 18:09:06 (6.78 MB/s) - 已保存 “pdksh-5.2.14-37.el5_8.1.i386.rpm.1” [202853/202853])
已安装:
  pdksh.i386 0:5.2.14-37.el5_8.1                                                 

作为依赖被安装:
  glibc.i686 0:2.12-1.212.el6     nss-softokn-freebl.i686 0:3.14.3-23.3.el6_8    

作为依赖被升级:
  glibc.x86_64 0:2.12-1.212.el6       glibc-common.x86_64 0:2.12-1.212.el6      
  nscd.x86_64 0:2.12-1.212.el6       

完毕！

```

## 7. 修改监听配置文件并启动

```shell
su - oracle
LISTENERIP=$(ifconfig | grep "inet addr:" | grep -vP "`curl icanhazip.com 2>/dev/null`|127.0.0.1" |awk -F "[ :]*" '{print $4}')
sed -i "s/LISTENERIP/${LISTENERIP}/" /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
lsnrctl status
lsnrctl start
```

练习
```shell
[oracle@db ~]$ lsnrctl status

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 08-APR-2019 18:23:48

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=TCP)(HOST=172.19.34.227)(PORT=1521))
TNS-12541: TNS:no listener
 TNS-12560: TNS:protocol adapter error
  TNS-00511: No listener
   Linux Error: 111: Connection refused

[oracle@db ~]$ lsnrctl start

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 08-APR-2019 18:24:01

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Starting /alidata/app/oracle/product/11.2.0/dbhome_1//bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 11.2.0.4.0 - Production
System parameter file is /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
Log messages written to /alidata/app/oracle/diag/tnslsnr/db/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.19.34.227)(PORT=1521)))

Connecting to (ADDRESS=(PROTOCOL=TCP)(HOST=172.19.34.227)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                08-APR-2019 18:24:02
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
Listener Log File         /alidata/app/oracle/diag/tnslsnr/db/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.19.34.227)(PORT=1521)))
The listener supports no services
The command completed successfully
[oracle@db ~]$ lsnrctl status

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 08-APR-2019 18:24:07

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=TCP)(HOST=172.19.34.227)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                08-APR-2019 18:24:02
Uptime                    0 days 0 hr. 0 min. 5 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
Listener Log File         /alidata/app/oracle/diag/tnslsnr/db/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.19.34.227)(PORT=1521)))
The listener supports no services
The command completed successfully
[oracle@db ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Mon Apr 8 18:26:11 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> select 1;
select 1
*
ERROR at line 1:
ORA-01034: ORACLE not available
Process ID: 0
Session ID: 0 Serial number: 0
```
