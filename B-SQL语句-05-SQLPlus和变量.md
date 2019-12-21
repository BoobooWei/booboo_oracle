# SQL语句-查询语句-SQLPlus和变量

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [SQL语句-查询语句-SQLPlus和变量](#sql语句-查询语句-sqlplus和变量)
	- [变量的类型](#变量的类型)
		- [替代变量](#替代变量)
			- [实践1-where 字句中包含替代变量](#实践1-where-字句中包含替代变量)
			- [实践2-select 字句中包含替代变量](#实践2-select-字句中包含替代变量)
			- [实践3-from 字句中包含替代变量](#实践3-from-字句中包含替代变量)
			- [实践4-如果替代变量的类型为字符串，需要加单引号](#实践4-如果替代变量的类型为字符串需要加单引号)
			- [实践5-分页查询:每页5行](#实践5-分页查询每页5行)
			- [实践6-替代变量的声明调用查看取消](#实践6-替代变量的声明调用查看取消)
			- [实践7-`&&`的作用](#实践7-的作用)
		- [SQLPlus环境变量](#sqlplus环境变量)
			- [实践1- `verify`新老语句的对比开关](#实践1-verify新老语句的对比开关)
			- [实践2- `echo`控制脚本执行时是否显示命令](#实践2-echo控制脚本执行时是否显示命令)
			- [实践3- arraysize](#实践3-arraysize)
			- [实践4-feedback](#实践4-feedback)
			- [实践5-`heading`决定是否列标题显示在报表中](#实践5-heading决定是否列标题显示在报表中)
			- [实践6-`long`默认打印出80个字符](#实践6-long默认打印出80个字符)
		- [SQLPlus报表格式](#sqlplus报表格式)
			- [实践1-列名换行](#实践1-列名换行)
			- [实践2-给工资列加美元前缀](#实践2-给工资列加美元前缀)
			- [实践3-给sal和comm列设置美元前缀，列名居中显示](#实践3-给sal和comm列设置美元前缀列名居中显示)
			- [实践4-清空格式](#实践4-清空格式)
			- [实践5-在上一条sql的基础上进行排序，再次调用用`/`](#实践5-在上一条sql的基础上进行排序再次调用用)
			- [实践6-BREAK 命令将行分成部分并限制重复的值](#实践6-break-命令将行分成部分并限制重复的值)
			- [实践7-将结果集以报表的形式打印bti](#实践7-将结果集以报表的形式打印bti)
		- [SQLPlus的spool脱机模式](#sqlplus的spool脱机模式)
	- [SQLPlus行转列](#sqlplus行转列)

<!-- /TOC -->

## 变量的类型

|变量类型|设置|查看|调用|备注|
|:--|:--|:--|:--|:--|
|替代变量|define p=sal|define p|&p 或者 &&p|临时生效，可以出现在任何位置|
|SQLPlus环境变量|set echo on|show echo||当前会话生效|
|SQLPlus环境变量|配置文件|show echo||永久生效|

### 替代变量

若没有事先声明一个变量，那么引用的时候：

1. `&p` 代表一次性声明，从键盘输入变量的值，下次还需要再次输入，define命令不能看到p变量
2. `&&p` 代表当前会话中的声明，从键盘输入变量的值，下次就不需要再输入，define命令能看到p变量

#### 实践1-where 字句中包含替代变量

查询emp表中部门编号为变量p的值的员工姓名

```sql
SQL> select ename,deptno from emp where deptno=&p;
Enter value for p: 10
old   1: select ename,deptno from emp where deptno=&p
new   1: select ename,deptno from emp where deptno=10

ENAME	       DEPTNO
---------- ----------
CLARK		   10
KING		   10
MILLER		   10

SQL> select ename,deptno from emp where deptno=&p;
Enter value for p: 20
old   1: select ename,deptno from emp where deptno=&p
new   1: select ename,deptno from emp where deptno=20

ENAME	       DEPTNO
---------- ----------
SMITH		   20
JONES		   20
SCOTT		   20
ADAMS		   20
FORD		   20

```

#### 实践2-select 字句中包含替代变量

查看雇员姓名和变量c的值

```sql
SQL> select ename,&c from emp;
Enter value for c: deptno
old   1: select ename,&c from emp
new   1: select ename,deptno from emp

ENAME	       DEPTNO
---------- ----------
SMITH		   20
ALLEN		   30
WARD		   30
JONES		   20
MARTIN		   30
BLAKE		   30
CLARK		   10
SCOTT		   20
KING		   10
TURNER		   30
ADAMS		   20

ENAME	       DEPTNO
---------- ----------
JAMES		   30
FORD		   20
MILLER		   10

14 rows selected.

SQL> select ename,&c from emp;
Enter value for c: sal
old   1: select ename,&c from emp
new   1: select ename,sal from emp

ENAME		  SAL
---------- ----------
SMITH		  800
ALLEN		 1600
WARD		 1250
JONES		 2975
MARTIN		 1250
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500
ADAMS		 1100

ENAME		  SAL
---------- ----------
JAMES		  950
FORD		 3000
MILLER		 1300

14 rows selected.
```


#### 实践3-from 字句中包含替代变量

查看变量p所代表的表中的前5行

```sql
SQL> select * from &t where rownum < 6;
Enter value for t: salgrade
old   1: select * from &t where rownum < 6
new   1: select * from salgrade where rownum < 6

     GRADE	LOSAL	   HISAL
---------- ---------- ----------
	 1	  700	    1200
	 2	 1201	    1400
	 3	 1401	    2000
	 4	 2001	    3000
	 5	 3001	    9999

SQL> select * from &t where rownum < 6;
Enter value for t: dept
old   1: select * from &t where rownum < 6
new   1: select * from dept where rownum < 6

    DEPTNO DNAME	  LOC
---------- -------------- -------------
	10 ACCOUNTING	  NEW YORK
	20 RESEARCH	  DALLAS
	30 SALES	  CHICAGO
	40 OPERATIONS	  BOSTON

```

#### 实践4-如果替代变量的类型为字符串，需要加单引号

查询emp表中雇员姓名为某个值的

```sql
SQL> select * from emp where ename=&e;
Enter value for e: scott
old   1: select * from emp where ename=&e
new   1: select * from emp where ename=scott
select * from emp where ename=SCOTT
                              *
ERROR at line 1:
ORA-00904: "SCOTT": invalid identifier


SQL> select * from emp where ename='&e';
Enter value for e: SCOTT
old   1: select * from emp where ename='&e'
new   1: select * from emp where ename='SCOTT'

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000
	20

```

#### 实践5-分页查询:每页5行

按照工资高低排序，并分页显示，每页5行

```bash
1 1 5
2 6 10
3 11 15
n n*5-4   n*5
```


```sql
SQL> select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &p*5-4 and &p*5;
Enter value for p: 1
Enter value for p: 1
old   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &p*5-4 and &p*5
new   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between 1*5-4 and 1*5

	RN ENAME	     SAL
---------- ---------- ----------
	 1 KING 	    5000
	 2 FORD 	    3000
	 3 SCOTT	    3000
	 4 JONES	    2975
	 5 BLAKE	    2850

SQL> /
Enter value for p: 2
Enter value for p: 2
old   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &p*5-4 and &p*5
new   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between 2*5-4 and 2*5

	RN ENAME	     SAL
---------- ---------- ----------
	 6 CLARK	    2450
	 7 ALLEN	    1600
	 8 TURNER	    1500
	 9 MILLER	    1300
	10 WARD 	    1250

SQL> /
Enter value for p: 3
Enter value for p: 3
old   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &p*5-4 and &p*5
new   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between 3*5-4 and 3*5

	RN ENAME	     SAL
---------- ---------- ----------
	11 MARTIN	    1250
	12 ADAMS	    1100
	13 JAMES	     950
	14 SMITH	     800

```

#### 实践6-替代变量的声明调用查看取消

```sql
SQL> define
DEFINE _DATE	       = "31-JUL-17" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcl" (CHAR)
DEFINE _USER	       = "SCOTT" (CHAR)
DEFINE _PRIVILEGE      = "" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1102000400" (CHAR)
DEFINE _EDITOR	       = "vim" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options" (CHAR)
DEFINE _O_RELEASE      = "1102000400" (CHAR)
```

声明一个替代变量define

```sql
SQL> define col=sal

SQL> define
DEFINE _DATE	       = "31-JUL-17" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcl" (CHAR)
DEFINE _USER	       = "SCOTT" (CHAR)
DEFINE _PRIVILEGE      = "" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1102000400" (CHAR)
DEFINE _EDITOR	       = "vim" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options" (CHAR)
DEFINE _O_RELEASE      = "1102000400" (CHAR)
DEFINE COL	       = "sal" (CHAR)

SQL> select ename,&col from emp;
old   1: select ename,&col from emp
new   1: select ename,sal from emp

ENAME		  SAL
---------- ----------
SMITH		  800
ALLEN		 1600
WARD		 1250
JONES		 2975
MARTIN		 1250
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500
ADAMS		 1100

ENAME		  SAL
---------- ----------
JAMES		  950
FORD		 3000
MILLER		 1300

14 rows selected.
```

查看变量的值

```sql
SQL> select '&col' from dual;
old   1: select '&col' from dual
new   1: select 'sal' from dual

SA
---
sal
```

取消变量undefine

```sql
SQL> undefine col
SQL> define
DEFINE _DATE	       = "31-JUL-17" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcl" (CHAR)
DEFINE _USER	       = "SCOTT" (CHAR)
DEFINE _PRIVILEGE      = "" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1102000400" (CHAR)
DEFINE _EDITOR	       = "vim" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options" (CHAR)
DEFINE _O_RELEASE      = "1102000400" (CHAR)
SQL> select '&col' from dual;
Enter value for col: xx
old   1: select '&col' from dual
new   1: select 'xx' from dual

'X'
--
xx
```


#### 实践7-`&&`的作用

```sql
SQL> select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &&p*5-4 and &p*5;
Enter value for p: 1
old   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &&p*5-4 and &p*5
new   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between 1*5-4 and 1*5

	RN ENAME	     SAL
---------- ---------- ----------
	 1 KING 	    5000
	 2 FORD 	    3000
	 3 SCOTT	    3000
	 4 JONES	    2975
	 5 BLAKE	    2850

SQL> definle
SP2-0042: unknown command "definle" - rest of line ignored.
SQL> define
DEFINE _DATE	       = "31-JUL-17" (CHAR)
DEFINE _CONNECT_IDENTIFIER = "orcl" (CHAR)
DEFINE _USER	       = "SCOTT" (CHAR)
DEFINE _PRIVILEGE      = "" (CHAR)
DEFINE _SQLPLUS_RELEASE = "1102000400" (CHAR)
DEFINE _EDITOR	       = "vim" (CHAR)
DEFINE _O_VERSION      = "Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options" (CHAR)
DEFINE _O_RELEASE      = "1102000400" (CHAR)
DEFINE P	       = "1" (CHAR)

SQL> select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &&p*5-4 and &p*5;
old   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between &&p*5-4 and &p*5
new   1: select b.* from (select rownum rn,a.* from (select ename,sal from emp order by sal desc ) a ) b where rn between 1*5-4 and 1*5

	RN ENAME	     SAL
---------- ---------- ----------
	 1 KING 	    5000
	 2 FORD 	    3000
	 3 SCOTT	    3000
	 4 JONES	    2975
	 5 BLAKE	    2850

```

* 优点是第二个&p不需要手动输入了
* 缺点在于下一次如果需要修改p的值，还得undefine

### SQLPlus环境变量

|SET 变量和值|描述|备注|
|:--|:--|:--|
|VERIFY {OFF\|ON}|新老两行的比较是否显示|默认开启|
|ECHO {OFF\|ON}|执行sql脚本时，是否显示脚本中的sql语句|默认关闭|
|ARRAY[SIZE] {20\| n}|设置数据库取回数据的大小（行）|默认为15，范围为1～5000|
|FEED[BACK] {6\|n\|OFF\|ON}| 当查询选择了n行后,显示查询返回记录的数量||
|HEA[DING] {OFF\|ON}|决定是否列标题显示在报表中|默认开启|
|LONG {80\|n} |设置显示 LONG 值时的最大宽度|默认80个字符|


获取更加可读性的报表,你可以通过使用下面的命令控制报表栏

|命令|描述|
|:---|:--|
|COL[UMN]|控制列格式|
|TTI[TLE] [text\|OFF\|ON]|指定每页报表顶部显示的标题|
|BTI[TLE] [text\|OFF\|ON]|指定每页报表底部显示的脚注|
|BRE[AK] [ON report_element]|限制重复的值和使用连接符将数据行分成几部分|

#### 实践1- `verify`新老语句的对比开关


show命令查看环境变量verify

```sql
SQL> show verify
verify ON
```

设置该环境变量为off状态

```sql
SQL> set verify off


SQL> show verify
verify OFF

SQL> select ename,sal from emp where sal>&p;
Enter value for p: 2000

ENAME		  SAL
---------- ----------
JONES		 2975
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
FORD		 3000

6 rows selected.
```



#### 实践2- `echo`控制脚本执行时是否显示命令

```sql
SQL> show echo
echo OFF
SQL> list
  1* select ename,sal from emp where sal>&p
SQL> save 1.sql
Created file 1.sql
SQL> get 1.sql
  1* select ename,sal from emp where sal>&p
SQL> @1
Enter value for p: 2000
old   1: select ename,sal from emp where sal>&p
new   1: select ename,sal from emp where sal>2000

ENAME		  SAL
---------- ----------
JONES		 2975
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
FORD		 3000

6 rows selected.

SQL> set echo on
SQL> @1.sql
SQL> select ename,sal from emp where sal>&p
  2  /
Enter value for p: 2000
old   1: select ename,sal from emp where sal>&p
new   1: select ename,sal from emp where sal>2000

ENAME		  SAL
---------- ----------
JONES		 2975
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
FORD		 3000

6 rows selected.
```

#### 实践3- arraysize

数据库取回数据的大小为15行

```sql
SQL> show arraysize
arraysize 15
```
arraysize最大值为5000

```sql
SQL> set arraysize 5000
SQL> set arraysize 5001
SP2-0267: arraysize option 5001 out of range (1 through 5000)
```

#### 实践4-feedback

当查询选择了n行后,显示查询返回记录的数量

```sql
SQL> show feedback
FEEDBACK ON for 6 or more rows

SQL> set feedback on;
SQL> show feedback;
FEEDBACK ON for 1 or more rows
SQL> select * from salgrade;

     GRADE	LOSAL	   HISAL
---------- ---------- ----------
	 1	  700	    1200
	 2	 1201	    1400
	 3	 1401	    2000
	 4	 2001	    3000
	 5	 3001	    9999

5 rows selected.

SQL> set feedback off;
SQL> show feedback;
feedback OFF
SQL> set feedback 6;
SQL> show feedback;
FEEDBACK ON for 6 or more rows
```

#### 实践5-`heading`决定是否列标题显示在报表中

```sql
SQL> show heading
heading ON
SQL> select * from salgrade;

     GRADE	LOSAL	   HISAL
---------- ---------- ----------
	 1	  700	    1200
	 2	 1201	    1400
	 3	 1401	    2000
	 4	 2001	    3000
	 5	 3001	    9999

SQL> set heading off;
SQL> select * from salgrade;

	 1	  700	    1200
	 2	 1201	    1400
	 3	 1401	    2000
	 4	 2001	    3000
	 5	 3001	    9999

SQL> set heading on;
```

#### 实践6-`long`默认打印出80个字符

```sql
SQL> show long
long 80
```

打印emp表的元数据，发现不全

```sql
SQL> select dbms_metadata.get_ddl('TABLE','EMP') from dual;

DBMS_METADATA.GET_DDL('TABLE','EMP')
--------------------------------------------------------------------------------

  CREATE TABLE "SCOTT"."EMP"
   (	"EMPNO" NUMBER(4,0),
	"ENAME" VARCHAR2(10),
```

修改long的值

```sql
SQL> set long 50000

SQL> select dbms_metadata.get_ddl('TABLE','EMP') from dual;

DBMS_METADATA.GET_DDL('TABLE','EMP')
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

### SQLPlus报表格式

#### 实践1-列名换行

```sql
SQL> col ename heading 'first|name'
SQL> select ename,sal from emp;

first
name		  SAL
---------- ----------
SMITH		  800
ALLEN		 1600
WARD		 1250
JONES		 2975
MARTIN		 1250
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500
ADAMS		 1100
JAMES		  950
FORD		 3000
MILLER		 1300

14 rows selected.
```

#### 实践2-给工资列加美元前缀

```sql
SQL> col sal for $99,999.99
SQL> select ename,sal from emp;

first
name		   SAL
---------- -----------
SMITH	       $800.00
ALLEN	     $1,600.00
WARD	     $1,250.00
JONES	     $2,975.00
MARTIN	     $1,250.00
BLAKE	     $2,850.00
CLARK	     $2,450.00
SCOTT	     $3,000.00
KING	     $5,000.00
TURNER	     $1,500.00
ADAMS	     $1,100.00
JAMES	       $950.00
FORD	     $3,000.00
MILLER	     $1,300.00

14 rows selected.
```

#### 实践3-给sal和comm列设置美元前缀，列名居中显示

```sql
SQL> col sal justify c for $99,999.99
SQL> col comm justify c for $99,999.99

SQL> select ename,sal,comm from emp;

first
name	       SAL	  COMM
---------- ----------- -----------
SMITH	       $800.00
ALLEN	     $1,600.00	   $300.00
WARD	     $1,250.00	   $500.00
JONES	     $2,975.00
MARTIN	     $1,250.00	 $1,400.00
BLAKE	     $2,850.00
CLARK	     $2,450.00
SCOTT	     $3,000.00
KING	     $5,000.00
TURNER	     $1,500.00	      $.00
ADAMS	     $1,100.00
JAMES	       $950.00
FORD	     $3,000.00
MILLER	     $1,300.00

14 rows selected.
```


#### 实践4-清空格式

```sql
SQL> col ename clear
SQL> col sal clear
SQL> col comm clear
SQL> select ename,sal,comm from emp;

ENAME		  SAL	    COMM
---------- ---------- ----------
SMITH		  800
ALLEN		 1600	     300
WARD		 1250	     500
JONES		 2975
MARTIN		 1250	    1400
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500	       0
ADAMS		 1100
JAMES		  950
FORD		 3000
MILLER		 1300

14 rows selected.
```

#### 实践5-在上一条sql的基础上进行排序，再次调用用`/`

```sql
SQL> select deptno,ename from emp;

    DEPTNO ENAME
---------- ----------
	20 SMITH
	30 ALLEN
	30 WARD
	20 JONES
	30 MARTIN
	30 BLAKE
	10 CLARK
	20 SCOTT
	10 KING
	30 TURNER
	20 ADAMS
	30 JAMES
	20 FORD
	10 MILLER

14 rows selected.

SQL> a  order by deptno
  1* select deptno,ename from emp order by deptno
SQL> /

    DEPTNO ENAME
---------- ----------
	10 CLARK
	10 KING
	10 MILLER
	20 JONES
	20 FORD
	20 ADAMS
	20 SMITH
	20 SCOTT
	30 WARD
	30 TURNER
	30 ALLEN
	30 JAMES
	30 BLAKE
	30 MARTIN

14 rows selected.
```

#### 实践6-BREAK 命令将行分成部分并限制重复的值

```sql
SQL> select deptno,ename from emp;

    DEPTNO ENAME
---------- ----------
	20 SMITH
	30 ALLEN
	30 WARD
	20 JONES
	30 MARTIN
	30 BLAKE
	10 CLARK
	20 SCOTT
	10 KING
	30 TURNER
	20 ADAMS
	30 JAMES
	20 FORD
	10 MILLER

14 rows selected.

SQL> break on deptno
SQL> /

    DEPTNO ENAME
---------- ----------
	20 SMITH
	30 ALLEN
	   WARD
	20 JONES
	30 MARTIN
	   BLAKE
	10 CLARK
	20 SCOTT
	10 KING
	30 TURNER
	20 ADAMS
	30 JAMES
	20 FORD
	10 MILLER

14 rows selected.

SQL> select deptno,ename from emp order by deptno;

    DEPTNO ENAME
---------- ----------
	10 CLARK
	   KING
	   MILLER
	20 JONES
	   FORD
	   ADAMS
	   SMITH
	   SCOTT
	30 WARD
	   TURNER
	   ALLEN
	   JAMES
	   BLAKE
	   MARTIN

14 rows selected.
```

清除break

```sql
SQL> clear break
breaks cleared
```


#### 实践7-将结果集以报表的形式打印bti

```sql
SQL> show tti
ttitle OFF and is the first few characters of the next SELECT statement
SQL> show bti
btitle OFF and is the following 10 characters:
End report
SQL> tti 'Start Booboo'
SQL> bti 'End Booboo'
SQL> set pagesize 25
SQL> select ename,sal,deptno from emp;

Mon Jul 31										       page    1
						      Start Booboo

ENAME		  SAL	  DEPTNO
---------- ---------- ----------
SMITH		  800	      20
ALLEN		 1600	      30
WARD		 1250	      30
JONES		 2975	      20
MARTIN		 1250	      30
BLAKE		 2850	      30
CLARK		 2450	      10
SCOTT		 3000	      20
KING		 5000	      10
TURNER		 1500	      30
ADAMS		 1100	      20
JAMES		  950	      30
FORD		 3000	      20
MILLER		 1300	      10




						       End Booboo

14 rows selected.

```

注意：以上和sql语句无关，都是sqlplus带来的一些特性



### SQLPlus的spool脱机模式

* spool 1.txt 开始脱机
* spool off 结束脱机存盘
* spool 1.txt append 追加脱机
* spool off 结束脱机存盘

```sql
SQL> spool 1.txt
SQL> select * fro salgrade;
select * fro salgrade
         *
ERROR at line 1:
ORA-00923: FROM keyword not found where expected


SQL> select * from salgrade;

     GRADE	LOSAL	   HISAL
---------- ---------- ----------
	 1	  700	    1200
	 2	 1201	    1400
	 3	 1401	    2000
	 4	 2001	    3000
	 5	 3001	    9999

SQL> spool off
SQL> spool 1.txt append
SQL> select * from dept;

    DEPTNO DNAME	  LOC
---------- -------------- -------------
	10 ACCOUNTING	  NEW YORK
	20 RESEARCH	  DALLAS
	30 SALES	  CHICAGO
	40 OPERATIONS	  BOSTON

SQL> spool off


[oracle@oracle0 ~]$ cat 1.txt
SQL> select * fro salgrade;
select * fro salgrade
         *
ERROR at line 1:
ORA-00923: FROM keyword not found where expected


SQL> select * from salgrade;

     GRADE      LOSAL      HISAL                                                                                        
---------- ---------- ----------                                                                                        
         1        700       1200                                                                                        
         2       1201       1400                                                                                        
         3       1401       2000                                                                                        
         4       2001       3000                                                                                        
         5       3001       9999                                                                                        

SQL> spool off
SQL> select * from dept;

    DEPTNO DNAME          LOC                                                                                           
---------- -------------- -------------                                                                                 
        10 ACCOUNTING     NEW YORK                                                                                      
        20 RESEARCH       DALLAS                                                                                        
        30 SALES          CHICAGO                                                                                       
        40 OPERATIONS     BOSTON                                                                                        

SQL> spool off
```


## SQLPlus行转列

一直以来，觉得MySQL中使用\G参数改变输出结果集的显示方式非常好用，尤其是在命令行界面。但是ORACLE数据库没有这个功能，今天在搜索到Tom大师的一篇博文时，发现大师用一个存储过程print_table实现了类似这样的功能。只是我们这些凡夫俗子不知道而已，特意整理在此，方便自己或有需要的人以后查看。

```sql
CREATE OR REPLACE PROCEDURE print_table(p_query IN VARCHAR2)
AUTHID CURRENT_USER
IS
 l_thecursor INTEGER DEFAULT dbms_sql.open_cursor;
 l_columnvalue VARCHAR2(4000);
 l_status  INTEGER;
 l_desctbl  dbms_sql.desc_tab;
 l_colcnt  NUMBER;
BEGIN
 EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';

 dbms_sql.parse(l_thecursor, p_query, dbms_sql.native);

 dbms_sql.describe_columns (l_thecursor, l_colcnt, l_desctbl);

 FOR i IN 1 .. l_colcnt LOOP
  dbms_sql.define_column (l_thecursor, i, l_columnvalue, 4000);
 END LOOP;

 l_status := dbms_sql.EXECUTE(l_thecursor);

 WHILE ( dbms_sql.Fetch_rows(l_thecursor) > 0 ) LOOP
  FOR i IN 1 .. l_colcnt LOOP
   dbms_sql.column_value (l_thecursor, i, l_columnvalue);

   dbms_output.Put_line (RPAD(L_desctbl(i).col_name, 30)
         || ': '
         || l_columnvalue);
  END LOOP;

  dbms_output.put_line('-----------------');
 END LOOP;

 EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-MON-rr'' ';
EXCEPTION
 WHEN OTHERS THEN
    EXECUTE IMMEDIATE
    'alter session set nls_date_format=''dd-MON-rr'' ';

    RAISE;
END;
/
```

测试

```sql
SQL> execute print_table('select * from v$session where rownum < 2');
SADDR			      : 00000000DF62D4B8
SID			      : 1
SERIAL# 		      : 1
AUDSID			      : 0
PADDR			      : 00000000DF4C9A20
USER#			      : 0
USERNAME		      :
COMMAND 		      : 0
OWNERID 		      : 2147483644
TADDR			      :
LOCKWAIT		      :
STATUS			      : ACTIVE
SERVER			      : DEDICATED
SCHEMA# 		      : 0
SCHEMANAME		      : SYS
OSUSER			      : oracle
PROCESS 		      : 30539
MACHINE 		      : NB-flexgw1
PORT			      : 0
TERMINAL		      : UNKNOWN
PROGRAM 		      : oracle@NB-flexgw1 (GEN0)
TYPE			      : BACKGROUND
SQL_ADDRESS		      : 00
SQL_HASH_VALUE		      : 0
SQL_ID			      :
SQL_CHILD_NUMBER	      : 0
SQL_EXEC_START		      :
SQL_EXEC_ID		      :
PREV_SQL_ADDR		      : 00
PREV_HASH_VALUE 	      : 0
PREV_SQL_ID		      :
PREV_CHILD_NUMBER	      : 0
PREV_EXEC_START 	      :
PREV_EXEC_ID		      :
PLSQL_ENTRY_OBJECT_ID	      :
PLSQL_ENTRY_SUBPROGRAM_ID     :
PLSQL_OBJECT_ID 	      :
PLSQL_SUBPROGRAM_ID	      :
MODULE			      :
MODULE_HASH		      : 0
ACTION			      :
ACTION_HASH		      : 0
CLIENT_INFO		      :
FIXED_TABLE_SEQUENCE	      : 0
ROW_WAIT_OBJ#		      : -1
ROW_WAIT_FILE#		      : 0
ROW_WAIT_BLOCK# 	      : 0
ROW_WAIT_ROW#		      : 0
TOP_LEVEL_CALL# 	      : 0
LOGON_TIME		      : 18-dec-2019 19:02:50
LAST_CALL_ET		      : 89209
PDML_ENABLED		      : NO
FAILOVER_TYPE		      : NONE
FAILOVER_METHOD 	      : NONE
FAILED_OVER		      : NO
RESOURCE_CONSUMER_GROUP       :
PDML_STATUS		      : DISABLED
PDDL_STATUS		      : DISABLED
PQ_STATUS		      : DISABLED
CURRENT_QUEUE_DURATION	      : 0
CLIENT_IDENTIFIER	      :
BLOCKING_SESSION_STATUS       : NO HOLDER
BLOCKING_INSTANCE	      :
BLOCKING_SESSION	      :
FINAL_BLOCKING_SESSION_STATUS : NO HOLDER
FINAL_BLOCKING_INSTANCE       :
FINAL_BLOCKING_SESSION	      :
SEQ#			      : 29733
EVENT#			      : 7
EVENT			      : rdbms ipc message
P1TEXT			      : timeout
P1			      : 300
P1RAW			      : 000000000000012C
P2TEXT			      :
P2			      : 0
P2RAW			      : 00
P3TEXT			      :
P3			      : 0
P3RAW			      : 00
WAIT_CLASS_ID		      : 2723168908
WAIT_CLASS#		      : 6
WAIT_CLASS		      : Idle
WAIT_TIME		      : 0
SECONDS_IN_WAIT 	      : 1
STATE			      : WAITING
WAIT_TIME_MICRO 	      : 1383807
TIME_REMAINING_MICRO	      : 1616193
TIME_SINCE_LAST_WAIT_MICRO    : 0
SERVICE_NAME		      : SYS$BACKGROUND
SQL_TRACE		      : DISABLED
SQL_TRACE_WAITS 	      : FALSE
SQL_TRACE_BINDS 	      : FALSE
SQL_TRACE_PLAN_STATS	      : FIRST EXEC
SESSION_EDITION_ID	      : 0
CREATOR_ADDR		      : 00000000DF4C9A20
CREATOR_SERIAL# 	      : 1
ECID			      :
-----------------

PL/SQL procedure successfully completed.
```

SQLPLUS需要开启参数`serveroutput`，才能打印存储过程的结果。

```sql
SQL> set serveroutput on
SQL> exec print_table('select * from scott.t01 where rownum < 2')
EMPNO			      : 7369
ENAME			      : SMITH
JOB			      : CLERK
MGR			      : 7902
HIREDATE		      : 17-dec-1980 00:00:00
SAL			      : 800
COMM			      :
DEPTNO			      : 20
-----------------

PL/SQL procedure successfully completed.

```

