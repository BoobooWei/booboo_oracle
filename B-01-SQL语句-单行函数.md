# SQL语句

## 查询语句DQL

```shell
select *|{[distinct] column | expression [alias] , ...}
from table;
```

1. select 后面跟 通配符|关键字|表达式 别名 或者一些计算
2. from 后面跟 表名 或者 结果集 ，这就是oracle对国标扩展的部分，能够对结果集进行二次查询
3. 必须要有结束符号 ; 有结束符，sql才会被运行
4. 大小写不区分
5. 可以多行书写

### 简单的sql查询


|简单的sql查询|语句|
|:--|:--|
|查看scott用户下有哪些表和视图|SQL> select * from tab;|
|描述一张表的结构，不看表中的数据|SQL> desc dept|
|查看雇员表中的所有数据|select * from dept;|
|描述雇员表的结构|SQL> desc emp|
|查看emp表中感兴趣的列|SQL> select ename,sal from emp;|
|在select中使用四则运算:null不能参与四则运算|select ename,(sal+100)*12 from emp;|
|为列定义别名|select ename AS first_name,sal*12 "Annual Salary" from emp;|
|连接操作符|select ename,job,ename\|\|' is a '\|\|job detail from emp;|
|压缩重复行|select distinct deptno,job from emp;|
|将缓冲区中的命令保存为脚本|SQL> save p1_1.sql|
|查看sql脚本内容|SQL> get p1_1.sql|
|运行sql脚本|SQL> @p1_1.sql|

sqlplus结果集的显示风格为:

* 字符串和日期类型左对齐
* 数字类型右对齐
* 缺省显示为大写



```shell
SQL> SELECT * FROM TAB;

TNAME			       TABTYPE	CLUSTERID
------------------------------ ------- ----------
BONUS			       TABLE
DEPT			       TABLE
EMP			       TABLE
SALGRADE		       TABLE

SQL> desc dept;
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 DEPTNO 				   NOT NULL NUMBER(2)
 DNAME						    VARCHAR2(14)
 LOC						    VARCHAR2(13)

SQL> select * from dept;

    DEPTNO DNAME	  LOC
---------- -------------- -------------
	10 ACCOUNTING	  NEW YORK
	20 RESEARCH	  DALLAS
	30 SALES	  CHICAGO
	40 OPERATIONS	  BOSTON

SQL> select ename,sal from emp;

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

SQL> select ename,(sal+100)*12 from emp;

ENAME	   (SAL+100)*12
---------- ------------
SMITH		  10800
ALLEN		  20400
WARD		  16200
JONES		  36900
MARTIN		  16200
BLAKE		  35400
CLARK		  30600
SCOTT		  37200
KING		  61200
TURNER		  19200
ADAMS		  14400

ENAME	   (SAL+100)*12
---------- ------------
JAMES		  12600
FORD		  37200
MILLER		  16800

14 rows selected.

# (SAL+100)*12列在磁盘上并没有保存，我们称其为计算表达式所生成的伪列
# 空值不能参与运算
SQL> select ename,sal,comm,sal+comm from emp;

ENAME		  SAL	    COMM   SAL+COMM
---------- ---------- ---------- ----------
SMITH		  800
ALLEN		 1600	     300       1900
WARD		 1250	     500       1750
JONES		 2975
MARTIN		 1250	    1400       2650
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500	       0       1500
ADAMS		 1100

ENAME		  SAL	    COMM   SAL+COMM
---------- ---------- ---------- ----------
JAMES		  950
FORD		 3000
MILLER		 1300

14 rows selected.

# 将工资和奖金求和，结果发现奖金comm列为null的员工不用发工资了！这是错误的

SQL> select ename as first_name , sal*12 "Annual Salary" from emp;    

FIRST_NAME Annual Salary
---------- -------------
SMITH		    9600
ALLEN		   19200
WARD		   15000
JONES		   35700
MARTIN		   15000
BLAKE		   34200
CLARK		   29400
SCOTT		   36000
KING		   60000
TURNER		   18000
ADAMS		   13200

FIRST_NAME Annual Salary
---------- -------------
JAMES		   11400
FORD		   36000
MILLER		   15600

14 rows selected.

# as可以省略，如果别名加了引号，则显示指定的字符，而不会使用缺省的大写

SQL> select ename,job,ename||' is a '||job detail from emp;

ENAME	   JOB	     DETAIL
---------- --------- -------------------------
SMITH	   CLERK     SMITH is a CLERK
ALLEN	   SALESMAN  ALLEN is a SALESMAN
WARD	   SALESMAN  WARD is a SALESMAN
JONES	   MANAGER   JONES is a MANAGER
MARTIN	   SALESMAN  MARTIN is a SALESMAN
BLAKE	   MANAGER   BLAKE is a MANAGER
CLARK	   MANAGER   CLARK is a MANAGER
SCOTT	   ANALYST   SCOTT is a ANALYST
KING	   PRESIDENT KING is a PRESIDENT
TURNER	   SALESMAN  TURNER is a SALESMAN
ADAMS	   CLERK     ADAMS is a CLERK

ENAME	   JOB	     DETAIL
---------- --------- -------------------------
JAMES	   CLERK     JAMES is a CLERK
FORD	   ANALYST   FORD is a ANALYST
MILLER	   CLERK     MILLER is a CLERK

14 rows selected.

# ||是字符连接符 detail是别名

SQL> select distinct deptno,job from emp;

    DEPTNO JOB
---------- ---------
	20 CLERK
	30 SALESMAN
	20 MANAGER
	30 CLERK
	10 PRESIDENT
	30 MANAGER
	10 CLERK
	10 MANAGER
	20 ANALYST

9 rows selected.

# distinct 去除重复

SQL> save p1_1.sql
Created file p1_1.sql
SQL> get p1_1.sql
  1* select distinct deptno,job from emp
SQL> @p1_1.sql

    DEPTNO JOB
---------- ---------
	20 CLERK
	30 SALESMAN
	20 MANAGER
	30 CLERK
	10 PRESIDENT
	30 MANAGER
	10 CLERK
	10 MANAGER
	20 ANALYST

9 rows selected.

```

