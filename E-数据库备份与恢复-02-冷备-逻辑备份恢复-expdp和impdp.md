# 冷备和恢复工具-expdp和impdp

*逻辑备份和恢复*

> 2019.11.14 BoobooWei

[toc]

## 数据泵官方介绍

[Oracle Data Pump](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump.html#GUID-501A9908-BCC5-434C-8853-9A6096766B5A)

本部分讨论的主题包括数据泵导出，数据泵导入，旧模式，性能和数据泵API `DBMS_DATAPUMP`。

- [Oracle数据泵概述](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-overview.html#GUID-17FAE261-0972-4220-A2E4-44D479F519D4)
  Oracle数据泵技术可将数据和元数据从一个数据库高速移动到另一个数据库。
- [Oracle数据泵导出](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-export-utility.html#GUID-5F7380CE-A619-4042-8D13-1F7DDE429991)
  Oracle数据泵导出实用程序用于将数据和元数据卸载到一组操作系统文件中，这些文件称为转储文件集。
- [Oracle数据泵导入](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html#GUID-D11E340E-14C6-43B8-AB09-6335F0C1F71B)
  使用Oracle数据泵导入，您可以将导出转储文件集加载到目标数据库中，或直接从源数据库中加载目标数据库，而无需插入文件。
- [Oracle数据泵旧模式](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-legacy-mode.html#GUID-B4A887AD-1E1D-4305-A6D8-DC16D3B28BA9)
  在Oracle数据泵旧模式下，您可以在Oracle数据泵导出和数据泵导入命令行上使用原始的导出和导入参数。
- [Oracle数据泵性能](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-performance-tips.html#GUID-B41F187E-3613-48F8-B47E-CD9BC918424B)
  了解Oracle数据泵导出和导入如何比原始的导出和导入更好，以及如何提高导出和导入操作的性能。
- [Oracle Data Pump API](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/using-oracle_datapump-api.html#GUID-EAD7AE4B-778A-4369-9842-68E026409045)
  您可以使用Oracle Data Pump PL / SQL API自动执行数据移动操作`DBMS_DATAPUMP`。



## 数据泵组件

Oracle数据泵由三个不同的部分组成：

- 命令行客户端，`expdp`以及`impdp`
- 该`DBMS_DATAPUMP`PL / SQL程序包（也称为数据泵API）
- 该`DBMS_METADATA`PL / SQL程序包（也称为元数据API）

数据泵客户端`expdp`和分别`impdp`调用数据泵导出实用程序和数据泵导入实用程序。

在`expdp`和`impdp`客户机使用规定的程序`DBMS_DATAPUMP`PL / SQL包来执行导出和导入命令，使用在命令行中输入的参数。这些参数支持导出和导入完整数据库或数据库子集的数据和元数据。

移动元数据时，数据泵将使用`DBMS_METADATA`PL / SQL软件包提供的功能。该`DBMS_METADATA`包提供了用于提取，操作和重新创建字典元数据的集中式工具。

在`DBMS_DATAPUMP`和`DBMS_METADATA`PL / SQL程序包可独立使用的数据泵客户。

> 注意：
>
> 所有数据泵的导出和导入处理，包括读取和写入转储文件，都是在指定数据库连接字符串选择的系统（服务器）上完成的。**这意味着对于非特权用户，数据库管理员（DBA）必须为在该服务器文件系统上读写的数据泵文件创建目录对象。**
>
> 也可以看看：
>
> * [*《 Oracle数据库PL / SQL软件包和类型参考*](https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/toc.htm)》中有关`DBMS_DATAPUMP`和`DBMS_METADATA`软件包的描述
>
> - [*《 Oracle数据库SecureFiles和大型对象开发人员指南》*](https://docs.oracle.com/cd/E11882_01/appdev.112/e18294/adlob_bfile_ops.htm#ADLOB45842)中有关创建目录对象时要考虑的准则的信息

### 数据泵如何移动数据？

有关Data Pump如何将数据移入和移出数据库的信息，请参阅以下部分：

- [使用数据文件复制来移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CEGFEEJE)
- [使用直接路径移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJAFDGIC)
- [使用外部表移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJABAHDJ)
- [使用常规路径移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJAGCCAJ)
- [使用网络链接导入移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJABHJHD)

> 注意：
>
> 数据泵不使用 禁用唯一索引。要将数据加载到表中，必须删除索引或重新启用索引。

### 数据泵导出和导入操作的必需角色

许多数据泵的导出和导入操作都要求用户`DATAPUMP_EXP_FULL_DATABASE`扮演一个角色和/或一个`DATAPUMP_IMP_FULL_DATABASE`角色。当您运行数据库创建过程中的标准脚本时，会自动为Oracle数据库定义这些角色。（请注意，尽管这些角色的名称中包含单词FULL，但实际上对于所有导出和导入模式（不仅是完全模式），都需要这些角色。）

该`DATAPUMP_EXP_FULL_DATABASE`角色仅影响导出操作。该`DATAPUMP_IMP_FULL_DATABASE`角色影响导入操作和使用Import `SQLFILE`参数的操作。这些角色允许执行导出和导入的用户执行以下操作：

- 在其架构范围之外执行操作
- 监视其他用户启动的作业
- 非特权用户无法引用的导出对象（例如表空间定义）和导入对象（例如目录定义）

这些是强大的角色。在向用户授予这些角色时，数据库管理员应谨慎行事。

尽管`SYS`没有为架构分配任何这些角色，但是由Data Pump执行的所有需要这些角色的安全检查也都授予了对该`SYS`架构的访问权限。

> 也可以看看：
> [*《 Oracle数据库安全指南》*](https://docs.oracle.com/cd/E11882_01/network.112/e36292/authorization.htm#DBSEG4414)中有关Oracle数据库安装中预定义角色的更多信息


## expdp导出步骤

### 1 创建逻辑目录

* 第一步：在服务器上创建真实的目录；（注意：第三步创建逻辑目录的命令不会在OS上创建真正的目录，所以要先在服务器上创建真实的目录。）`mkdir /home/oracle/expbk`

* 第二步：用sys管理员登录sqlplus `sqlplus / as sysdba`

* 第三步：创建逻辑目录`SQL> create directory data_dir as '/home/oracle/expbk';`

* 第四步：查看管理员目录，检查是否存在`select * from dba_directories;`

  ```sql
  SQL> select * from dba_directories;

  OWNER                          DIRECTORY_NAME
  ------------------------------ ------------------------------
  DIRECTORY_PATH
  --------------------------------------------------------------------------------
  SYS                            DATA_DIR
  /home/oracle/dmp/user
  ```


* 第五步：用sys管理员给你的指定用户赋予在该目录的操作权限 `SQL> grant read,write on directory data_dir to user;`


### 2 `expdp`的五种导出方式

#### 第一种：`full=y`全量导出数据库

```bash
expdp user/passwd@orcl dumpfile=expdp.dmp directory=data_dir full=y logfile=expdp.log;
```

#### 第二种：`schemas`按用户导出

```bash
expdp user/passwd@orcl schemas=user dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第三种：`tablespace`按表空间导出

```bash
expdp sys/passwd@orcl tablespaces=tbs1,tbs2 dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第四种：`tables`导出表

```bash
expdp user/passwd@orcl tables=table1,table2 dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第五种：`query`按查询条件导

```bash
expdp user/passwd@orcl tables=table1 query='where number=1234' dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

### 3 `impdp`导入步骤

（1）如果不是同一台服务器，需要先将上面的dmp文件下载到目标服务器上；

（2）参照“expdp导出步骤”里的前三步，建立逻辑目录；

（3）用impdp命令导入，对应五种方式：

#### 第一种：`full=y`全量导入数据库

```bash
impdp user/passwd directory=data_dir dumpfile=expdp.dmp full=y;
```

#### 第二种：`schemas`按用户导出后同名用户导入

```bash
impdp A/passwd schemas=A directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

#### 第三种：`tablespaces`导入表空间

同用户：

```bash
impdp sys/passwd tablespaces=tbs1 directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

跨用户：将表空间TBS01、TBS02、TBS03导入到表空间A_TBS，将用户B的数据导入到A，并生成新的oid防止冲突；

```bash
impdp A/passwd remap_tablespace=TBS01:A_TBS,TBS02:A_TBS,TBS03:A_TBS remap_schema=B:A FULL=Y transform=oid:n 
directory=data_dir dumpfile=expdp.dmp logfile=impdp.log
```

#### 第四种：`tables`导入表

同用户：

```bash
impdp A/passwd tables=table1,table2 dumpfile=expdp.dmp logfile=impdp.log;
```

跨用户：从A用户中把表table1和table2导入到B用户中

```bash
impdp B/passwd tables=A.table1,A.table2 remap_schema=A:B directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

#### 第五种：追加数据

`--table_exists_action`:导入对象已存在时执行的操作。有效关键字:`SKIP,APPEND,REPLACE和TRUNCATE`

```bash
impdp sys/passwd directory=data_dir dumpfile=expdp.dmp schemas=system table_exists_action=replace logfile=impdp.log; 

```

| table_exists_action | 含义                                             |
| ------------------- | ------------------------------------------------ |
| APPEND              | 已存在表，追加数据，（若存在主键冲突则导入失败） |
| REPLACE             | 已存在表，先drop，再导入                         |
| SKIP                | 已存在表，则跳过并处理下一个对象                 |
| TRUNCATE            | 已存在表，先truncate，再导入                     |

```
TABLE_EXISTS_ACTION
Action to take if imported object already exists.
Valid keywords are: APPEND, REPLACE, [SKIP] and TRUNCATE.
```

## 课堂实践

### 实践1-创建逻辑目录用于存放逻辑备份

```bash
[oracle@oratest ~]$ mkdir /home/oracle/expbk
[oracle@oratest ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Sun Nov 10 00:21:27 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL> select *from dba_directories;

OWNER			       DIRECTORY_NAME
------------------------------ ------------------------------
DIRECTORY_PATH
--------------------------------------------------------------------------------
SYS			       ORACLE_OCM_CONFIG_DIR
/u01/app/oracle/product/11.2.0.4/ccr/hosts/oratest/state

SYS			       DATA_PUMP_DIR
/u01/app/oracle/product/11.2.0.4/rdbms/log/

SYS			       ORACLE_OCM_CONFIG_DIR2
/u01/app/oracle/product/11.2.0.4/ccr/state


SQL> column directory_path format a40
SQL> select *from dba_directories;

OWNER			       DIRECTORY_NAME
------------------------------ ------------------------------
DIRECTORY_PATH
----------------------------------------
SYS			       ORACLE_OCM_CONFIG_DIR
/u01/app/oracle/product/11.2.0.4/ccr/hos
ts/oratest/state

SYS			       DATA_PUMP_DIR
/u01/app/oracle/product/11.2.0.4/rdbms/l
og/

SYS			       ORACLE_OCM_CONFIG_DIR2

OWNER			       DIRECTORY_NAME
------------------------------ ------------------------------
DIRECTORY_PATH
----------------------------------------
/u01/app/oracle/product/11.2.0.4/ccr/sta
te


SQL> create or replace directory expbk as '/home/oracle/expbk';

Directory created.

SQL> grant read,write on directory expbk to scott;

Grant succeeded.

SQL> select *from dba_directories;

OWNER			       DIRECTORY_NAME
------------------------------ ------------------------------
DIRECTORY_PATH
----------------------------------------
SYS			       EXPBK
/home/oracle/expbk

SYS			       ORACLE_OCM_CONFIG_DIR
/u01/app/oracle/product/11.2.0.4/ccr/hos
ts/oratest/state

SYS			       DATA_PUMP_DIR
/u01/app/oracle/product/11.2.0.4/rdbms/l

OWNER			       DIRECTORY_NAME
------------------------------ ------------------------------
DIRECTORY_PATH
----------------------------------------
og/

SYS			       ORACLE_OCM_CONFIG_DIR2
/u01/app/oracle/product/11.2.0.4/ccr/sta
te
```

### 实践2-解决报错 ORA-39213  

执行`expdp`时报错如下：

```bash
ORA-39006: internal error
ORA-39213: Metadata processing is notavailable
```

执行`oerr ora <错误编号>`查看报错明细：

```bash
[oracle@oratest expbk]$ oerr ora 39213
39213, 00000, "Metadata processing is not available"
// *Cause:  The Data Pump could not use the Metadata API.  Typically,
//          this is caused by the XSL stylesheets not being set up properly.
// *Action: Connect AS SYSDBA and execute dbms_metadata_util.load_stylesheets
//          to reload the stylesheets.
```

可以看到解决方法为，使用`sysdba`角色的用户执行`execute  sys.dbms_metadata_util.load_stylesheets;`

### 实践3-全库备份导出

```bash
[oracle@oratest expbk]$ expdp userid=system/oracle job_name=full_job directory=expbk dumpfile=full.dump full=y logfile=full.log

Export: Release 11.2.0.4.0 - Production on Sun Nov 10 00:36:56 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
Starting "SYSTEM"."FULL_JOB":  userid=system/******** job_name=full_job directory=expbk dumpfile=full.dump full=y logfile=full.log 
Estimate in progress using BLOCKS method...
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
Total estimation using BLOCKS method: 576 KB
Processing object type DATABASE_EXPORT/TABLESPACE
Processing object type DATABASE_EXPORT/PROFILE
Processing object type DATABASE_EXPORT/SYS_USER/USER
Processing object type DATABASE_EXPORT/SCHEMA/USER
Processing object type DATABASE_EXPORT/ROLE
Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
Processing object type DATABASE_EXPORT/RESOURCE_COST
Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
Processing object type DATABASE_EXPORT/SCHEMA/SEQUENCE/SEQUENCE
Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
Processing object type DATABASE_EXPORT/CONTEXT
Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
Processing object type DATABASE_EXPORT/SCHEMA/SYNONYM
Processing object type DATABASE_EXPORT/SCHEMA/TYPE/TYPE_SPEC
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/PRE_TABLE_ACTION
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/GRANT/OWNER_GRANT/OBJECT_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/PACKAGE_SPEC
Processing object type DATABASE_EXPORT/SCHEMA/FUNCTION/FUNCTION
Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/PROCEDURE
Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/COMPILE_PACKAGE/PACKAGE_SPEC/ALTER_PACKAGE_SPEC
Processing object type DATABASE_EXPORT/SCHEMA/FUNCTION/ALTER_FUNCTION
Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/ALTER_PROCEDURE
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type DATABASE_EXPORT/SCHEMA/VIEW/VIEW
Processing object type DATABASE_EXPORT/SCHEMA/VIEW/GRANT/OWNER_GRANT/OBJECT_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/VIEW/COMMENT
Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE_BODIES/PACKAGE/PACKAGE_BODY
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/REF_CONSTRAINT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/POST_TABLE_ACTION
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TRIGGER
Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA
Processing object type DATABASE_EXPORT/AUDIT
. . exported "SCOTT"."DEPT"                              5.929 KB       4 rows
. . exported "SCOTT"."EMP"                               8.562 KB      14 rows
. . exported "SCOTT"."SALGRADE"                          5.859 KB       5 rows
. . exported "SCOTT"."T02"                               5.421 KB       1 rows
. . exported "SYSTEM"."REPCAT$_AUDIT_ATTRIBUTE"          6.328 KB       2 rows
. . exported "SYSTEM"."REPCAT$_OBJECT_TYPES"             6.882 KB      28 rows
. . exported "SYSTEM"."REPCAT$_RESOLUTION_METHOD"        5.835 KB      19 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_STATUS"          5.484 KB       3 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_TYPES"           6.289 KB       2 rows
. . exported "OUTLN"."OL$"                                   0 KB       0 rows
. . exported "OUTLN"."OL$HINTS"                              0 KB       0 rows
. . exported "OUTLN"."OL$NODES"                              0 KB       0 rows
. . exported "SCOTT"."BONUS"                                 0 KB       0 rows
. . exported "SYSTEM"."DEF$_AQCALL"                          0 KB       0 rows
. . exported "SYSTEM"."DEF$_AQERROR"                         0 KB       0 rows
. . exported "SYSTEM"."DEF$_CALLDEST"                        0 KB       0 rows
. . exported "SYSTEM"."DEF$_DEFAULTDEST"                     0 KB       0 rows
. . exported "SYSTEM"."DEF$_DESTINATION"                     0 KB       0 rows
. . exported "SYSTEM"."DEF$_ERROR"                           0 KB       0 rows
. . exported "SYSTEM"."DEF$_LOB"                             0 KB       0 rows
. . exported "SYSTEM"."DEF$_ORIGIN"                          0 KB       0 rows
. . exported "SYSTEM"."DEF$_PROPAGATOR"                      0 KB       0 rows
. . exported "SYSTEM"."DEF$_PUSHED_TRANSACTIONS"             0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_AUDIT_COLUMN"                 0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_COLUMN_GROUP"                 0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_CONFLICT"                     0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_DDL"                          0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_EXCEPTIONS"                   0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_EXTENSION"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_FLAVORS"                      0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_FLAVOR_OBJECTS"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_GENERATED"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_GROUPED_COLUMN"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_INSTANTIATION_DDL"            0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_KEY_COLUMNS"                  0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_OBJECT_PARMS"                 0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_PARAMETER_COLUMN"             0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_PRIORITY"                     0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_PRIORITY_GROUP"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REFRESH_TEMPLATES"            0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPCAT"                       0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPCATLOG"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPCOLUMN"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPGROUP_PRIVS"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPOBJECT"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPPROP"                      0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_REPSCHEMA"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_RESOLUTION"                   0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_RESOLUTION_STATISTICS"        0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_RESOL_STATS_CONTROL"          0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_RUNTIME_PARMS"                0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_SITES_NEW"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_SITE_OBJECTS"                 0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_SNAPGROUP"                    0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_OBJECTS"             0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_PARMS"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_REFGROUPS"           0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_SITES"               0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_TEMPLATE_TARGETS"             0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_USER_AUTHORIZATIONS"          0 KB       0 rows
. . exported "SYSTEM"."REPCAT$_USER_PARM_VALUES"             0 KB       0 rows
. . exported "SYSTEM"."SQLPLUS_PRODUCT_PROFILE"              0 KB       0 rows
Master table "SYSTEM"."FULL_JOB" successfully loaded/unloaded
******************************************************************************
Dump file set for SYSTEM.FULL_JOB is:
  /home/oracle/expbk/full.dump
Job "SYSTEM"."FULL_JOB" successfully completed at Sun Nov 10 00:37:27 2019 elapsed 0 00:00:31

[oracle@oratest expbk]$ ll -h
total 2.7M
-rw-r----- 1 oracle oinstall 2.7M Nov 10 00:37 full.dump
-rw-r--r-- 1 oracle oinstall 8.6K Nov 10 00:37 full.log
[oracle@oratest expbk]$ file full.dump
full.dump: DBase 3 data file (1728087684 records)
[oracle@oratest expbk]$ strings full.dump | head -n 20
"SYSTEM"."FULL_JOB"
x86_64/Linux 2.4.xx
BOOBOO
ZHS16GBK
11.02.00.04.00
001:001:000001:000001
HDR>T<?
1B"#
ejVW
4DDE
]uW\[
JVhv
L2k[
Q)hZ
E)H'
$DD@D
UUUUUUUUUUV`
.0](
HF((0
&`wrA
```


## 逻辑备份恢复工具对比

[Oracle 官网帮助](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_legacy.htm#SUTIL960)

| 工具区别   | `exp\imp`         | `expdp\impdp`     |
| ---------- | ----------------- | ----------------- |
| 使用位置   | 服务器/客户端都可 | 只能服务端        |
| 影响因素   | 网络、磁盘        | 磁盘              |
| 备份速度   | 更慢              | 更快              |
| 恢复速度   | 更慢              | 更快              |
| 数据库版本 |                   | `oracle 11g 开始` |

###  我的理解

1. 与`exp`工具一样，`expdp`工具也属于逻辑备份，数据一致性为：备份开始的时间点；
2. 有三种使用方式：1）命令行；2）参数文件；3）交互式
3. 数据泵的导出模式：1）`full` 完全模式；2）`schema` 库模式；3）`tables` 表模式；4） `tablespace`表空间模式；5） `transport_tablespaces`可传输表空间模式
4. 从`11g`开始使用该工具做逻辑备份
5. 备份文件为`二进制文件`

