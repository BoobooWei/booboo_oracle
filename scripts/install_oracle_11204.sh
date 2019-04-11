#!/usr/bin/env bash
# Usage: bash install_oracle_11204.sh [OPTION]...
# arg:
## -l 指定字符集，例如LANG=ZHS16GBK\AL32UTF8\AL16UTF16，用法： -l AL32UTF8
## -s 指定SID，例如ORACLE_SID=BOOBOO，用法： -s BOOBOO


for arg in ${@}
do
    case $arg in
      -l)
          shift;
          NLS_LANG=$1;;
      -s)
          shift;
          ORACLE_SID=$1;;
    esac
done

LANG=AMERICAN_AMERICA.${LANG}
ORACLE_SID=${ORACLE_SID}

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
export ORACLE_SID=${ORACLE_SID}
export NLS_LANG=AMERICAN_AMERICA.${NLS_LANG}
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
bash /alidata/app/oraInventory/orainstRoot.sh
bash /alidata/app/oracle/product/11.2.0/dbhome_1/root.sh

su - oracle
LISTENERIP=$(ifconfig | grep "inet addr:" | grep -vP "`curl icanhazip.com 2>/dev/null`|127.0.0.1" |awk -F "[ :]*" '{print $4}')
sed -i "s/LISTENERIP/${LISTENERIP}/" /alidata/app/oracle/product/11.2.0/dbhome_1/network/admin/listener.ora
lsnrctl status
lsnrctl start


mkdir -p $ORACLE_BASE/oradata/$ORACLE_SID
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
mkdir -p $ORACLE_BASE/flash_recovery_area
grep -v '^#\|^$' $ORACLE_HOME/dbs/init.ora | sed  "s/\(ORCL\|orcl\)/${ORACLE_SID}/;s/<ORACLE_BASE>/\$ORACLE_BASE/;s@ora_control1@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control1.ctl@;s@ora_control2@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control2.ctl@" > $ORACLE_HOME/dbs/init${ORACLE_SID}.ora

orapwd file=orapw${db_name} password=oracle entries=30

echo "create spfile from pfile" | sqlplus / as sysdba
echo "startup nomount" | sqlplus / as sysdba


LANG=AL32UTF8
cat > $ORACLE_HOME/dbs/createdb.sql << ENDF
CREATE DATABASE $ORACLE_SID
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE GROUP 1 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo01a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo01b.log') SIZE 100M BLOCKSIZE 512,
           GROUP 2 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo02a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo02b.log') SIZE 100M BLOCKSIZE 512,
           GROUP 3 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo03a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo03b.log') SIZE 100M BLOCKSIZE 512
   MAXLOGFILES 5
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 1
   MAXDATAFILES 100
   CHARACTER SET US7ASCII
   NATIONAL CHARACTER SET ${LANG}
   EXTENT MANAGEMENT LOCAL
   DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/system01.dbf' SIZE 325M REUSE
   SYSAUX DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/sysaux01.dbf' SIZE 325M REUSE
   DEFAULT TABLESPACE users
      DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/users01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE temp
      TEMPFILE '$ORACLE_BASE/oradata/$ORACLE_SID/temp01.dbf'
      SIZE 20M REUSE
   UNDO TABLESPACE undotbs1
      DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

      
