# SQL语句-DDL管理5大对象

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [SQL语句-DDL管理5大对象](#sql语句-ddl管理5大对象)
	- [管理的对象](#管理的对象)
		- [对象命名规则](#对象命名规则)
	- [管理表](#管理表)
		- [表的分类](#表的分类)
		- [数据类型](#数据类型)
		- [表操作](#表操作)
			- [创建表](#创建表)
			- [查看表的结构](#查看表的结构)
			- [子查询建表拷贝行](#子查询建表拷贝行)
			- [子查询建表拷贝表结构](#子查询建表拷贝表结构)
			- [创建事务级临时表](#创建事务级临时表)
			- [创建会话级临时表](#创建会话级临时表)
			- [增加列](#增加列)
			- [修改列](#修改列)
			- [重命名列](#重命名列)
			- [删除列](#删除列)
			- [在业务高峰期删除列分为两步](#在业务高峰期删除列分为两步)
			- [对列添加注释](#对列添加注释)
			- [对表添加注释](#对表添加注释)
			- [重命名表](#重命名表)
			- [截断表](#截断表)
			- [将表放入回收站](#将表放入回收站)
			- [将回收站对象还原](#将回收站对象还原)
			- [彻底删除表](#彻底删除表)
			- [清空回收站](#清空回收站)
	- [管理约束](#管理约束)
		- [建表时直接启用约束，列级别启用约束，约束产用系统命名](#建表时直接启用约束列级别启用约束约束产用系统命名)
		- [建表时直接启用约束，列级别启用约束，约束产用户命名](#建表时直接启用约束列级别启用约束约束产用户命名)
		- [启用唯一键约束](#启用唯一键约束)
		- [启用主键约束](#启用主键约束)
		- [启用外键约束](#启用外键约束)
		- [启用check约束](#启用check约束)
		- [外键的级联操作](#外键的级联操作)
		- [查看约束状态](#查看约束状态)
		- [启用|关闭约束](#启用关闭约束)
		- [其它操作](#其它操作)
		- [删除约束](#删除约束)
	- [管理视图](#管理视图)
		- [视图的优点](#视图的优点)
		- [视图的分类—简单视图和复杂视图](#视图的分类简单视图和复杂视图)
		- [管理视图的权限](#管理视图的权限)
			- [查看用户目前是否没有创建视图的权限](#查看用户目前是否没有创建视图的权限)
			- [授予用户创建视图的权限](#授予用户创建视图的权限)
			- [创建视图](#创建视图)
			- [创建视图](#创建视图)
			- [删除视图](#删除视图)
	- [管理序列](#管理序列)
		- [序列两个伪列](#序列两个伪列)
		- [序列的初始值不可以修改，其他属性都可以修改](#序列的初始值不可以修改其他属性都可以修改)
		- [使用序列](#使用序列)
		- [删除序列](#删除序列)
	- [管理索引](#管理索引)
		- [何时创建索引](#何时创建索引)
		- [索引的数据字典](#索引的数据字典)
		- [索引的操作](#索引的操作)
			- [手工创建索引](#手工创建索引)
			- [查看索引是否被使用](#查看索引是否被使用)
			- [基于函数的索引](#基于函数的索引)
			- [删除索引](#删除索引)
		- [索引测试](#索引测试)
			- [index_stats表分析](#indexstats表分析)
			- [rowid的格式](#rowid的格式)
	- [管理同义词](#管理同义词)
		- [创建私有同义词](#创建私有同义词)
		- [创建公有同义词](#创建公有同义词)
		- [删除同义词](#删除同义词)

<!-- /TOC -->

## 管理的对象

* 表：存储数据
* 视图：一张或多张表的数据子集
* 序列
* 索引
* 同义词

### 对象命名规则

* 由`数字、字母`、`_`、`$`、`#`组成
* 表名和列名必须以字母开头，长度为1-30个字符
* 同一个用户不能拥有两个同名的对象
* 名字中不能使用Oracle服务器的保留字
* 不区分大小写
* 双引号打破规则

## 管理表

### 表的分类

* 用户表:由用户创建和维护的表的集和；包含用户信息
* 数据字典:由oracle服务器创建和维护的表的集和；包含数据库信息；用户记录oracle自己工作属性和状态的

|数据字典分类|前缀|描述|备注|
|:--|:--|:--|:--|
|字典表|user_|包含有关用户拥有对象的信息|当前用户所拥有的rw|
|字典表|all_|包含所有用户可以访问的表的信息（对象表和相关的表）|当前用户所拥有的rw以及有权力查看ro的对象的信息|
|字典表|dba_|受限制视图，只能被DBA角色的人访问|数据库管理员才有权限查看|
|动态性能视图|v$|动态视图，数据库服务器性能，内存和锁|初始化在内存中，c语言的结构数组，作为排错和优化的|


```SQL
--scott/tiger
--scott用户拥有的表rw权限
SQL> select table_name from user_tables;

TABLE_NAME
------------------------------
T01
SALGRADE
BONUS
EMP
DEPT

--scott用户拥有的rw以及可查看ro的对象
SQL> select table_name from all_tables;

TABLE_NAME
------------------------------
DUAL
SYSTEM_PRIVILEGE_MAP
TABLE_PRIVILEGE_MAP
STMT_AUDIT_OPTION_MAP
AUDIT_ACTIONS
WRR$_REPLAY_CALL_FILTER
HS_BULKLOAD_VIEW_OBJ
HS$_PARALLEL_METADATA
HS_PARTITION_COL_NAME
HS_PARTITION_COL_TYPE
HELP
...省略

--sysdba用户查看所有的对象
SQL> select table_name from dba_tables;
...省略
TABLE_NAME
------------------------------
LOGMNRC_DBNAME_UID_MAP
DIMENSION_EXCEPTIONS
AQ$_STREAMS_QUEUE_TABLE_L
AQ$_ORDERS_QUEUETABLE_L

2864 rows selected.

--sysdba用户查看scn
SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1134479
```

### 数据类型

|数据类型|描述|
|:--|:--|
|varchar2(size)|可变长度字符数据|
|char(size)|固定长度字符数据|
|number(p,s)|可变长度数字数据|
|date|日期和时间数值|
|long|可变长度字符数据，最大2G|
|clob|字符数据，最大到4G|
|raw and long raw|原始二进制数据|
|blob|二进制数，最大到4G|
|bfile|存储到外部文件中的二进制数，最大到4G|
|rowid|表示行在表中的唯一地质|

### 表操作

#### 创建表
```sql
create table t01 (id number(3),name varchar2(12));
create table t02 (id number,name varchar2(12),salary number(7,2) default 1000);
```

#### 查看表的结构

```SQL
desc t01;
```

#### 子查询建表拷贝行

```SQL
create table t03 as select empno,ename,sal,deptno from emp where deptno=30;
```

#### 子查询建表拷贝表结构

```SQL
create table t03 as select empno,ename,sal,deptno from emp where 1=0;
```

#### 创建事务级临时表

commit 数据消失,表结构共享，数据是每个会话私有的

```SQL
create global temporary table temp01 as select * from emp;
```

#### 创建会话级临时表

connect & disconnect 数据消失

```SQL
create global temporary table temp02 on commit preserve rows as select * from emp;
```

#### 增加列

```SQL
alter table t03 add (hiredate date);
alter table t03 add (loc varchar2(10));
```

#### 修改列

```SQL
alter table t03 modify (loc varchar2(13));
alter table t03 modify (hiredate date default sysdate);
```

#### 重命名列

```SQL
alter table t03 rename column loc to location;
```

#### 删除列

```SQL
alter table t03 drop (hiredate);
```

#### 在业务高峰期删除列分为两步

1. 系统繁忙时设置列为未使用状态：（不产生IO，在字典中将该列屏蔽掉）

```SQL
alter table t03 set unused column sal;
```

2. 系统不繁忙时删除未使用状态的列：（产生IO）

```SQL
alter table t03 drop unused columns;
```



#### 对列添加注释

```SQL
comment on column t03.ename is 'first name';
select COLUMN_NAME,COMMENTS from user_col_comments where TABLE_NAME='T03';
```

#### 对表添加注释

```SQL
comment on table t03 is 'employees copy';
select COMMENTS from user_tab_comments where TABLE_NAME='T03';
```

#### 重命名表

```SQL
rename t03 to t04;
```

#### 截断表

```SQL
truncate table t04;
```

清空表中所有数据，不记录数据的老镜像，直接将表变成初始化状态


#### 将表放入回收站

```SQL
drop table t02;
```

#### 将回收站对象还原

```SQL
SQL> show recyclebin
SQL> flashback table t02 to before drop;
```

#### 彻底删除表

```SQL
drop table t01 purge;
```

#### 清空回收站

```SQL
purge recyclebin;
```





## 管理约束

* not null 非空
* unique 唯一键
* primary key 主键（非空和唯一）
* foreign key 外键（基于主键）
* check （指定的一个条件必须为真）


### 建表时直接启用约束，列级别启用约束，约束产用系统命名

```SQL
create table t01 (id number not null);
select CONSTRAINT_NAME,CONSTRAINT_TYPE,SEARCH_CONDITION from user_constraints where TABLE_NAME='T01';
select constraint_name,column_name from user_cons_columns where table_name='T01';
```

### 建表时直接启用约束，列级别启用约束，约束产用户命名

```SQL
create table t01 (id number constraint nn_t01_id not null);
```
* not null约束只能在列级别启用

### 启用唯一键约束
```SQL
create table t01 (id number constraint uk_t01_id unique);
```

### 启用主键约束
```SQL
create table t01 (id number constraint pk_t01_id primary key);
```

### 启用外键约束
```SQL
create table t02 (id number constraint fk_t02_id references t01);
select CONSTRAINT_NAME,CONSTRAINT_TYPE,R_CONSTRAINT_NAME from user_constraints where TABLE_NAME='T02';
```

### 启用check约束
```SQL
create table t03 (id number,salary number constraint ck_t03_sal check (salary>1000));
select CONSTRAINT_NAME,CONSTRAINT_TYPE,SEARCH_CONDITION from user_constraints where TABLE_NAME='T03';
```

### 外键的级联操作

使用`on delete set null`有一点需要注意的是，被参参照其他表的那一列必须能够被赋空，不能有not null约束，对于上面的例子来说是emp中dept列一定不能有not null约束，如果已经定义了not null约束，又使用了on delete set null来删除被参照的数据时，将会发生：ORA-01407: 无法更新 (”DD”.”EMP”.”DEPT”) 为 NULL的错误。

总的来讲`on delete cascade`和`on delete set null`的作用是用来处理级联删除问题的，如果你需要删除的数据被其他数据所参照，那么你应该决定到底希望oracle怎么处理那些参照这些即将要删除数据的数据的，你可以有三种方式：

* 禁止删除。这也是oracle默认的
* 将那些参照本值的数据的对应列赋空，这个需要使用on delete set null关键字
* 将那些参照本值的数据一并删除，这个需要使用on delete cascade关键字

```SQL
alter table t02 drop constraint FK_T02_ID;
alter table t02 add constraint FK_T02_ID foreign key (id) references t01 on delete set null;
alter table t02 add constraint FK_T02_ID foreign key (id) references t01 on delete cascade;
```

### 查看约束状态
```SQL
select CONSTRAINT_NAME,STATUS,VALIDATED from user_constraints where table_name='T01';
```

### 启用|关闭约束

* ENABLED  VALIDATED
* ENABLED  NOT VALIDATED
* DISABLED NOT VALIDATED
* DISABLED VALIDATED:不影响子表数据的前提下重建父表


```SQL
alter table t02 modify constraint FK_T02_ID disable;
alter table t02 modify constraint FK_T02_ID enable;
alter table t02 modify constraint FK_T02_ID enable novalidate; --不限制老数据
alter table t02 modify constraint FK_T02_ID disable validate;

create table t04 (x int constraint u unique);
insert into t04 values (1);
alter table t04 mdify constraint u disable;
insert into t04 values (1);
alter table t04 mdify constraint u enable novalidate;
create index i_t04_x on t04 (x);
```
[约束的禁用和启用文档](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-TABLE.html#GUID-F9CE0CC3-13AE-4744-A43C-EAC7A71AAAB6)

课堂练习题



```sqlplus
create table emp01 (
    emp_no number(2) constraint emp_emp_no_pk primary key,
    ename varchar2(15), 
    salary number(8,2), 
    mgr_no number(2)
);

新建表emp01，其中emp_no上有一个主键 emp_emp_no_pk
alter table emp01 add constraint emp_mgr_fk
    foreign key (mgr_no)
    references emp01(emp_no)
    on delete set null;
新建一个外键 emp_mgr_fk，`on delete set null` 代表 删除emp_no时，mgr_no不删除变为null；

alter table emp01 disable constraint emp_emp_no_pk cascade;
禁用主键时，主键和外键都被禁用
为何此处要有参数 cascade ？

如果FOREIGN KEYs引用a UNIQUE或PRIMARY KEY，则必须在CASCADE CONSTRAINTS语句中包括该子句DROP，否则无法删除该约束。

alter table emp01 enable constraint emp_emp_no_pk;
启用主键，此时只启用主键，外键还是禁用状态。
select  OWNER,CONSTRAINT_NAME, TABLE_NAME,STATUS from user_constraints where table_name='EMP01';
检查约束状态
```



### 其它操作

```SQL
alter table emp add constraint ck_emp_sal check (sal>1000 and sal is not null);
@?/rdbms/admin/utlexcpt.sql
alter table emp add constraint ck_t04_sal check (sal>=1000 and sal is not null) exceptions into exceptions;
```

### 删除约束
```SQL
drop constraint:
alter table e drop constraint XXXXXXXXXX;
alter table d drop constraint PK_D_ID cascade;
```

## 管理视图

### 视图的优点

* 限制对数据的访问（主要功能）
* 简化复杂的查询
* 数据的独立性
* 不同的标准给访问数据的用户分组
* 往往会降低性能


### 视图的分类—简单视图和复杂视图

|特性|简单视图|复杂视图|
|:--|:--|:--|
|表的数量|1|多个|
|包含函数|no|yes|
|包含组数据|no|yes|
|通过视图的dml操作|yes|不一定|


### 管理视图的权限

* CREATE VIEW
* CREATE ANY VIEW


#### 查看用户目前是否没有创建视图的权限

```SQL
SQL> conn scott/tiger;
Connected.

SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION
UNLIMITED TABLESPACE
CREATE TABLE
CREATE CLUSTER
CREATE SEQUENCE
CREATE PROCEDURE
CREATE TRIGGER
CREATE TYPE
CREATE OPERATOR
CREATE INDEXTYPE

10 rows selected.
```


#### 授予用户创建视图的权限

```SQL
SQL> conn / as sysdba
Connected.
SQL> grant CREATE VIEW to scott;

Grant succeeded.

SQL> conn scott/tiger;
Connected.
SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION
UNLIMITED TABLESPACE
CREATE TABLE
CREATE CLUSTER
CREATE VIEW
CREATE SEQUENCE
CREATE PROCEDURE
CREATE TRIGGER
CREATE TYPE
CREATE OPERATOR
CREATE INDEXTYPE

11 rows selected.
```

#### 创建视图

vu10为10部门的所有信息集和

```SQL
create view vu10 as select * from emp where deptno=10;
create or replace view vu10 as select empno,ename,sal,deptno from emp where deptno=10;
create or replace view vu10 (employee_id,first_name,salary,department_id)
as select empno,ename,sal,deptno from emp where deptno=10;
create or replace view vu10 as select empno employee_id,ename,sal salary,deptno department_id from emp where deptno=10;
```

#### 创建视图

```SQL
create or replace force view vu30 as select empno,ename,sal,deptno from e01 where deptno=30;
select object_name,status from user_objects where object_name='VU30';
create or replace force view vu30 as select empno,ename,sal,deptno from e01 where deptno=30 with check option;
select text from user_views where view_name='VU30';

SQL> create or replace force view vu30 as select empno,ename,sal,deptno from e01 where deptno=30;
select object_name,status from user_objects where object_name='VU30';
Warning: View created with compilation errors.

SQL> create or replace force view vu30 as select empno,ename,sal,deptno from e01 where deptno=30 with check option;

Warning: View created with compilation errors.

SQL> select view_name ,text from user_views;

VIEW_NAME
------------------------------
TEXT
--------------------------------------------------------------------------------
BOOBOO01
select ename,sal,deptno from emp where deptno=10

VU30
select empno,ename,sal,deptno from e01 where deptno=30 with check option
```

#### 删除视图

```SQL
drop view vu30;
```

## 管理序列

> oracle和mysql不同，mysql中可以直接在列中声明自增长auto_increment

* 自动生成的唯一序列号
* 是可分享的对象
* 通常用来创建主键值
* 替代应用程序代码
* 当缓冲在内存中时，加速访问序列的小略


数字产生器，只增不降，不可回退，为数字主键填充数据

```SQL
create sequence seq_empno
start with 7935
increment by 1
minvalue 7935
maxvalue 9999
cache 50
nocycle;

SQL> create sequence seq_empno
  2  start with 7935                                                    
  3  increment by 1
  4  minvalue 7935
  5  maxvalue 9999
  6  cache 50
  7  nocycle;

Sequence created.

SQL> select * from user_sequences;

SEQUENCE_NAME			MIN_VALUE  MAX_VALUE INCREMENT_BY C O CACHE_SIZE
------------------------------ ---------- ---------- ------------ - - ----------
LAST_NUMBER
-----------
SEQ_EMPNO			     7935	9999		1 N N	      50
       7935

```

### 序列两个伪列

与序列相关的两个伪列，currval & nextval，崭新的序列没有初始化的序列没有currval只有nextval

* currval 当前值
* nextval 下一个值

```SQL
select seq_empno.currval,seq_empno.nextval from dual;
```

### 序列的初始值不可以修改，其他属性都可以修改

```SQL
alter sequence seq_empno increment by 5;
alter sequence seq_empno minvalue 7936;
alter sequence seq_empno maxvalue 8888;
alter sequence seq_empno cache 100;
alter sequence seq_empno cycle;
```

### 使用序列

```SQL
insert into emp (empno) values (seq_empno.nextval);
```

### 删除序列

```SQL
drop sequence seq_empno;
```


## 管理索引

> 相当于目录，记录表中的关键字和rowid的对应关系，加速查找数据的速度。

### 何时创建索引

* 一列包含有大范围值
* 一列包含有大量空值
* 多于一列经常在where字句或者联合条件下被一起使用
* 表很大并且大部分的查询预期检索少于2%或%4的行数
* 多不一定好

### 索引的数据字典

* `user_indexes` 数据字典视图包含索引的名字和唯一性
* `user_ind_columns` 视图包含索引名称，表名称和列名称
* `index_stats` 索引的详细信息

### 索引的操作

#### 手工创建索引

```
create index i_emp_ename on emp (ename);
```

#### 查看索引是否被使用
```
set autotrace traceonly explain
select * from emp where ename='SCOTT';
set autotrace off
```

#### 基于函数的索引
```
create index i_emp_ename_f on emp (upper(ename));
```

#### 删除索引
```
drop index I_EMP_NAME_F;
```


### 索引测试

```SQL
--新建测试表e01
create table e01 as select * from emp;
--扩充数据
insert into e01 select * from e01;
--将该语句多执行几次
/
--修改empno的属性
alter table e01 modify (empno number);
--将empno的值改为rownum
update e01 set empno=rownum
--开启sqlplus中的时间记录器
set timing on
--查看当前该表的大小
SQL> select blocks/128 from user_segments where segment_name='E01';

BLOCKS/128
----------
	39
--39M
--看执行时间
SQL> select * from e01 where empno=1500;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      1500 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300
	30


Elapsed: 00:00:00.02

--看执行成本
set autot trace exp

SQL> set autot trace exp
SQL> select * from e01 where empno=1500;
Elapsed: 00:00:00.00

Execution Plan
----------------------------------------------------------
Plan hash value: 3036185917

--------------------------------------------------------------------------
| Id  | Operation	  | Name | Rows  | Bytes | Cost (%CPU)| Time	 |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	 |    54 |  4698 |  1338   (1)| 00:00:17 |
|*  1 |  TABLE ACCESS FULL| E01  |    54 |  4698 |  1338   (1)| 00:00:17 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("EMPNO"=1500)

Note
-----
   - dynamic sampling used for this statement (level=2)

--查看e01表有4992个block块，每个block大小为8KB
SQL> select segment_name,blocks from user_segments where segment_name=upper('e01');

SEGMENT_NAME
--------------------------------------------------------------------------------
    BLOCKS
----------
E01
      4992
--当前为了找到empno为1500的行，会读取4992个block
--新建索引
SQL> create index i_e01_empno on e01 (empno);

Index created.
--重新查看相同的sql，对比执行成本的对比
SQL> set linesize 150
SQL> select * from e01 where empno=1500;
Elapsed: 00:00:00.00

Execution Plan
----------------------------------------------------------
Plan hash value: 2767643581

-------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)| Time	  |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  |	1 |    87 |	2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| E01	  |	1 |    87 |	2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN	    | I_E01_EMPNO |	1 |	  |	2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPNO"=1500)

Note
-----
   - dynamic sampling used for this statement (level=2)
--可以看到执行成本从1338降低到2
--索引的详细信息
SQL> desc index_stats
 Name										     Null?    Type
 ----------------------------------------------------------------------------------- -------- --------------------------------------------------------
 HEIGHT 										      NUMBER
 BLOCKS 										      NUMBER
 NAME											      VARCHAR2(30)
 PARTITION_NAME 									      VARCHAR2(30)
 LF_ROWS										      NUMBER
 LF_BLKS										      NUMBER
 LF_ROWS_LEN										      NUMBER
 LF_BLK_LEN										      NUMBER
 BR_ROWS										      NUMBER
 BR_BLKS										      NUMBER
 BR_ROWS_LEN										      NUMBER
 BR_BLK_LEN										      NUMBER
 DEL_LF_ROWS										      NUMBER
 DEL_LF_ROWS_LEN									      NUMBER
 DISTINCT_KEYS										      NUMBER
 MOST_REPEATED_KEY									      NUMBER
 BTREE_SPACE										      NUMBER
 USED_SPACE										      NUMBER
 PCT_USED										      NUMBER
 ROWS_PER_KEY										      NUMBER
 BLKS_GETS_PER_ACCESS									      NUMBER
 PRE_ROWS										      NUMBER
 PRE_ROWS_LEN										      NUMBER
 OPT_CMPR_COUNT 									      NUMBER
 OPT_CMPR_PCTSAVE									      NUMBER

--打开scott用户的信息搜集
begin
dbms_stats.gather_schema_stats(ownname=>'scott',
estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE,
options=>'gather',
degree=>DBMS_STATS.AUTO_DEGREE,
method_opt=>'for all columns size repeat',
cascade=>TRUE);
END;
/

--查看表的情况
SQL> select num_rows,blocks from user_tab_statistics;

  NUM_ROWS     BLOCKS
---------- ----------
	 4	    5
	15	    5
	 0	    0
	 5	    5
	 0	    0
    860160	 4909

6 rows selected.

Elapsed: 00:00:00.06
SQL> select table_name,blocks from user_tables;

TABLE_NAME			   BLOCKS
------------------------------ ----------
E01				     4909
T01					0
SALGRADE				5
BONUS					0
EMP					5
DEPT					5

6 rows selected.
--查看索引情况
SQL> select index_name,blevel,num_rows from user_ind_statistics;

INDEX_NAME			   BLEVEL   NUM_ROWS
------------------------------ ---------- ----------
PK_DEPT 				0	   4
PK_EMP					0	  15
I_E01_EMPNO				2     860160


--分析索引结构有效性
--index_stats记录的时当前会话中最近一次的分析索引情况
select name,height,blocks,br_blks,br_rows,lf_blks,lf_rows from index_stats;

create index i_e01 on e01 (deptno);
select name,height,blocks,br_blks,br_rows,lf_blks,lf_rows from index_stats;
analyze index i_e01 validate structure;
select name,height,blocks,br_blks,br_rows,lf_blks,lf_rows from index_stats;

NAME				   HEIGHT     BLOCKS	BR_BLKS    BR_ROWS    LF_BLKS	 LF_ROWS
------------------------------ ---------- ---------- ---------- ---------- ---------- ----------
I_E01					3	1664	      5       1567	 1568	  802816

SQL> analyze index i_e01_empno validate structure;

Index analyzed.

Elapsed: 00:00:00.37
SQL> select name,height,blocks,br_blks,br_rows,lf_blks,lf_rows from index_stats;

NAME				   HEIGHT     BLOCKS	BR_BLKS    BR_ROWS    LF_BLKS	 LF_ROWS
------------------------------ ---------- ---------- ---------- ---------- ---------- ----------
I_E01_EMPNO				3	1920	      5       1791	 1792	  860160
```

#### index_stats表分析

|属性|说明|
|:--|:--|
|height|索引的高度，层级从0开始|
|blocks|索引在后台占用多少块|
|br_blks|索引分支有多少块|
|br_rows|索引分支有多少行|
|lf_blks|叶子有多少块|
|lf_rows|叶子有多少行|

```flow
st=>start: 查找empno为450的行
i_br=>inputoutpu: 索引分支(1-480的行在xx叶子节点上)
i_lf=>inputoutput: 索引叶子(450的行对应的rowid为xxx)
data_b=>inputoutput: 数据块
e=>end

st->i_br->i_lf->data_b->e
```

* 所有的数据都是放在叶子节点上
* 分支记录的是“范围+地址”
* 叶子记录的时“关键字+rowid的一个组合”
* rowid是记录数据的物理地址

通过rowid来查找数据是最快的

```SQL
SQL> select rowid,ename,empno from e01 where rownum < 11;

ROWID		   ENAME	   EMPNO
------------------ ---------- ----------
AAAVo9AAEAAAAILAAA		       1
AAAVo9AAEAAAAILAAB SMITH	       2
AAAVo9AAEAAAAILAAC ALLEN	       3
AAAVo9AAEAAAAILAAD WARD 	       4
AAAVo9AAEAAAAILAAE JONES	       5
AAAVo9AAEAAAAILAAF MARTIN	       6
AAAVo9AAEAAAAILAAG BLAKE	       7
AAAVo9AAEAAAAILAAH CLARK	       8
AAAVo9AAEAAAAILAAI SCOTT	       9
AAAVo9AAEAAAAILAAJ KING 	      10

SQL> select rowid,empno,ename from e01 where rowid='AAAVo9AAEAAAAILAAI';

Execution Plan
----------------------------------------------------------
Plan hash value: 3699198527

-----------------------------------------------------------------------------------
| Id  | Operation		   | Name | Rows  | Bytes | Cost (%CPU)| Time	  |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	   |	  |	1 |    22 |	1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY USER ROWID| E01  |	1 |    22 |	1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------

SQL> select rowid,empno,ename from e01 where empno=9;

Execution Plan
----------------------------------------------------------
Plan hash value: 2767643581

-------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)| Time	  |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  |	1 |    22 |	4   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| E01	  |	1 |    22 |	4   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN	    | I_E01_EMPNO |	1 |	  |	3   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPNO"=9)

--可以看到通过rowid来查找数据的消耗是1
```

#### rowid的格式

rowid是64进制的

例如`AAAVREAAEAAAACXAAI`

|对象id|文件id|块id|row number|
|:--|:--|:--|:--|
|AAAVRE|AAE|AAAACX|AAI|
|6位|3位|6位|3位|
|object_id|file_id|block_id|row number|

> 注意：在rowid中过的最后三位记录的row number是计算机记录的从0开始的，而我们在读表的时候使用的rownum是从1开始的。

64位换算

```SQL
A  -   Z    a    -   z   0   -   9   +   /
0  -   25   26   -   51  52  -   61  62  63
VRE = 21*64*64+17*64+4 = 87108
2*64+23 = 151

--AAAVo9AAEAAAAILAAI 代表的含义
AAAVo9=21*64*64+40*64+61*1=88637
AAE=4
AAAAIL=8*64+11=523
AAI=8

对象id为88637
文件id为4
块id为523
rownum为8

--通过rowid来手动读取数据
conn / as sysdba
alter system dump datafile 4 block 523;
show parameter background;

SQL> show parameter background

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
background_core_dump		     string	 partial
background_dump_dest		     string	 /u01/app/oracle/diag/rdbms/orc
						 l/orcl/trace
[oracle@oracle0 ~]$ cd /u01/app/oracle/diag/rdbms/orcl/orcl/trace
[oracle@oracle0 trace]$ ll
total 3280
-rw-r----- 1 oracle oinstall   87570 Oct 12 13:20 alert_orcl.log
drwxr-xr-x 2 oracle oinstall    4096 Oct 12 13:11 cdmp_20171012131154
-rw-r----- 1 oracle oinstall    3105 Oct  9 12:45 orcl_ckpt_2709.trc
-rw-r----- 1 oracle oinstall      98 Oct  9 12:45 orcl_ckpt_2709.trm
-rw-r----- 1 oracle oinstall    4431 Oct 12 13:32 orcl_ckpt_2711.trc
[oracle@oracle0 trace]$ for i in `ls`;do grep -l data_block $i ;done
orcl_diag_2717_20171012131154.trc
orcl_ora_3395.trc

Trace file /u01/app/oracle/diag/rdbms/orcl/orcl/trace/orcl_ora_3395.trc
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1
System name:    Linux
Node name:      oracle0.example.com
Release:        2.6.18-398.el5
Version:        #1 SMP Tue Aug 12 06:26:17 EDT 2014
Machine:        x86_64
Instance name: orcl
Redo thread mounted by this instance: 1
Oracle process number: 19
Unix process pid: 3395, image: oracle@oracle0.example.com (TNS V1-V3)


*** 2017-10-12 14:53:12.908
*** SESSION ID:(138.11) 2017-10-12 14:53:12.908
*** CLIENT ID:() 2017-10-12 14:53:12.908
*** SERVICE NAME:(SYS$USERS) 2017-10-12 14:53:12.908
*** MODULE NAME:(sqlplus@oracle0.example.com (TNS V1-V3)) 2017-10-12 14:53:12.908
*** ACTION NAME:() 2017-10-12 14:53:12.908
...此处省略
tab 0, row 8, @0xb6e
tl: 39 fb: --H-FL-- lb: 0x2  cc: 8
col  0: [ 2]  c1 0a
col  1: [ 5]  53 43 4f 54 54
col  2: [ 7]  41 4e 41 4c 59 53 54
col  3: [ 3]  c2 4c 43
col  4: [ 7]  77 bb 04 13 01 01 01
col  5: [ 2]  c2 1f
col  6: *NULL*
col  7: [ 2]  c1 15
--找到rownum=8的行，找到ename列的值为“53 43 4f 54 54”16进制
select chr(to_number('53','xx'))||chr(to_number('43','xx'))||chr(to_number('4f','xx'))||chr(to_number('54','xx'))||chr(to_number('54','xx')) from dual;

SQL> select chr(to_number('53','xx'))||chr(to_number('43','xx'))||chr(to_number('4f','xx'))||chr(to_number('54','xx'))||chr(to_number('54','xx')) from dual;

CHR(T
-----
SCOTT
```

oracle中可以通过`chr(to_number('43','xx'))`将16进制转字符串



## 管理同义词

> 对象的别名

### 创建私有同义词
```SQL
create synonym e01 for scott.e01;
```

### 创建公有同义词
```SQL
create public synonym e01 for scott.e01;
```

### 删除同义词
```SQL
drop synonym e01;
```
