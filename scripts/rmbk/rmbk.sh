USER=oracle
LD_LIBRARY_PATH=/alidata/oracle/product/11.2.0/db_1/lib:/lib:/usr/lib
ORACLE_SID=testdb
ORACLE_HOSTNAME=NB-flexgw1
ORACLE_BASE=/alidata/oracle
ORACLE_BASE=/alidata/oracle
PATH=/alidata/oracle/product/11.2.0/db_1/bin:/usr/sbin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/lib/golang/bin:/usr/local/go/bin:/alidata/mysql/bin:/home/oracle/bin
MAIL=/var/spool/mail/oracle
PWD=/home/oracle
SQLPATH=/home/oracle/login.sql
HOME=/home/oracle
LOGNAME=oracle
CLASSPATH=/alidata/oracle/product/11.2.0/db_1/jlib:/alidata/oracle/product/11.2.0/db_1/rdbms/jlib
ORACLE_HOME=/alidata/oracle/product/11.2.0/db_1
ORACLE_HOME=/alidata/oracle/product/11.2.0/db_1
rmbk_dir=/home/oracle/rmbk
dirname=`date +'%Y%m%d'`
mkdir -p ${rmbk_dir}/${dirname}
week=`date +'%w'`

if [[ ${week} == 0 ]]
then
    level=0
else
    level=1
fi

rman target / log=/home/oracle/rmbk/bak_inc${level}.log append cmdfile=/home/oracle/rmbk/rmanbk_inc${level}

#del old folders
find /home/oracle/rmbk -type d -mtime +13 -exec ls -d {} \;
find /home/oracle/rmbk -mtime +13 -exec rm -rf {} \;
