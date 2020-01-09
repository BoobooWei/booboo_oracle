#!/bin/bash
# centos6 install oracle 11.2.0.4 rac 静默安装grid
# Usage: bash AutoInstallRac02Grid.sh
# 在节点1上，使用grid用户执行


echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

source set_resource_plan.sh
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
INVENTORY_LOCATION=${rac_dir}/grid/app/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=${rac_dir}/grid/app/grid
ORACLE_HOME=${rac_dir}/grid/app/11.2.0/grid
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
./runInstaller -showProgress -ignorePrereq -silent -responseFile ${grid_tmp}/grid.rsp  &> ${grid_tmp}/install_grid.result
echo_green "grid静默安装 结束"
}

check_grid(){
echo_red "grid集群检查 开始"
${rac_dir}/grid/app/11.2.0/grid/bin/crsctl check cluster -all
${rac_dir}/grid/app/11.2.0/grid/bin/crs_stat -t
echo_green "grid集群检查 结束"
}

install_adm(){
echo_red "静默安装asm实例 开始"

echo_green "静默安装asm实例 开始"
}

check_user grid
set_grid_rsp
#check_before_install_grid
install_grid
echo_red "请查看日志，确认是否安装成功"
read -p "成功输入1 失败输入0" num
if [[ $num == 1 ]]
then
    echo_green "1. /u01/app/oraInventory/orainstRoot.sh 2. /u01/app/11.2.0/grid/root.sh"
    read -p "请打开新的终端执行脚本，执行完成后按回车继续"
    read -p "开始检查集群，按回车"
    check_grid
else
    echo_red "安装失败，结束程序"
    exit
fi