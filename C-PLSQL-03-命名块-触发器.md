# PLSQL-命名块-触发器

> 2020.01.28 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [PLSQL-命名块-触发器](#plsql-命名块-触发器)   
   - [触发器概述](#触发器概述)   
      - [使用触发器的原因](#使用触发器的原因)   
      - [触发器和约束有何不同](#触发器和约束有何不同)   
      - [触发器的分类](#触发器的分类)   
      - [何时触发](#何时触发)   
   - [DML触发器](#dml触发器)   
      - [用于检测触发DML语句的条件谓词](#用于检测触发dml语句的条件谓词)   
      - [构建实验表](#构建实验表)   
      - [创建触发器-After](#创建触发器-after)   
      - [创建触发器-Before](#创建触发器-before)   
      - [管理触发器](#管理触发器)   
   - [系统触发器](#系统触发器)   
      - [建立一个登录的审计触发器](#建立一个登录的审计触发器)   
         - [构建实验表 `login_table`](#构建实验表-login_table)   
         - [创建登陆后的触发动作 `logon_trig`](#创建登陆后的触发动作-logon_trig)   
         - [创建退出前的触发动作 `logoff_trig`](#创建退出前的触发动作-logoff_trig)   
         - [验证触发器](#验证触发器)   

<!-- /MDTOC -->

## 触发器概述

像存储过程一样，触发器是一个命名的PL / SQL单元，它存储在数据库中并且可以重复调用。与存储过程不同，可以启用和禁用触发器，但是不能显式调用它。

一种 触发器 就像一个存储过程，一旦发生指定事件，Oracle数据库就会自动调用该过程。

> 注意：
> 该数据库只能检测系统定义的事件。您无法定义自己的事件。

[PL/SQL Triggers](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/triggers.htm#LNPLS020)

### 使用触发器的原因

触发器使您可以自定义数据库管理系统。例如，您可以使用触发器来：

* 自动生成虚拟列值

* 记录事件

* 收集表访问的统计信息

* 针对视图发出DML语句时修改表数据

* 当子表和父表位于分布式数据库的不同节点上时，强制引用完整性

* 发布有关数据库事件，用户事件和SQL语句的信息以订阅应用程序

* 在正常工作时间后阻止对表执行DML操作

* 防止无效交易

* 强制执行您无法使用约束定义的复杂业务或参照完整性规则（请参阅“触发器和约束如何不同”）


### 触发器和约束有何不同

触发和 约束可以约束数据输入，但是它们有很大的不同。

触发器始终仅适用于新数据。例如，触发器可以阻止DML语句将NULL值插入数据库列中，但是该列可能包含NULL在定义触发器之前或禁用触发器时插入到该列中的值。

约束可以仅应用于新数据（如触发器），也可以应用于新数据和现有数据。约束行为取决于约束状态，如《Oracle数据库SQL语言参考》中所述。

与强制执行相同规则的触发器相比，约束更易于编写且不易出错。但是，触发器可以强制执行某些约束无法执行的复杂业务规则。Oracle强烈建议您仅在以下情况下使用触发器来限制数据输入：

当子表和父表位于分布式数据库的不同节点上时，强制实施引用完整性

强制执行无法使用约束定义的复杂业务或参照完整性规则

### 触发器的分类

* 如果触发器是在表或视图上创建的，则触发事件由DML语句组成，该触发器称为**DML触发器**。有关更多信息，请参见[“ DML触发器”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/triggers.htm#CIHEHBEB)。
* 如果触发器是在模式或数据库上创建的，则触发事件由DDL或数据库操作语句组成，并且该触发器称为**系统触发器**。有关更多信息，请参见[“系统触发器”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/triggers.htm#CIHEFBJA)。

### 何时触发

* Before 在条件运行前，执行触发器

* After 在条件运行后，执行触发器

* INSTEAD OF 替代触发，作用在视图上

## DML触发器

DML触发器可以是简单的也可以是复合的。

一种 **简单的DML触发器**正是在其中之一**触发**时间点：

- 在触发语句运行之前

  （该触发器称为`BEFORE` *语句触发器*或*语句级* `BEFORE` *触发器。*）

- 触发语句运行后

  （该触发器称为`AFTER` *语句触发器*或*语句级* `AFTER` *触发器。*）

- 触发语句影响的每一行之前

  （该触发器称为`BEFORE` *每行触发器*或*行级* `BEFORE` *触发器。*）

- 在触发语句影响的每一行之后

  （该触发器称为`AFTER` *每行触发器*或*行级* `AFTER` *触发器。*）

### 用于检测触发DML语句的条件谓词

DML触发器的触发事件可以由多个触发语句组成。当其中之一触发触发器时，触发器可以通过使用**条件谓词**：

| 条件谓词                  | 当且仅当以下情况为真：                 |
| :------------------------ | :------------------------------------- |
| `INSERTING`               | 一条`INSERT`语句触发了触发器。         |
| `UPDATING`                | 一条`UPDATE`语句触发了触发器。         |
| `UPDATING ('``column``')` | `UPDATE`影响指定列的语句触发了触发器。 |
| `DELETING`                | 一条`DELETE`语句触发了触发器。         |



条件谓词可以出现在`BOOLEAN`表达式可以出现的任何位置。

### 构建实验表

```sqlpus
connect scott/tiger
drop table d purge;
drop table e purge;
create table d as select * from dept;
create table e as select * from emp;
select * from d;
Select * from e;
```

### 创建触发器-After

* 当 D 表的部门号修改的时候 E 表的对应部门号也相应的修改

* 当 D 表的某个部门号删除的时候，E 表的对应部门同时被删除

```plsql
create or replace trigger d_update
after
delete or update of deptno on d
for each row
begin
--当 D 表的部门号修改的时候 E 表的对应部门号也相应的修改
	if (updating and old.deptno != :new.deptno)
	then
		update e set deptno =: new.deptno where deptno = :old.deptno;
	end if;
--当 D 表的某个部门号删除的时候，E 表的对应部门同时被删除
	if deleting
	then
		delete e where deptno := old.deptno;
	end if;
end;
/
```

验证触发器的功能


```plsql
update d set deptno=50 where deptno=30; select * from e;
select * from d;
delete d where deptno=20;
select * from e;
select * from d;
Commit;
```

### 创建触发器-Before

* 禁止对表 E 的 SAL 列进行修改；

* 一旦发现有对该列的update操作则报错。

```plsql
禁止对表 E 的 SAL 列进行修改
create or replace trigger e_update
before update of sal on e
begin
if updating then raise_application_error(-20001,'工资不能被改动'); end if;
end;
/
```

### 管理触发器

查看触发器状态

```sqlplus
select trigger_name, status from user_triggers;
```

禁用某个触发器

```sqlplus
alter trigger d_update disable;
```

禁用表的所有触发器

```sqlplus
alter table d disable all triggers;
```

删除触发器

```plsql
drop trigger d_update;
```



## 系统触发器

一种 **系统触发器**是在架构或数据库上创建的。它的触发事件是由任一DDL语句（中列出的[“ *ddl_event* ”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/create_trigger.htm#CIHGCJHC)）或数据库操作的语句（中列出[“ *database_event* ”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/create_trigger.htm#CIHFAEJC)）。

系统触发了其中之一 时间点：

- 在触发语句运行之前

  （该触发器称为`BEFORE` *语句触发器*或*语句级* `BEFORE` *触发器。*）

- 触发语句运行后

  （该触发器称为`AFTER` *语句触发器*或*语句级* `AFTER` *触发器。*）

- 代替触发`CREATE`语句

  （该触发器称为`INSTEAD` `OF` `CREATE` *触发器*。）



### 建立一个登录的审计触发器

#### 构建实验表 `login_table`

```plsql
conn scott/tiger
drop table login_table;
create table login_table(user_id varchar2(15),log_date date,action varchar2(15));
```

#### 创建登陆后的触发动作 `logon_trig`

```plsql
--on schema 方式为只记录当前的用户行为
CREATE OR REPLACE TRIGGER logon_trig
AFTER LOGON ON SCHEMA
BEGIN
INSERT INTO login_table(user_id, log_date, action)
VALUES (USER, SYSDATE, 'Logging on');
END;
/
```

#### 创建退出前的触发动作 `logoff_trig`

```plsql
CREATE OR REPLACE TRIGGER logoff_trig
BEFORE LOGOFF ON SCHEMA
BEGIN
INSERT INTO login_table(user_id, log_date, action) VALUES (USER, SYSDATE, 'Logging off');
END; /
```

#### 验证触发器

```plsql
conn scott/tiger
conn hr/hr
conn scott/tiger
select user_id, to_char(log_date,'yyyy/mm/dd:hh24:mi:ss') log_date, action from login_table;
```

删除触发器

```plsql
drop trigger logon_trig;
drop trigger logoff_trig;
```
