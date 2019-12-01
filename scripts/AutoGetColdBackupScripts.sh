#!/bin/bash

# 离线冷备-物理文件备份脚本生成器
# Author: BooBooWei
# Date	: 2019-11-24


read -p '指定备份目录 [ default /home/oracle/coldbk] :' coldbk
if [ -z ${coldbk} ]
then
	coldbk=/home/oracle/coldbk
	echo "备份目录为：${coldbk}"
else	
	echo "备份目录为：${coldbk}"
fi	

read -p '指定备份子目录 [默认为当前的年月日时分秒] :' dir_name
if [ -z ${dir_name} ]
then
	dir_name=`date +'%Y%m%d%H%M%S'`
	echo "备份子目录为：${dir_name}"
else	
	echo "备份子目录为：${dir_name}"
fi
	
read -p '开始生成脚本，请按回车键'
	
# 创建目录
mkdir -p ${coldbk}/${dir_name}
echo "${coldbk}/${dir_name}目录创建	OK" 

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
select 'cp -v '||name||' ${coldbk}/${dir_name}/'
from
(select name from v\$controlfile
union all
select name from v\$datafile
union all
select member from v\$logfile);
spool off
exit
ENDF

sqlplus /nolog @${coldbk}/get_cmd.txt $> /dev/null

# 编写冷备脚本

cat > ${coldbk}/bk.sh << ENDF
sqlplus /nolog @${coldbk}/shut.txt
cp -v $ORACLE_HOME/dbs/orapw$ORACLE_SID ${coldbk}/${dir_name}/
cp -v $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ${coldbk}/${dir_name}/
cp -v $ORACLE_HOME/dbs/init.ora ${coldbk}/${dir_name}/
ENDF

grep -v '^$' ${coldbk}/${dir_name}/tmp_cmd.lst >> ${coldbk}/bk.sh

cat >> ${coldbk}/bk.sh << ENDF
sqlplus /nolog @${coldbk}/start.txt
ENDF

echo "离线冷备-物理文件备份脚本生成	OK"
echo "查看脚本：ll ${coldbk}/bk.sh"



#自动恢复脚本
#sed -n '1p' bk.sh > rt.sh
#grep -v 'sqlplus' bk.sh | awk '{split($3,i,"/");print $1,$2,$4i[length(i)],$3}' >> rt.sh
#sed -n '$p' bk.sh >> rt.sh
#chmod a+x rt.sh
