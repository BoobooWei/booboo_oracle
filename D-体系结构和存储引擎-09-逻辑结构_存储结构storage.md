# 存储空间

[TOC]

## 存储结构

### 逻辑结构

### 物理结构

## tablespace的空间管理

## segment的空间管理

## extent管理

## oracle block空间管理




## 笔记

```bash
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

tablespace的空间管理：
DMT : dictionary management tablespace
LMT : local management tablespace

select tablespace_name,extent_management from dba_tablespaces;
alter system dump datafile 7 block min 1 block max 127;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
segment的空间管理：段内所拥有的空闲空间如何管理
select tablespace_name,segment_space_management from dba_tablespaces;
MANUAL:
AUTO  :

什么叫做MANUAL:使用空闲列表管理段内的空闲块
创建段空间管理模式为手工的表空间：
create tablespace tbs04 datafile '/testdata/tbs04.dbf' size 10m segment space management manual;
向表空间下创建表：
create table scott.t04 (x int,name varchar2(10)) segment creation immediate tablespace tbs04;
查看表的空闲列表：
select freelists from dba_tables where table_name='T04';
查看t04段的头：
select header_file,header_block from dba_segments where segment_name='T04';

SQL> select header_file,header_block from dba_segments where segment_name='T04';

HEADER_FILE HEADER_BLOCK
----------- ------------
	  9	     128

alter system checkpoint;
alter session set tracefile_identifier='t04_1';
alter system dump datafile 9 block 128;
空闲列表就是段头块中的指针，指向段内的空闲块
SEG LST:: flg: UNUSED lhd: 0x00000000 ltl: 0x00000000

insert into scott.t04 values (1,'Tom');
SEG LST:: flg: USED   lhd: 0x02400082 ltl: 0x02400082

什么叫做auto:使用位图块管理段内的空闲空间
create tablespace tbs05 datafile '/testdata/tbs05.dbf' size 10m;

create table scott.t06 (x int,name varchar2(10)) segment creation immediate tablespace tbs05;

查看t06段的头：
SQL> select header_file,header_block from dba_segments where segment_name='T06';

HEADER_FILE HEADER_BLOCK
----------- ------------
	 10	     130

alter system checkpoint;
alter session set tracefile_identifier='t06_1';
alter system dump datafile 10 block 130;
-----------------------------------------------
Last Level 1 BMB:  0x02800080
Last Level II BMB:  0x02800081
Last Level III BMB:  0x00000000
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extent管理：

extent分配：
create table t07 (x int,name varchar2(20));
insert into t07 values (1,'Tom');
commit;

SQL> select file_id,block_id,blocks from dba_extents where segment_name='T07';

   FILE_ID   BLOCK_ID	  BLOCKS
---------- ---------- ----------
	 4	  128	       8

数据增长时会自动分配extent！
手工扩展：
alter table t07 allocate extent (size 128k);

extent空间分配算法（类型）：
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

extent回收：
alter table scott.t05 deallocate unused;

alter table t05 enable row movement;
alter table t05 shrink space;

alter table t05 move;

truncate
drop
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
oracle block空间管理:
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

计算行的分布情况:
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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```