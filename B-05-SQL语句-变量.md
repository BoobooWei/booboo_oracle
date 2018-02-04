### 变量

[toc]

#### 变量的类型

|变量类型|设置|查看|调用|备注|
|:--|:--|:--|:--|:--|
|替代变量|define p=sal|define p|&p 或者 &&p|临时生效，可以出现在任何位置|
|SQLPlus环境变量|set echo on|show echo||当前会话生效|
|SQLPlus环境变量|配置文件|show echo||永久生效|


其中若没有事先define声明一个变量，那么引用的时候：
1. `&p` 代表一次性声明，从键盘输入变量的值，下次还需要再次输入，define命令不能看到p变量
2. `&&p` 代表当前会话中的声明，从键盘输入变量的值，下次就不需要再输入，define命令能看到p变量



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
|COL[UMN][column option]|控制列格式| 
|TTI[TLE] [text\|OFF\|ON]|指定每页报表顶部显示的标题|
|BTI[TLE] [text\|OFF\|ON]|指定每页报表底部显示的脚注|
|BRE[AK] [ON report_element]|限制重复的值和使用连接符将数据行分成几部分|


#### 应用实例

1. where 字句中包含替代变量 

```shell
# 查询emp表中部门编号为变量p的值的员工姓名
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

2. select 字句中包含替代变量

```shell
# 查看雇员姓名和变量c的值
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


3. from 字句中包含替代变量

```shell
# 查看变量p所代表的表中的前5行
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

4. 如果替代变量的类型为字符串，需要加单引号

```shell
# 查询emp表中雇员姓名为某个值的
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

5. 分页查询:每页5行


```shell
#按照工资高低排序，并分页显示，每夜5行
#1 1 5
#2 6 10
#3 11 15
#n n*5-4   n*5
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

6. 替代变量的声明，调用，查看，取消

```shell
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

# 声明一个替代变量
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

# 查看变量的值
SQL> select '&col' from dual;
old   1: select '&col' from dual
new   1: select 'sal' from dual

'SA
---
sal

# 取消变量
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

'X
--
xx

```


7. &&的作用

```shell
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


8. `verify`新老语句的对比开关

```shell
# show命令查看环境变量verify
SQL> show verify
verify ON

# 设置该环境变量为off状态
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



9. `echo`控制脚本执行时是否显示命令

```shell
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

10. 其他sqlplush环境变量

```shell
# 数据库取回数据的大小为15行
SQL> show arraysize
arraysize 15

# 最大值为5000
SQL> set arraysize 5000
SQL> set arraysize 5001
SP2-0267: arraysize option 5001 out of range (1 through 5000)

# 当查询选择了n行后,显示查询返回记录的数量
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

# 决定是否列标题显示在报表中

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

# 默认打印出80个字符
SQL> show long
long 80

## 打印emp表的元数据，发现不全
SQL> select dbms_metadata.get_ddl('TABLE','EMP') from dual;

DBMS_METADATA.GET_DDL('TABLE','EMP')
--------------------------------------------------------------------------------

  CREATE TABLE "SCOTT"."EMP"
   (	"EMPNO" NUMBER(4,0),
	"ENAME" VARCHAR2(10),

## 修改long的值
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

11. 报表格式

```shell
# 列名换行
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

# 给工资列加美元前缀
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

# 给sal和comm列设置美元前缀，列名居中显示

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

# 清空格式
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

# 在上一条sql的基础上进行排序，再次调用用/

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

# BREAK 命令将行分成部分并限制重复的值
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

# 清除break
SQL> clear break
breaks cleared

# 将结果集以报表的形式打印bti
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



12. spool脱机模式

* spool 1.txt 开始脱机
* spool off 结束脱机存盘
* spool 1.txt append 追加脱机
* spool off 结束脱机存盘



```shell
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










