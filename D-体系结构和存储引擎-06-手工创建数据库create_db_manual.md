# 手工创建数据库

> 2019.10.08 BoobooWei

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [手工创建数据库](#手工创建数据库)
	- [实践——手工创建数据库db01](#实践手工创建数据库db01)
	- [自动静默建库脚本](#自动静默建库脚本)
		- [1. 根据模板配置创建参数文件](#1-根据模板配置创建参数文件)
		- [2. 创建口令文件](#2-创建口令文件)
		- [3. 创建pfile并启动到nomount状态](#3-创建pfile并启动到nomount状态)
		- [4. 生成建库SQL](#4-生成建库sql)
		- [5. 执行生成数据字典信息的脚本并执行](#5-执行生成数据字典信息的脚本并执行)

<!-- /TOC -->

[创建和配置Oracle数据库](https://docs.oracle.com/cd/B28359_01/server.111/b28310/create.htm#i1017640)

## 实践——手工创建数据库db01

```
1.修改系统环境变量
export ORACLE_SID=db01

2.创建口令文件
orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=oracle

3.创建参数文件
vi $ORACLE_HOME/dbs/initdb01.ora
--------------------------------------------------
db_name='db01'
sga_target=800m
compatible=11.2.0.4.0
control_files='/home/oracle/db01/control01.crl'
audit_file_dest='/home/oracle/db01/adump'
diagnostic_dest='/home/oracle/db01'
db_recovery_file_dest_size=4g
db_recovery_file_dest='/home/oracle/db01'
undo_tablespace=undo01
--------------------------------------------------

4.创建相关目录：
mkdir -p /home/oracle/db01/
mkdir -p /home/oracle/db01/adump

5.创建spfile启动实例到nomount
sqlplus / as sysdba
create spfile from pfile;
startup nomount

6.创建数据库
create database db01
datafile '/home/oracle/db01/system01.dbf' size 200m autoextend on next 50m extent management local
sysaux datafile '/home/oracle/db01/sysaux01.dbf' size 100m autoextend on next 50m
default temporary tablespace temp tempfile '/home/oracle/db01/temp01.dbf' size 50m
undo tablespace undo01 datafile '/home/oracle/db01/undo01.dbf' size 50m
character set zhs16gbk
national character set al16utf16
logfile
group 1 '/home/oracle/db01/redo01.log' size 50m,
group 2 '/home/oracle/db01/redo02.log' size 50m;

7.构造数据字典和PL/SQL运行环境
@?/rdbms/admin/catalog
@?/rdbms/admin/catproc
```


## 自动静默建库脚本

```bash
\#!/bin/bash
echo "author: BoobooWei"
echo "Desc: 安装数据库"
echo "User: Oracle"

### 1. 根据模板配置创建参数文件
export ORACLE_SID=BOOBOO
mkdir -p $ORACLE_BASE/oradata/$ORACLE_SID
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
mkdir -p $ORACLE_BASE/flash_recovery_area
grep -v '^#\|^$' $ORACLE_HOME/dbs/init.ora | sed  "s/\(ORCL\|orcl\)/${ORACLE_SID}/;s/<ORACLE_BASE>/\$ORACLE_BASE/;s@ora_control1@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control1.ctl@;s@ora_control2@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control2.ctl@" > $ORACLE_HOME/dbs/init${ORACLE_SID}.ora


### 2. 创建口令文件
orapwd file=orapw$ORACLE_SID password=oracle entries=30

### 3. 创建pfile并启动到nomount状态
echo "create spfile from pfile" | sqlplus / as sysdba
echo "startup nomount" | sqlplus / as sysdba


### 4. 生成建库SQL
cat > createdb.sql << ENDF
CREATE DATABASE $ORACLE_SID
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE GROUP 1 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo01a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo01b.log') SIZE 100M BLOCKSIZE 512,
           GROUP 2 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo02a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo02b.log') SIZE 100M BLOCKSIZE 512,
           GROUP 3 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo03a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo03b.log') SIZE 100M BLOCKSIZE 512
   MAXLOGFILES 5
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 1
   MAXDATAFILES 100
   CHARACTER SET US7ASCII
   NATIONAL CHARACTER SET AL16UTF16
   EXTENT MANAGEMENT LOCAL
   DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/system01.dbf' SIZE 325M REUSE
   SYSAUX DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/sysaux01.dbf' SIZE 325M REUSE
   DEFAULT TABLESPACE users
      DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/users01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE temp
      TEMPFILE '$ORACLE_BASE/oradata/$ORACLE_SID/temp01.dbf'
      SIZE 20M REUSE
   UNDO TABLESPACE undotbs1
      DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
ENDF

echo "@createdb.sql" | sqlplus / as sysdba

### 5. 执行生成数据字典信息的脚本并执行

cat > 1.sql << ENDF
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
conn system/oracle
@?/sqlplus/admin/pupbld.sql
ENDF

echo "@1.sql" | sqlplus / as sysdba
```
