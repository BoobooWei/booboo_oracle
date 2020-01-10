# 在阿里云ECS上搭建Oracle11g RAC实施方案

[TOC]

## RAC 概念

[Real Application Clusters Administration and Deployment Guide ](https://docs.oracle.com/cd/E11882_01/rac.112/e41960/toc.htm)

Oracle RAC 是 Oracle Real Application Cluster  的简写，Oracle Real Application Clusters通过将单个数据库服务器作为单个故障点删除而为客户提供了最高的数据库可用性。在群集服务器环境中，数据库本身在服务器池之间共享，这意味着，如果服务器池中的任何服务器发生故障，数据库将继续在正常运行的服务器上运行。Oracle RAC不仅使客户能够在服务器发生故障时继续处理数据库工作负载，而且还可以通过减少数据库脱机进行计划内维护操作的时间来进一步降低停机成本。 

Oracle Real Application Clusters使Oracle数据库跨集群服务器池的透明部署成为可能。这使客户可以轻松地将其单服务器Oracle数据库重新部署到数据库服务器集群上，从而充分利用集群数据库服务器提供的组合内存容量和处理能力。 

Oracle Real Application Clusters提供了在服务器池中轻松部署Oracle数据库并充分利用群集提供的性能，可伸缩性和可用性所需的所有软件组件。Oracle RAC利用Oracle Grid Infrastructure作为Oracle RAC数据库系统的基础。Oracle Grid Infrastructure包括Oracle集群件和Oracle自动存储管理（ASM），它们可以在高度可用且可扩展的数据库云环境中高效共享服务器和存储资源。 

Oracle RAC 根本的功能就在于多节点的负载均衡（Loadbalance）以及实例级的故障转移（Failover）。以下是 Oracle11g RAC 的原理图：

![img](pic/04.jpg)



## 背景

### ECS 上主机安装 RAC 的问题

在 ECS 主机上安装 Oracle RAC，一直以来有两个需要解决的问题，一是多网卡 IP 的配置， 一是共享存储。

* 多网卡 IP 的配置：阿里云HAVIP；使用 N2N 
* 共享存储：阿里云共享块存储；使用 ISCSI

本文档，使用N2N和ISCSI实现。

## 规划

本方案将在 ASM 上存储 OCR 和表决磁盘文件，具体是存储在一个名为 `+CRS` 的磁盘组中，该磁盘组使用*外部冗余* 配置，只有一个 OCR 位置和一个表决磁盘位置。ASM 磁盘组应在共享存储器上创建，大小至少为 2GB。 

Oracle 物理数据库文件（数据、联机重做日志、控制文件、存档重做日志）将安装在 ASM 上一个名为 `+DATA` 的 ASM 磁盘组中，而快速恢复区将在一个名为 `+FRA` 的 ASM 磁盘组上创建。

两个 Oracle RAC 节点和网络存储服务器配置如下：

| **节点**                |                  |                  |                               |                  |                                                              |
| ----------------------- | ---------------- | ---------------- | ----------------------------- | ---------------- | ------------------------------------------------------------ |
| **节点名称**            | **实例名称**     | **数据库名称**   | **处理器**                    | **RAM**          | **操作系统**                                                 |
| **rac1**                | rac1             | racdb            | 14个双核 Intel Xeon，3.00 GHz | 4GB              | CentOS 6.7- (x86_64)                                         |
| **rac2**                | rac2             |                  | 4个双核 Intel Xeon，3.00 GHz  | 4GB              | CentOS 6.7- (x86_64)                                         |
| **网络配置**            |                  |                  |                               |                  |                                                              |
| **节点名称**            | **公共 IP 地址** | **专用 IP 地址** | **虚拟 IP 地址**              | **SCAN 名称**    | **SCAN IP 地址**                                             |
| **node1**               | 172.16.10.19     | 172.16.9.75      | 172.16.10.29                  | rac-cluster-scan | 172.16.10.88                                                 |
| **node2**               | 172.16.10.20     | 172.16.9.76      | 172.16.10.30                  |                  |                                                              |
| **Oracle 软件组件**     |                  |                  |                               |                  |                                                              |
| **软件组件**            | **操作系统用户** | **主组**         | **辅助组**                    | **主目录**       | **Oracle 基目录/Oracle 主目录**                              |
| **Grid Infrastructure** | grid             | oinstall         | asmadmin、asmdba、asmoper     | `/home/grid`     | `/alidata/app/grid` `/u01/app/11.2.0/grid`                   |
| **Oracle RAC**          | oracle           | oinstall         | dba、oper、asmdba             | `/home/oracle`   | `/alidata/app/oracle` `/alidata/app/oracle/product/11.2.0/dbhome_1` |
| **存储组件**            |                  |                  |                               |                  |                                                              |
| **存储组件**            | **文件系统**     | **卷大小**       | **ASM 卷组名**                | **ASM 冗余**     | **Openfiler 卷名**                                           |
| **OCR/表决磁盘**        | ASM              | 2GB              | +CRS                          | External         | racdb-crs1                                                   |
| **数据库文件**          | ASM              | 32GB             | +RACDB_DATA                   | External         | racdb-data1                                                  |
| **快速恢复区**          | ASM              | 32GB             | +FRA                          | External         | racdb-fra1                                                   |

## 安装配置

### 资源规划-全局参数配置

```bash
#!/bin/bash
# set_resource_plan.sh
# Auth: BoooBooWei 2020.01.09

set_resource_plan(){
ssh_port=22
grid_tmp=/home/grid/grid_tmp/ # grid 安装记录临时存放路径
grid_passwd=Zyadmin123 # grid 应答文件中SYSASMPassword 和 monitorPassword 的密码
database_name=racdb # 数据库名称

node1_hostname=rac1 # 节点1 名称，主机名，实例名
node1_physic_ip=eth0:172.16.1.24 # 节点1 真实的物理网卡和地址
node1_public_ip=eth1:172.16.10.19 # 节点1 公共IP 网卡和地址
node1_public_vip=172.16.10.29 # 节点1 虚拟IP 网卡和地址
node1_private_ip=eth2:172.16.2.75 # 节点1 专用IP 网卡和地址
node1_domain_pub=(rac1 rac1.example.com) # 节点1 公共IP 域名
node1_domain_pub_v=(rac1-vip rac1-vip.example.com) # 节点1 虚拟IP 域名
node1_domain_pri=(rac1-priv rac1-priv.example.com) # 节点1 专用IP 域名


node2_hostname=rac2 # 节点2 名称，主机名，实例名
node2_physic_ip=eth0:172.16.1.23 # 节点2 真实的物理网卡和地址
node2_public_ip=eth1:172.16.10.20 # 节点2 公共IP 网卡和地址
node2_public_vip=172.16.10.30 # 节点2 虚拟IP 网卡和地址
node2_private_ip=eth2:172.16.2.76 # 节点2 专用IP 网卡和地址
node2_domain_pub=(rac2 rac2.example.com) # 节点2 公共IP 域名
node2_domain_pub_v=(rac2-vip rac2-vip.example.com) # 节点2 虚拟IP 域名
node2_domain_pri=(rac2-priv rac2-priv.example.com) # 节点2 专用IP 域名

scan_ip=172.16.10.88 # SCAN IP 地址
scan_name=rac-cluster-scan # SCAN名称

rac_dir=/alidata/ # rac和oracle安装最顶级目录
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

# 获取公共IP和网卡
node1_public_ip_addr=${node1_public_ip#*:}
node1_public_ip_eth=${node1_public_ip/:*}
node2_public_ip_addr=${node2_public_ip#*:}
node2_public_ip_eth=${node2_public_ip/:*}
}


set_resource_plan
```

### 通用配置

| No.  | 配置项                            | 自动化 |
| ---- | --------------------------------- | ------ |
| 1    | 设置/etc/hosts文件                | Yes    |
| 2    | 配置/etc/sysctl.conf参数          | Yes    |
| 3    | 配置/etc/security/limits.conf参数 | Yes    |
| 4    | 配置/etc/pam.d/login参数          | Yes    |
| 5    | 关闭iptables & selinux            | Yes    |
| 6    | 配置 modprobe hangcheck-timer     | Yes    |
| 7    | 配置/etc/profile文件              | Yes    |
| 8    | 创建用户及组                      | Yes    |
| 9    | 创建目录                          | Yes    |
| 10   | 配置NTP                           | Yes    |


### rac1/rac2环境配置

| No.  | 配置项                 | 自动化 |
| ---- | ---------------------- | ------ |
| 1    | 修改主机名             | Yes    |
| 2    | 设置oracle用户环境变量 | Yes    |
| 3    | 设置grid用户环境变量   | Yes    |
| 4    | 配置节点间的ssh信任    | 半自动 |

### rac1/rac2配置N2N

| No.  | 配置项                 | 自动化 |
| ---- | ---------------------- | ------ |
| 1    | 修改主机名             | Yes    |
| 2    | 设置oracle用户环境变量 | Yes    |

### rac1/rac2配置ISCSI

| No.  | 配置项                 | 自动化 |
| ---- | ---------------------- | ------ |
| 1    | 修改主机名             | Yes    |
| 2    | 设置oracle用户环境变量 | Yes    |

如果修改了主机名需要先重启服务器让其永久生效。

### 软件安装

| No.  | 配置项                       | 自动化 |
| ---- | ---------------------------- | ------ |
| 1    | 依赖软件包安装               | Yes    |
| 2    | 设置主机启动级别为5 图形界面 | Yes    |
| 3    | 获取RAC安装包                | Yes    |

### 安装grid

| No.  | 配置项                   | 自动化 |
| ---- | ------------------------ | ------ |
| 1    | 静默安装grid应答文件准备 | Yes    |
| 2    | grid检查环境             | Yes    |
| 3    | grid静默安装             | Yes    |
|      | root执行脚本             | No     |

### 安装ASM实例

| No.  | 配置项                  | 自动化 |
| ---- | ----------------------- | ------ |
| 1    | 静默安装asm应答文件准备 |        |
| 2    | asm实例添加DATA磁盘组   |        |

### 安装oracle

### 创建数据库

### 配置监听





待确认问题：

待解决：开机启动时如何在集群前启动？