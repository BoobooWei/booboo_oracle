管理日志文件:
记录所有数据块的变化
用来做恢复
以组为单位工作
数据库正常工作至少需要2组日志
每组下可以拥有多个成员
组之间时切换运行
同一组下的成员之间时镜像关系
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
