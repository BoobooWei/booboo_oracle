# SQL语句-查询语句-多表连接

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [SQL语句-查询语句-多表连接](#sql语句-查询语句-多表连接)
	- [熟悉每一张表的结构](#熟悉每一张表的结构)
	- [原理](#原理)
	- [案例](#案例)
		- [1. SMITH工作在哪里？](#1-smith工作在哪里)
		- [2. 10号部门的员工都工作在哪些城市？](#2-10号部门的员工都工作在哪些城市)
		- [3. 销售部门都有哪些员工，分别工作在哪些城市？](#3-销售部门都有哪些员工分别工作在哪些城市)
		- [4. 有所的员工姓名和对应的工作城市](#4-有所的员工姓名和对应的工作城市)
		- [5. 每个城市和对应的员工姓名，虽然波士顿没有员工，但是公司是有波士顿分部的，波士顿也要统计出来。](#5-每个城市和对应的员工姓名虽然波士顿没有员工但是公司是有波士顿分部的波士顿也要统计出来)
		- [6. 每个城市工作的员工有几个？](#6-每个城市工作的员工有几个)
		- [7. 每一个员工的工资等级是多少](#7-每一个员工的工资等级是多少)
		- [8. 每一个员工的直属领导者是谁？](#8-每一个员工的直属领导者是谁)
	- [国标连接语法](#国标连接语法)

<!-- /TOC -->

## 熟悉每一张表的结构


|emp|解释|
|:--|:--|
| EMPNO	|雇员编号|
| ENAME	|雇员名字|
| JOB	|职位|
| MGR	|上级编号|
| HIREDATE|雇佣时间|
| SAL	|工资|
| COMM	|奖金|
| DEPTNO|部门编号|

|dept|解释|
|:--|:--|
| DEPTNO|部门编号|
| DNAME	|部门名称|
| LOC|位置|

|bonus|解释|
|:--|:--|
| ENAME|雇员名字
| JOB|职位|
| SAL|工资|
| COMM|奖金|

|salgrade|解释|
|:--|:--|
| GRADE|等级|
| LOSAL|最低薪资|
| HISAL|最高薪资|

## 原理

1. `N`张表相连，需要`N-1`个条件
2. 多表连接，在oracle内部是两两相连
3. 内连接 `from a,b where a.id=b.id` 为
4. 右连接 `from a right join b on a.id=b.id` 等效于 `from a,b where a.id(+)=b.id`
5. 左连接 `from a left join b on a.id=b.id` 等小于 `from a,b where a.id=b.id(+)`
6. `count(*)` 会统计为null的行;count(列名)则不统计null的行
7. 不等连接 `from a,b where a.id between b.cc and b.dd`
8. 自连接 `from a t1,b t2 whee t1.id=t2.idd`
9. 笛卡尔连接 `from a,b`


## 案例

### 1. SMITH工作在哪里？

```sql
SQL> select ename,loc from emp,dept where emp.deptno=dept.deptno and lower(ename)='smith';

ENAME	   LOC
---------- -------------
SMITH	   DALLAS
```

### 2. 10号部门的员工都工作在哪些城市？

```sql
SQL> select ename,loc from emp,dept where emp.deptno=dept.deptno and emp.deptno=10;

ENAME	   LOC
---------- -------------
CLARK	   NEW YORK
KING	   NEW YORK
MILLER	   NEW YORK
```

### 3. 销售部门都有哪些员工，分别工作在哪些城市？

```sql
SQL> select ename,dname,loc from emp,dept where emp.deptno=dept.deptno and lower(dept.dname)='sales';
ENAME	   DNAME	  LOC
---------- -------------- -------------
WARD	   SALES	  CHICAGO
TURNER	   SALES	  CHICAGO
ALLEN	   SALES	  CHICAGO
JAMES	   SALES	  CHICAGO
BLAKE	   SALES	  CHICAGO
MARTIN	   SALES	  CHICAGO
```

### 4. 有所的员工姓名和对应的工作城市

```sql
SQL> select ename,loc from emp,dept where emp.deptno=dept.deptno;

ENAME	   LOC
---------- -------------
CLARK	   NEW YORK
KING	   NEW YORK
MILLER	   NEW YORK
JONES	   DALLAS
FORD	   DALLAS
ADAMS	   DALLAS
SMITH	   DALLAS
SCOTT	   DALLAS
WARD	   CHICAGO
TURNER	   CHICAGO
ALLEN	   CHICAGO
JAMES	   CHICAGO
BLAKE	   CHICAGO
MARTIN	   CHICAGO
```


### 5. 每个城市和对应的员工姓名，虽然波士顿没有员工，但是公司是有波士顿分部的，波士顿也要统计出来。

```sql
SQL> select ename,loc from emp,dept where emp.deptno(+)=dept.deptno;

ENAME	   LOC
---------- -------------
CLARK	   NEW YORK
KING	   NEW YORK
MILLER	   NEW YORK
JONES	   DALLAS
FORD	   DALLAS
ADAMS	   DALLAS
SMITH	   DALLAS
SCOTT	   DALLAS
WARD	   CHICAGO
TURNER	   CHICAGO
ALLEN	   CHICAGO
JAMES	   CHICAGO
BLAKE	   CHICAGO
MARTIN	   CHICAGO
	   BOSTON

15 rows selected.

SQL> select ename,loc from emp right join dept on emp.deptno=dept.deptno;

ENAME	   LOC
---------- -------------
CLARK	   NEW YORK
KING	   NEW YORK
MILLER	   NEW YORK
JONES	   DALLAS
FORD	   DALLAS
ADAMS	   DALLAS
SMITH	   DALLAS
SCOTT	   DALLAS
WARD	   CHICAGO
TURNER	   CHICAGO
ALLEN	   CHICAGO
JAMES	   CHICAGO
BLAKE	   CHICAGO
MARTIN	   CHICAGO
	   BOSTON

15 rows selected.

```

### 6. 每个城市工作的员工有几个？

```sql
SQL> select loc,count(*) from emp,dept where emp.deptno=dept.deptno group by loc;

LOC		COUNT(*)
------------- ----------
NEW YORK	       3
CHICAGO 	       6
DALLAS		       5
```

> 以上结果不够准确，因为波士顿还有分部，要加上波士顿

```sql
SQL> select count(ename),loc from emp right join dept on emp.deptno=dept.deptno group by loc;

COUNT(ENAME) LOC
------------ -------------
	   3 NEW YORK
	   6 CHICAGO
	   0 BOSTON
	   5 DALLAS

SQL> select count(*),loc from emp right join dept on emp.deptno=dept.deptno group by loc;

  COUNT(*) LOC
---------- -------------
	 3 NEW YORK
	 6 CHICAGO
	 1 BOSTON
	 5 DALLAS

```

以上统计中，必须使用count(列名)，count(*)将null值也统计进去了。


### 7. 每一个员工的工资等级是多少

```sql
SQL> select ename,grade from emp,salgrade where sal > losal and sal < hisal;

ENAME		GRADE
---------- ----------
SMITH		    1
JAMES		    1
ADAMS		    1
WARD		    2
MARTIN		    2
MILLER		    2
TURNER		    3
ALLEN		    3
CLARK		    4
BLAKE		    4
JONES		    4
KING		    5

12 rows selected.

SQL> select ename,grade from emp,salgrade where sal between losal and  hisal;

ENAME		GRADE
---------- ----------
SMITH		    1
JAMES		    1
ADAMS		    1
WARD		    2
MARTIN		    2
MILLER		    2
TURNER		    3
ALLEN		    3
CLARK		    4
BLAKE		    4
JONES		    4
SCOTT		    4
FORD		    4
KING		    5

14 rows selected.

```

oralce 不等连接

### 8. 每一个员工的直属领导者是谁？

```sql
SQL> select a.ename ename,b.ename manager from emp a,emp  b where a.mgr=b.empno;

ENAME	   MANAGER
---------- ----------
FORD	   JONES
SCOTT	   JONES
TURNER	   BLAKE
ALLEN	   BLAKE
WARD	   BLAKE
JAMES	   BLAKE
MARTIN	   BLAKE
MILLER	   CLARK
ADAMS	   SCOTT
BLAKE	   KING
JONES	   KING
CLARK	   KING
SMITH	   FORD

13 rows selected.

```

自连接


## 国标连接语法

|国标|语法|oracle|语法|备注|
|:--|:--|:--|:--|:--|
|交叉连接|`select ename,loc from emp cross join dept;`|笛卡尔连接|`select ename,loc from emp,dept;`||
|自然连接-有同名列|`select ename,loc from emp natural join dept;`|等值连接|`select ename,loc from emp,dept where emp.deptno=dept.deptno`|自然连接的前提条件是必须拥有同名的列|
|自然连接-多个同名列|`select ename,loc from emp join dept using (col1);`|等值连接|`select ename,loc from emp,dept where emp.deptno=dept.deptno`|;若两张表有多个同名列则需要用using(col)修正；|
|自然连接-无同名列|`select ename,loc from emp join dept on (emp.col1=dept.col2);`|等值连接|`select ename,loc from emp,dept where emp.col1=dept.col2`|若两张表没有同名的列则用on(a.co1=b.co2);|
|右外连接|`select ename,loc from emp right outer join dept using (deptno);`|右连接|`select ename,loc from emp,dept where emp.deptno(+)=dept.deptno;`|以右表为准|
|左外连接|`select ename,loc from emp left outer join dept using (deptno);`|左连接|`select ename,loc from emp,dept where emp.deptno=dept.deptno(+);`|以左表为准|
|全外连接|`select ename,loc from emp full outer join dept using (deptno);`|比较复杂||||


推荐使用国标，功能全，oracle书写简单