### 限制和排列数据

1. 工资高于1500的销售员？
2. 查询10部门的雇员和20部门工资小与2000的雇员？
3. 查询有奖金的雇员？
4. 使用rownum伪列限制查询返回的行的数量

```shell
SQL> select ename,sal from emp where sal>1500;

ENAME		  SAL
---------- ----------
ALLEN		 1600
JONES		 2975
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
FORD		 3000

7 rows selected.

SQL> select deptno,ename,sal from emp where (deptno=10 or deptno=20) and sal < 2000;

    DEPTNO ENAME	     SAL
---------- ---------- ----------
	20 SMITH	     800
	20 ADAMS	    1100
	10 MILLER	    1300

SQL> select deptno,ename,sal from emp where deptno in (10,20) and sal < 2000;

    DEPTNO ENAME	     SAL
---------- ---------- ----------
	20 SMITH	     800
	20 ADAMS	    1100
	10 MILLER	    1300

SQL> select ename,comm from emp where comm is not null;

ENAME		 COMM
---------- ----------
ALLEN		  300
WARD		  500
MARTIN		 1400
TURNER		    0

SQL> select ename from emp where rownum < 6;

ENAME
----------
SMITH
ALLEN
WARD
JONES
MARTIN

# mysql中限制行是用limit，而oracle用rownum
```


### 单行函数

>  五种：字符函数、数值函数、日期函数、转换函数、其他函数

#### 字符函数

|字符串函数|函数名|解释|
|:--|:--|:--|
|大小写转换|LOWER(column or expression)|小写|
||UPPER(column or expression)|把字母全部变成大写|
||INITCAP(column or expression)|首字母大写|
|字符处理|CONCAT(column1 or expression1,column2\|expression2)|连接字符|
||SUBSTR(column or expression,m[,n])|截取从索引位m的字符开始的数量为n个的字符，索引从1开始|
||LENGTH(column or expression)|返回字符串长度|
||INSTR(column or expression,‘string’, [,m], [n] )|返回字符串的位置。你可以随机地指定从第 m 个字母开始搜索第 n 个要查找的字符串。m 和 n 缺省为 1, 意思是从第一个字母开始查找第一次出现要查找的字符串的位置。|
||LPAD(column or expression, n,'string')|右对齐字符串,左面用指定字符填充至 n位;|
||RPAD(column or expression, n,'string')|左对齐字符串,右边用指定字符填充至 n位|
||TRIM(leading or trailing or both, trim_character FROM trim_source)|删除头尾字符，默认为空白，类似于python中strim|
||REPLACE(text,search_string,replacement_string)|查找并替换字符串|

#####  字符函数示例

1. 记录中的字符串是区分大小写，如果想从海量数据中搜索scott用户，该如何去做呢？

```shell
select * from emp where lower(ename)='scott';
```

究竟用lower还是upper，需要规范前端应用程序，如果小写就都小写，要大写就都大写，函数的选择影响索引的创建，代码的书写规则影响后面索引的创建。

2. instr和substr的区别
instr为指定一个字符获取该字符在目标字符串的位置
substr为截取制定索引位的字符串
将两者结合在一起用，比如打印字符串中第一个a和第二个a之间的字符串，包含第一个a



```shell
SQL> select instr('abca','a') from dual;

INSTR('ABCA','A')
-----------------
		1

SQL> select instr('abca','a',2) from dual;

INSTR('ABCA','A',2)
-------------------
		  4

SQL> select substr('abca',1,4-1) from dual;

SUB
---
abc

SQL> select instr('superman batman wonderwoman','batman') from dual;

INSTR('SUPERMANBATMANWONDERWOMAN','BATMAN')
-------------------------------------------
					 10
# 截取字符串'superman batman wonderwoman'中从batman开始到最后

SQL> select substr('superman batman wonderwoman',instr('superman batman wonderwoman','batman')) from dual;

SUBSTR('SUPERMANBA
------------------
batman wonderwoman

```

