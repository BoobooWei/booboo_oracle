# SQL语句-DML语句的使用

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [SQL语句-DML语句的使用](#sql语句-dml语句的使用)
	- [DML的分类](#dml的分类)
		- [insert](#insert)
		- [update](#update)
		- [delete](#delete)
		- [truncate](#truncate)
	- [事务](#事务)
	- [操作实践](#操作实践)
		- [1. 向emp表中添加新行：](#1-向emp表中添加新行)
		- [2. 子查询拷贝行](#2-子查询拷贝行)
		- [3. 修改表中数据](#3-修改表中数据)
		- [4. 向虚拟表中插入行](#4-向虚拟表中插入行)
		- [5. with check option 选项](#5-with-check-option-选项)
		- [6. merge合并行](#6-merge合并行)

<!-- /TOC -->

数据操纵语言( DML )是SQL的核心部分。当你想要增加,更新或者删除数据库中的数据的时候,你可以通过执行DML语句来实现。一组DML语句的集合组成了一个逻辑工作单元称为事务。

想想银行业的数据库,当银行顾客将金钱从一个储蓄账户转移到一个核算帐户,该事务可能由三个独立的操作组成:减少储蓄帐户的金额,增加核算帐户的金额,在事务日志中记录该事务。Oracle服务器必须保证所有的这些SQL语句执行后帐户间数目的平衡。当某些事情阻止了事务中一个语句的执行,那么事务中其他语句必须被撤销。


## DML的分类

* 增 insert into
* 删 delete from （对比truncate）
* 改 update
* 合并行 merge
* 控制事务处理


### insert

使用 INSERT 语句可在表中添加新行:

```sql
INSERT INTO table [(column [, column...])]
VALUES (value [, value...]);
```


### update

使用 UPDATE 语句修改表中的现有值:

```sql
UPDATE table
SET column = value [, column = value, ...]
[WHERE condition];
```

如果需要,可以一次更新多行。

### delete

使用 DELETE 语句可以从表中删除现有行:

```sql
DELETE [FROM] table
[WHERE condition];
```

### truncate

TRUNCATE 语句
* 从表中删除所有行,使表为空并保留表结构不变
* 是数据定义语言 (DDL) 语句而不是 DML 语句,无法轻易将其取消
* 语法:

`TRUNCATE TABLE table_name;`

## 事务

* commit 提交
* rollback 回滚到事务开始之前
* savepoint A 保存状态
* rollback to savepoint A 回滚到状态A

## 操作实践

### 1. 向emp表中添加新行：

对所有列赋值

```sql
desc emp
insert into emp values (1,'Tom','CLERK',7698,to_date('yyyy-mm-dd','2016-08-25'),1450,null,30);
```

对指定的列赋值
```sql
insert into emp (empno,ename) values (2,'Jerry');
```

sql脚本`inst.sql`


```sql
insert into dept values (&deptno,upper('&dname'),upper('&loc'));
```

### 2. 子查询拷贝行

```sql
emp表中有奖金的员工存放在新创建的表bonus中
insert into bonus select ENAME,JOB,SAL,COMM from emp where comm>0;
```

### 3. 修改表中数据

```sql
smith工资涨百分之10
update emp set sal=sal*1.1 where ename='SMITH';
```

### 4. 向虚拟表中插入行

```sql
insert into (select empno,ename,deptno from emp where deptno=10)
values (2,'Alvin',20);

通过sql脚本来执行`ins10.sql`


```sql
insert into (select * from emp where deptno=10 with check option)
values (&empno,'&ename','&job',&mgr,'&hiredate',&sal,&comm,&deptno);
```

### 5. with check option 选项

```sql
设置with check option选项
SQL> insert into (select * from emp where deptno=10 with check option) values (901,'booboo2','dba',7782,sysdate,7000,8000,10);

1 row created.

SQL> select * from emp where deptno=10;
     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
       901 booboo2    dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10

SQL> insert into (select * from emp where deptno=10 with check option) values (901,'booboo2','dba',7782,sysdate,7000,8000,20);
insert into (select * from emp where deptno=10 with check option) values (901,'booboo2','dba',7782,sysdate,7000,8000,20)
                           *
ERROR at line 1:
ORA-01402: view WITH CHECK OPTION where-clause violation
```
如果设置了该选项，那么插入的新记录，必须和where后面的匹配，比如案例中，where指定了部门为10，那么插入的也必须为10部门的记录。

### 6. merge合并行

* 数据源：emp
* 目标表：copy_emp

```sql
create table copy_emp as select * from emp where deptno=10;
```

* matched--> 目标表中的主键值在数据源中被找到
* not matched --> 数据源中主键在目标表中不存在

```sql
merge into copy_emp c
using emp e
on (c.empno=e.empno)
when matched then
update set
c.ename=e.ename,
c.job=e.job,
c.mgr=e.mgr,
c.hiredate=e.hiredate,
c.sal=e.sal,
c.comm=e.comm,
c.deptno=e.deptno
when not matched then
insert values
(e.empno,
e.ename,
e.job,
e.mgr,
e.hiredate,
e.sal,
e.comm,
e.deptno);
```


操作记录

```sql
SQL> create table copy_emp as select * from emp where deptno=10;

Table created.

SQL> merge into copy_emp c
  2  using emp e
  3  on (c.empno=e.empno)
when matched then
update set
c.ename=e.ename,
c.job=e.job,
c.mgr=e.mgr,
c.hiredate=e.hiredate,
c.sal=e.sal,
c.comm=e.comm,
c.deptno=e.deptno
when not matched then
insert values
(e.empno,
e.ename,
e.job,
e.mgr,
e.hiredate,
e.sal,
e.comm,
 22  e.deptno);

16 rows merged.

SQL> select * from copy_emp;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
       901 booboo2    dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10
      7844 TURNER     SALESMAN	      7698 08-SEP-81	   1500 	 0	   30
      7521 WARD       SALESMAN	      7698 22-FEB-81	   1250        500	   30
      7654 MARTIN     SALESMAN	      7698 28-SEP-81	   1250       1400	   30
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20
      7698 BLAKE      MANAGER	      7839 01-MAY-81	   2850 		   30
      7566 JONES      MANAGER	      7839 02-APR-81	   2975 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000 		   20
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7876 ADAMS      CLERK	      7788 23-MAY-87	   1100 		   20
      7900 JAMES      CLERK	      7698 03-DEC-81	    950 		   30

16 rows selected.
```


源表进行了修改
```sql
SQL> insert into emp (empno,ename,sal) values (1,'Alvin',1400);

1 row created.

SQL> update emp set sal=1111 where empno=7788;

1 row updated.
```

目标表与源表不一致了
```sql
SQL> select * from copy_emp;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
       901 booboo2    dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10
      7844 TURNER     SALESMAN	      7698 08-SEP-81	   1500 	 0	   30
      7521 WARD       SALESMAN	      7698 22-FEB-81	   1250        500	   30
      7654 MARTIN     SALESMAN	      7698 28-SEP-81	   1250       1400	   30
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20
      7698 BLAKE      MANAGER	      7839 01-MAY-81	   2850 		   30
      7566 JONES      MANAGER	      7839 02-APR-81	   2975 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000 		   20
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7876 ADAMS      CLERK	      7788 23-MAY-87	   1100 		   20
      7900 JAMES      CLERK	      7698 03-DEC-81	    950 		   30

16 rows selected.

SQL> select * from emp;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
       901 booboo2    dba	      7782 31-JUL-17	   7000       8000	   10
	 1 Alvin					   1400
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30
      7521 WARD       SALESMAN	      7698 22-FEB-81	   1250        500	   30
      7566 JONES      MANAGER	      7839 02-APR-81	   2975 		   20
      7654 MARTIN     SALESMAN	      7698 28-SEP-81	   1250       1400	   30
      7698 BLAKE      MANAGER	      7839 01-MAY-81	   2850 		   30
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7788 SCOTT      ANALYST	      7566 19-APR-87	   1111 		   20
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7844 TURNER     SALESMAN	      7698 08-SEP-81	   1500 	 0	   30
      7876 ADAMS      CLERK	      7788 23-MAY-87	   1100 		   20
      7900 JAMES      CLERK	      7698 03-DEC-81	    950 		   30
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000 		   20
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10


17 rows selected.
```

再次合并

```sql
merge into copy_emp c
using emp e
on (c.empno=e.empno)
when matched then
update set
c.ename=e.ename,
c.job=e.job,
c.mgr=e.mgr,
c.hiredate=e.hiredate,
c.sal=e.sal,
c.comm=e.comm,
c.deptno=e.deptno
when not matched then
insert values
(e.empno,
e.ename,
e.job,
e.mgr,
e.hiredate,
e.sal,
e.comm,
e.deptno);

17 rows merged.
```

合并后与源表一致

```sql
SQL> select * from copy_emp;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
       901 booboo2    dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10
      7844 TURNER     SALESMAN	      7698 08-SEP-81	   1500 	 0	   30
      7521 WARD       SALESMAN	      7698 22-FEB-81	   1250        500	   30
      7654 MARTIN     SALESMAN	      7698 28-SEP-81	   1250       1400	   30
      7788 SCOTT      ANALYST	      7566 19-APR-87	   1111 		   20
      7698 BLAKE      MANAGER	      7839 01-MAY-81	   2850 		   30
      7566 JONES      MANAGER	      7839 02-APR-81	   2975 		   20
      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300	   30
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000 		   20
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7876 ADAMS      CLERK	      7788 23-MAY-87	   1100 		   20
      7900 JAMES      CLERK	      7698 03-DEC-81	    950 		   30
	 1 Alvin					   1400

17 rows selected.
```

这是数据仓库的一些用法

修改目标表后再此合并

```sql
SQL> update copy_emp set sal=1499 where empno=1;

1 row updated.

SQL> select * from emp where empno=1;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
	 1 Alvin					   1400

SQL> select * from copy_emp where empno=1;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
	 1 Alvin					   1499

merge into copy_emp c
using emp e
on (c.empno=e.empno)
when matched then
update set
c.ename=e.ename,
c.job=e.job,
c.mgr=e.mgr,
c.hiredate=e.hiredate,
c.sal=e.sal,
c.comm=e.comm,
c.deptno=e.deptno
when not matched then
insert values
(e.empno,
e.ename,
e.job,
e.mgr,
e.hiredate,
e.sal,
e.comm,
e.deptno);

17 rows merged.

SQL> select * from emp where empno=1;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
	 1 Alvin					   1400

SQL> select * from copy_emp where empno=1;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
	 1 Alvin					   1400
```
