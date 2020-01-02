# 逻辑结构_存储结构

> 2019-12-22 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [逻辑结构_存储结构](#逻辑结构_存储结构)   
   - [存储结构](#存储结构)   
      - [数据库实例](#数据库实例)   
      - [物理结构](#物理结构)   
      - [逻辑结构](#逻辑结构)   
   - [tablespace的空间管理](#tablespace的空间管理)   
      - [sysaux表空间](#sysaux表空间)   
      - [users数据表空间](#users数据表空间)   
      - [永久表空间管理](#永久表空间管理)   
         - [监控表空间的空间使用情况](#监控表空间的空间使用情况)   
         - [与空间问题相关的可恢复语句](#与空间问题相关的可恢复语句)   
         - [表空间扩容](#表空间扩容)   
         - [大文件表空间](#大文件表空间)   
      - [temp临时表空间](#temp临时表空间)   
         - [实践1-创建事务提交即销毁的临时表](#实践1-创建事务提交即销毁的临时表)   
         - [实践2-创建会话提交即销毁的临时表](#实践2-创建会话提交即销毁的临时表)   
         - [实践3-执行排序操作使用临时表空间](#实践3-执行排序操作使用临时表空间)   
         - [实践4-验证删除临时表空间不影响数据库使用](#实践4-验证删除临时表空间不影响数据库使用)   
   - [segment的空间管理](#segment的空间管理)   
   - [extent管理](#extent管理)   
   - [oracle block空间管理](#oracle-block空间管理)   

<!-- /MDTOC -->

> 前面我们学习了物理结构中的8大文件，接下来学习逻辑结构


## 存储结构

```
存储结构：
   逻辑结构          物理结构
  database
     |
 tablespace   ---<  datafile
     |                 |
  segment              |
     |                 |
  extent               |
     |                 ^
oracle block  ---<  OS block
```

### 数据库实例

Oracle数据库服务器由一个Oracle数据库和一个或多个Oracle数据库实例组成。 每次启动数据库时，都会分配一个称为系统全局区域（SGA）的共享内存区域，并启动Oracle数据库后台进程。`后台进程`和`SGA`的组合称为Oracle数据库[实例](https://docs.oracle.com/cd/B28359_01/server.111/b28318/glossary.htm#CBAFGFCJ)。

### 物理结构

Oracle数据库的物理数据库结构，包括数据文件，控制文件，重做日志文件，已归档的重做日志文件，参数文件，警报和跟踪日志文件以及备份文件。

the physical database structures of an Oracle database, including `datafiles`,`control files`, `online Redo Log Files`, `archived redo log files`, `parameter files`, `alert and trace log files`, and `backup files`.

补充`password files`

包括以下主题：

- [口令文件](<https://docs.oracle.com/cd/B28359_01/server.111/b28318/security.htm#CNCPT1568>)

- [参数文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABGABFB)

- [警报和跟踪日志文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABBBJGE)

- [控制文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#i66199)

- [联机重做日志文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#i60995)

- [存档的重做日志文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABIDCDB)

- [数据文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABJHFAJ)

- [备份文件](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABIGDCE)



### 逻辑结构

逻辑存储结构：数据块，扩展区，段和表空间。这些逻辑存储结构使Oracle数据库可以对磁盘空间使用进行细粒度的控制。

 logical storage structures: `data blocks`, `extents`, `segments`, and `tablespaces`. These logical storage structures enable Oracle Database to have fine-grained control of disk space use.

包括以下主题：

- [数据块](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABBEDEH)
- [扩展区](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABGGEJC)
- [段](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABFJBBC)
- [表空间](https://docs.oracle.com/cd/B28359_01/server.111/b28318/intro.htm#BABBGCEH)

## tablespace的空间管理

tablespace的空间管理：

* DMT : dictionary management tablespace
* LMT : local management tablespace


管理表空间和数据文件:
* Database files 	Maximum per database 	65533
	 Database files 	Maximum per tablespace 	Operating system dependent; usually 1022

表空间相当于vg;数据文件相当于pv;一个表空间下至少要包含一个数据文件

表空间按照存储的内容分成3类:

```SQL
select tablespace_name,contents from dba_tablespaces order by 2;
```

|CONTENTS|备注|
|:--|:--|
|PERMANENT| 保存永久对象|
|TEMPORARY| 保存临时表的数据和排序的中间结果|
|UNDO     | 不能保存任何对象，只能保存数据修改前的老镜像，老镜像存储在rollback segment|



```SQL
select tablespace_name,extent_management from dba_tablespaces;
alter system dump datafile 7 block min 1 block max 127;
```

|表空间|system|sysaux|temp|
|:--|:--|:--|:--|
|说明|数据库内最重要的表空间<br>在建立数据库时,就诞生了<br>在数据库open的时候必须online |表空间(system auxiliary辅助) <br>10g新引入的新的表空间<br>分担system表空间的压力 |临时表空间的内部分配由oracle自动完成<br>重新启动数据库时该表空间都会重新分配<br>有排序需求时分配，SHUTDOWN后回收|
|存放内容|该表空间含有数据字典的基表<br>含有包,函数,视图,存储过程的定义<br>原则上不存放用户的数据|一些应用程序的存放数据空间<br>|用来排序或临时存放数据的<br>不存放永久的对象 |
|其他||不能改名称, 可以offline,但部分数据库功能受影响|数据库内可以有多个临时表空间|


### sysaux表空间

查看有那些应用程序使用了sysaux表空间

```SQL
select * from V$SYSAUX_OCCUPANTS;
SELECT OCCUPANT_NAME, SCHEMA_NAME, MOVE_PROCEDURE FROM V$SYSAUX_OCCUPANTS;
```


### users数据表空间

查看和修改数据库默认数据表空间

> 10g新特性

```SQL
SELECT property_value
FROM database_properties
WHERE property_name ='DEFAULT_PERMANENT_TABLESPACE';
```

修改数据库的默认数据默认表空间

```SQL
ALTER DATABASE DEFAULT TABLESPACE newusers;
```

* 以前版本的默认表空间为system,现在可以自己指定。
* 默认数据表空间不能被删除，想将它删除请先指定别的表空间为默认数据表空间。

### 永久表空间管理

|永久表空间管理|命令|
|:--|:--|
|创建永久表空间tbs01|create tablespace tbs01 datafile '/home/oracle/tbs01.dbf' size 10m;|
|向指定表空间下创建表|create table scott.t01 tablespace tbs01 as select * from scott.emp;<br>create table scott.t02 (x int,name varchar2(20)) tablespace tbs01;|
|查看表空间下拥有哪些表|select owner,table_name from dba_tables where tablespace_name='TBS01';|
|查看一张表属于哪一个表空间|select tablespace_name from dba_tables where table_name='T03';|
|查看用户的默认表空间|select default_tablespace from dba_users where username='SCOTT';<br>create table scott.t03 (x int); --> default_tablespace|
|修改用户的默认表空间|alter user scott default tablespace tbs01;|
|数据库默认永久表空间|创建数据库的时候system表空间被指定为默认永久表空间。<br>创建用户的时候如果没有指明默认表空间，那么用户就使用数据库的默认永久表空间保存数据。<br>查看数据库的默认永久表空间<br>select * from database_properties where rownum<4;|
|修改数据库的默认永久表空间|alter database default tablespace tbs01;<br>|create user tom identified by tom;<br>grant connect,resource to tom;<br>create table tom.t04 (x int);|
|查看表空间的状态|select tablespace_name,status from dba_tablespaces;|
|修改表空间状态|alter tablespace tbs01 read only;<br>alter tablespace tbs01 read write;<br>alter tablespace tbs01 offline;<br>alter tablespace tbs01 online;|
|移动数据文件|适合可以offline的表空间！<br>查看数据文件和表空间的对应关系<br>select tablespace_name,file_name from dba_data_files;<br>alter tablespace tbs01 offline;<br>!mv /home/oracle/tbs01.dbf /home/oracle/db01/tbs01.dbf<br>修改控制文件中的指针<br>alter tablespace tbs01 rename datafile '/home/oracle/tbs01.dbf' to '/home/oracle/db01/tbs01.dbf';<br>alter tablespace tbs01 online;<br>不可以offline的表空间如果需要移动文件，使用移动日志文件的手段！|
|移动字符设备表空间|select name,blocks,block1_offset from v$datafile<br>alter tablespace tbs02 offline;<br>!dd if=/dev/raw/raw1 of=/home/oracle/db01/tbs02.dbf bs=8K count=1281<br>alter tablespace tbs02 rename datafile '/dev/raw/raw1' to '/home/oracle/db01/tbs02.dbf';<br>alter tablespace tbs02 online;|



#### 监控表空间的空间使用情况

```SQL
select a.tablespace_name,a.curr_mb,a.max_mb,nvl(b.free_mb,0),round(nvl(b.free_mb,0)/a.curr_mb,4)*100||'%' free_pct
from
(select TABLESPACE_NAME,sum(BLOCKS)/128 curr_mb,sum(MAXBLOCKS)/128 max_mb from dba_data_files group by TABLESPACE_NAME) a,
(select TABLESPACE_NAME,sum(BLOCKS)/128 free_mb from dba_free_space group by TABLESPACE_NAME) b
where a.TABLESPACE_NAME=b.TABLESPACE_NAME(+)
order by 4;
```

#### 与空间问题相关的可恢复语句

在`resumable`开启 的情况下，如果Oracle执行某一个SQL申请不到空间了，会停顿下来（时间可以由TIMEOUT来控制），但是不会报`OUT-OF-SPACE`这个错 误。等你把空间的问题解决了，Oracle会继续从停下来的部分开始刚才的SQL。

```SQL
grant resumable to scott;
alter session enable resumable;
select * from dba_resumable;
```

 步骤：

1. 具有dba角色的用户：`grant resumable to scott`

2. scott下面就可以执行`ALTER SESSION{ ENABLE RESUMABLE [ TIMEOUT integer ][ NAME string ]| DISABLE RESUMABLE}`
3. 监控：通过`USER_RESUMABLE` and `DBA_RESUMABLE`来查看


#### 表空间扩容

```SQL
select file_id,file_name from dba_data_files where tablespace_name='TBS02';

FILE_ID FILE_NAME
------- ---------------------------
 5      /home/oracle/db01/tbs02.dbf

--修改现有文件的大小：

alter database datafile '/home/oracle/db01/tbs02.dbf' resize 20m;
--打开数据文件的自动增长属性
alter database datafile '/home/oracle/db01/tbs02.dbf' autoextend on next 10m maxsize 100m;
--增加新的数据文件:1022
alter tablespace tbs02 add datafile '/home/oracle/db01/tbs02b.dbf' size 20m;
```

#### 大文件表空间

大文件表空间的文件的上限是 `(4G-3)*8K`,只能有一个数据文件

```SQL
create bigfile tablespace tbs03 datafile '/home/oracle/db01/tbs03.dbf' size 10m;
ORA-32771: cannot add file to bigfile tablespace
```

### temp临时表空间    

1. 临时表空间中存放的是什么？

   临时表数据（事务提交即销毁 | 会话提交即销毁） 和 排序缓冲

2. 临时表空间是否可以删除？

   可以删除；备份的时候不需要备份。

3. 如何查看临时表空间属性？

```SQL
select TABLESPACE_NAME,CONTENTS,LOGGING from dba_tablespaces where tablespace_name='TEMP';
select TABLESPACE_NAME,CONTENTS,LOGGING from dba_tablespaces order by 2;
select * from v$tempfile;
select * from dba_temp_files;
```

#### 实践1-创建事务提交即销毁的临时表

只是将数据清空，表还在

```SQL
create global temporary table temp as select * from emp;
```

#### 实践2-创建会话提交即销毁的临时表

只是将数据清空，表还在

```SQL
create global temporary table temp2 on commit preserve rows as select * from emp;
```

#### 实践3-执行排序操作使用临时表空间

```SQL
select USERNAME,TABLESPACE,BLOCKS from v$sort_usage;
```

#### 实践4-验证删除临时表空间不影响数据库使用

```SQL
alter system set pga_aggregate_target=10m;
show parameter pga_aggregate_target;
show parameter memory_target;
--1 准备一个大表21万行
SYS@BOOBOO>select count(*) from scott.ob1;

  COUNT(*)
----------
    217968

--对该表进行排序后报错说临时表空间不够了使用
SYS@BOOBOO>select * from scott.ob1 order by 1,2,3,4,5;
select * from scott.ob1 order by 1,2,3,4,5
                    *
ERROR at line 1:
ORA-01652: unable to extend temp segment by 128 in tablespace TEMP
select USERNAME,TABLESPACE,BLOCKS from v$sort_usage;

--2 准备一个大表2.7万行
SYS@BOOBOO>select count(*) from scott.ob1;

  COUNT(*)
----------
     27246
--使用了临时表
SYS@BOOBOO>select USERNAME,TABLESPACE,BLOCKS from v$sort_usage;

USERNAME		       TABLESPACE			   BLOCKS
------------------------------ ------------------------------- ----------
SYS			       TEMP				      384

```

#### 其他常用命令

```SQL
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
```

##### 移动临时文件

查看临时文件和临时表空间的对应关系
```sql
select tablespace_name,file_name from dba_temp_files;
alter tablespace temp02 add tempfile '/home/oracle/db01/temp02.dbf' size 50m;
alter database tempfile '/home/oracle/temp02.dbf' drop;

shut immediate
startup mount
!mv /home/oracle/db01/temp02.dbf /home/oracle/temp02.dbf
alter database rename file '/home/oracle/db01/temp02.dbf' to '/home/oracle/temp02.dbf';
alter database open;
```

##### 查看所有的物理文件

```sql
select * from
(select name from v$controlfile
union all
select name from v$datafile
union all
select name from v$tempfile
union all
select member from v$logfile);
```

## segment的空间管理

segment的空间管理，重点掌握两种管理段内所拥有的空闲空间的方式：

* MANUAL:使用空闲列表管理段内的空闲块
* AUTO  :使用位图块管理段内的空闲空间

```SQL
select tablespace_name,segment_space_management from dba_tablespaces;

SYS@BOOBOO>select tablespace_name,segment_space_management from dba_tablespaces;

TABLESPACE_NAME 	       SEGMEN
------------------------------ ------
SYSTEM			       MANUAL
SYSAUX			       AUTO
UNDOTBS1		       MANUAL
TEMP			       MANUAL
USERS			       MANUAL
TS2			       AUTO

6 rows selected.
```



### MANUAL

什么叫做MANUAL:使用空闲列表管理段内的空闲块

创建段空间管理模式为手工的表空间：

```sql
create tablespace tbs04 datafile '/testdata/tbs04.dbf' size 10m segment space management manual;
```

向表空间下创建表：

```sql
create table scott.t04 (x int,name varchar2(10)) segment creation immediate tablespace tbs04;
```

查看表的空闲列表：

```sql
select freelists from dba_tables where table_name='T04';
```

查看t04段的头：

```sql
select header_file,header_block from dba_segments where segment_name='T04';

SQL> select header_file,header_block from dba_segments where segment_name='T04';

HEADER_FILE HEADER_BLOCK
----------- ------------
	  9	     128

alter system checkpoint;
alter session set tracefile_identifier='t04_1';
alter system dump datafile 9 block 128;
```
空闲列表就是段头块中的指针，指向段内的空闲块

```sql
SEG LST:: flg: UNUSED lhd: 0x00000000 ltl: 0x00000000

insert into scott.t04 values (1,'Tom');
SEG LST:: flg: USED   lhd: 0x02400082 ltl: 0x02400082
```

### AUTO

什么叫做auto:使用位图块管理段内的空闲空间

```sql
create tablespace tbs05 datafile '/testdata/tbs05.dbf' size 10m;

create table scott.t06 (x int,name varchar2(10)) segment creation immediate tablespace tbs05;
```
查看t06段的头：

```sql
SQL> select header_file,header_block from dba_segments where segment_name='T06';

HEADER_FILE HEADER_BLOCK
----------- ------------
	 10	     130

alter system checkpoint;
alter session set tracefile_identifier='t06_1';
alter system dump datafile 10 block 130;
```

```
Last Level 1 BMB:  0x02800080
Last Level II BMB:  0x02800081
Last Level III BMB:  0x00000000
```

## extent管理

### extent分配

#### 数据增长时会自动分配extent

```SQL
create table t07 (x int,name varchar2(20));
insert into t07 values (1,'Tom');
commit;

SQL> select file_id,block_id,blocks from dba_extents where segment_name='T07';

   FILE_ID   BLOCK_ID	  BLOCKS
---------- ---------- ----------
	 4	  128	       8
```



#### 手工扩展

```sql
alter table t07 allocate extent (size 128k);
```

extent空间分配算法（类型）：
```sql
select tablespace_name,allocation_type from dba_tablespaces;
SYSTEM :系统扩展，阶梯增长
1~16 extent   : 8*8K
17~80 extent  : 128*8K
81~200 extent : 1024*8K
201~   extent : 8192*8K

SQL> select blocks,count(*) from dba_extents where segment_name='T07' group by blocks order by 1;

    BLOCKS   COUNT(*)
---------- ----------
	 8	   16
	   128	   63
	  1024        120
	  8192        ...

UNIFORM:同一分配（extent的尺寸不变）
create tablespace tbs06 datafile '/testdata/tbs06.dbf' size 100m uniform size 10m;
```

### extent回收
```sql
alter table scott.t05 deallocate unused;

alter table t05 enable row movement;
alter table t05 shrink space;

alter table t05 move;

truncate
drop
```

## oracle block空间管理

### block空间管理

```SQL
SQL> show parameter db_block_size

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
db_block_size			     integer	 8192

create table t09 (x int,y varchar2(20)) pctfree 0;

begin
  for i in 1..800 loop
    insert into t09 values (i,'A');
  end loop;
  commit;
end;
/

SQL> select file_id,block_id,blocks from dba_extents where segment_name='T09';

   FILE_ID   BLOCK_ID	  BLOCKS
---------- ---------- ----------
	 4	  384	       8

384\385\386\387\388\389\390\391
```

### 计算行的分布情况

```sql
SQL> select dbms_rowid.rowid_block_number(rowid),count(*) from scott.t09 group by dbms_rowid.rowid_block_number(rowid) order by 1;

DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)   COUNT(*)
------------------------------------ ----------
				 388	    733
				 389	     67

alter session set tracefile_identifier='t09_1';
alter system dump datafile 4 block min 388 block max 389;

update scott.t09 set y=rpad('A',20,'A') where x<6;
commit;
alter system checkpoint;
```



## 删除表空间和文件

```SQL
--删除空的表空间，但是不包含物理文件
drop tablespace tablespace_name;
--删除非空表空间，但是不包含物理文件
drop tablespace tablespace_name including contents;
--删除空表空间，包含物理文件
drop tablespace tablespace_name including datafiles;
--删除非空表空间，包含物理文件
drop tablespace tablespace_name including contents and datafiles;
--如果其他表空间中的表有外键等约束关联到了本表空间中的表的字段，就要加上CASCADE CONSTRAINTS
drop tablespace tablespace_name including contents and datafiles CASCADE CONSTRAINTS;
```