3. 填充，打印固定字符，实现左右对齐

```shell
SQL> select lpad('abc',6,'*') from dual;

LPAD('
------
***abc

SQL> select rpad('abc',6,'*') from dual;

RPAD('
------
abc***
```

4. 删除字符串`  ab  `前后空白

```shell
SQL> select trim('  abc  ') from dual;

TRI
---
abc

SQL> select '  abc  ' from dual;

'ABC'
-------
  abc
```

一般空格在左边容易发现，空格在右边不容易发现，默认取出的半角的，所以最好再来一次全角的空格。

例如，从emp中查找雇员名为scott的详细信息

```shell
SQL> insert into emp values (1111,'SCoTT ','ANALYST',7566,'19-APR-87',3000,20,NULL);

1 row created.

SQL> select * from emp where lower(ename)='scott';

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20

SQL> select * from emp where trim(lower(ename))='scott';

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      1111 SCoTT      ANALYST	      7566 19-APR-87	   3000 	20
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20

SQL> select * from emp where trim(' ' from trim(lower(ename)))='scott';

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      1111 SCoTT      ANALYST	      7566 19-APR-87	   3000 	20
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20

```

trim只能带一个字符


5. 替换字符串

```shell
SQL> select replace('superman batman wonderwoman','batman','booboo') from dual;

REPLACE('SUPERMANBATMANWOND
---------------------------
superman booboo wonderwoman

```

6. 显示姓氏的最后一个字母是n的那些雇员的相应资料:

```shell
SQL> select ename from emp where substr(lower(ename),instr(lower(ename),'n',-1)) = 'n' ;

ENAME
----------
ALLEN
MARTIN

SQL> select ename from emp where lower(ename) like '%n';

ENAME
----------
ALLEN
MARTIN

```
7. 执行以下sql并解释的含义

```shell
select concat('Hello','World') from dual;
select concat(ename,job) from emp;
select substr('Helloworld',1,2) from dual;
select substr('Helloworld',5) from dual;
select substr('Helloworld',-5,2) from dual;
select length('Helloworld') from dual;
select instr('Helloworld','l') from dual;
select instr('Helloworld','l',1,2) from dual;
select instr('Helloworld','l',-1,2) from dual;
select instr('Helloworld','l',-1) from dual;
select lpad('Hello',10,'*') from dual;
select rpad('Hello',10,'*') from dual;
select trim('H' from 'HelloHhHH') from dual;
select * from emp where trim(' ' from UPPER(ename))='SCOTT';
select replace('Helloworld','owo','xxoo') from dual;
```

#### 数值函数

- ROUND :将值舍入到指定的小数位
- TRUNC :将值截断到指定的小数位
- MOD :返回除法运算的余数

DUAL 是可用于查看函数和计算结果的公用表。

执行以下sql并解释的含义

```shell
select round(45.926,2) from dual;
select round(45.926,0) from dual;
select round(45.926) from dual;
select round(45.926,-1) from dual;

select trunc(45.926,2) from dual;
select trunc(45.926,0) from dual;
select trunc(45.926) from dual;
select trunc(45.926,-1) from dual;

select mod(15,4) from dual;
select power(3,3) from dual;
select ceil(1.00001) from dual;
select abs(-190) from dual;
```

#### 日期函数

日期是以数字保存的，可以进行加减运算

|函数| 结果|
|:--|:--|
|MONTHS_BETWEEN| 两个日期之间的月数|
|ADD_MONTHS| 将指定的月数添加到日期|
|NEXT_DAY |指定日期之后的下一个日期|
|LAST_DAY| 当月最后一天|
|ROUND |舍入日期|
|TRUNC| 截断日期|
|MONTHS_BETWEEN('01-SEP-95','11-JAN-94')| 19.6774194|
|ADD_MONTHS ('31-JAN-96',1) |'29-FEB-96'|
|NEXT_DAY ('01-SEP-95','FRIDAY') |'08-SEP-95'|
|LAST_DAY ('01-FEB-95') |'28-FEB-95'|


1. 计算每一个雇员工作的时间（天）

* sysdate返回当前时间
* hiredate雇员入职时间


```shell
SQL> select sysdate from dual;

SYSDATE
---------
29-JUN-17

SQL> select sysdate - hiredate from emp;

SYSDATE-HIREDATE
----------------
      11029.7991
      13343.7991
      13278.7991
      13276.7991
      13237.7991
      13058.7991
      13208.7991
      13169.7991
      11029.7991
      13008.7991
      13078.7991
      10995.7991
      12992.7991
      12992.7991
      12941.7991

15 rows selected.
```

