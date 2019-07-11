## DCL管理用户

[TOC]

> 需掌握以下知识点：
> * 创建用户
> * 创建角色
> * grant和revoke
> * 创建和访问数据库连接

### 权限

权限分为：
* 系统权限：获取访问数据库的权限 （典型的DBA权限；用户系统权限）
* 对象权限：操作数据库对象的内容 

> 个人理解：系统权限包括了ddl和dcl语句;对象权限包括了alter和dql和dml

#### 系统权限

* 超过100个权限可用
* 数据库管理员拥有高级别的系统权限用于进行下列任务：创建、删除用户；删除表；备份表

##### 典型的DBA权限

| 系统权限              | 操作认证               |
| :---------------- | :----------------- |
| create user       | 创建其他数据库用户（需要dba角色） |
| drop user         | 删除一个用户             |
| drop any table    | 删除任何模式下的表          |
| backup any table  | 使用导出工具备份任何模式中的表    |
| select andy table | 在模式中查询表，视图或者快照     |
| create andy table | 在任何模式下可以创建表        |

* 模式是对象的集和，例如表，视图，子查询。

##### 典型用户权限

| 系统权限             | 操作认证                  |
| :--------------- | :-------------------- |
| create session   | 连接到数据库                |
| create table     | 在用户的模式中创建表            |
| create sequence  | 在用户的模式中创建序列           |
| create view      | 在用户的模式中创建视图           |
| create procedure | 在用户的模式中创建一个存储过程，函数或者包 |

#### 对象权限


**授予对象权限**

不同的对象权限对不同类型的模式对象是可用的。一个用户自动拥有包含在用户模式里面模式对象的对象权限。

> 我的理解：拥有该表用户默认就拥有了对该表的所有对象权限（例如DQL\DML和alter），表可以该为其他对象例如视图、序列、过程。

一个用户可以将自己拥有的模式对象上面的所有对象权限授予任何其他的用户和角色。如果授予时使用了WITH GRANT OPTION，那么受让人可以将对象权限进一步授予其他的用户；否则受让人只可以使用权限，但是不可以将它授予其他人。

**WITH GRANT OPTION**

授予的特权可以将特权传递给其他的用户和角色。

**PUBLIC**

授权所有用户访问这张表

> 我的理解：
* 我的表可以给别人（B）使用吗？可以的。
* 别人（B）可以把我的表再给C使用吗？ 可以的。
* 我想把我的表给所有人使用可以吗？ 可以的。


| 对象权限       | 表    | 视图   | 序列   | 过程   |
| :--------- | :--- | :--- | :--- | :--- |
| alter      | *    |      | *    |      |
| select     | *    | *    | *    |      |
| update     | *    | *    |      |      |
| delete     | *    | *    |      |      |
| insert     | *    |      |      |      |
| execute    |      |      |      | *    |
| index      | *    |      |      |      |
| references | *    | *    |      |      |



### 角色

#### 什么是角色？

角色是命名的组，包含相关的权限可以授予用户。这个方法可以使撤销和维护权限变得简单。一个用户可以拥有几个角色，几个用户可以分配相同的角色。角色通常为数据库的应用程序创建。

#### 创建和分配角色

步骤：
1. DBA必须创建角色
2. DBA可以分配权利
3. DBA给用户授与角色

语法：
```shell
create role x_role;
grant create table , create view to x_role;
grant x_role to batman,superman;
```

```shell
SQL> show user;
USER is "SYS"
SQL> create role python;   

Role created.

SQL> grant create session,create table to python;

Grant succeeded.

SQL> grant python to superman identified by superman;

Grant succeeded.

SQL> conn superman/superman
Connected.

SQL> show user;
USER is "SUPERMAN"
SQL> create table t1 (id int);

Table created.

SQL> select * from tab;

TNAME			       TABTYPE	CLUSTERID
------------------------------ ------- ----------
T1			       TABLE


SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION
CREATE TABLE

SQL> select * from user_tab_privs;

no rows selected

SQL> select * from user_sys_privs;

no rows selected

```
### 权限数据字典

