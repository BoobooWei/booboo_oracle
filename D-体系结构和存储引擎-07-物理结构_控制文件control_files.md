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