这里计算的结果为天数


2. 计算每个雇员工作的时间，单位为月

* months_between() 计算两个时间点间的月数

```shell
SQL> select ename,months_between(sysdate,hiredate) from emp;

ENAME	   MONTHS_BETWEEN(SYSDATE,HIREDATE)
---------- --------------------------------
SCoTT				 362.348474
SMITH				  438.41299
ALLEN				 436.316216
WARD				   436.2517
JONES				 434.896861
MARTIN				 429.058152
BLAKE				 433.929119
CLARK				 432.671055
SCOTT				 362.348474
KING				  427.41299
TURNER				 429.703313
ADAMS				 361.219442
JAMES				 426.864603
FORD				 426.864603
MILLER				 425.219442

15 rows selected.

```

3. 假设员工使用期都是三个月，查看员工专正日期

* add_months() 在制定时间点上加多少个月份

```shell
SQL> select ename,hiredate,add_months(hiredate,3)  from emp;

ENAME	   HIREDATE  ADD_MONTH
---------- --------- ---------
SCoTT	   19-APR-87 19-JUL-87
SMITH	   17-DEC-80 17-MAR-81
ALLEN	   20-FEB-81 20-MAY-81
WARD	   22-FEB-81 22-MAY-81
JONES	   02-APR-81 02-JUL-81
MARTIN	   28-SEP-81 28-DEC-81
BLAKE	   01-MAY-81 01-AUG-81
CLARK	   09-JUN-81 09-SEP-81
SCOTT	   19-APR-87 19-JUL-87
KING	   17-NOV-81 17-FEB-82
TURNER	   08-SEP-81 08-DEC-81
ADAMS	   23-MAY-87 23-AUG-87
JAMES	   03-DEC-81 03-MAR-82
FORD	   03-DEC-81 03-MAR-82
MILLER	   23-JAN-82 23-APR-82

15 rows selected.
```

4. 这周六是哪一天？本月最后一天是那一天？

* next_day() 用周几的方式来表示将来的某一天
* last_day() 指定时间点所在月份的最后一天，返回自然月的最后一天

```shell
SQL> select sysdate from dual;

SYSDATE
---------
29-JUN-17

SQL> select next_day(sysdate,'sun') as SUN ,last_day(sysdate) Last from dual;

SUN	  LAST
--------- ---------
02-JUL-17 30-JUN-17

```

5. 生日所在那个月的最后一天

```shell
SQL> select last_day(to_date('1990-04-15','yyyy-mm-dd')) from dual;

LAST_DAY(
---------
30-APR-90

SQL> select last_day(to_date('1900-02-15','yyyy-mm-dd')) from dual;

LAST_DAY(
---------
28-FEB-00
```

每四年会多23小时48分钟xx秒，差了十几分钟，这样累计400年我们就丢了一天，这一天算到哪里去呢？

就在1900年就不算闰年，（能被100整除，还能被400整除）


还可以用来计算自然月的月底销售人员的销售额

期末量、期初量、同比、环比

6. 日期只显示年或者月

round() 四舍不入
trunc() 截断日期

```shell
SQL> select sysdate from dual;

SYSDATE
---------
29-JUN-17

SQL> select round(sysdate,'year') from dual;

ROUND(SYS
---------
01-JAN-17

SQL> select round(sysdate+30,'year') from dual;

ROUND(SYS
---------
01-JAN-18

SQL> select round(sysdate,'month') from dual;

ROUND(SYS
---------
01-JUL-17

SQL> select round(sysdate-15,'month') from dual;

ROUND(SYS
---------
01-JUN-17


SQL> select round(sysdate-15,'month') from dual;

ROUND(SYS
---------
01-JUN-17

SQL> select to_date('2017-07-16','yyyy-mm-dd') from dual;

TO_DATE('
---------
16-JUL-17

SQL> select round(to_date('2017-07-16','yyyy-mm-dd'),'year') from dual;

ROUND(TO_
---------
01-JAN-18

SQL> select trunc(to_date('2017-07-16','yyyy-mm-dd'),'year') from dual;

TRUNC(TO_
---------
16-JAN-17

SQL> select round(to_date('2017-07-16','yyyy-mm-dd'),'month') from dual;

ROUND(TO_
---------
01-AUG-17

SQL> select trunc(to_date('2017-07-16','yyyy-mm-dd'),'month') from dual;

TRUNC(TO_
---------
01-JUL-17

```

8. 执行以下sql并解释的含义


```shell
select sysdate from dual;
select sysdate,sysdate+1/1440 from dual;
select months_between(sysdate,hiredate),ename from emp;
select sysdate,add_months(sysdate,6) from dual;
select sysdate,next_day(sysdate,'wed') from dual;
select sysdate,last_day(to_date('01-feb-1900','dd-mon-yyyy')) from dual;
select round(sysdate,'month') from dual;
select round(sysdate,'year') from dual;
select trunc(sysdate,'month') from dual;
select trunc(sysdate,'year') from dual;
```





