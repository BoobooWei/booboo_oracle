#!/bin/bash

# author: BoobooWei
# Desc: 安装数据库
# User: Oracle 

## 1. 根据模板配置创建参数文件
export ORACLE_SID=BOOBOO
mkdir -p $ORACLE_BASE/oradata/$ORACLE_SID
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
mkdir -p $ORACLE_BASE/flash_recovery_area
grep -v '^#\|^$' $ORACLE_HOME/dbs/init.ora | sed  "s/\(ORCL\|orcl\)/${ORACLE_SID}/;s/<ORACLE_BASE>/\$ORACLE_BASE/;s@ora_control1@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control1.ctl@;s@ora_control2@\$ORACLE_BASE/oradata/${ORACLE_SID}/ora_control2.ctl@" > $ORACLE_HOME/dbs/init${ORACLE_SID}.ora


## 2. 创建口令文件
orapwd file=orapw$ORACLE_SID password=oracle entries=30

## 3. 创建pfile并启动到nomount状态
echo "create spfile from pfile" | sqlplus / as sysdba
echo "startup nomount" | sqlplus / as sysdba


## 4. 生成建库SQL
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

## 5. 执行生成数据字典信息的脚本并执行

cat > 1.sql << ENDF
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
conn system/oracle
@?/sqlplus/admin/pupbld.sql
ENDF

echo "@1.sql" | sqlplus / as sysdba

