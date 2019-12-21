#!/bin/bash
# auth:booboowei
# date:20191215
# script_name:rman_recover_full_database.sh

# 指定全备份路径
rmanbk=/home/oracle/rmanbk/
# 指定SID的bash启动参数文件
sid_file=/home/oracle/.bash_profile

get_variables(){
# 通过RMAN恢复
echo "Get SID and RMAN backup file of spfile and controlfile."
cd $rmanbk
for i in `ls`;do db_name=`strings $i | grep db_name`; if [[ $db_name != '' ]];then file=$i;sid=`echo $db_name | awk -F '=' '{print $2}' |awk -F "'" '{print $2}'`;fi;done
echo "SID       :"$sid
echo "RMAN FILE :"$file
echo 
}


clean_database(){
echo "Set SID and Clean up database."
# 设置SID
sed -i "s/.*ORACLE_SID.*/export ORACLE_SID=${sid}/" ${sid_file}
source ${sid_file}
# 清空数据库

echo -e "shutdown immediate;\nstartup restrict exclusive force mount;\ndrop database;\nexit;" > /tmp/clean_database.sql 
sqlplus / as sysdba @/tmp/clean_database.sql
}


recover_database(){
cat > /tmp/rman_recover_database.sql << ENDF
run{
startup nomount;
restore spfile from "${rmanbk}/${file}";
startup force nomount;
restore controlfile from "${rmanbk}/${file}";
alter database mount;
catalog start with "${rmanbk}";
restore database;
recover database;
alter database open resetlogs;
}
ENDF

rman target / @/tmp/rman_recover_database.sql
echo "alter database open resetlogs;" | sqlplus / as sysdba
}

get_variables
clean_database
recover_database