#### 转换函数

数据类型转化分为两种：
1. 隐式数据类型转换 系统自己能作的比较简单的，例如数字变字符串之类的
2. 显示数据类型转换 必须通过函数，你来制定规则

##### 隐式数据类型转换

Oracle服务器可以自动转换下面的数据类型

* number<--->varchar2|char<---->date

##### 显式数据类型转换


num----------------------------->char---------------------------->date

				to_char(num,'$9.00')		to_date(char,'YYYY-MM-DD')

num<-----------------------------char<-----------------------------date

`to_number(char,'L99.00')	to_char(date,'YYYY-MM-DD')`

1. date to_char

TO_CHAR(date, 'format_model')

日期格式样式的元素

|元素| 结果|
|:--|:--|
|YYYY| 用数字表示的完整年份|
|YEAR| 拼写出的年份(用英文表示)|
|MM| 月份的两位数值|
|MONTH| 月份的完整名称|
|MON| 月份的三个字母缩写|
|DY| 一周中某日的三个字母缩写|
|DAY| 一周中某日的完整名称|
|DD| 用数字表示的月份中某日|


```shell
SQL> select to_char(sysdate,'YYYY-MM-DD') from dual;

TO_CHAR(SY
----------
2017-07-03

SQL> select to_char(sysdate,'year-month-day') from dual;

TO_CHAR(SYSDATE,'YEAR-MONTH-DAY')
--------------------------------------------------------------
twenty seventeen-july	  -monday

SQL> select to_char(sysdate,'year-month-dy') from dual;

TO_CHAR(SYSDATE,'YEAR-MONTH-DY')
--------------------------------------------------------
twenty seventeen-july	  -mon

SQL> select to_char(sysdate,'dd-mon-rr') from dual;

TO_CHAR(S
---------
03-jul-17

SQL> select to_char(hiredate,'yyyy-mm-dd') from emp;

TO_CHAR(HI
----------
1987-04-19
1980-12-17
1981-02-20
1981-02-22
1981-04-02
1981-09-28
1981-05-01
1981-06-09
1987-04-19
1981-11-17
1981-09-08
1987-05-23
1981-12-03
1981-12-03
1982-01-23

15 rows selected.

SQL> select to_char(hiredate,'dd-mm-yy') from emp;

TO_CHAR(
--------
19-04-87
17-12-80
20-02-81
22-02-81
02-04-81
28-09-81
01-05-81
09-06-81
19-04-87
17-11-81
08-09-81
23-05-87
03-12-81
03-12-81
23-01-82

15 rows selected.

SQL> select hiredate from emp;

HIREDATE
---------
19-APR-87
17-DEC-80
20-FEB-81
22-FEB-81
02-APR-81
28-SEP-81
01-MAY-81
09-JUN-81
19-APR-87
17-NOV-81
08-SEP-81
23-MAY-87
03-DEC-81
03-DEC-81
23-JAN-82

15 rows selected.
```

日期的后台保存是，前置0+世纪+年+月+日

2. number to_char


TO_CHAR(number, 'format_model')

下面列出了一些格式元素,可以将其与 TO_CHAR 函数配合使用,以便将数字值显示为字符:

|元素|结果|
|:--|:--|
|9 |代表一个数字|
|0| 强制显示零|
|$| 放置一个浮动的美元符号|
|L| 使用浮动的本地货币符号|
|.| 显示小数点|
|,| 显示作为千位指示符的逗号|


``` shell

# 将数字以指定格式打印出来

SQL> select ename,to_char(sal,'L99,999.99') as sal from emp;

ENAME	   SAL
---------- --------------------
SCoTT		      $3,000.00
SMITH			$800.00
ALLEN		      $1,600.00
WARD		      $1,250.00
JONES		      $2,975.00
MARTIN		      $1,250.00
BLAKE		      $2,850.00
CLARK		      $2,450.00
SCOTT		      $3,000.00
KING		      $5,000.00
TURNER		      $1,500.00
ADAMS		      $1,100.00
JAMES			$950.00
FORD		      $3,000.00
MILLER		      $1,300.00

15 rows selected.

# 00和99的区别在整数会前置0补满指定位数

SQL> select ename,to_char(sal,'L00,000.00') as sal from emp;

ENAME	   SAL
---------- --------------------
SCoTT		     $03,000.00
SMITH		     $00,800.00
ALLEN		     $01,600.00
WARD		     $01,250.00
JONES		     $02,975.00
MARTIN		     $01,250.00
BLAKE		     $02,850.00
CLARK		     $02,450.00
SCOTT		     $03,000.00
KING		     $05,000.00
TURNER		     $01,500.00
ADAMS		     $01,100.00
JAMES		     $00,950.00
FORD		     $03,000.00
MILLER		     $01,300.00

15 rows selected.



```

