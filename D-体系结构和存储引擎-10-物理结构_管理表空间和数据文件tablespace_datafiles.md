
```bash
管理表空间和数据文件:
Database files 	Maximum per database 	65533 
Database files 	Maximum per tablespace 	Operating system dependent; usually 1022

表空间相当于vg
数据文件相当于pv
一个表空间下至少要包含一个数据文件

表空间按照存储的内容分成3类:
select tablespace_name,contents from dba_tablespaces order by 2;
------------------------------------------------------------------------------
PERMANENT: 保存永久对象
TEMPORARY: 保存临时表的数据和排序的中间结果
UNDO     : 不能保存任何对象，只能保存数据修改前的老镜像，老镜像存储在rollback segment
------------------------------------------------------------------------------
永久表空间的管理：
创建永久表空间tbs01:
create tablespace tbs01 datafile '/home/oracle/tbs01.dbf' size 10m;
向指定表空间下创建表:
create table scott.t01 tablespace tbs01 as select * from scott.emp;
create table scott.t02 (x int,name varchar2(20)) tablespace tbs01;
查看表空间下拥有哪些表:
select owner,table_name from dba_tables where tablespace_name='TBS01';
查看一张表属于哪一个表空间：
select tablespace_name from dba_tables where table_name='T03';
查看用户的默认表空间：
select default_tablespace from dba_users where username='SCOTT';
create table scott.t03 (x int); --> default_tablespace
修改用户的默认表空间：
alter user scott default tablespace tbs01;
数据库默认永久表空间：
创建数据库的时候system表空间被指定为默认永久表空间。
创建用户的时候如果没有指明默认表空间，那么用户就使用数据库的默认永久表空间保存数据。
查看数据库的默认永久表空间
select * from database_properties where rownum<4;
修改数据库的默认永久表空间
alter database default tablespace tbs01;
create user tom identified by tom;
grant connect,resource to tom;
create table tom.t04 (x int);
查看表空间的状态：
select tablespace_name,status from dba_tablespaces;
修改表空间状态：
alter tablespace tbs01 read only;
alter tablespace tbs01 read write;

alter tablespace tbs01 offline;
alter tablespace tbs01 online;

移动数据文件：适合可以offline的表空间！
查看数据文件和表空间的对应关系
select tablespace_name,file_name from dba_data_files;
alter tablespace tbs01 offline;
!mv /home/oracle/tbs01.dbf /home/oracle/db01/tbs01.dbf
--修改控制文件中的指针
alter tablespace tbs01 rename datafile '/home/oracle/tbs01.dbf' to '/home/oracle/db01/tbs01.dbf';
alter tablespace tbs01 online;
*不可以offline的表空间如果需要移动文件，使用移动日志文件的手段！
移动字符设备表空间：
SQL> select name,blocks,block1_offset from v$datafile
SQL> alter tablespace tbs02 offline;
SQL> !dd if=/dev/raw/raw1 of=/home/oracle/db01/tbs02.dbf bs=8K count=1281
SQL> alter tablespace tbs02 rename datafile '/dev/raw/raw1' to '/home/oracle/db01/tbs02.dbf';
SQL> alter tablespace tbs02 online;

监控表空间的空间使用情况:
select a.tablespace_name,a.curr_mb,a.max_mb,nvl(b.free_mb,0),round(nvl(b.free_mb,0)/a.curr_mb,4)*100||'%' free_pct
from
(select TABLESPACE_NAME,sum(BLOCKS)/128 curr_mb,sum(MAXBLOCKS)/128 max_mb from dba_data_files group by TABLESPACE_NAME) a,
(select TABLESPACE_NAME,sum(BLOCKS)/128 free_mb from dba_free_space group by TABLESPACE_NAME) b
where a.TABLESPACE_NAME=b.TABLESPACE_NAME(+)
order by 4;

与空间问题相关的可恢复语句：
grant resumable to scott;
alter session enable resumable;
select * from dba_resumable;

表空间扩容：
select file_id,file_name from dba_data_files where tablespace_name='TBS02';

FILE_ID FILE_NAME
------- ---------------------------
 5      /home/oracle/db01/tbs02.dbf

修改现有文件的大小：
alter database datafile '/home/oracle/db01/tbs02.dbf' resize 20m;
打开数据文件的自动增长属性
alter database datafile '/home/oracle/db01/tbs02.dbf' autoextend on next 10m maxsize 100m;
增加新的数据文件:1022
alter tablespace tbs02 add datafile '/home/oracle/db01/tbs02b.dbf' size 20m;

大文件表空间:文件的上限是 (4G-3)*8K,只能有一个数据文件
create bigfile tablespace tbs03 datafile '/home/oracle/db01/tbs03.dbf' size 10m;
ORA-32771: cannot add file to bigfile tablespace
------------------------------------------------------------------------------
临时表空间的管理: 保存临时表的数据和排序的中间结果
创建临时表空间:
create temporary tablespace temp02 tempfile '/home/oracle/temp02.dbf' size 50m;

查看临时表空间的使用情况：
create global temporary table temp02 on commit preserve rows as select * from emp;
select USERNAME,TABLESPACE,BLOCKS from v$sort_usage;

select * from t05 order by 5,4,3,2,1;

数据库默认临时表空间:
select * from database_properties where rownum<4;
查看用户使用的默认临时表空间：
select temporary_tablespace from dba_users where username='SCOTT';
修改用户使用的默认临时表空间：
alter user scott temporary tablespace temp02;
临时表空间组：只针对临时表空间
select * from dba_tablespace_groups;
将临时表空间加入到组，临时表空间组会自动创建
alter tablespace temp tablespace group tempgroup;
alter tablespace temp02 tablespace group tempgroup;
将用户排序指向临时表空间组
alter user scott temporary tablespace tempgroup;
排序操作由oracle服务器自动均衡到组下不同的临时表空间！
表空间改名：
alter tablespace TEMP rename to temp01;
移动临时文件：
查看临时文件和临时表空间的对应关系
select tablespace_name,file_name from dba_temp_files;
alter tablespace temp02 add tempfile '/home/oracle/db01/temp02.dbf' size 50m;
alter database tempfile '/home/oracle/temp02.dbf' drop;

shut immediate
startup mount
!mv /home/oracle/db01/temp02.dbf /home/oracle/temp02.dbf
alter database rename file '/home/oracle/db01/temp02.dbf' to '/home/oracle/temp02.dbf';
alter database open;
---------------------------------------------------------------------------------------
select * from
(select name from v$controlfile
union all
select name from v$datafile
union all
select name from v$tempfile
union all
select member from v$logfile);

移动数据库到目录 /testdata/
mkdir /testdata
chown oracle. /testdata -R

set lines 3000
set pages 3000
set trimspool on
set heading off
spool mv_file.sql
select '!mv '||name||' /testdata/'
from
(select name from v$controlfile
union all
select name from v$datafile
union all
select name from v$tempfile
union all
select member from v$logfile);
spool off
spool rename_file.sql
select 'alter database rename file '||chr(39)||name||chr(39)||' to '||chr(39)||'/testdata'||substr(name,instr(name,'/',-1))||chr(39)||';'
from
(select name from v$datafile
union all
select name from v$tempfile
union all
select member from v$logfile);
spool off

alter system set control_files=
'/testdata/control01.ctl',
'/testdata/control02.ctl'
scope=spfile;

shut immediate
@mv_file.sql
startup mount
@rename_file.sql
alter database open;
---------------------------------------------------------------------------------------
管理undo表空间：
创建undo表空间：
create undo tablespace undo02 datafile '/testdata/undo02.dbf' size 10m;
切换undo表空间：
alter system set undo_tablespace=undo02;

undo数据文件的移动： 和移动日志文件相同
undo扩容：和永久表空间相同

undo表空间中的老镜像的作用：
为事务提供回退
为事务提供恢复
提供读一致性

commit之后老镜像仍然会保留一段时间！可以实现闪回误操作！
select * from emp as of timestamp(sysdate-10/1440);
alter table emp enable row movement;
flashback table emp to timestamp(sysdate-10/1440);
```
