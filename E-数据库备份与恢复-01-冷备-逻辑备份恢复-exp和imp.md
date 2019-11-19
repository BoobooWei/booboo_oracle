# 冷备和恢复工具-exp和imp

*逻辑备份和恢复*

> 2019.11.10 BoobooWei

[toc]

## `exp`和`imp`简介

冷备（俗称的备份）中，`exp`属于逻辑备份工具。

我的理解：

1. Oracle `exp`  备份工具对应 MySQL 的逻辑备份工具 `mysqldump`

2. 备份需要考虑两点：`数据一致性`和`服务可用性`

3. Oracle `exp`与 MySQL `mysqldump`备份`InnoDB`存储引擎的表在`数据一致性`上是相同的，备份的数据的时间点为`备份开始的时间点`

4. Oracle `exp`与 MySQL `mysqldump`备份`InnoDB`存储引擎的表在`服务可用性`上是相同的，备份的数据时`不影响数据库的读和写`,但`mysqldump`需要指定参数`--single-transaciton`

5. 从功能上来对比：Oracle `exp`功能更多：1）可以备份`表空间`；2）可以备份`闪回数据（历史版本数据）`

6. 从备份文件类型对比：Oracle `exp`的备份文件为`二进制文件`（可通过`strings`命令转为`文本文件`）； MySQL `mysqldump`备份文件为`文本文件（sql语句）`

7. Oracle`imp`导入工具是专门解析`exp`工具备份的`二进制文件`，并导入到Oracle数据库的一个工具。

8. Oracle `exp`重点掌握以下功能：`单表导出、单表过滤行导出、多表导出、元数据导出、全库导出、属于某个用户的表导出、表空间导出`

### `exp`注意事项

1. `exp`程序需在目录中发现同名文件会直接覆盖，不提示；
2. `exp`无法备份无段的空表，`版本 < Oracle11.2`
3.  一定要注意字符集，可以在备份之前`测试中文`
4. 若`字符集不一致`，导入后数据直接`丢失`
5. 该工具已过时，建议逻辑备份使用`expdp`

## 逻辑备份恢复的一般步骤

### `exp`逻辑备份的一般步骤

1. 检查字符集一致性
2. 创建备份目录
3. 开始备份
4. 检查备份

### `imp`逻辑恢复的一般步骤

1. 检查字符集一致性
2. 清数据
3. 导入数据
4. 检查数据

## 检查字符集一致性

### 1 检查Oracle实例字符集的SQL命令

```sql
column parameter format a35
column value format a30
select * from nls_database_parameters;
select userenv('language') from dual;
```

### 2 检查Oracle实例字符集的Bash命令

```bash
echo $NLS_LANG
```

### 3 修改Oracle实例字符集的Bash命令

```bash
NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
```

### 4 修改Oracle实例字符集的SQL命令

```sql
shutdown immediate;
startup mount;
alter system enable restricted session;
alter system set job_queue_processes=0;
alter system set aq_tm_processes=0;
alter database open;
ALTER DATABASE character set INTERNAL_USE ZHS16GBK;
shutdown immediate;
startup;
```

### 5 检查Oracle实例字符集的SQL命令

```sql
column parameter format a35
column value format a30
select * from nls_database_parameters;
select userenv('language') from dual;
```




##  课堂实践

### 实践1-检查字符集一致性

