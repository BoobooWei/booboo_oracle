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

* 多网卡 IP 的配置：阿里云HAVIP；使用 N2N ；域名解析
* 共享存储：阿里云共享块存储；使用 ISCSI2Nodes + LVM的镜像模式实现Failover

## 规划

本方案将在 ASM 上存储 OCR 和表决磁盘文件，具体是存储在一个名为 `+CRS` 的磁盘组中，该磁盘组使用*外部冗余* 配置，只有一个 OCR 位置和一个表决磁盘位置。ASM 磁盘组应在共享存储器上创建，大小至少为 2GB。 

Oracle 物理数据库文件（数据、联机重做日志、控制文件、存档重做日志）将安装在 ASM 上一个名为 `+RACDB_DATA` 的 ASM 磁盘组中，而快速恢复区将在一个名为 `+FRA` 的 ASM 磁盘组上创建。

两个 Oracle RAC 节点和网络存储服务器配置如下：

| **节点**                |                  |                               |                               |                      |                                                             |
| ----------------------- | ---------------- | ----------------------------- | ----------------------------- | -------------------- | ----------------------------------------------------------- |
| **节点名称**            | **实例名称**     | **数据库名称**                | **处理器**                    | **RAM**              | **操作系统**                                                |
| **node1**               | racdb1           | racdb. idevelopment. info     | 1 个双核 Intel Xeon，3.00 GHz | 4GB                  | CentOS 6.7- (x86_64)                                        |
| **node2**               | racdb2           | 1 个双核 Intel Xeon，3.00 GHz | 4GB                           | OEL 5.4 - (x86_64)   |                                                             |
| **openfiler1**          |                  |                               | 2 个 Intel Xeon，3.00 GHz     | 6GB                  | Openfiler 2.3 - (x86_64)                                    |
| **网络配置**            |                  |                               |                               |                      |                                                             |
| **节点名称**            | **公共 IP 地址** | **专用 IP 地址**              | **虚拟 IP 地址**              | **SCAN 名称**        | **SCAN IP 地址**                                            |
| **node1**               | 192.168.14.146   | 192.168.220.128               | 192.168.1.251                 | racnode-cluster-scan | 192.168.1.187                                               |
| **node2**               | 192.168.14.147   | 192.168.220.129               | 192.168.1.252                 |                      |                                                             |
| **openfiler1**          | 192.168.14.148   | 192.168.220.130               |                               |                      |                                                             |
| **Oracle 软件组件**     |                  |                               |                               |                      |                                                             |
| **软件组件**            | **操作系统用户** | **主组**                      | **辅助组**                    | **主目录**           | **Oracle 基目录/Oracle 主目录**                             |
| **Grid Infrastructure** | grid             | oinstall                      | asmadmin、asmdba、asmoper     | `/home/grid`         | `/u01/app/grid` `/u01/app/11.2.0/grid`                      |
| **Oracle RAC**          | oracle           | oinstall                      | dba、oper、asmdba             | `/home/oracle`       | `/u01/app/oracle` `/u01/app/oracle/product/11.2.0/dbhome_1` |
| **存储组件**            |                  |                               |                               |                      |                                                             |
| **存储组件**            | **文件系统**     | **卷大小**                    | **ASM 卷组名**                | **ASM 冗余**         | **Openfiler 卷名**                                          |
| **OCR/表决磁盘**        | ASM              | 2GB                           | +CRS                          | External             | racdb-crs1                                                  |
| **数据库文件**          | ASM              | 32GB                          | +RACDB_DATA                   | External             | racdb-data1                                                 |
| **快速恢复区**          | ASM              | 32GB                          | +FRA                          | External             | racdb-fra1                                                  |




