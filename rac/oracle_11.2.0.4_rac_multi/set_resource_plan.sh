#!/bin/bash
# set_resource_plan.sh
# Auth: BoooBooWei 2020.01.09

set_resource_plan(){
ssh_port=22
scripts_dir=/root # 脚本存放路径
grid_tmp=/home/grid/grid_tmp/ # grid 安装记录临时存放路径
grid_passwd=Zyadmin123 # grid 应答文件中SYSASMPassword 和 monitorPassword 的密码
database_name=rac # 数据库名称
LANG=ZHS16GBK # 数据库字符集 ZHS16GBK\AL32UTF8\AL16UTF16

node1_hostname=rac1 # 节点1 名称，主机名，实例名
node1_physic_ip=eth0:172.16.1.31 # 节点1 真实的物理网卡和地址
node1_public_ip=eth0:172.16.1.31 # 节点1 公共IP 网卡和地址
node1_public_vip=172.16.1.100 # 节点1 虚拟IP 网卡和地址
node1_private_ip=eth1:172.16.2.82 # 节点1 专用IP 网卡和地址
node1_domain_pub=(rac1 rac1.example.com) # 节点1 公共IP 域名
node1_domain_pub_v=(rac1-vip rac1-vip.example.com) # 节点1 虚拟IP 域名
node1_domain_pri=(rac1-priv rac1-priv.example.com) # 节点1 专用IP 域名


node2_hostname=rac2 # 节点2 名称，主机名，实例名
node2_physic_ip=eth0:172.16.1.30 # 节点2 真实的物理网卡和地址
node2_public_ip=eth0:172.16.1.30 # 节点2 公共IP 网卡和地址
node2_public_vip=172.16.1.101 # 节点2 虚拟IP 网卡和地址
node2_private_ip=eth1:172.16.2.81 # 节点2 专用IP 网卡和地址
node2_domain_pub=(rac2 rac2.example.com) # 节点2 公共IP 域名
node2_domain_pub_v=(rac2-vip rac2-vip.example.com) # 节点2 虚拟IP 域名
node2_domain_pri=(rac2-priv rac2-priv.example.com) # 节点2 专用IP 域名

scan_ip=172.16.1.88 # SCAN IP 地址
scan_name=rac-cluster-scan # SCAN名称

rac_dir=/alidata/ # rac和oracle安装最顶级目录
grid_oracle_base=${rac_dir}/grid/app/grid
grid_oracle_home=${rac_dir}/grid/app/11.2.0/grid
oracle_oracle_base=${rac_dir}/oracle
oracle_oracle_home=${rac_dir}/oracle/product/11.2.0/dbhome_1
INVENTORY_LOCATION=${rac_dir}/grid/app/oraInventory

shared_storage=("/dev/vdb1" "/dev/vdb2") # 共享存储块设备


# 获取真实的物理网卡IP和网卡
node1_physic_ip_addr=${node1_physic_ip#*:}
node1_physic_ip_eth=${node1_physic_ip/:*}
node2_physic_ip_addr=${node2_physic_ip#*:}
node2_physic_ip_eth=${node2_physic_ip/:*}

# 获取专用IP和网卡
node1_private_ip_addr=${node1_private_ip#*:}
node1_private_ip_eth=${node1_private_ip/:*}
node2_private_ip_addr=${node2_private_ip#*:}
node2_private_ip_eth=${node2_private_ip/:*}

# 获取专用IP的网段（/24）
node1_private_ip_net=`echo ${node1_private_ip_addr} | awk -F '.' '{print $1"."$2"."$3".0"}'`
node2_private_ip_net=`echo ${node2_private_ip_addr} | awk -F '.' '{print $1"."$2"."$3".0"}'`

# 获取公共IP和网卡
node1_public_ip_addr=${node1_public_ip#*:}
node1_public_ip_eth=${node1_public_ip/:*}
node2_public_ip_addr=${node2_public_ip#*:}
node2_public_ip_eth=${node2_public_ip/:*}

# 获取公共IP的网段（/24）
node1_public_ip_net=`echo ${node1_public_ip_addr} | awk -F '.' '{print $1"."$2"."$3".0"}'`
node2_public_ip_net=`echo ${node2_public_ip_addr} | awk -F '.' '{print $1"."$2"."$3".0"}'`
}
