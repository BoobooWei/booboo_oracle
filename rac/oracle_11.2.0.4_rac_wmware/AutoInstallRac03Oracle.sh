#!/bin/bash
# centos6 install oracle 11.2.0.4 rac 静默安装oracle实例
# Usage: bash AutoInstallRac03Oracle.sh
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


set_oracle_rsp(){
echo_red "静默安装oracle应答文件准备 开始"
sed -i 's/\(<HOME NAME=.*\)>/\1 CRS="true">/' ${INVENTORY_LOCATION}/ContentsXML/inventory.xml
cat > ${oracle_tmp}/db.rsp << ENDF
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=${node1_domain_pub[1]}
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=${INVENTORY_LOCATION}
SELECTED_LANGUAGES=en
ORACLE_HOME=${oracle_oracle_home}
ORACLE_BASE=${oracle_oracle_base}
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.CLUSTER_NODES=rac1,rac2
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.config.starterdb.characterSet=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=Zyadmin123
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
ENDF
echo_green "静默安装oracle应答文件准备 结束"
}


install_oracle(){
echo_red "oracle实例静默安装 开始"
cd /software/database/database
./runInstaller -ignorePrereq -silent -force -responseFile ${oracle_tmp}/db.rsp
echo_green "oracle实例静默安装 安装中"
}


echo_red "开始时间："
date +'%Y%m%d %H:%M:%S'
check_user oracle
set_oracle_rsp
install_oracle
read
echo_red "请查看日志，确认是否安装成功"
read
echo_green "成功输入1 失败输入0："
read num
if [[ $num == 1 ]]
then
    echo_green "请打开新的终端执行脚本，执行完成后按回车继续"
    read
else
    echo_red "安装失败，结束程序"
    exit
fi

echo_red "结束时间："
date +'%Y%m%d %H:%M:%S'
