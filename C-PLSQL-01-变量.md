# PLSQL-变量

> 2019.12.29 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:1 flatten:0 bullets:0 updateOnSave:1 -->

1. [PLSQL-变量](#plsql-变量)   
&emsp;1.1. [为什么要使用 pl/sql](#为什么要使用-plsql)   
&emsp;1.2. [块的结构和声明变量](#块的结构和声明变量)   
&emsp;1.3. [使用变量](#使用变量)   
&emsp;&emsp;1.3.1. [变量的优点](#变量的优点)   
&emsp;&emsp;1.3.2. [设置变量的语法](#设置变量的语法)   
&emsp;&emsp;1.3.3. [变量的命名规则](#变量的命名规则)   
&emsp;&emsp;1.3.4. [变量的作用范围](#变量的作用范围)   
&emsp;&emsp;1.3.5. [`%TYPE`属性](#%type属性)   
&emsp;1.4. [流程控制](#流程控制)   
&emsp;&emsp;1.4.1. [条件判断](#条件判断)   
&emsp;&emsp;&emsp;1.4.1.1. [`IF`条件判断](#if条件判断)   
&emsp;&emsp;&emsp;1.4.1.2. [`CASE`条件判断](#case条件判断)   
&emsp;&emsp;1.4.2. [循环](#循环)   
&emsp;&emsp;&emsp;1.4.2.1. [基本循环loop](#基本循环loop)   
&emsp;&emsp;&emsp;1.4.2.2. [While 循环](#while-循环)   
&emsp;&emsp;&emsp;1.4.2.3. [For循环](#for循环)   
&emsp;1.5. [实践](#实践)   
&emsp;&emsp;1.5.1. [实践1-书写一个最简单的块，运行并查看结果](#实践1-书写一个最简单的块，运行并查看结果)   
&emsp;&emsp;1.5.2. [实践2-在块中操作变量](#实践2-在块中操作变量)   
&emsp;&emsp;1.5.3. [实践3-在块中操作变量理解`%TYPE`属性](#实践3-在块中操作变量理解%type属性)   
&emsp;&emsp;1.5.4. [实践4-在块中操作表的数据](#实践4-在块中操作表的数据)   
&emsp;&emsp;1.5.5. [实践5-在块中的分支操作`IF`语句](#实践5-在块中的分支操作if语句)   
&emsp;&emsp;1.5.6. [实践6-在块中的分支操作`CASE`语句](#实践6-在块中的分支操作case语句)   

<!-- /MDTOC -->

## 为什么要使用 pl/sql

* 便于维护(模块化)
* 提高数据安全性和完整性(通过程序操作数据)
* 提高性能(编译好的)
* 简化代码(反复调用)

## 块的结构和声明变量

* 块：是 PL/SQL 的基石；程序都是通过块组成。
* 匿名块：没有名称的块叫匿名块，完成一定的功能。

|模块的组成|说明|是否必要|
|:--|:--|:--|
|`DECLARE`|变量声明部分|非|
|`Begin`|逻辑处理执行部分的开始|是|
|`Exception`|错误处理部分|非|
|`End`|逻辑处理结束|是|
| `/` |`Begin` 语句的提交|是|

```plsql
--是行注释
/* */是多行注释
declare
  --私有变量声明
begin
  --代码主体
exception
  --异常处理
end;
/
```

## 使用变量

### 变量的优点

* 用来存储数据
* 操作存储的数据
* 可以重复应用
* 使维护工作简单

### 设置变量的语法

```PLSQL
identifier [CONSTANT] datatype [NOT NULL] [:= | DEFAULT expr];
```

* `[ ]`内为可选项
* 每行定义一个变量
* 在 declare 部分声明
* 如果设置了`Not null` 一定要给初值
* `CONSTANT` 也一定要给值
* `:=` 为赋值，`=`为逻辑判断，判断是否相等。

### 变量的命名规则

* 在不同的模块中，变量可以重名
* 变量的名称不应该和模块中引用的列的名称相同
* 变量名称应该有一定的可读性


### 变量的作用范围

* 外部模块变量可以传到内部模块
* 内部模块的变量不会影响外部


### `%TYPE`属性

* 声明一个变量和某列数据类型相同
* 声明一个变量和另外一个变量数据类型一致

减小程序的无效的可能性，可以不知道列的数据类型，定义一个与之相同的变量。

```PLSQL
v_name emp.ename%TYPE;
v_balance NUMBER(7,2);
v_min_balance v_balance%TYPE := 10;
```

## 流程控制

### 条件判断

#### `IF`条件判断

分支就是树的结构，条件就是分支的选择，我们只能走到一个支干上，即使每个条件都符合，我们也只能 操作一个支干的语句。

* `IF`-`THEN`-`END IF`
* `IF`-`THEN`-`ELSE`-`END IF `
* `IF`-`THEN`-`ELSIF`-`END IF`

语法

```plsql
IF condition
THEN statements;
[ELSIF condition THEN statements;]
[ELSE
statements;]
END IF;
```

#### `CASE`条件判断

语法

```SQLPLUS
CASE v1
WHEN 'A' THEN 'Excellent'
WHEN 'B' THEN 'Very Good'
WHEN 'C' THEN 'Good'
ELSE 'No such grade'
END;
```

### 循环

#### 基本循环loop

```PLSQL
Declare
v1 number(2) :=1;
Begin
Loop
insert into t1 values (v1);
v1:=v1+1;
Exit When v1>10 ;
End loop;
End; /
```

建立实验表 t1，我们将想 t1 表中加入数据。

```PLSQL
drop table t1 purge;
create table t1 (c1 number(2));
select * from t1;
```
Loop 循环必须含有退出的条件，而且该条件一定要每次循环都要变化，如果没有变化就是死循环，死循环的结果就是 cpu 总是 100%，你可以重新启动数据库来消除死循环。




#### While 循环

#### For循环





## 实践

### 实践1-书写一个最简单的块，运行并查看结果

> 先设定 SQLPLUS 的环境变量，如果不指定默认值为不输出，设定后用 `show` 来验证。


```SQLPLUS
set serveroutput on
show serveroutput
```

该实验的目的是掌握简单的 pl/sql 语法，执行一个最简单的匿名块。

书写一个最简单的块，将字符串输出到屏幕。使用的是 `sqlplus` 输出 `Hello world`。

```sqlplus
begin
dbms_output.put_line('-----------------Begin------------------');
dbms_output.put_line('hello world');
dbms_output.put_line('-----------------End------------------');
end;
/
```

每句话以分号结束，最后加上 `/`。

### 实践2-在块中操作变量

该实验的目的是掌握在 pl/sql 块中操作变量。

说出一下变量定义的含义。

```PLSQL
DECLARE
v_hiredate DATE;
v_deptno NUMBER(2) NOT NULL := 10;
v_location VARCHAR2(13) := 'Atlanta';
c_comm CONSTANT NUMBER := 1400;
v_valid BOOLEAN NOT NULL := TRUE;
```

### 实践3-在块中操作变量理解`%TYPE`属性

该实验的目的是掌握参数定义时的`%TYPE`属性。

```PLSQL
DECLARE
v_sal NUMBER (9,2);
g_monthly_sal v_sal%TYPE := 10;
BEGIN
/* Compute the annual salary based on the
monthly salary input from the user */
v_sal := g_monthly_sal * 12;
dbms_output.put_line(v_sal);
END; -- This is the end of the block
/
```

### 实践4-在块中操作表的数据

该实验的目的是掌握在 pl/sql 块中操作数据库中的表，通过`select..into..`将表中的数据放入到变量。

1. 取表中的数据

* 一定要有 into
* 一次只能操作一行，
* 操作多行得用循环
* 变量类型和个数要匹配

```PLSQL
declare
v1 emp.ename%type;
v2 emp.sal%type;
begin
select ename,sal into v1,v2 from emp where empno=7900;
dbms_output.put_line(v1);
dbms_output.put_line(v2);
end;
/
```

2. 删除表中的数据并打印删除的行数

DML 语句和 SQL 相同，使用隐式游标的属性来控制 DML，有四种隐式的游标：
* `SQL%ROWCOUNT`
* `SQL%FOUND`
* `SQL%NOTFOUND`
* `SQL%ISOPEN`

```PLSQL
declare
v1 emp.deptno%type :=20;
v2 number;
begin
delete emp where deptno=v1;
v2:=sql%rowcount;
dbms_output.put_line('delete rows :');
dbms_output.put_line(v2);
rollback;
end;
/
```

执行结果

```SQLPLUS
SCOTT@testdb>select * from emp where deptno=20;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      CLERK	      7902 17-DEC-80	    800 		   20
      7566 JONES      MANAGER	      7839 02-APR-81	   2975 		   20
      7788 SCOTT      ANALYST	      7566 19-APR-87	   3000 		   20
      7876 ADAMS      CLERK	      7788 23-MAY-87	   1100 		   20
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000 		   20

declare
v1 emp.deptno%type :=20;
v2 number;
begin
  5  delete emp where deptno=v1;
v2:=sql%rowcount;
dbms_output.put_line('delete rows :');
dbms_output.put_line(v2);
rollback;
end;
 11  /
delete rows :
5

PL/SQL procedure successfully completed.
```

### 实践5-在块中的分支操作`IF`语句

该实验的目的是掌握在 pl/sql 块中使用 if 语句进行分支操作。

```PLSQL
DECLARE
v1 DATE := to_date('12-11-1990','mm-dd-yyyy');
v2 BOOLEAN;
BEGIN
IF MONTHS_BETWEEN(SYSDATE,v1) > 5 THEN
v2 := TRUE;
dbms_output.put_line('True');
ELSE
v2 := FALSE;
dbms_output.put_line('False');
END IF;
end;
/
```

结果

```PLSQL
True

PL/SQL procedure successfully completed.
```


### 实践6-在块中的分支操作`CASE`语句

该实验的目的是掌握在 pl/sql 块中使用 `CASE` 语句进行分支操作。

```PLSQL
DECLARE
v1 CHAR(1) := UPPER('&v1');
v2 VARCHAR2(20);
BEGIN
v2 :=CASE v1
WHEN 'A' THEN 'Excellent'
WHEN 'B' THEN 'Very Good'
WHEN 'C' THEN 'Good'
ELSE 'No such grade'
END;
DBMS_OUTPUT.PUT_LINE (v1 || ' is  ' || v2); END;
/
```

Null 的逻辑运算真值表
* True and null 结果为 null
* Flase and null 结果为 flase