| 数据字典视图              | 描述             |
| :------------------ | :------------- |
| role_sys_privs      | 角色被授予的系统权限     |
| role_tab_privs      | 角色被授予的对象权限     |
| user_role_privs     | 用户被授予的角色权限     |
| user_tab_privs_made | 用户的对象被授予的对象权限  |
| user_tab_privs_recd | 用户被授予的对象权限     |
| user_col_privs_made | 用户对象的列被授予的对象权限 |
| user_col_privs_recd | 用户指定的列被授予的对象权限 |
| user_sys_privs      | 用户被授予的系统权限     |
| dba_sys_privs       | 用户被授予的系统权限     |
| dba_tab_privs       | 用户被授予的对象权限     |
| dba_col_privs       | 用户被授予的列级别的对象权限 |
| dba_role_privs      | 用户被授予的角色权限     |

```shell
# 背景：scott用户给ops$boobo 授权了emp表的select权限

# 使用ops$boobo 用户登陆
SQL> select * from user_sys_privs;

USERNAME		       PRIVILEGE				ADM
------------------------------ ---------------------------------------- ---
OPS$BOOBOO		       CREATE SESSION				NO


SQL> set linesize 500
SQL> select * from user_tab_privs;

GRANTEE 		       OWNER			      TABLE_NAME		     GRANTOR			    PRIVILEGE				     GRA HIE
------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------------------- --- ---
OPS$BOOBOO		       SCOTT			      EMP			     SCOTT			    SELECT				     YES NO

SQL> select * from user_tab_privs_recd;

OWNER			       TABLE_NAME		      GRANTOR			     PRIVILEGE				      GRA HIE
------------------------------ ------------------------------ ------------------------------ ---------------------------------------- --- ---
SCOTT			       EMP			      SCOTT			     SELECT				      YES NO

SQL> select * from user_tab_privs_made;

no rows selected

# 使用scott用户登陆
SQL> select * from user_tab_privs;

GRANTEE 		       OWNER			      TABLE_NAME		     GRANTOR			    PRIVILEGE				     GRA HIE
------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------------------- --- ---
OPS$BOOBOO		       SCOTT			      EMP			     SCOTT			    SELECT				     YES NO

SQL> select * from user_tab_privs_recd;

no rows selected

SQL> select * from user_tab_privs_made;

GRANTEE 		       TABLE_NAME		      GRANTOR			     PRIVILEGE				      GRA HIE
------------------------------ ------------------------------ ------------------------------ ---------------------------------------- --- ---
OPS$BOOBOO		       EMP			      SCOTT			     SELECT				      YES NO


```


### 创建和管理用户总结

