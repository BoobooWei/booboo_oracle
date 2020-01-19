#!/bin/bash
# centos6 install oracle 11.2.0.4 rac 静默创建数据库
# Usage: bash AutoInstallRac04Database.sh
# author: BoobooWei
# 在节点1上，使用oracle用户执行



echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

source ${scripts_dir}/set_resource_plan.sh
mkdir -p ${oracle_tmp}

check_user(){
username=`whoami`
echo_green "当前用户为 ${username}"
if [[ ${username} == $1 ]]
then
    echo_green "执行用户与要求一致"
else
    echo_red "执行用户与要求不一致，请切换用户为 $1"
fi
}


set_database_rsp(){
echo_red "静默创建数据库应答文件准备 开始"
cat > ${oracle_tmp}/dbca.rsp << ENDF
[GENERAL]
RESPONSEFILE_VERSION = "11.2.0"
OPERATION_TYPE = "createDatabase"
[CREATEDATABASE]
GDBNAME = "rac"
DB_UNIQUE_NAME = "rac"
SID = "rac"
NODELIST=rac1,rac2
TEMPLATENAME = "General_Purpose.dbc"
SYSPASSWORD = "Zyadmin123"
SYSTEMPASSWORD = "Zyadmin123"
DATAFILEDESTINATION = "+DATA"
STORAGETYPE=ASM
DISKGROUPNAME=DATA
CHARACTERSET = "ZHS16GBK"
NATIONALCHARACTERSET= "UTF8"
DB_BLOCK_SIZE=8192
TOTALMEMORY = "1024"
ENDF
echo_green "静默创建数据库应答文件准备 结束"
}


create_database(){
echo_red "oracle实例静默安装 开始"
cd /software/database/database
./runInstaller -ignorePrereq -silent -force -responseFile ${oracle_tmp}/db.rsp
echo_green "oracle实例静默安装 安装中"
}

check_database(){
echo_green "集群数据库检查"
sqlplus -S / as sysdba
select name,open_mode from v$database;
select host_name,instance_name from gv$instance;
}


echo_red "开始时间："
date +'%Y%m%d %H:%M:%S'
check_user oracle
set_database_rsp
create_database
read
echo_red "请查看日志，确认是否安装成功"
read
echo_green "成功输入1 失败输入0："
read num
if [[ $num == 1 ]]
then
    echo_green "执行完成后按回车继续"
    read
    check_database
else
    echo_red "安装失败，结束程序"
    exit
fi

echo_red "结束时间："
date +'%Y%m%d %H:%M:%S'
