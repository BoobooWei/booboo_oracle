# 物理结构_控制文件

[TOC]

## 复习

前面给大家介绍了：
1. 口令文件，记录超级用户的户名和口令，存放的位置是固定的  `$ORALCE_HOME/dbs/`下, sys或是能做sys审核的用户
2. 参数文件，也放在`$ORALCE_HOME/dbs/`下，如果想放在非标准路径下也可以，参数文件中保存的是非默认值的初始化参数，是启动实例的特征参数，有文本的pfile和二进制的spfile，spfile优先级高于pfile，命名规则，`spfile<$ORACLE_SID>.ora
   spfile.ora
   init<$ORACLE_SID>.ora` 不同实例的区别就在于参数文件的不同
3. 跟踪文件，两个目录，四种类型；audit是审计文件，diagnotic是诊断文件；诊断文件又分三种：警报日志，后台进程跟踪文件，用户进程跟踪文件，这些文件将来可以做故障排查和优化。
4. 数据库启动的阶段，nomount最主要的操作是加载实例，nomount状态下最主要的可执行操作是可以创建数据库；从nomount到mount需要控制文件，create database命令自动创建控制文件；从mount到open需要日志文件和数据文件。
5. 现在要启动的数据库是谁，由谁决定的呢？怎么决定的呢？通过 `$ORACLE_SID`去找`口令文件`和`参数文件`；通过`参数文件`找到`控制文件`；通过`控制文件`找到`其他文件(联机日志和数据文件)`。

```
$ORACLE_SID --> 口令文件和参数文件 --> 控制文件 --> 其他文件（联机日志和数据文件）
```



## 控制文件概念