[参考文档](https://blog.csdn.net/lihuarongaini/article/details/71512116)

```bash
SQL> column parameter format a35
SQL> column value format a30
SQL> select * from nls_database_parameters;

PARAMETER			    VALUE
----------------------------------- ------------------------------
NLS_LANGUAGE			    AMERICAN
NLS_TERRITORY			    AMERICA
NLS_CURRENCY			    $
NLS_ISO_CURRENCY		    AMERICA
NLS_NUMERIC_CHARACTERS		    .,
NLS_CHARACTERSET		    AL32UTF8
NLS_CALENDAR			    GREGORIAN
NLS_DATE_FORMAT 		    DD-MON-RR
NLS_DATE_LANGUAGE		    AMERICAN
NLS_SORT			    BINARY
NLS_TIME_FORMAT 		    HH.MI.SSXFF AM

PARAMETER			    VALUE
----------------------------------- ------------------------------
NLS_TIMESTAMP_FORMAT		    DD-MON-RR HH.MI.SSXFF AM
NLS_TIME_TZ_FORMAT		    HH.MI.SSXFF AM TZR
NLS_TIMESTAMP_TZ_FORMAT 	    DD-MON-RR HH.MI.SSXFF AM TZR
NLS_DUAL_CURRENCY		    $
NLS_COMP			    BINARY
NLS_LENGTH_SEMANTICS		    BYTE
NLS_NCHAR_CONV_EXCP		    FALSE
NLS_NCHAR_CHARACTERSET		    UTF8
NLS_RDBMS_VERSION		    11.2.0.4.0

20 rows selected.

--查询:语言_地域.字符集
SQL> select userenv('language') from dual;

USERENV('LANGUAGE')
--------------------------------------------------------------------------------
AMERICAN_AMERICA.AL32UTF8

--查看系统变量$NLS_LANG
[oracle@oratest expbk]$ echo $NLS_LANG
AMERICAN_AMERICA.ZHS16GBK

--操作系统设置的字符集与数据库服务的字符集不一致，修改操作系统字符集
[oracle@oratest expbk]$ NLS_LANG=AMERICAN_AMERICA.AL32UTF8
[oracle@oratest expbk]$ echo $NLS_LANG
AMERICAN_AMERICA.AL32UTF8
```

### 实践2-修改服务器字符集为`AMERICAN_AMERICA.ZHS16GBK`

```bash
--1.修改操作系统变量$NLS_LANG
[oracle@oratest expbk]$ echo $NLS_LANG
AMERICAN_AMERICA.ZHS16GBK

--2.修改数据库服务器的字符集参数
column parameter format a35
column value format a30
select * from nls_database_parameters;

shutdown immediate;
startup mount;
alter system enable restricted session;
alter system set job_queue_processes=0;
alter system set aq_tm_processes=0;
alter database open;
ALTER DATABASE character set INTERNAL_USE ZHS16GBK;
shutdown immediate;
startup;
```

### 实践3-备份`scott`用户的`t02`表并恢复到当前实例

> 应用场景：误操作恢复到全量备份的状态，不在乎新写入的数据，生产中不实用

#### 要求

1. 通过`exp`工具备份`scott`用户下的`t02`表 
2. 模拟人为误操作将`t02`表`drop`
3. 通过`imp`工具将`t02`表还原

#### Step1：备份

```bash
--查看备份前t02表中的数据
SQL> show user;
USER is "SCOTT"
SQL> select * from t02;

	 X Y
---------- --------------------
         1 中国
	 2 巴西

--创建备份目录	 
[oracle@oratest ~]$ mkdir oracle_exp_backup
[oracle@oratest ~]$ ll oracle_exp_backup/ -d
drwxr-xr-x 2 oracle oinstall 4096 Nov 16 19:51 oracle_exp_backup/

--开始备份
[oracle@oratest ~]$ exp scott/tiger tables=t02 file=/home/oracle/oracle_exp_backup/t02.dmp buffer=10000 log=/home/oracle/oracle_exp_backup/backup_t02.log

Export: Release 11.2.0.4.0 - Production on Sat Nov 16 19:56:14 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.


Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
Export done in ZHS16GBK character set and AL16UTF16 NCHAR character set

About to export specified tables via Conventional Path ...
. . exporting table                            T02          2 rows exported
Export terminated successfully without warnings.

--查看备份文件
[oracle@oratest ~]$ ll oracle_exp_backup/
total 20
-rw-r--r-- 1 oracle oinstall   427 Nov 16 19:56 backup_t02.log
-rw-r--r-- 1 oracle oinstall 16384 Nov 16 19:56 t02.dmp

[oracle@oratest ~]$ cd oracle_exp_backup/
[oracle@oratest oracle_exp_backup]$ strings t02.dmp | head
TEXPORT:V11.02.00
USCOTT
RTABLES
8192
                                      Sat Nov 16 19:56:15 2019/home/oracle/oracle_exp_backup/t02.dmp
#G#G
#G#G
-08:00
BYTE
UNUSED
```

#### Step2：模拟误操作

```sql
SQL> conn scott/tiger
Connected.
SQL> show user;
USER is "SCOTT"
SQL> drop table t02 purge;

Table dropped.
SQL> select * from t02;
select * from t02
              *
ERROR at line 1:
ORA-00942: table or view does not exist
```

#### Step3：恢复数据

```bash
[oracle@oratest oracle_exp_backup]$ pwd
/home/oracle/oracle_exp_backup
[oracle@oratest oracle_exp_backup]$ ll
total 20
-rw-r--r-- 1 oracle oinstall   427 Nov 16 19:56 backup_t02.log
-rw-r--r-- 1 oracle oinstall 16384 Nov 16 19:56 t02.dmp
[oracle@oratest oracle_exp_backup]$ strings t02.dmp | head -n 10
TEXPORT:V11.02.00
USCOTT
RTABLES
8192
                                      Sat Nov 16 19:56:15 2019/home/oracle/oracle_exp_backup/t02.dmp
#G#G
#G#G
-08:00
BYTE
UNUSED
[oracle@oratest oracle_exp_backup]$ imp scott/tiger tables=t02 file=/home/oracle/oracle_exp_backup/t02.dmp buffer=10000 log=/home/oracle/oracle_exp_backup/imp_t02.log

Import: Release 11.2.0.4.0 - Production on Sat Nov 16 20:30:24 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.


Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

Export file created by EXPORT:V11.02.00 via conventional path
import done in ZHS16GBK character set and AL16UTF16 NCHAR character set
. importing SCOTT's objects into SCOTT
. importing SCOTT's objects into SCOTT
. . importing table                          "T02"          2 rows imported
Import terminated successfully without warnings.

SQL> select * from t02;

	 X Y
---------- --------------------
         1 中国
	 2 巴西

```

### 实践4-备份`scott`用户的所有表并导入到其他实例

> 应用场景：11g之前做数据迁移，数据量不大的情况下

#### 要求

1. 通过`exp`工具备份`scott`用户下的所有表 
2. 通过`imp`工具将`scott`用户下的所有表导入到其他实例

#### Step1：备份

```bash
exp scott/tiger owner=scott file=/home/oracle/oracle_exp_backup/scott.dmp buffer=10000000 log=/home/oracle/oracle_exp_backup/scott.log
```

#### Step2：导入

```bash
grant connect,resource,create view to scott identified by tiger;
imp scott/tiger file=/home/oracle/oracle_exp_backup/scott.dmp full=y
```



### 实践5-单表带过滤条件的备份和恢复

```bash
--1.备份单表带过滤条件
[oracle@oratest expbk]$ exp userid=scott/tiger tables=t02 file=/home/oracle/expbk/t02.query.dmp query=\'where y=\'\'中国\'\'\' buffer=10000 log=/home/oracle/t02.query.exp.log

Export: Release 11.2.0.4.0 - Production on Sat Nov 9 22:23:35 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.


Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
Export done in ZHS16GBK character set and AL16UTF16 NCHAR character set

About to export specified tables via Conventional Path ...
. . exporting table                            T02          1 rows exported
EXP-00091: Exporting questionable statistics.
Export terminated successfully with warnings.

--2.查看备份文件和日志
[oracle@oratest expbk]$ ll
total 32
-rw-r--r-- 1 oracle oinstall 16384 Nov  9 22:17 t02.dmp
-rw-r--r-- 1 oracle oinstall 16384 Nov  9 22:23 t02.query.dmp
[oracle@oratest expbk]$ cd ..
[oracle@oratest ~]$ ll
total 48
drwxr-xr-x. 7 oracle oinstall 4096 Aug 26  2013 database
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Desktop
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Documents
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Downloads
drwxr-xr-x  2 oracle oinstall 4096 Nov  9 22:23 expbk
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Music
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Pictures
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Public
-rw-r--r--  1 oracle oinstall  508 Nov  9 22:19 t02.exp.log
-rw-r--r--  1 oracle oinstall  470 Nov  9 22:23 t02.query.exp.log
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Templates
drwxr-xr-x  2 oracle oinstall 4096 Jun  9 14:27 Videos
[oracle@oratest ~]$ cd expbk/
[oracle@oratest expbk]$ ll
total 32
-rw-r--r-- 1 oracle oinstall 16384 Nov  9 22:17 t02.dmp
-rw-r--r-- 1 oracle oinstall 16384 Nov  9 22:23 t02.query.dmp

--3.将二进制的备份文件转换为文本文件查看
[oracle@oratest expbk]$ strings t02.query.dmp 
TEXPORT:V11.02.00
USCOTT
RTABLES
8192
                                       Sat Nov 9 22:23:35 2019/home/oracle/expbk/t02.query.dmp
#G#G
#G#G
-08:00
BYTE
UNUSED
INTERPRETED
DISABLE:ALL
METRICST
TABLE "T02"
CREATE TABLE "T02" ("X" NUMBER(*,0), "Y" VARCHAR2(20))  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT) TABLESPACE "USERS" LOGGING NOCOMPRESS
INSERT INTO "T02" ("X", "Y") VALUES (:1, :2)
ALTER TABLE "T02" ADD  PRIMARY KEY ("X") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT) TABLESPACE "USERS" LOGGING ENABLE
METRICSTreferential integrity constraints
METRICET 1
METRICSTtriggers
METRICET 1
METRICSTbitmap, functional and extensible indexes
TABLE "T02"
ANALSTATS CR "T02" ("X" ) 
BEGIN  DBMS_STATS.SET_INDEX_STATS(NULL,'"SYS_C                         "',NULL,NULL,NULL,1,1,1,1,1,1,0,6); END;
ENDTABLE
METRICET 2
METRICSTposttables actions
METRICET 2
METRICSTPost-inst procedural actions 
METRICET 2
METRICSTDeferred analyze commands 
TABLE "T02"
ANALCOMPUTE INDEXR "T02" ANALYZI 13763 "T02" 2 ("X" ) 
ENDTABLE
METRICET 3
METRICETG0
EXIT
EXIT

--4.登陆数据库删除t02表
[oracle@oratest expbk]$ sqlplus scott/tiger 
SQL> drop table t02 purge;

Table dropped.

--5.开始导入数据，以追加的模式 ignore=y
[oracle@oratest expbk]$ imp userid=scott/tiger tables=t02 file=/home/oracle/expbk/t02.query.dmp ignore=y buffer=10000 log=/home/oracle/t02.query.imp.log

Import: Release 11.2.0.4.0 - Production on Sat Nov 9 22:29:12 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.


Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

Export file created by EXPORT:V11.02.00 via conventional path
import done in ZHS16GBK character set and AL16UTF16 NCHAR character set
. importing SCOTT's objects into SCOTT
. importing SCOTT's objects into SCOTT
. . importing table                          "T02"          1 rows imported
Import terminated successfully without warnings.

--5.检查数据
[oracle@oratest expbk]$ sqlplus scott/tiger
SQL> select * from t02;

	 X Y
---------- --------------------
         1 中国

```



## 老师笔记

```bash
创建保存备份的目录：
mkdir /home/oracle/expbk

逻辑备份：对数据库做select（数据迁移）
跨用户传输数据
跨数据库传输数据
数据库版本升级
为测试库保留历史数据

打印逻辑导出的帮助
exp help=y

查询:语言_地域.字符集
SQL> select userenv('language') from dual;

导出单张表：
exp scott/tiger tables=ob1 file=/home/oracle/expbk/ob1.dmp buffer=10000000 log=/home/oracle/expbk/expob1.log

导出单张表时过滤行：
exp scott/tiger tables=ob1 file=/home/oracle/expbk/ob1_table.dmp buffer=10000000 log=/home/oracle/expbk/expob1.log query=\'where object_type=\'\'TABLE\'\'\'
导入时追加行：
exp scott/tiger tables=ob1 file=/home/oracle/expbk/ob1_table.dmp ignore=y buffer=10000000 log=/home/oracle/expbk/impob1.log 

导出多张表：将多张表捆绑为一个读一致性CONSISTENT
exp scott/tiger tables=ob1,ob2 file=/home/oracle/expbk/ob.dmp buffer=10000000 log=/home/oracle/expbk/expob.log CONSISTENT=y

闪回导出：必须使用system用户，导出的是undo中的老镜像
exp system/uplooking tables=scott.emp file=/home/oracle/expbk/emp_1040.dmp buffer=1000000 flashback_time=\"to_timestamp\(\'2016-10-08 10:00:00\',\'yyyy-mm-dd hh24:mi:ss\'\)\" log=/home/oracle/expbk/emp_1040.log

只导出元数据： rows=n compress=n
exp scott/tiger tables=ob1 file=/home/oracle/expbk/ob1_metadata.dmp buffer=10000000 log=/home/oracle/expbk/expob1.log rows=n compress=n

导出用户模式:并没有导出创建用户的命令
exp scott/tiger owner=scott file=/home/oracle/expbk/scott.dmp buffer=10000000 log=/home/oracle/expbk/scott.log

drop user scott cascade;
grant connect,resource,create view to scott identified by tiger;
还原用户数据：
imp scott/tiger file=/home/oracle/expbk/scott.dmp full=y 
跨用户导入数据：
imp system/uplooking file=/home/oracle/expbk/scott.dmp fromuser=scott touser=u01 tables=DEPT,EMP,SALGRADE log=impu01.log

导出表空间模式：需要管理员权限
exp system/uplooking tablespaces=tbs010 file=/home/oracle/expbk/tbs010.dmp buffer=10000000 log=/home/oracle/expbk/tbs010.log

drop tablespace tbs010 including contents and datafiles;
create tablespace tbs010 datafile '/home/oracle/coldbk/tbs010.dbf' size 10m;

imp system/uplooking full=y file=/home/oracle/expbk/tbs010.dmp

传输表空间模式：
select userenv('language') from dual;
USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.WE8MSWIN1252

将表空间只读
alter tablespace tbs010 read only;
导出表空间元数据
exp \'/ as sysdba\' tablespaces=tbs010 transport_tablespace=y file=/home/oracle/expbk/tbs010.dmp log=/home/oracle/expbk/tbs010.log
将数据文件拷贝到远程节点：
scp /home/oracle/coldbk/tbs010.dbf oracle@172.25.11.10:/home/oracle

使用网络将元数据导入到远程节点
1110 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.11.10)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl.example.com)
    )
  )

在远程节点创建用户
grant connect,resource to blake identified by balke;

imp \'sys/oracle@1110 as sysdba\' tablespaces=tbs010 transport_tablespace=y file=/home/oracle/expbk/tbs010.dmp datafiles=\'/home/oracle/tbs010.dbf\' log=/home/oracle/expbk/tbs010.log

alter tablespace TBS010 read write;
alter tablespace TBS010 read write;

导出全库模式：
exp system/uplooking full=y file=/home/oracle/expbk/full.dmp buffer=100000000 log=/home/oracle/expbk/full.log

vi /home/oracle/expbk/exp.sh
-------------------------------------------------------------------
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=orcl
export LANG=zh_CN.utf8
export NLS_LANG=AMERICAN_AMERICA.WE8MSWIN1252
name=`date '+%Y%m%d_%H%M%S'`
`$ORACLE_HOME/bin/exp userid=scott/tiger tables=ob1 file=/home/oracle/expbk/ob1\_$name.dmp buffer=1048576 feedback=10000 log=/home/oracle/expbk/ob1\_$name.log`
-------------------------------------------------------------------
chmod +x /home/oracle/expbk/exp.sh

使用主机管道压缩备份文件：
mknod /home/oracle/expbk/exp_pipe p
exp userid=scott/tiger tables=ob1 log=/home/oracle/expbk/ob1.log file=/home/oracle/expbk/exp_pipe & gzip </home/oracle/expbk/exp_pipe> ob1_compress.dmp.gz
```
