#!/bin/bash
# get_resource_plan.sh
# Auth: BoooBooWei 2020.01.09

echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

get_resource_plan(){
# 交互式创建root用户无密钥登陆两个节点
rm -rf /root/.ssh/id_rsa
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
for i in ${node1_physic_ip_addr} ${node2_physic_ip_addr}
do
    ssh-copy-id "-p ${ssh_port} root@${i}"
done


# 获取节点物理信息
node1_cpu=`lscpu| grep ^CPU\(s\): | awk '{print $2}'`
node2_cpu=`ssh ${node2_physic_ip_addr} -p ${ssh_port} lscpu| grep ^CPU\(s\): | awk '{print $2}'`

node1_mem=`cat /proc/meminfo | grep MemTotal| awk '{print $2 $3}'`
node2_mem=`ssh ${node2_physic_ip_addr} -p ${ssh_port} cat /proc/meminfo | grep MemTotal| awk '{print $2 $3}'`

node1_os=`cat /etc/redhat-release`
node2_os=`ssh ${node2_physic_ip_addr} -p ${ssh_port} cat /etc/redhat-release`

echo_red "节点信息"
printf "%-20s %-10s %-20s %-20s %-20s %-20s \n"  节点名称 数据库名称 处理器 内存 操作系统
printf "%-20s %-10s %-10s %-10s %-10s %-20s \n"  ${node1_hostname} ${database_name} ${node1_cpu} ${node1_mem} "${node1_os}"
printf "%-20s %-10s %-10s %-10s %-10s %-20s \n"  ${node2_hostname} ${database_name} ${node2_cpu} ${node2_mem} "${node2_os}"

echo_red "资源规划-全局参数配置"
printf "%-25s %-25s %-25s %-25s %-20s %-20s \n"  节点名称 公共IP-网卡 虚拟IP-网卡 专用IP-网卡 SCAN-IP SCAN名称
printf "%-20s %-20s %-20s %-20s %-20s %-20s \n"  ${node1_hostname} ${node1_public_ip_addr}-${node1_public_ip_eth} ${node1_public_vip} ${node1_private_ip_addr}-${node1_private_ip_eth} ${scan_ip} ${scan_name}
printf "%-20s %-20s %-20s %-20s %-20s %-20s \n"  ${node2_hostname} ${node2_public_ip_addr}-${node2_public_ip_eth} ${node2_public_vip} ${node2_private_ip_addr}-${node2_private_ip_eth}

echo_red "Oracle 软件组件"
printf "%-30s %-30s %-30s %-25s %-30s %-20s \n"  软件组件 操作系统用户 主组 辅助组 主目录 Oracle基目录/Oracle主目录
printf "%-30s %-20s %-20s %-30s %-20s %-20s \n"  "Grid Infrastructure" "grid  " "oinstall" "asmadmin、asmdba、asmoper" "/home/grid  " "/alidata/app/grid,/u01/app/11.2.0/grid"
printf "%-30s %-20s %-20s %-30s %-20s %-20s \n"  "Oracle RAC         " "oracle" "oinstall" "dba、oper、asmdba        " "/home/oracle" "/alidata/app/oracle,/alidata/app/oracle/product/11.2.0/dbhome_1"

echo_red "Oracle Grid 密码"
echo ${grid_passwd}
}

source set_resource_plan.sh
get_resource_plan