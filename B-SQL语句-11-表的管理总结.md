# 表的管理总结

> Oracle对五大对象的管理
> 新建、修改、删除、查看

[toc]

## 对象命名规则

* 由数字、字母、_、$、#组成
* 表名和列名必须以字母开头，长度为1-30个字符
* 同一个用户不能拥有两个同名的对象
* 名字中不能使用Oracle服务器的保留字
* 不区分大小写
* 双引号打破规则

## 管理的对象

|对象|新建|修改|删除|查看|数据字典|
|:--|:--|:--|:--|:--|:--|
|表|create table|alter table| drop table|desc;select|user_tables|
|约束|create table add constraint |alter table modify constraint|alter table drop constraint|desc|user_constraints|
|视图|create view|no|drop view|select|user_views|
|序列|create sequence|alter sequence|drop sequence|select|no|
|索引|create index||drop index|select|user_indexes user_ind_columns index_stats|
|同义词|create synonym|no|drop synonym|||

## 常用查询

sysdba用户查看所有的对象

```shell
SQL> select segment_name,blocks from user_segments;
```

sysdba用户查看所有的对象
```shell
select table_name from dba_tables;
```


scott用户拥有的rw以及可查看ro的对象
```shell
select table_name from all_tables;
```


scott用户拥有的表rw权限
```shell
select table_name from user_tables;
```


sysdba用户查看scn
```shell
select current_scn from v$database;
```


查看约束状态
```shell
select CONSTRAINT_NAME,STATUS,VALIDATED from user_constraints where table_name='T01';
```


scott用户拥有的视图
```shell
select view_name ,text from user_views;
```


查看序列的当前值和下一个值
```shell
select seq_empno.currval,seq_empno.nextval from dual;
```


查看索引情况
```shell
select index_name,blevel,num_rows from user_ind_statistics;
```


分析索引结构有效性
index_stats记录的时当前会话中最近一次的分析索引情况

```shell
create index i_e01 on e01 (deptno);
analyze index i_e01 validate structure;
select name,height,blocks,br_blks,br_rows,lf_blks,lf_rows from index_stats;
```


打开scott用户的信息搜集
```shell
begin
dbms_stats.gather_schema_stats(ownname=>'scott',
estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE,
options=>'gather',
degree=>DBMS_STATS.AUTO_DEGREE,
method_opt=>'for all columns size repeat',
cascade=>TRUE);
END;
/
```


查看表的情况
```shell
SQL> select num_rows,blocks from user_tab_statistics;
```

### 查看建表语句

```sql
SET SERVEROUTPUT ON 
SET LINESIZE 1000 
SET FEEDBACK OFF 
set long 99999           
set pagesize 4000  
select dbms_metadata.get_ddl('TABLE','表名','用户名') from dual;
--注意参数必须大写


SQL> select dbms_metadata.get_ddl('TABLE','EMP','SCOTT') from dual;

DBMS_METADATA.GET_DDL('TABLE','EMP','SCOTT')
--------------------------------------------------------------------------------

  CREATE TABLE "SCOTT"."EMP"
   (	"EMPNO" NUMBER(4,0),
	"ENAME" VARCHAR2(10),
	"JOB" VARCHAR2(9),
	"MGR" NUMBER(4,0),
	"HIREDATE" DATE,
	"SAL" NUMBER(7,2),
	"COMM" NUMBER(7,2),
	"DEPTNO" NUMBER(2,0),
	 CONSTRAINT "PK_EMP" PRIMARY KEY ("EMPNO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE,
	 CONSTRAINT "FK_DEPTNO" FOREIGN KEY ("DEPTNO")
	  REFERENCES "SCOTT"."DEPT" ("DEPTNO") ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"
```



## index_stats表分析

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


## rowid的格式

rowid是64进制的

例如`AAAVREAAEAAAACXAAI`

|对象id|文件id|块id|row number|
|:--|:--|:--|:--|
|AAAVRE|AAE|AAAACX|AAI|
|6位|3位|6位|3位|
|object_id|file_id|block_id|row number|

> 注意：在rowid中过的最后三位记录的row number是计算机记录的从0开始的，而我们在读表的时候使用的rownum是从1开始的。

