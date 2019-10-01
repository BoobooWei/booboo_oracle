跟踪文件的管理
1.审计文件:超级用户的连接和数据库的启动停止
show parameter audit_file_dest

监控审计路径下的空闲空间
df -h /u01/app/oracle/admin/orcl/adump

ORA-09925: Unable to create audit trail file

修改审计路径：
mkdir -p /home/oracle/orcl/adump
alter system set audit_file_dest='/home/oracle/orcl/adump' scope=spfile;

2.诊断文件
show parameter diagnostic_dest
/u01/app/oracle
/u01/app/oracle/diag/rdbms/orcl/orcl/trace

show parameter background_dump_dest

警报日志：alert_<$ORACLE_SID>.log,数据库报错信息的概要文件
后台进程的跟踪文件:<$ORACLE_SID>_进程名字_pid.trc，后台进程工作时的消息或者报错信息
用户进程的跟踪文件:<$ORACLE_SID>_ora_pid.trc,记录user process发出的消息，但是需要手工打开跟踪

*打开指定的会话的跟踪：
获得需要跟踪的会话的信息：
select sid,serial#,username from v$session where machine='oracle4.example.com';

  SID    SERIAL# USERNAME
----- ---------- ------------------------------
20	  139 SCOTT

打开跟踪：
EXEC DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(sid,serial#,boolean);
EXEC DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(20,139,true);
做业务
关闭跟踪：
EXEC DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(20,139,false);

查找跟踪文件：
SQL> select spid from v$process p,v$session s where p.addr=s.paddr and s.sid=20;

SPID
------------------------
5874

格式化用户跟踪文件
tkprof orcl_ora_5874.trc 1.txt