3. char to_number

TO_NUMBER(char[, 'format_model'])

```shell
SQL> select to_number(' $00,800.00','L99999.00') from dual;

TO_NUMBER('$00,800.00','L99999.00')
-----------------------------------
				800

SQL> select to_number(' $00,800.00','$99999.00') from dual;

TO_NUMBER('$00,800.00','$99999.00')
-----------------------------------
				800

SQL> select to_number(' $00,800.00','$9999.00') from dual;
select to_number(' $00,800.00','$9999.00') from dual
                 *
ERROR at line 1:
ORA-01722: invalid number
```

必须指定相同位数，否则会报错。

4. char to_date

TO_DATE(char[, 'format_model'])


```shell
SQL> select to_date('1997-10-1','yyyy-mm-dd') from dual;

TO_DATE('
---------
01-OCT-97

SQL> select to_char(to_date('1997-10-1','yyyy-mm-dd'),'yyyy-mm-dd') from dual;

TO_CHAR(TO
----------
1997-10-01
```

##### RR和YY年份

yy年份表示法，当前系统时间所在的世纪

> 场景重现

1997年10月1日 记录在数据库中用dd-mon-yy表示为 01-OCT-97

1. 1998年，用户读取该数据，读 yyyy-mm-dd 为 1997-10-01
2. 2008年，用户读取该数据，读 yyyy-mm-dd 为 2007-10-01

此时就出错了，因为数据库内部使用yy的方式记录年，读取世纪时是根据当前世纪来取的，于是无法跨越千年。


rr年份表示法，以50年为分界，已经取代了yy方式

|当前日期|日期范围|记录时间|日期范围|显示世纪|
|:--|:--|:--|:--|:--|
|now |0-49 |date |0-49 |本世纪|
|now |50-99|date|50-99|本世纪|
|now|0-49|date|50-99|上个世纪|
|now|50-99|date|0-49|下个世纪|


```shell
SQL> select
  2  to_char(sysdate,'yyyy') curr_year,
  3  to_char(to_date('07','yy'),'yyyy') yy07,
  4  to_char(to_date('97','yy'),'yyyy') yy97,
  5  to_char(to_date('07','rr'),'yyyy') rr07,
  6  to_char(to_date('97','rr'),'yyyy') rr97
  7  from dual;

CURR YY07 YY97 RR07 RR97
---- ---- ---- ---- ----
2017 2007 2097 2007 1997

# 将字符串97转换为日期时，一定注意rr和yy，建议不要用两位表示年份。

SQL> select to_char(to_date('97-2-1','rr-mm-dd'),'yyyy-mm-dd') from dual;

TO_CHAR(TO
----------
1997-02-01

SQL> select to_char(to_date('97-2-1','yy-mm-dd'),'yyyy-mm-dd') from dual;

TO_CHAR(TO
----------
2097-02-01
```


练习以下sql：

```shell
select sysdate,to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') from dual;
select ename,sal,to_char(sal,'L999,999.99') from emp;
select to_number('$800.00','L999.99') from dual;
select to_date('2016-09-15','yyyy-mm-dd') from dual;
select
to_char(sysdate,'yyyy') curr_year,
to_char(to_date('05','yy'),'yyyy') yy05,
to_char(to_date('99','yy'),'yyyy') yy99,
to_char(to_date('05','rr'),'yyyy') rr05,
to_char(to_date('99','rr'),'yyyy') rr99
from dual;
```

#### 嵌套函数

* 单行函数可以嵌套到任意层。
* 嵌套函数的计算顺序是从最内层到最外层。

```shell
# 打印出大写的雇员名字从第一位开始的8个字符，并加上'_china'
SQL> select ename,upper(concat(substr(ename,1,8),'_china')) from emp;

ENAME	   UPPER(CONCAT(S
---------- --------------
SCoTT	   SCOTT _CHINA
SMITH	   SMITH_CHINA
ALLEN	   ALLEN_CHINA
WARD	   WARD_CHINA
JONES	   JONES_CHINA
MARTIN	   MARTIN_CHINA
BLAKE	   BLAKE_CHINA
CLARK	   CLARK_CHINA
SCOTT	   SCOTT_CHINA
KING	   KING_CHINA
TURNER	   TURNER_CHINA
ADAMS	   ADAMS_CHINA
JAMES	   JAMES_CHINA
FORD	   FORD_CHINA
MILLER	   MILLER_CHINA

15 rows selected.

# 打印大写雇员的姓名，去除头尾空白并加上'_china'

SQL> select ename,upper(concat(trim(' ' from ename),'_china')) from emp;

ENAME	   UPPER(CONCAT(TRI
---------- ----------------
SCoTT	   SCOTT_CHINA
SMITH	   SMITH_CHINA
ALLEN	   ALLEN_CHINA
WARD	   WARD_CHINA
JONES	   JONES_CHINA
MARTIN	   MARTIN_CHINA
BLAKE	   BLAKE_CHINA
CLARK	   CLARK_CHINA
SCOTT	   SCOTT_CHINA
KING	   KING_CHINA
TURNER	   TURNER_CHINA
ADAMS	   ADAMS_CHINA
JAMES	   JAMES_CHINA
FORD	   FORD_CHINA
MILLER	   MILLER_CHINA

15 rows selected.
SQL> select to_char(round((sal/7),2),'9G99D99') from emp;

TO_CHAR(
--------
 4,28.57
 1,14.29
 2,28.57
 1,78.57
 4,25.00
 1,78.57
 4,07.14
 3,50.00
 4,28.57
 7,14.29
 2,14.29
 1,57.14
 1,35.71
 4,28.57
 1,85.71

15 rows selected.

SQL> select to_char(round((sal/7),2),'999D99') from emp;

TO_CHAR
-------
 428.57
 114.29
 228.57
 178.57
 425.00
 178.57
 407.14
 350.00
 428.57
 714.29
 214.29
 157.14
 135.71
 428.57
 185.71

15 rows selected.
```

