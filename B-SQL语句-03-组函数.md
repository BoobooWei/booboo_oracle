# SQL语句-查询语句-组函数

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [SQL语句-查询语句-组函数](#sql语句-查询语句-组函数)
	- [组函数语法](#组函数语法)
	- [应用实例](#应用实例)
		- [1. 雇员中最大工资，最小工资，工资总和，平均工资。](#1-雇员中最大工资最小工资工资总和平均工资)
		- [2. 每个部门的工资总和和平均值](#2-每个部门的工资总和和平均值)
		- [3. 部门工资总和的最大值为多少](#3-部门工资总和的最大值为多少)
		- [4. 部门工资总和最多的部门名称和工资总和](#4-部门工资总和最多的部门名称和工资总和)
		- [5. 工资总和超过9000的部门](#5-工资总和超过9000的部门)
		- [6. 雇员中工资相同的员工分别是谁，工资为所少？](#6-雇员中工资相同的员工分别是谁工资为所少)
		- [7. 相同的工资有几个？](#7-相同的工资有几个)
		- [8. 每一年参加工作的雇员的数量](#8-每一年参加工作的雇员的数量)
	- [课后练习](#课后练习)

<!-- /TOC -->

## 组函数语法

> 对多行进行的计算

|组函数类型|解释|
|:--|:--|
|avg()|平均|
|count()|统计|
|max()|最大值|
|min()|最小值|
|stddev|估算标准偏差|
|sum|求和|
|variance|方差|

* group by 字句进行分组
* having 字句聚合函数过滤


| 序列                                        | 举例      |
| ------------------------------------------- | --------- |
| `rownum()`                                  | 1 2 3 4 5 |
| `rank() over (partition by order by)`       | 1 2 2 4 5 |
| `dense_rank() over (partition by order by)` | 1 2 2 3 4 |

```sql
select rank() over (partition by deptno order by sal desc) ord from emp;
```

* partition by 给结果集分组
* order by 给结果集排序
* rank() 在每个分组内部进行排名


## 应用实例

### 1. 雇员中最大工资，最小工资，工资总和，平均工资。

```sql
SQL> select min(sal),max(sal),sum(sal),avg(sal) from emp;

  MIN(SAL)   MAX(SAL)	SUM(SAL)   AVG(SAL)
---------- ---------- ---------- ----------
       800	 5000	   29025 2073.21429
```

### 2. 每个部门的工资总和和平均值

```sql
SQL> select deptno,to_char(avg(sal),'L99999.99') avg_sal,to_char(sum(sal),'L99999.99') sum_sal from emp group by deptno;

    DEPTNO AVG_SAL	       SUM_SAL
---------- ------------------- -------------------
	30	      $1566.67		  $9400.00
	20	      $2175.00		 $10875.00
	10	      $2916.67		  $8750.00
```

### 3. 部门工资总和的最大值为多少

```sql
SQL> select max(sum(sal)) from emp group by deptno;

MAX(SUM(SAL))
-------------
	10875
```

### 4. 部门工资总和最多的部门名称和工资总和

```sql
SQL> select deptno,sum_sal from (select deptno,sum(sal) sum_sal from emp group by deptno order by sum_sal desc ) where rownum < 2;

    DEPTNO    SUM_SAL
---------- ----------
	20	10875
```

### 5. 工资总和超过9000的部门

```sql
SQL> select deptno,sum(sal) sum_sal from emp group by deptno having sum_sal > 9000;
select deptno,sum(sal) sum_sal from emp group by deptno having sum_sal > 9000
                                                               *
ERROR at line 1:
ORA-00904: "SUM_SAL": invalid identifier


SQL> select deptno,sum(sal) sum_sal from emp group by deptno having sum(sal) > 9000;

    DEPTNO    SUM_SAL
---------- ----------
	30	 9400
	20	10875

```

* 注意having字句后面不可以使用别名。
* where字句不可以过滤组函数运算后的结果。


### 6. 雇员中工资相同的员工分别是谁，工资为所少？

```sql
SQL> select e1.ename,e2.ename,e1.sal from emp e1,emp e2 where e1.sal=e2.sal and e1.ename != e2.ename;

ENAME	   ENAME	     SAL
---------- ---------- ----------
MARTIN	   WARD 	    1250
WARD	   MARTIN	    1250
FORD	   SCOTT	    3000
SCOTT	   FORD 	    3000
```

### 7. 相同的工资有几个？

```sql
SQL> select sal,count(sal) from emp group by sal;

       SAL COUNT(SAL)
---------- ----------
      2450	    1
      5000	    1
      1300	    1
      1250	    2
      2850	    1
      2975	    1
      1100	    1
      3000	    2
       800	    1
      1600	    1
      1500	    1

       SAL COUNT(SAL)
---------- ----------
       950	    1

12 rows selected.

SQL> select sal,count(sal) from emp group by sal having count(sal)>1;

       SAL COUNT(SAL)
---------- ----------
      1250	    2
      3000	    2

SQL> select sal from emp group by sal having count(sal)>1;

       SAL
----------
      1250
      3000

SQL> select ename,sal from emp where sal in (select sal from emp group by sal having count(sal)>1);

ENAME		  SAL
---------- ----------
WARD		 1250
MARTIN		 1250
SCOTT		 3000
FORD		 3000
```

### 8. 每一年参加工作的雇员的数量

```sql
SQL> select count(to_char(hiredate,'yyyy')) enum, to_char(hiredate,'yyyy') year from emp group by to_char(hiredate,'yyyy');

      ENUM YEAR
---------- ----
	 2 1987
	 1 1980
	 1 1982
	10 1981

SQL> select sum(case when to_char(hiredate,'yy')='81' then 1 else 0 end) "81",sum(decode(to_char(hiredate,'yy'),82,1,0)) "82",sum(decode(to_char(hiredate,'yy'),80,1,0)) "80",sum(decode(to_char(hiredate,'yy'),87,1,0)) "87" from emp;

	81	   82	      80	 87
---------- ---------- ---------- ----------
	10	    1	       1	  2


```




## 课后练习

```sql
select max(sal),min(sal),sum(sal),avg(sal) from emp;

select count(*) from emp;
select count(*) from emp where deptno=30;
select count(deptno) from emp;
select count(distinct deptno) from emp;
select count(comm) from emp;
select avg(comm) from emp;
select avg(nvl(comm,0)) from emp;
select deptno,sum(sal) from emp group by deptno;
select deptno,job,sum(sal) from emp group by deptno,job;
select deptno,sum(sal) from emp having sum(sal)>9000 group by deptno;
--------------------------------
10部门的最大工资
--------------------------------
查找重复的工资
--------------------------------
80年 81年 82年 87年都有多少新员工

1980  1981  1982  1987
----  ----  ----  ----
   1    10     1     2
--------------------------------
```
