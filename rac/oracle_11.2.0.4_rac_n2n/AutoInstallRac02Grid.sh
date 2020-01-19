#!/bin/bash
# centos6 install oracle 11.2.0.4 rac 静默安装grid+asm
# Usage: bash AutoInstallRac02Grid.sh
# 在节点1上，使用grid用户执行


echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

source ${scripts_dir}/set_resource_plan.sh
mkdir -p ${grid_tmp}

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


set_grid_rsp(){
echo_red "静默安装grid应答文件准备 开始"
cat > ${grid_tmp}/grid.rsp << ENDF
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=${node1_domain_pub[1]}
INVENTORY_LOCATION=${INVENTORY_LOCATION}
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=${grid_oracle_base}
ORACLE_HOME=${grid_oracle_home}
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=asmoper
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=${scan_name}
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=rac-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=${node1_domain_pub[1]}:${node1_domain_pub_v[1]},${node2_domain_pub[1]}:${node2_domain_pub_v[1]}
# 1 pub 2 priv 3 nouse
oracle.install.crs.config.networkInterfaceList=${node1_physic_ip_eth}:${node1_physic_ip_addr}:3,${node1_public_ip_eth}:${node1_public_ip_addr}:1,${node1_private_ip_eth}:${node1_private_ip_addr}:2
oracle.install.crs.config.storageOption=ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.diskDriveMapping=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL

oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=
oracle.install.asm.SYSASMPassword=${grid_passwd}
oracle.install.asm.diskGroup.name=OCR
oracle.install.asm.diskGroup.redundancy=EXTERNAL
oracle.install.asm.diskGroup.AUSize=1
oracle.install.asm.diskGroup.disks=/dev/raw/raw1
oracle.install.asm.diskGroup.diskDiscoveryString=
oracle.install.asm.monitorPassword=${grid_passwd}
oracle.install.crs.upgrade.clusterNodes=
oracle.install.asm.upgradeASM=false
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
PROXY_HOST=
PROXY_PORT=0
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
ENDF
echo_green "静默安装grid应答文件准备 结束"
}

check_before_install_grid(){
echo_red "grid检查环境 开始"
cd /software/grid/grid
./runcluvfy.sh stage -pre crsinst -n ${node1_domain_pub[0]},${node2_domain_pub[0]} -fixup -verbose &> ${grid_tmp}check.result
echo_green "grid检查环境 结束"

}

install_grid(){
echo_red "grid静默安装 开始"
cd /software/grid/grid
./runInstaller -showProgress -ignorePrereq -silent -responseFile ${grid_tmp}/grid.rsp
echo_green "grid静默安装 安装中"
}

check_grid(){
echo_red "grid集群检查 开始"
${grid_oracle_home}/bin/crsctl check cluster -all
${grid_oracle_home}/bin/crs_stat -t
echo_red "防止监听没有成功启动,可在两个节点执行以下命令保证监听都启动。"
echo_green "srvctl add listener"
echo_green "srvctl start listener"
${grid_oracle_home}/bin/srvctl add listener
${grid_oracle_home}/bin/srvctl  start listener
${grid_oracle_home}/bin/srvctl status listener
ssh rac2 ${grid_oracle_home}/bin/srvctl add listener
ssh rac2 ${grid_oracle_home}/bin/srvctl start listener
ssh rac2 ${grid_oracle_home}/bin/srvctl status listener
crs_stat -t
echo_green "grid集群检查 结束"
}

install_adm(){
echo_red "静默安装asm实例 开始"
sqlplus -S / as sysasm << ENDF
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK '/dev/raw/raw2';
alter diskgroup data mount;
select inst_id,name,state from gv\$asm_diskgroup;
exit;
ENDF

cd ${grid_oracle_home}/dbs
orapwd file='orapw+ASM' entries=5 password=Zyadmin123 force=y
scp ${grid_oracle_home}/dbs/orapw+ASM rac2:${grid_oracle_home}/dbs/orapw+ASM
sqlplus -S / as sysasm << ENDF
create user asmsnmp identified by Zyadmin123;
grant sysdba to asmsnmp;
select * from gv\$pwfile_users;
ENDF

echo_green "静默安装asm实例 结束"
}


echo_red "开始时间："
date +'%Y%m%d %H:%M:%S'
check_user grid
set_grid_rsp
#check_before_install_grid
install_grid
echo_red "请查看日志，确认是否安装成功"
read
echo_green "成功输入1 失败输入0："
read num
if [[ $num == 1 ]]
then
    echo_green "请打开新的终端执行脚本，执行完成后按回车继续"
    read
    echo_green "开始检查集群，按回车"
    read
    check_grid
    install_adm
else
    echo_red "安装失败，结束程序"
    exit
fi

echo_red "结束时间："
date +'%Y%m%d %H:%M:%S'
