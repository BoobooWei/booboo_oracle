#!/bin/bash

# 离线冷备-物理文件备份脚本生成器
# Author: BooBooWei
# Date	: 2019-11-24

# 指定备份目录
coldbk=/home/oracle/coldbk
# 指定备份子目录，为当前的年月日时分秒
dir_name=`date +'%Y%m%d%H%M%S'`
# 创建目录
mkdir -p ${coldbk}/${dir_name}

# 准备停库脚本
cat > ${coldbk}/shut.txt << ENDF
conn / as sysdba
shutdown immediate
exit
ENDF


# 准备启动脚本
cat > ${coldbk}/start.txt << ENDF
conn / as sysdba
startup
exit
ENDF

# 准备拼接语句
cat > ${coldbk}/get_cmd.txt << ENDF
conn / as sysdba
set echo off
set feedback off
set heading off
set pagesize 1000
set linesize 100
spool ${coldbk}/${dir_name}/tmp_cmd
select 'cp -v '||name||' ${coldbk}/${dir_name}'
from
(select name from v\$controlfile
union all
select name from v\$datafile
union all
select member from v\$logfile);
spool off
exit
ENDF

sqlplus /nolog @${coldbk}/get_cmd.txt 

# 编写冷备脚本

cat > ${coldbk}/bk.sh << ENDF
sqlplus /nolog @${coldbk}/shut.txt
cp -v $ORACLE_HOME/dbs/orapw$ORACLE_SID ${coldbk}/${dir_name}
cp -v $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ${coldbk}/${dir_name}
cp -v $ORACLE_HOME/dbs/init$ORACLE_SID.ora ${coldbk}/${dir_name}
ENDF

grep -v '^$' ${coldbk}/${dir_name}/tmp_cmd.lst >> ${coldbk}/bk.sh

cat >> ${coldbk}/bk.sh << ENDF
sqlplus /nolog @${coldbk}/start.txt
ENDF

