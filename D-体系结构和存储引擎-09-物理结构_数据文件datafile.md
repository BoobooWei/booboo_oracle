# 日志文件

> 2019-12-02 - BoobooWei

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [日志文件](#日志文件)
	- [`redolog` 文件分类](#redolog-文件分类)
		- [联机重做日志文件](#联机重做日志文件)
		- [存档的重做日志文件](#存档的重做日志文件)
	- [对 `redolog` 的管理](#对-redolog-的管理)
	- [笔记](#笔记)

<!-- /TOC -->

## `redolog` 文件分类

### 联机重做日志文件

[Managing the Redo Log](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-the-redo-log.html#GUID-BC1F1762-0BB1-4218-B7AF-6160C395AAE4)

每个Oracle数据库都有一组两个或多个联机**重做日志文件**。这些联机重做日志文件，以及重做日志文件的存档副本，统称为数据库的重做日志。一个[**重做日志**](https://docs.oracle.com/cd/B28359_01/server.111/b28318/glossary.htm#CHDIHFBC)由重做条目（也称为**重做记录**），其记录的所有数据更改作出。如果发生故障导致修改后的数据无法永久写入数据文件，则可以从重做日志中获取更改，因此永远不会丢失工作。

为了防止涉及重做日志本身的故障，Oracle数据库允许您创建**多路复用的重做日志，**以便可以在不同的磁盘上维护两个或**多个重做日志**副本。

### 存档的重做日志文件

[Managing Archived Redo Log Files](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-archived-redo-log-files.html#GUID-5EE4AC49-E1B2-41A2-BEE7-AA951EAAB2F3)

归档的重做日志文件是数据库生成的在线重做日志文件的脱机副本。当数据库处于`ARCHIVELOG`模式时，Oracle数据库会自动归档重做日志文件。Oracle建议您启用联机重做日志的自动存档。

## 对 `redolog` 的管理

| 管理内容                                                     | SQL                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 查看日志的工作工作状态                                       | select * from v$log;                                         |
| 查看日志的物理信息                                           | select * from v$logfile;                                     |
| 查看日志切换的历史                                           | select SEQUENCE#,to_char(FIRST_TIME,'yyyy-mm-dd hh24:mi:ss') from v$log_history; |
| 监控日志切换频率：(成员大小、组的数量、切换频率，决定数据库性能) | select to_char(first_time,'yyyymmddhh24'),count(*) from v$log_history group by to_char(first_time,'yyyymmddhh24'); |
| 改变成员尺寸：添加新的组同时指定新的成员大小                 | alter database add logfile group 3 '/home/oracle/db01/redo03.log' size 100m;<br/>alter database add logfile group 4 '/home/oracle/db01/redo04.log' size 100m; |
| 删除日志组                                                   | alter database drop logfile group 1;                         |
| 手工切换日志                                                 | alter system switch logfile;                                 |
| 手工产生检查点                                               | alter system checkpoint;                                     |
| 在组下增加成员                                               | alter database add logfile member <br/>'/home/oracle/redo01b.log' to group 1,<br/>'/home/oracle/redo02b.log' to group 2,<br/>'/home/oracle/redo03b.log' to group 3; |
| 移动日志文件                                                 | shutdown immediate<br/>startup mount<br/>!mv /home/oracle/redo01b.log /home/oracle/db01/redo01b.log<br/>!mv /home/oracle/redo02b.log /home/oracle/db01/redo02b.log<br/>!mv /home/oracle/redo03b.log /home/oracle/db01/redo03b.log<br/>alter database rename file '/home/oracle/redo01b.log' to '/home/oracle/db01/redo01b.log';<br/>alter database rename file '/home/oracle/redo02b.log' to '/home/oracle/db01/redo02b.log';<br/>alter database rename file '/home/oracle/redo03b.log' to '/home/oracle/db01/redo03b.log'; |
| **归档模式**                                                 | 每次联机日志切换时，当前组都会被备份下来，生成归档文件！     |
| 查看数据库是否为归档模式                                     | show parameter DB_RECOVERY_FILE_DEST                         |
| 将数据库转换为归档模式                                       | shutdown immediate<br/>startup mount<br/>alter database archivelog;<br/>alter database open;<br/>archive log list |
| 查看存档位置                                                 | show parameter DB_RECOVERY_FILE_DEST                         |
| 查看已经归档的日志文件                                       | select sequence#,name from v$archived_log;                   |
| 修改存档位置                                                 | mkdir -p /home/oracle/arc_cctv_dest1/<br/>alter system set log_archive_dest_1='location=/home/oracle/arc_cctv_dest1/';<br/>alter system switch logfile;<br/>select sequence#,name from v$archived_log; |



练习

```sql
SQL> column member format a30
SQL> select * from v$logfile;

    GROUP# STATUS  TYPE    MEMBER			  IS_	  CON_ID
---------- ------- ------- ------------------------------ --- ----------
	 3	   ONLINE  /u01/app/oracle/oradata/booboo NO	       0
			   /redo03.log

	 2	   ONLINE  /u01/app/oracle/oradata/booboo NO	       0
			   /redo02.log

	 1	   ONLINE  /u01/app/oracle/oradata/booboo NO	       0
			   /redo01.log


SQL> show parameter DB_RECOVERY_FILE_DEST;

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest		     string
db_recovery_file_dest_size	     big integer 0

SQL> archive log list;
Database log mode	       No Archive Mode
Automatic archival	       Disabled
Archive destination	       /u01/app/oracle/product/12.2.0/db_1/dbs/arch
Oldest online log sequence     4
Current log sequence	       6

```

您必须在以`NOARCHIVELOG`或`ARCHIVELOG`模式运行数据库之间进行选择。

是否启用已归档的重做日志文件组的归档取决于数据库上运行的应用程序的可用性和可靠性要求。如果在发生磁盘故障时无法承受丢失数据库中任何数据的风险，请使用`ARCHIVELOG`模式。填充的重做日志文件的存档可能需要您执行额外的管理操作。

- [在NOARCHIVELOG模式下](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-archived-redo-log-files.html#GUID-21A9A3AC-1D90-4848-B3BB-3A9E797547F8)
  运行数据库在`NOARCHIVELOG`模式下运行数据库时，将禁用重做日志的归档。
- [在ARCHIVELOG模式下](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-archived-redo-log-files.html#GUID-36F3335E-A28B-47BA-82C2-E17B4C8A453A)
  运行数据库在`ARCHIVELOG`模式下运行数据库时，将启用重做日志的归档。

- [Running a Database in NOARCHIVELOG Mode](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-archived-redo-log-files.html#GUID-21A9A3AC-1D90-4848-B3BB-3A9E797547F8)
  When you run your database in `NOARCHIVELOG` mode, you disable the archiving of the redo log.
- [Running a Database in ARCHIVELOG Mode](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/managing-archived-redo-log-files.html#GUID-36F3335E-A28B-47BA-82C2-E17B4C8A453A)
  When you run a database in `ARCHIVELOG` mode, you enable the archiving of the redo log.

## 笔记


```bash
管理日志文件:
记录所有数据块的变化
用来做恢复
以组为单位工作
数据库正常工作至少需要2组日志
每组下可以拥有多个成员
组之间是切换运行
同一组下的成员之间是镜像关系
成员的信息记录在控制文件

查看日志的工作工作状态：
select * from v$log;
查看日志的物理信息
select * from v$logfile;
查看日志切换的历史
select SEQUENCE#,to_char(FIRST_TIME,'yyyy-mm-dd hh24:mi:ss') from v$log_history;
监控日志切换频率：(成员大小、组的数量、切换频率，决定数据库性能)
select to_char(first_time,'yyyymmddhh24'),count(*) from v$log_history group by to_char(first_time,'yyyymmddhh24');
改变成员尺寸：添加新的组同时指定新的成员大小
alter database add logfile group 3 '/home/oracle/db01/redo03.log' size 100m;
alter database add logfile group 4 '/home/oracle/db01/redo04.log' size 100m;
删除日志组：
alter database drop logfile group 1;
手工切换日志：
alter system switch logfile;
手工产生检查点：
alter system checkpoint;
在组下增加成员：
alter database add logfile member
'/home/oracle/redo01b.log' to group 1,
'/home/oracle/redo02b.log' to group 2,
'/home/oracle/redo03b.log' to group 3;
移动日志文件：
shutdown immediate
startup mount
!mv /home/oracle/redo01b.log /home/oracle/db01/redo01b.log
!mv /home/oracle/redo02b.log /home/oracle/db01/redo02b.log
!mv /home/oracle/redo03b.log /home/oracle/db01/redo03b.log
alter database rename file '/home/oracle/redo01b.log' to '/home/oracle/db01/redo01b.log';
alter database rename file '/home/oracle/redo02b.log' to '/home/oracle/db01/redo02b.log';
alter database rename file '/home/oracle/redo03b.log' to '/home/oracle/db01/redo03b.log';

归档模式：
每次联机日志切换时，当前组都会被备份下来，生成归档文件！
查看数据库是否为归档模式
archive log list
将数据库转换为归档模式
shutdown immediate
startup mount
alter database archivelog;
alter database open;
archive log list

查看存档位置：
show parameter DB_RECOVERY_FILE_DEST
查看已经归档的日志文件：
select sequence#,name from v$archived_log;

修改存档位置：
mkdir -p /home/oracle/arc_cctv_dest1/
alter system set log_archive_dest_1='location=/home/oracle/arc_cctv_dest1/';
alter system switch logfile;
select sequence#,name from v$archived_log;
```