| 功能               | 命令                                       |
| :--------------- | :--------------------------------------- |
| 创建用户的基本命令        | create user smith identified by smith;   |
| 授予权限             | grant create session to smith;           |
| 连接到指定用户下         | conn smith/smith                         |
| 查看当前用户是谁         | show user                                |
| 查看当前版本下所有的系统权限   | select distinct privilege from dba_sys_privs; |
| 查看与table有关的权限    | select distinct privilege from dba_sys_privs where privilege like '%TABLE%'; |
| 回收权限             | revoke CREATE ANY TABLE from SMITH;      |
| 查看用户拥有的权限        | select * from session_privs;             |
| 使用角色管理权限         | create role r_clerk;grant create session,create table,create synonym to r_clerk;grant r_clerk to smith; |
| 角色的嵌套            | create user jones identified by jones password expire;create role r_manager;grant r_clerk,create view to r_manager;grant r_manager to jones; |
| 使用sql语句修改用户口令    | alter user jones identified by oracle;   |
| 使用sql语句解锁用户      | alter user scott identified by tiger account unlock; |
| 使用sqlplus命令修改口令  | password                                 |
| 对象权限             | SQL> grant select on scott.e01 to smith;SQL> grant update (comm) on scott.e01 to smith;SQL> grant delete on scott.e01 to smith;SQL> grant insert on scott.e01 to smith; |
| 查看用户被授予的系统权限     | SQL> select privilege from dba_sys_privs where GRANTEE='TOM'; |
| 查看用户被授予的对象权限     | col GRANTEE for a15；col PRIVILEGE for a20；col owner for a15；SQL> SELECT GRANTEE,PRIVILEGE,OWNER,TABLE_NAME FROM DBA_TAB_PRIVS WHERE GRANTEE='TOM'; |
| 查看用户被授予的列级别的对象权限 | SQL> SELECT OWNER,TABLE_NAME,COLUMN_NAME,PRIVILEGE FROM DBA_COL_PRIVS where GRANTEE='TOM'; |
| 用户被授予的角色         | SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE='TOM'; |
| 角色被授予的角色         | SELECT * FROM ROLE_ROLE_PRIVS WHERE ROLE='R1'; |
| 角色被授予的系统权限       | select * from ROLE_SYS_PRIVS WHERE ROLE='R1'; |
| 角色被授予的对象权限       | select * from ROLE_TAB_PRIVS WHERE ROLE='R1'; |

```shell
# sysdba创建一个用户blake
SQL> create user blake identified by blake;

User created.
# 该用户什么都做不了
SQL> conn blake/blake;
ERROR:
ORA-01045: user BLAKE lacks CREATE SESSION privilege; logon denied


Warning: You are no longer connected to ORACLE.
# MySQL创建用户就会默认存在一个usage的权限允许该用户连接上数据库服务器

# Oracle需要给用户授予create session的权限才能允许连接
SQL> conn / as sysdba
Connected.
SQL> grant create session to blake;

Grant succeeded.

SQL> conn blake/blake;
Connected.
SQL> show user;
USER is "BLAKE"

# 用户的命名规则
# 操作系统审核的用户：安全机制在系统级别，则前缀为ops$，后缀为当前登陆到服务器的操作系统用户名
# os_authent_prefix 变量的值为 ops$
SQL> conn / as sysdba
Connected.

SQL> show parameter os

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
db_lost_write_protect		     string	 NONE
diagnostic_dest 		     string	 /u01/app/oracle
optimizer_index_cost_adj	     integer	 100
os_authent_prefix		     string	 ops$
os_roles			     boolean	 FALSE
remote_os_authent		     boolean	 FALSE
remote_os_roles 		     boolean	 FALSE
timed_os_statistics		     integer	 0

# 后缀为当前登陆到服务器的操作系统用户名
SQL> select distinct osuser from v$session;

OSUSER
------------------------------
oracle

# 如何创建操作系统审核的用户
SQL> create user ops$oracle identified by oracle;

User created.

SQL> grant create session to ops$oracle;

Grant succeeded.

SQL> conn /
Connected.
SQL> show user;
USER is "OPS$ORACLE"

# 若目前是booboo用户登陆的服务器如何创建一个对应的操作系统审核用户
# booboo的所属组为oinstall，附加组为dba

[root@oracle0 ~]# id booboo
uid=501(booboo) gid=501(oinstall) groups=501(oinstall),500(dba)
[root@oracle0 ~]# su - booboo
[booboo@oracle0 ~]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Fri Oct 20 17:20:09 2017

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL> select distinct osuser from v$session ;

OSUSER
------------------------------
booboo
oracle

SQL> show parameter os;

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
db_lost_write_protect		     string	 NONE
diagnostic_dest 		     string	 /u01/app/oracle
optimizer_index_cost_adj	     integer	 100
os_authent_prefix		     string	 ops$
os_roles			     boolean	 FALSE
remote_os_authent		     boolean	 FALSE
remote_os_roles 		     boolean	 FALSE
timed_os_statistics		     integer	 0
SQL> grant create session to ops$booboo identified by booboo;

Grant succeeded.

SQL> conn /
Connected.
SQL> show user
USER is "OPS$BOOBOO"

# 查看自己的权限
SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION

# 查看sysdba的权限
SQL> conn / as sysdba
SQL> select * from session_privs;

# 授予多个系统权限给一个用户
SQL> grant create table,create sequence to ops$booboo;

Grant succeeded.

SQL> conn /
Connected.
SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION
CREATE TABLE
CREATE SEQUENCE
# 注意此处的create权限包含了对对象的创建、修改、删除操作

SQL> conn /
Connected.

SQL> create table t1 (id int);

Table created.
SQL> insert into t1 values (1);
insert into t1 values (1)
            *
ERROR at line 1:
ORA-01950: no privileges on tablespace 'USERS'

SQL> alter table t1 add (name int);

Table altered.

SQL> desc t1;
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID						    NUMBER(38)
 NAME						    NUMBER(38)

SQL> drop table t1 purge;

Table dropped.

# 回收权限
SQL> conn / as sysdba   
Connected.
SQL> revoke create table ,create sequence from ops$booboo ;

# 级联授权
SQL> grant create table to ops$booboo with admin option;

SQL> conn /
Connected.
SQL> show user;
USER is "OPS$BOOBOO"

Grant succeeded.

SQL> select * from session_privs;

PRIVILEGE
----------------------------------------
CREATE SESSION
CREATE TABLE

SQL> grant create table to tom ;

Grant succeeded.

SQL> grant create table to ops$oracle;

Grant succeeded.

```


