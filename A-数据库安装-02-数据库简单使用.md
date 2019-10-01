<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [数据库简单使用](#数据库简单使用)
	- [第一次连接oracle数据库](#第一次连接oracle数据库)
	- [解锁scott用户](#解锁scott用户)
	- [配置数据库环境](#配置数据库环境)
		- [开机自动启动数据库](#开机自动启动数据库)
		- [安装插件rlwrap](#安装插件rlwrap)
		- [美化结果集的脚本文件](#美化结果集的脚本文件)
	- [客户端sqldeveloper工具的使用](#客户端sqldeveloper工具的使用)

<!-- /TOC -->

# 数据库简单使用

## 第一次连接oracle数据库

1. 需要.bashrc中的变量 ORACLE_SID="你安装的数据库名"
2. 通过sqlplus来执行
- A. 本地匿名登陆	`sqlplus /` ；解释：“/”左右为 用户名/密码，现在是匿名登陆
- B. 使用最高权限使用者登陆`sqlplus / as sysdba` ；解释： `as sysdba`是指定登陆用户的角色为oracle数据库sys用户，而sys用户在oracle内部的地位就等于root在linux中的地位，最大权限，不受库的限制，是管理用户

> 为了学习sql语句，我们使用一个scott用户

## 解锁scott用户

```shell
[oracle@install0 oracle]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Fri May 26 16:47:07 2017

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL> show user;
USER is "SYS"
SQL> conn scott/tiger;
ERROR:
ORA-28000: the account is locked


Warning: You are no longer connected to ORACLE.
SQL> conn / as sysdba;
Connected.
SQL> alter user scott identified by tiger account unlock;   

User altered.

SQL> conn scott/tiger;   
Connected.
SQL> select * from tab;

TNAME			       TABTYPE	CLUSTERID
------------------------------ ------- ----------
BONUS			       TABLE
DEPT			       TABLE
EMP			       TABLE
SALGRADE		       TABLE
```

- `show user`命令可以查看到当前登陆的用户名为`sys`
- oracle中有一个用户叫`scott`，初始密码为`tiger`,该用户当前是被锁定的状态；
- `conn scott/tiger` 该命令尝试连接scott用户
- `conn / as sysdba` 该命令重新连接sys用户
- `alter user scott identified by tiger account unlock;` 该命令将scott用户解锁
- `conn scott/tiger` 此时就发现可以连接上scott用户，该用户有很多表，我们可以拿来作sql练习
- `select * from tab;` 查看scott用户有哪些表,里面有四张表，能完成90%的sql语句练习

## 配置数据库环境


### 开机自动启动数据库

```shell
vi /etc/oratab
-------------------------------------------
orcl:/u01/app/oracle/product/11.2.0/db_1:Y

vi /etc/rc.local
-------------------------------------------
su - oracle '-c dbstart $ORACLE_HOME'
```



### 安装插件rlwrap

使sqlplus可以光标回退，命令回显，使用方向键操作命令行

```shell
scp rlwrap-0.30-1.el5.i386.rpm root@172.25.0.12:/root
ssh root@172.25.0.12
rpm -ivh rlwrap-0.30-1.el5.i386.rpm
```

在.bashrc中增加调用sqlplus的别名

```shell
vi .bashrc
------------------------------------
alias sqlplus='rlwrap sqlplus'
```

使.bashrc新增的内容生效

```shell
source .bashrc
```

启动sqlplus

```shell
sqlplus /nolog
sqlplus / as sysdba
sqlplus scott/tiger
```

### 美化结果集的脚本文件

```shell
vi /home/oracle/login.sql
-------------------------
set linesize 120
set pagesize 500
```

增加环境变量使sqlplus永远能读取/home/oracle/login.sql

```shell
vi .bashrc
---------------------------
export SQLPATH=/home/oracle
```

使.bashrc新增的内容生效

```shell
source .bashrc
```

## 客户端sqldeveloper工具的使用

oracle 11g中没有了isql/plus（b/s）,而是改为了sqldeveloper（C/S）

1. 启动监听`lsnrctl start`
2. 修改`alter system register`
3. 查看监听状态`lsnrctl status`，获取监听端口1521和数据库实例db01
4. 打开sqldeveloper软件`$ORACLE_HOME/sqldeveloper/sqldeveloper.sh`
```shell
connection name : scoot
username: scoot
password: triger
save password yes
hostname:172.25.0.11
port:1521
sid:db01
```