#### 常规函数

> 主要是用来修改空值的；可用于任何数据类型

|函数名|解释|
|:--|:--|
|NVL (expr1, expr2)|1空为2，1不空则1|
|NVL2 (expr1, expr2, expr3)|1空为3，1不空为2|
|NULLIF (expr1, expr2)|1和2相等则输出null，否则输出1|
|COALESCE (expr1, expr2, ..., exprn)|返回枚举中的第一个非空表达式|

```shell
# 计算员工工资和奖金的和

SQL> select ename,sal,comm,sal+comm from emp;

ENAME		  SAL	    COMM   SAL+COMM
---------- ---------- ---------- ----------
SCoTT		 3000	      20       3020
SMITH		  800
ALLEN		 1600	     300       1900
WARD		 1250	     500       1750
JONES		 2975
MARTIN		 1250	    1400       2650
BLAKE		 2850
CLARK		 2450
SCOTT		 3000
KING		 5000
TURNER		 1500	       0       1500
ADAMS		 1100
JAMES		  950
FORD		 3000
MILLER		 1300

15 rows selected.

SQL> select ename,sal,comm,sal+nvl(comm,0) from emp;

ENAME		  SAL	    COMM SAL+NVL(COMM,0)
---------- ---------- ---------- ---------------
SCoTT		 3000	      20	    3020
SMITH		  800			     800
ALLEN		 1600	     300	    1900
WARD		 1250	     500	    1750
JONES		 2975			    2975
MARTIN		 1250	    1400	    2650
BLAKE		 2850			    2850
CLARK		 2450			    2450
SCOTT		 3000			    3000
KING		 5000			    5000
TURNER		 1500	       0	    1500
ADAMS		 1100			    1100
JAMES		  950			     950
FORD		 3000			    3000
MILLER		 1300			    1300

15 rows selected.

SQL> select nvl2(null,1,2) from dual;

NVL2(NULL,1,2)
--------------
	     2

SQL> select nvl2('a',1,2) from dual;

NVL2('A',1,2)
-------------
	    1

SQL> select nullif(1,1) from dual;

NULLIF(1,1)
-----------


SQL> select nullif(1,2) from dual;

NULLIF(1,2)
-----------
	  1

SQL> select nullif(3,2) from dual;

NULLIF(3,2)
-----------
	  3

# 有奖金返回奖金，没有奖金返回工资
SQL> select coalesce(comm,sal)from emp;

COALESCE(COMM,SAL)
------------------
		20
	       800
	       300
	       500
	      2975
	      1400
	      2850
	      2450
	      3000
	      5000
		 0
	      1100
	       950
	      3000
	      1300

15 rows selected.

```



#### 条件表达式

可以在 SQL 语句中使用 IF-THEN-ELSE 逻辑。

|条件判断|语法|
|:--|:--|
|CASE表达式|case exp when 1 then e1 when 2 then e2 end  |
|DECODE函数|decode(exp,1,e1,2,e2,defaulte3)|