[控制文件概述](https://docs.oracle.com/cd/B28359_01/server.111/b28318/physical.htm#i10135)

### 什么是控制文件

数据库控制文件是数据库启动和成功运行所必需的小型二进制文件。Oracle数据库在使用过程中会不断更新控制文件，因此，只要打开数据库，控制文件就必须可用于写入。如果由于某种原因无法访问控制文件，则数据库将无法正常运行。

每个控制文件仅与一个Oracle数据库关联。

### 控制文件内容

控制文件包含有关实例在启动时和正常操作过程中访问所需的相关数据库的信息。控制文件信息只能由Oracle数据库修改；没有数据库管理员或用户可以编辑控制文件。

除其他外，控制文件包含以下信息：

- 数据库名称
- 数据库创建的时间戳
- 关联数据文件的名称和位置 和重做日志文件
- 表空间信息
- 数据文件离线范围
- 日志记录
- 存档的日志信息
- 备份集和备份件信息
- 备份数据文件和重做日志信息
- 数据文件复制信息
- 当前日志序号
- 检查点信息

数据库名称和时间戳源自数据库创建。数据库名称取自`DB_NAME`初始化参数指定的名称或`CREATE` `DATABASE`语句中使用的名称。

每次将数据文件或重做日志文件添加到数据库，重命名数据库或从数据库删除时，控制文件都会更新以反映此物理结构更改。记录这些更改，以便：

- Oracle数据库可以识别在数据库启动期间打开的数据文件和重做日志文件
- 如果需要恢复数据库，Oracle数据库可以识别所需或可用的文件

因此，如果您更改数据库的物理结构（使用`ALTER` `DATABASE`语句），则应立即备份控制文件。

控制文件还记录有关检查点的信息。每三秒钟，检查点进程（CKPT）在控制文件中记录有关重做日志中检查点位置的信息。在数据库恢复期间将使用此信息来告知Oracle数据库，在此点之前记录在重做日志组中的所有重做条目对于数据库恢复而言不是必需的；因此，在数据库恢复过程中，无需执行任何操作。它们已经被写入数据文件。

### 多路控制文件

与重做日志文件一样，Oracle数据库使多个相同的控制文件可以同时打开并为同一数据库写入。通过将单个数据库的多个控制文件存储在不同的磁盘上，可以防止控制文件出现单点故障。如果包含控制文件的单个磁盘崩溃，那么当Oracle数据库尝试访问损坏的控制文件时，当前实例将失败。但是，当当前控制文件的其他副本在不同磁盘上可用时，无需数据库恢复就可以重新启动实例。

如果操作期间数据库的*所有*控制文件都永久丢失，则实例将中止，并且需要进行媒体恢复。如果必须使用控制文件的较早备份，因为当前副本不可用，则介质恢复不是简单的。强烈建议您遵守以下条件：

- 对每个数据库使用多路复用控制文件
- 将每个副本存储在不同的物理磁盘上
- 使用操作系统镜像
- 监控备份

## 控制文件实践

### 查看控制文件中的记录片段

```sql
select TYPE,RECORD_SIZE,RECORDS_TOTAL,RECORDS_USED from v$controlfile_record_section;
```

### 增加控制文件

1. 修改参数
2. 停库
3. 拷贝控制文件
4. startup

### 控制文件改名

1. 修改参数
2. 停库
3. 修改文件名字
4. startup

### 移动控制文件

1. 修改参数
2. 停库
3. 移动控制文件
4. startup

### 减少控制文件

1. 修改参数
2. 停库
3. startup

### 重新创建控制文件

```sql
控制文件中最核心的内容时所有数据文件头的信息！
create controlfile reuse database db01 noresetlogs noarchivelog
datafile
'/home/oracle/db01/system01.dbf',
'/home/oracle/db01/sysaux01.dbf',
'/home/oracle/db01/undo01.dbf'
logfile
'/home/oracle/db01/redo01.log',
'/home/oracle/db01/redo02.log';

alter database open;
alter tablespace temp add tempfile '/home/oracle/db01/temp01.dbf' reuse;
```

### 重新创建控制文件时修改数据库名称：resetlogs

```sql
shut immediate
startup nomount
alter system set db_name='qq' scope=spfile;
startup force nomount

create controlfile reuse database db01 set database qq resetlogs noarchivelog
datafile
'/home/oracle/db01/system01.dbf',
'/home/oracle/db01/sysaux01.dbf',
'/home/oracle/db01/undo01.dbf'
logfile
'/home/oracle/db01/redo01.log' size 50m,
'/home/oracle/db01/redo02.log' size 50m;

alter database open resetlogs;
alter tablespace temp add tempfile '/home/oracle/db01/temp01.dbf' reuse;

修改实例名：
shut immediate
export ORACLE_SID=qq
mv $ORACLE_HOME/dbs/orapwdb01 $ORACLE_HOME/dbs/orapwqq
mv $ORACLE_HOME/dbs/spfiledb01.ora $ORACLE_HOME/dbs/spfileqq.ora
startup

同时修改数据库名字和ID：
SQL> select name,dbid from v$database;
SQL> shutdown immediate
SQL> startup mount
[oracle@oracle0 ~]$ nid target=sys/oracle dbname=cctv
SQL> startup nomount
SQL> alter system set db_name='cctv' scope=spfile;
SQL> startup force mount
修改实例名：
shut immediate
export ORACLE_SID=cctv
mv $ORACLE_HOME/dbs/orapwqq $ORACLE_HOME/dbs/orapwcctv
mv $ORACLE_HOME/dbs/spfileqq.ora $ORACLE_HOME/dbs/spfilecctv.ora
startup
```



## 笔记

```bash
管理控制文件：
记录数据库的物理信息的核心文件，二进制文件，
数据库正常工作至少需要1个控制文件，最多同时可以使用8个控制文件，
数据库在mount状态第一次加载控制文件，
数据库open时控制文件时刻被使用，
生产库推荐至少要同时使用2个控制文件，
控制文件的位置和数量由参数决定（control_files）,
所有的控制文件都是镜像关系。

查看控制文件中的记录片段：
select TYPE,RECORD_SIZE,RECORDS_TOTAL,RECORDS_USED from v$controlfile_record_section;

select name from v$controlfile;
show parameter control_files

增加控制文件：
1.修改参数
alter system set control_files=
'/home/oracle/db01/control01.crl',
'/home/oracle/db01/control02.crl'
scope=spfile;
2.停库
shutdown immediate
3.拷贝控制文件
cp -v /home/oracle/db01/control01.crl /home/oracle/db01/control02.crl
4.启动数据库
startup

控制文件改名：
1.修改参数
alter system set control_files=
'/home/oracle/db01/control01.ctl',
'/home/oracle/db01/control02.ctl'
scope=spfile;
2.停库
shutdown immediate
3.修改文件名字
!mv /home/oracle/db01/control01.crl /home/oracle/db01/control01.ctl
!mv /home/oracle/db01/control02.crl /home/oracle/db01/control02.ctl
4.启动数据库
startup

移动控制文件：
1.修改参数
alter system set control_files=
'/home/oracle/db01/control01.ctl',
'/home/oracle/control02.ctl'
scope=spfile;
2.停库
shutdown immediate
3.移动控制文件
!mv /home/oracle/db01/control02.ctl /home/oracle/control02.ctl
4.启动数据库
startup

减少控制文件：
1.修改参数
alter system set control_files=
'/home/oracle/db01/control01.ctl'
scope=spfile;
2.停库
shutdown immediate
3.启动数据库
startup

重新创建控制文件:控制文件中最核心的内容时所有数据文件头的信息！
create controlfile reuse database db01 noresetlogs noarchivelog
datafile
'/home/oracle/db01/system01.dbf',
'/home/oracle/db01/sysaux01.dbf',
'/home/oracle/db01/undo01.dbf'
logfile
'/home/oracle/db01/redo01.log',
'/home/oracle/db01/redo02.log';

alter database open;
alter tablespace temp add tempfile '/home/oracle/db01/temp01.dbf' reuse;

重新创建控制文件时修改数据库名称：resetlogs
shut immediate
startup nomount
alter system set db_name='qq' scope=spfile;
startup force nomount

create controlfile reuse database db01 set database qq resetlogs noarchivelog
datafile
'/home/oracle/db01/system01.dbf',
'/home/oracle/db01/sysaux01.dbf',
'/home/oracle/db01/undo01.dbf'
logfile
'/home/oracle/db01/redo01.log' size 50m,
'/home/oracle/db01/redo02.log' size 50m;

alter database open resetlogs;
alter tablespace temp add tempfile '/home/oracle/db01/temp01.dbf' reuse;

修改实例名：
shut immediate
export ORACLE_SID=qq
mv $ORACLE_HOME/dbs/orapwdb01 $ORACLE_HOME/dbs/orapwqq
mv $ORACLE_HOME/dbs/spfiledb01.ora $ORACLE_HOME/dbs/spfileqq.ora
startup

同时修改数据库名字和ID：
SQL> select name,dbid from v$database;
SQL> shutdown immediate
SQL> startup mount
[oracle@oracle0 ~]$ nid target=sys/oracle dbname=cctv
SQL> startup nomount
SQL> alter system set db_name='cctv' scope=spfile;
SQL> startup force mount
修改实例名：
shut immediate
export ORACLE_SID=cctv
mv $ORACLE_HOME/dbs/orapwqq $ORACLE_HOME/dbs/orapwcctv
mv $ORACLE_HOME/dbs/spfileqq.ora $ORACLE_HOME/dbs/spfilecctv.ora
startup
```