### 课后练习

1. 创建操作系统认证用户ops$tom
2. 查看自己的权限
3. 查看所有的权限
4. 级联授权


```shell
create role r1;
grant create session,create table to r1;

create role r2;
grant create view to r2;
grant delete on scott.emp to r2;

create role r3;
grant create procedure to r3;
grant update (sal) on scott.emp to r3;

grant r3 to r1;

create user tom identified by tom;
grant r1,r2 to tom;

grant create sequence to tom;
grant select on scott.emp to tom;
grant insert on scott.emp to tom;
grant update (comm) on scott.emp to tom;
```

### 级联授权

`dba --> user A --> user B`

系统权限级联授权：`with admin option` 权限回收无级联

```shell
grant CREATE SEQUENCE to tom with admin option;
```

对象权限级联授权：`with grant option` 权限回收有级联

```shell
grant insert on scott.e01 to tom with grant option;
```

```shell
# 系统管理员sysdba只能使用 with admin option
SQL> conn / as sysdba   
Connected.
# 级联授权
SQL> grant create table to ops$booboo with admin option;

# ops$booboo用户授权给ops$oracle用户create table的权限
SQL> grant create table to ops$oracle;

# sysdba回收ops$booboo用户的create table权限
SQL> conn / as sysdba
Connected.
SQL> revoke create table from ops$booboo;

# 测试发现ops$booboo用户的create table权限被回收了，而ops$oracle用户create table的权限没有被回收

|=================
# 一般用户只能使用with grant option
SQL> grant select on emp to ops$booboo with admin option;
grant select on emp to ops$booboo with admin option
                                       *
ERROR at line 1:
ORA-00993: missing GRANT keyword


SQL> grant select on emp to ops$booboo with grant option;

Grant succeeded.

# OPS$BOOBOO再授权给其他用户

SQL> grant select on scott.emp to ops$oracle ;

Grant succeeded.

SQL> show user;
USER is "OPS$BOOBOO"
SQL> set linesize 150
SQL> select * from scott.emp where rownum < 3;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30
# OPS$ORACLE用户
SQL> show user;
USER is "OPS$ORACLE"

SQL> set linesize 150;
SQL> select * from scott.emp where rownum < 3;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30


# scott用户回收对OPS$BOOBOO的授权后，ops$oracle也会失去select权限
SQL> revoke select on emp from ops$booboo;

Revoke succeeded.
```