```shell
# 职员工资上涨百分之10，销售工资上涨百分之15，其他人不变

SQL> select ename,job,sal,
  2  case job when 'CLERK' then sal*1.1
  3  when 'SALESMAN' then sal*1.15
  4  else sal end rev_sal
  5  from emp;

ENAME	   JOB		    SAL    REV_SAL
---------- --------- ---------- ----------
SCoTT	   ANALYST	   3000       3000
SMITH	   CLERK	    800        880
ALLEN	   SALESMAN	   1600       1840
WARD	   SALESMAN	   1250     1437.5
JONES	   MANAGER	   2975       2975
MARTIN	   SALESMAN	   1250     1437.5
BLAKE	   MANAGER	   2850       2850
CLARK	   MANAGER	   2450       2450
SCOTT	   ANALYST	   3000       3000
KING	   PRESIDENT	   5000       5000
TURNER	   SALESMAN	   1500       1725
ADAMS	   CLERK	   1100       1210
JAMES	   CLERK	    950       1045
FORD	   ANALYST	   3000       3000
MILLER	   CLERK	   1300       1430

15 rows selected.

SQL> select ename,job,sal,decode(sal,'CLERK',sal*1.1,'SALESMAN',sal*1.1,sal) rev_sal from emp;

ENAME	   JOB		    SAL    REV_SAL
---------- --------- ---------- ----------
SCoTT	   ANALYST	   3000       3000
SMITH	   CLERK	    800        800
ALLEN	   SALESMAN	   1600       1600
WARD	   SALESMAN	   1250       1250
JONES	   MANAGER	   2975       2975
MARTIN	   SALESMAN	   1250       1250
BLAKE	   MANAGER	   2850       2850
CLARK	   MANAGER	   2450       2450
SCOTT	   ANALYST	   3000       3000
KING	   PRESIDENT	   5000       5000
TURNER	   SALESMAN	   1500       1500
ADAMS	   CLERK	   1100       1100
JAMES	   CLERK	    950        950
FORD	   ANALYST	   3000       3000
MILLER	   CLERK	   1300       1300

15 rows selected.

# 工资低于1000并且job为雇员的员工薪资涨百分之15，其他人不涨
# 非标准的case when，不能转化为decode()
# 任何条件满足则break

SQL> select ename,job,sal,case when sal>1000 then sal when job='CLERK' then sal*1.15  else sal end as rev_sal from emp;

ENAME	   JOB		    SAL    REV_SAL
---------- --------- ---------- ----------
SCoTT	   ANALYST	   3000       3000
SMITH	   CLERK	    800        920
ALLEN	   SALESMAN	   1600       1600
WARD	   SALESMAN	   1250       1250
JONES	   MANAGER	   2975       2975
MARTIN	   SALESMAN	   1250       1250
BLAKE	   MANAGER	   2850       2850
CLARK	   MANAGER	   2450       2450
SCOTT	   ANALYST	   3000       3000
KING	   PRESIDENT	   5000       5000
TURNER	   SALESMAN	   1500       1500
ADAMS	   CLERK	   1100       1100
JAMES	   CLERK	    950     1092.5
FORD	   ANALYST	   3000       3000
MILLER	   CLERK	   1300       1300

15 rows selected.

```


练习以下语句


```shell
select ename,sal,comm,sal+nvl(comm,0) from emp;
select ename,sal,comm,nvl2(comm,sal+comm,sal) from emp;
select ename,sal,comm,coalesce(comm,sal,0) from emp;

select ename,
       job,
       sal,
case job when 'CLERK' then sal*1.1
         when 'ANALYST' then sal*1.20
else sal end raise_sal
from emp
order by job;

select ename,
       job,
       sal,
decode(job,
      'CLERK',sal*1.1,
      'ANALYST',sal*1.2,
      sal) raise_sal
from emp order by job;
```


## 与mysql的区别

|sql|mysql|oracle|
|:--|:--|:--|
|查看用户的表|use dbname;show tables;|conn user/password;select * from tab;|
|限制行数|select * from emp limit 5;|select * from emp where rownum < 6;|

## 大小写区分

### MySQL数据库名、表名、列名、别名大小写规则

`lower_case_table_names = 0 `
其中

* 0：区分大小写
* 1：不区分大小写

MySQL在Linux下数据库名、表名、列名、别名大小写规则是这样的：
* 数据库名与表名是严格区分大小写的；
* 表的别名是严格区分大小写的；
* 列名与列的别名在所有的情况下均是忽略大小写的；
* 变量名也是严格区分大小写的；

```shell
root@SH_MySQL-01 17:02:  [(none)]> select @@lower_case_table_names;
+--------------------------+
| @@lower_case_table_names |
+--------------------------+
|                        0 |
+--------------------------+
1 row in set (0.00 sec)

root@SH_MySQL-01 17:03:  [(none)]> use test;
Database changed
root@SH_MySQL-01 17:03:  [test]> select * from T1;
ERROR 1146 (42S02): Table 'test.T1' doesn't exist
root@SH_MySQL-01 17:03:  [test]> select * from t1;
+----+------+
| id | num  |
+----+------+
|  1 |  100 |
|  2 |  200 |
+----+------+
2 rows in set (0.00 sec)
```

### MySQL字符串大小写

校对规则以其相关的字符集名开始，通常包括一个语言名，并且以_ci（大小写不敏感）、_cs（大小写敏感）或_bin（二元）结束 。

比如 utf8字符集，

* utf8_general_ci,表示不区分大小写，这个是utf8字符集默认的校对规则；
* utf8_general_cs表示区分大小写；
* utf8_bin表示二进制比较，同样也区分大小写。