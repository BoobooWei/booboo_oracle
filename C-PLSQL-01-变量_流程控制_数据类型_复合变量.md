# PLSQL-变量_流程控制_数据类型_复合变量

> 2019.12.29 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [PLSQL-变量](#plsql-变量)   
   - [为什么要使用 pl/sql](#为什么要使用-plsql)   
   - [块的结构和声明变量](#块的结构和声明变量)   
   - [使用变量](#使用变量)   
      - [变量的优点](#变量的优点)   
      - [设置变量的语法](#设置变量的语法)   
      - [变量的命名规则](#变量的命名规则)   
      - [变量的作用范围](#变量的作用范围)   
      - [`%TYPE`属性](#%type属性)   
   - [流程控制](#流程控制)   
      - [条件判断](#条件判断)   
         - [`IF`条件判断](#if条件判断)   
         - [`CASE`条件判断](#case条件判断)   
      - [循环](#循环)   
         - [Loop循环](#loop循环)   
         - [While 循环](#while-循环)   
         - [For循环](#for循环)   
   - [数据类型](#数据类型)   
      - [scalar data types标量数据类型](#scalar-data-types标量数据类型)   
         - [SQL数据类型](#sql数据类型)   
         - [`BOOLEAN`](#boolean)   
         - [`BINARY_INTEGER` 和`BINARY_INTEGER`](#binary_integer-和binary_integer)   
         - [`REF CURSOR`](#ref-cursor)   
         - [Declaring and Defining Explicit Cursors](#declaring-and-defining-explicit-cursors)   
         - [`User-defined subtypes`](#user-defined-subtypes)   
      - [composite data types组合数据类型](#composite-data-types组合数据类型)   
   - [复合变量](#复合变量)   
      - [PL/SQL RECORDs](#plsql-records)   
         - [记录变量始终代表完整行](#记录变量始终代表完整行)   
         - [记录可以代表部分行的变量](#记录可以代表部分行的变量)   
         - [％ROWTYPE属性和虚拟列](#％rowtype属性和虚拟列)   
      - [PL/SQL Collections](#plsql-collections)   
   - [实践](#实践)   
      - [实践1-书写一个最简单的块，运行并查看结果](#实践1-书写一个最简单的块，运行并查看结果)   
      - [实践2-在块中操作变量](#实践2-在块中操作变量)   
      - [实践3-在块中操作变量理解`%TYPE`属性](#实践3-在块中操作变量理解%type属性)   
      - [实践4-在块中操作表的数据](#实践4-在块中操作表的数据)   
      - [实践5-在块中的分支操作`IF`语句](#实践5-在块中的分支操作if语句)   
      - [实践6-在块中的分支操作`CASE`语句](#实践6-在块中的分支操作case语句)   
      - [实践7-在块中使用三种循环`for.while.loop`](#实践7-在块中使用三种循环forwhileloop)   
      - [实践8-在块中自定义RECORD类型定义和变量声明](#实践8-在块中自定义record类型定义和变量声明)   
      - [实践9-在块中自定义RECORD字段的RECORD类型（嵌套记录Nested Record）](#实践9-在块中自定义record字段的record类型（嵌套记录nested-record）)   
      - [实践10-在块中自定义RECORD字段的RECORD类型（％ROWTYPE属性）](#实践10-在块中自定义record字段的record类型（％rowtype属性）)   
      - [实践11-在块中自定义COLLECTIONS的类型](#实践11-在块中自定义collections的类型)   
      - [实践12-使用集合的属性来操作集合的数据](#实践12-使用集合的属性来操作集合的数据)   
      - [实践13-成员为复合变量，每个主键访问一行数据](#实践13-成员为复合变量，每个主键访问一行数据)   
      - [实践14-在块中使用自定义游标](#实践14-在块中使用自定义游标)   
      - [实践15--在块中使用自定义游标和游标的属性](#实践15-在块中使用自定义游标和游标的属性)   
      - [实践16-在块中使用自定义游标和循环控制](#实践16-在块中使用自定义游标和循环控制)   
      - [实践18-在块中使用自定义游标之带变量的游标](#实践18-在块中使用自定义游标之带变量的游标)   
   - [课后练习](#课后练习)   

<!-- /MDTOC -->

## 为什么要使用 pl/sql

[Database PL/SQL Language Reference](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/toc.htm)

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

#### Loop循环

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

While 循环，先判定条件，每次循环时条件都要变化，如果不变化就是死循环。

```plsql
Declare
V1 number(2) :=1;
Begin
While v1<10 Loop
Insert into t1 values(v1);
v1:=v1+1;
End loop;
End;
/
```

#### For循环

For循环，pl/sql中的最常见的循环，是和游标操作的绝配。方便而直观。

```plsql
begin
for v1 in 1..9 loop
Insert into t1 values(v1);
end loop;
end;
/

begin
for v1 in REVERSE 1..9 loop
Insert into t1 values(v1);
end loop;
end;
/
```

For 循环特点

* 步长为 1
* 计数器不要声明，自动声明
*  对计数器只能引用。不能做赋值操作
*  计数器的数据类型和上下界的数据类型相同
*  计数器只能在循环体内引用

## 数据类型

每个PL / SQL常量，变量，参数和函数返回值都有一个 确定其存储格式以及其有效值和操作的**数据类型**。

* **scalar data types** 标量数据类型
* **composite data types** 组合数据类型

### scalar data types标量数据类型

PL / SQL在包中预定义了许多类型和子类型，`STANDARD`并允许您定义自己的子类型。

| PL / SQL标量数据类型    | 说明                                                         |
| ----------------------- | ------------------------------------------------------------ |
| SQL数据类型             | [SQL Data Types](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#LNPLS311) |
| `BOOLEAN`               | 布尔值                                                       |
| `PLS_INTEGER`           | 该`PLS_INTEGER`数据类型存储范围为-2147483648到2,147,483,647符号整数，在32位表示。<br>`PLS_INTEGER`数据类型 与 `NUMBER`数据类型及`NUMBER` 子类型对比的优点：<br>1) PLS_INTEGER 值需要较少的存储空间。<br>2) PLS_INTEGER操作使用硬件算术，因此它们比NUMBER使用库算法的操作快。<br>为了提高效率，请PLS_INTEGER在其范围内的所有计算中使用值。 |
| `BINARY_INTEGER`        | PL / SQL数据类型 `PLS_INTEGER`并且`BINARY_INTEGER`是相同的   |
| `REF` `CURSOR`          | 游标变量["Cursor Variables"](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/static.htm#i7106) |
| `User-defined subtypes` | 子类型可以：<br>- 提供与ANSI / ISO数据类型的兼容性<br>- 显示该类型数据项的预期用途<br>- 检测超出范围的值 |

#### SQL数据类型

| Data Type                                                    | Maximum Size in PL/SQL | Maximum Size in SQL                |
| :----------------------------------------------------------- | :--------------------- | :--------------------------------- |
| `CHAR`[Foot 1 ](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDIEDJI) | 32,767 bytes           | 2,000 bytes                        |
| `NCHAR`[Footref 1](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#sthref236) | 32,767 bytes           | 2,000 bytes                        |
| `RAW`[Footref 1](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#sthref237) | 32,767 bytes           | 2,000 bytes                        |
| `VARCHAR2`[Footref 1](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#sthref238) | 32,767 bytes           | 4,000 bytes                        |
| `NVARCHAR2`[Footref 1](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#sthref239) | 32,767 bytes           | 4,000 bytes                        |
| `LONG`[Foot 2 ](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDECHII) | 32,760 bytes           | 2 gigabytes (GB) - 1               |
| `LONG` `RAW`[Footref 2](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#sthref240) | 32,760 bytes           | 2 GB                               |
| `BLOB`                                                       | 128 terabytes (TB)     | (4 GB - 1) * `database_block_size` |
| `CLOB`                                                       | 128 TB                 | (4 GB - 1) * `database_block_size` |
| `NCLOB`                                                      | 128 TB                 | (4 GB - 1) * `database_block_size` |

#### `BOOLEAN`

TRUE or FALSE

#### `BINARY_INTEGER` 和`BINARY_INTEGER`

PL / SQL数据类型 `PLS_INTEGER`并且`BINARY_INTEGER`是相同的。为简单起见，本文档使用`PLS_INTEGER`表示`PLS_INTEGER`和`BINARY_INTEGER`。

该`PLS_INTEGER`数据类型存储范围为-2147483648到2,147,483,647符号整数，在32位表示。

该`PLS_INTEGER`数据类型有这些优点在`NUMBER`数据类型及`NUMBER`亚型：

- `PLS_INTEGER` 值需要较少的存储空间。
- `PLS_INTEGER`操作使用硬件算术，因此它们比`NUMBER`使用库算法的操作快。

为了提高效率，请`PLS_INTEGER`在其范围内的所有计算中使用值。

话题

- [防止PLS_INTEGER溢出](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDHGIGI)
- [预定义的PLS_INTEGER子类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDIBECH)
- [PLS_INTEGER的SIMPLE_INTEGER子类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CIHGBFGB)

#### `REF CURSOR`

游标变量[Cursor Variables](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/static.htm#i7106)

#### Declaring and Defining Explicit Cursors

You can either declare an explicit cursor first and then define it later in the same block, subprogram, or package, or declare and define it at the same time.

An explicit cursor declaration, which only declares a cursor, has this syntax:

```
CURSOR cursor_name [ parameter_list ] RETURN return_type;
```

An explicit cursor definition has this syntax:

```
CURSOR cursor_name [ parameter_list ] [ RETURN return_type ]
  IS select_statement;
```

If you declared the cursor earlier, then the explicit cursor definition defines it; otherwise, it both declares and defines it.

```plsql
DECLARE
  CURSOR c1 RETURN departments%ROWTYPE;    -- Declare c1

  CURSOR c2 IS                             -- Declare and define c2
    SELECT employee_id, job_id, salary FROM employees
    WHERE salary > 2000;

  CURSOR c1 RETURN departments%ROWTYPE IS  -- Define c1,
    SELECT * FROM departments              -- repeating return type
    WHERE department_id = 110;

  CURSOR c3 RETURN locations%ROWTYPE;      -- Declare c3

  CURSOR c3 IS                             -- Define c3,
    SELECT * FROM locations                -- omitting return type
    WHERE country_id = 'JP';
BEGIN
  NULL;
END;
/
```

#### `User-defined subtypes`

子类型可以：

- 提供与ANSI / ISO数据类型的兼容性
- 显示该类型数据项的预期用途
- 检测超出范围的值

话题

- [无约束子类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDEDEIG)
- [约束子类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDBBCIE)
- [相同数据类型族中具有基本类型的子类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/datatypes.htm#CHDEEDIH)

### composite data types组合数据类型

一种 **复合数据类型** 存储具有内部组件的值。您可以将整个复合变量作为参数传递给子程序，并且可以访问以下组件的内部组件：分别组合变量。内部组件可以是标量或复合的。您可以在任何可以使用标量变量的地方使用标量组件。PL / SQL使您可以定义两种复合数据类型，即收集和记录。您可以在可以使用相同类型的复合变量的任何地方使用复合组件。

注意：

如果您将复合变量作为参数传递给 远程子程序，则必须创建一个冗余的loop-back `DATABASE` `LINK`，以便在编译远程子程序时，验证源的类型检查器使用与调用方相同的用户定义复合变量类型定义。有关该`CREATE` `DATABASE` `LINK`语句的信息，请参见《[*Oracle数据库SQL语言参考》*](https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_5005.htm#SQLRF01205)。

* 在一个 **collection** ，内部组件始终具有相同的数据类型，并且被称为**元素**。您可以通过其唯一性来访问集合变量的每个元素索引，使用以下语法：`variable_name``(``index``)`。要创建集合变量，您可以定义一个集合类型，然后创建该类型的变量或使用`%TYPE`。

* 在一个 **record** ，内部组件可以具有不同的数据类型，并且被称为`Field`。您可以使用以下语法按其名称访问记录变量的每个字段：`variable_name.field_name`。要创建记录变量，您可以定义一个`RECORD`类型，然后创建该类型的变量，或者使用`%ROWTYPE`或`%TYPE`。

您可以创建记录的集合以及包含集合的记录。

收藏主题

- [集合类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CHDBHJEI)
- [关联数组](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CHDEIDIC)
- [Varrays（可变大小数组）](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CHDEIJHD)
- [嵌套表](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CHDHIGFH)
- [集合构造器](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#i20453)
- [将值分配给集合变量](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#i20985)
- [多维集合](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#i33997)
- [集合比较](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#i36377)
- [收集方法](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#i27396)
- [包装规格中定义的收集类型](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CJAJEIBA)



## 复合变量

Oracle 数据库中有两个引擎,`SQL 引擎`和 `PL\SQL 引擎`,我们在 pl/sql 的模块中调用了 sql 语句,数据库就要 在两个引擎中来回的切换，如果我们使用循环来处理SQL语句的话,就会造成频繁的在两个引擎中进行切换.。

为了避免这样的情况发生，我们最好是将要传递的值放入到复合变量中，一次传递更多的数据，这个技术叫 做**批量绑定**。

[PL/SQL Collections and Records](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#LNPLS005)

### PL/SQL RECORDs

在一个 **record**，内部组件可以具有不同的数据类型，并且被称为**域Field**。您可以使用以下语法按其名称访问记录变量的每个字段：`variable_name.field_name`。要创建记录变量，您可以定义一个`RECORD`类型，然后创建该类型的变量，或者使用`%ROWTYPE`或`%TYPE`。

 `%ROWTYPE` 属性可让您声明一个记录变量 表示数据库表或视图的全部或部分行。对于完整或部分行的每一列，记录都有一个具有相同名称和数据类型的字段。如果行的结构发生变化，那么记录的结构也会发生变化。

记录字段不继承相应列的约束或初始值（请参见[示例5-39](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#BEIBGEFH)）。

话题

- [记录变量始终代表完整行](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CIHBIDGC)
- [记录可以代表部分行的变量](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#CIHHHGAE)
- [％ROWTYPE属性和虚拟列](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#BABGAHFI)

#### 记录变量始终代表完整行

要声明一个始终代表数据库表或视图的完整行的记录变量，请使用以下语法：

```
variable_name  table_or_view_name％ROWTYPE;
```

对于表或视图的每一列，记录都有一个具有相同名称和数据类型的字段

#### 记录可以代表部分行的变量

要声明一个可以代表数据库表或视图的部分行的记录变量，请使用以下语法：

```plsql
variable_name cursor%ROWTYPE;
```

#### ％ROWTYPE属性和虚拟列

如果您使用 `%ROWTYPE` 属性以定义一个记录变量，该记录变量表示具有 虚拟列，则无法将该记录插入表中。相反，您必须将各个记录字段插入到表中，但不包括虚拟列。

[例5-42](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#BABEHIII)创建了一个记录变量，该变量代表具有虚拟列的表的完整行，填充该记录，并将该记录插入到表中，从而导致ORA-54013。

* 前缀为表的名称

* 内部域的属性为表中列的数据类型
* 域的名称为列的名称
* 便于存储表的一行

### PL/SQL Collections

在一个 **collection**，内部组件始终具有相同的数据类型，并且被称为**元素**。您可以通过其唯一性来访问集合变量的每个元素索引，使用以下语法：`variable_name(index)`。要创建集合变量，您可以定义一个集合类型，然后创建该类型的变量或使用`%TYPE`。

表面上看象数组，但不是，它更象一个带有主键的表，我们通过主键来访问数据。 含有两要素:

* 主键，数据类型为 BINARY_INTEGER
* 成员，可以为简单变量，也可以为记录复合变量

```plsql
TYPE type_name IS TABLE OF
{column_type | variable%TYPE
| table.column%TYPE} [NOT NULL]
| table.%ROWTYPE
[INDEX BY BINARY_INTEGER];
identifier type_name;
```

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
begin
dbms_output.put_line('-----------------Begin------------------');
dbms_output.put_line('v_hiredate:' || v_hiredate );
dbms_output.put_line('v_deptno' || v_deptno);
dbms_output.put_line('v_location' || v_location);
dbms_output.put_line('c_comm:' || c_comm );
dbms_output.put_line('-----------------End------------------');
end;
/
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
* `True and null` 结果为 `null`
* `Flase and null` 结果为` flase`

### 实践7-在块中使用三种循环`for.while.loop`

该实验的目的是掌握 pl/sql 块中使用 三种 循环的语法。

打印乘法口诀。

```plsql
-- for
declare
s varchar2(2000) := '';
begin
for i in 1..9 loop
  s := '';
	for j in 1..i loop
			s := s || j || ' * ' || i || ' = ' || i*j || '    ';
	end loop;
	dbms_output.put_line(s);
end loop;
end;
/

-- while
declare
s varchar2(2000) := '';
i number :=1;
j number :=1;
begin
while i <= 9 loop
  s := '';
	j := 1;
	while j <= i loop
			s := s || j || ' * ' || i || ' = ' || i*j || '    ';
			j := j + 1;
	end loop;
	dbms_output.put_line(s);
	i := i + 1;
end loop;
end;
/

-- loop
declare
s varchar2(2000) := '';
i number :=1;
j number :=1;
begin
loop
  s := '';
	j := 1;
	loop
			s := s || j || ' * ' || i || ' = ' || i*j || '    ';
			j := j + 1;
  exit when j > i; 		
	end loop;
	dbms_output.put_line(s);
	i := i + 1;
exit when i > 9;
end loop;
end;
/
```



运行结果

```bash
1 * 1 = 1    
1 * 2 = 2    2 * 2 = 4    
1 * 3 = 3    2 * 3 = 6    3 * 3 = 9    
1 * 4 = 4    2 * 4 = 8    3 * 4 = 12    4 * 4 = 16    
1 * 5 = 5    2 * 5 = 10    3 * 5 = 15    4 * 5 = 20    5 * 5 = 25    
1 * 6 = 6    2 * 6 = 12    3 * 6 = 18    4 * 6 = 24    5 * 6 = 30    6 * 6 = 36    
1 * 7 = 7    2 * 7 = 14    3 * 7 = 21    4 * 7 = 28    5 * 7 = 35    6 * 7 = 42    7 * 7 = 49    
1 * 8 = 8    2 * 8 = 16    3 * 8 = 24    4 * 8 = 32    5 * 8 = 40    6 * 8 = 48    7 * 8 = 56    8 * 8 = 64    
1 * 9 = 9    2 * 9 = 18    3 * 9 = 27    4 * 9 = 36    5 * 9 = 45    6 * 9 = 54    7 * 9 = 63    8 * 9 = 72    9 * 9 = 81    
```

三种循环，个人最喜欢for。^.^

### 实践8-在块中自定义RECORD类型定义和变量声明

自定义数据类型

* 定义新的数据类型`DeptRecTyp`
* 声明变量 `dept_rec`的数据类型为 `DeptRecTyp`
* 声明变量 `dept_rec_2` 的数据类型与 `dept_rec`的类型相同

```plsql
DECLARE
  TYPE DeptRecTyp IS RECORD (
    dept_id    NUMBER(4) NOT NULL := 10,
    dept_name  VARCHAR2(30) NOT NULL := 'Administration',
    mgr_id     NUMBER(6) := 200,
    loc_id     NUMBER(4)
  );

  dept_rec DeptRecTyp;
  dept_rec_2 dept_rec%TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('dept_rec:');
  DBMS_OUTPUT.PUT_LINE('---------');
  DBMS_OUTPUT.PUT_LINE('dept_id:   ' || dept_rec.dept_id);
  DBMS_OUTPUT.PUT_LINE('dept_name: ' || dept_rec.dept_name);
  DBMS_OUTPUT.PUT_LINE('mgr_id:    ' || dept_rec.mgr_id);
  DBMS_OUTPUT.PUT_LINE('loc_id:    ' || dept_rec.loc_id);

  DBMS_OUTPUT.PUT_LINE('-----------');
  DBMS_OUTPUT.PUT_LINE('dept_rec_2:');
  DBMS_OUTPUT.PUT_LINE('-----------');
  DBMS_OUTPUT.PUT_LINE('dept_id:   ' || dept_rec_2.dept_id);
  DBMS_OUTPUT.PUT_LINE('dept_name: ' || dept_rec_2.dept_name);
  DBMS_OUTPUT.PUT_LINE('mgr_id:    ' || dept_rec_2.mgr_id);
  DBMS_OUTPUT.PUT_LINE('loc_id:    ' || dept_rec_2.loc_id);
END;
/
```

运行结果

 ```plsql
dept_rec:
---------
dept_id:   10
dept_name: Administration
mgr_id:    200
loc_id:
-----------
dept_rec_2:
-----------
dept_id:   10
dept_name: Administration
mgr_id:    200
loc_id:
 ```

### 实践9-在块中自定义RECORD字段的RECORD类型（嵌套记录Nested Record）

`record`类型可以理解为`python`中的字典`dict`

```python
friend = {
  "name" : {
    "ename": "John",
    "job": "salesman",
  },
  "sal": 1000,
}
print(friend['name']['ename'],friend['name']['job'],friend['sal'])
# ('John', 'salesman', 1000)
```

使用PLSQL实现：

```plsql
DECLARE
  TYPE name_rec IS RECORD (
    ename  emp.ename%TYPE,
    job   emp.job%TYPE
  );

  TYPE contact IS RECORD (
    name  name_rec,                    -- nested record
    sal emp.sal%TYPE
  );

  friend contact;
BEGIN
  friend.name.ename := 'John';
  friend.name.job := 'salesman';
  friend.sal := '1000';

  DBMS_OUTPUT.PUT_LINE (
    friend.name.ename  || ' ' ||
    friend.name.job   || ', ' ||
    friend.sal
  );
END;
/
```

运行结果

```plsql
John salesman, 1000
```

### 实践10-在块中自定义RECORD字段的RECORD类型（％ROWTYPE属性）

* 声明变量`dept_rec`的数据类型与 表`dept`相同
* 赋予变量`dept_rec`的每个`field`一个值，并打印。

```plsql
DECLARE
  dept_rec dept%ROWTYPE;
  dept_rec2 dept%ROWTYPE;
BEGIN
  -- Assign values to fields:

  dept_rec.DEPTNO  := 10;
  dept_rec.DNAME := 'Administration';
  dept_rec.LOC    := 'New York';
  select * into dept_rec2 from dept where rownum = 1;

  -- Print fields:

  DBMS_OUTPUT.PUT_LINE('DEPTNO:   ' || dept_rec.DEPTNO);
  DBMS_OUTPUT.PUT_LINE('DNAME: ' || dept_rec.DNAME);
  DBMS_OUTPUT.PUT_LINE('LOC:    ' || dept_rec.LOC);

  DBMS_OUTPUT.PUT_LINE('DEPTNO:   ' || dept_rec2.DEPTNO);
  DBMS_OUTPUT.PUT_LINE('DNAME: ' || dept_rec2.DNAME);
  DBMS_OUTPUT.PUT_LINE('LOC:    ' || dept_rec2.LOC);
END;
/
```

执行结果

```plsql
DEPTNO:   10
DNAME: Administration
LOC:	New York
DEPTNO:   10
DNAME: ACCOUNTING
LOC:	NEW YORK
```

### 实践11-在块中自定义COLLECTIONS的类型

```plsql
DECLARE
TYPE t1 IS TABLE OF emp.ename%TYPE
INDEX BY BINARY_INTEGER;
TYPE t2 IS TABLE OF DATE INDEX BY BINARY_INTEGER;
v1 t1;
v2 t2;
BEGIN
V1(0) := 'AA';
v1(1) := 'CAMERON';
v2(8) := SYSDATE + 7;
select ename,hiredate into v1(7900),v2(7900) from emp where empno=7900; dbms_output.put_line(v1(1)||' '||v1(7900)); dbms_output.put_line(v2(8)||' '||v2(7900));
dbms_output.put_line(v1(0));
END;
/


DECLARE
TYPE t1 IS TABLE OF emp.ename%TYPE
INDEX BY BINARY_INTEGER;
v1 t1;
BEGIN
V1(0) := 'AA';
v1(1) := 'CAMERON';
dbms_output.put_line(v1(1));
END;
/

DECLARE
TYPE t1 IS TABLE OF NUMBER;
v1 t1 := t1(1,2,3);
BEGIN
dbms_output.put_line(v1(1));
END;
/
```

### 实践12-使用集合的属性来操作集合的数据

| 方法     | 类型 | 描述                                                 |
| :------- | :--- | :--------------------------------------------------- |
| `DELETE` | 程序 | 从集合中删除元素。                                   |
| `TRIM`   | 程序 | 从varray或嵌套表的末尾删除元素。                     |
| `EXTEND` | 程序 | 将元素添加到varray或嵌套表的末尾。                   |
| `EXISTS` | 功能 | `TRUE`当且仅当存在varray或嵌套表的指定元素时才返回。 |
| `FIRST`  | 功能 | 返回集合中的第一个索引。                             |
| `LAST`   | 功能 | 返回集合中的最后一个索引。                           |
| `COUNT`  | 功能 | 返回集合中元素的数量。                               |
| `LIMIT`  | 功能 | 返回集合可以具有的最大元素数。                       |
| `PRIOR`  | 功能 | 返回指定索引之前的索引。                             |
| `NEXT`   | 功能 | 返回在指定索引之后的索引。                           |

```plsql
DECLARE
  type nt_type is  table of number;
  nt nt_type := nt_type(11, 22, 33, 44, 55, 66);
  PROCEDURE print_nt(nt nt_type) IS
  	i number;
  begin
  	i := nt.FIRST;
  	IF i IS NULL THEN
    	DBMS_OUTPUT.PUT_LINE('nt is empty');
  	ELSE
    	WHILE i IS NOT NULL LOOP
      	DBMS_OUTPUT.PUT('nt.(' || i || ') = ');
        DBMS_OUTPUT.PUT(nt(i));
        DBMS_OUTPUT.PUT_line('');
      	i := nt.NEXT(i);
    	END LOOP;
    END IF;
    DBMS_OUTPUT.PUT_line('==========================');
  END;
BEGIN
  print_nt(nt);

  nt.DELETE(2);     -- Delete second element
  print_nt(nt);

  nt(2) := 2222;    -- Restore second element
  print_nt(nt);

  nt.DELETE(2, 4);  -- Delete range of elements
  print_nt(nt);

  nt(3) := 3333;    -- Restore third element
  print_nt(nt);

  nt.DELETE;        -- Delete all elements
  print_nt(nt);
END;
/
```

结果

```plsql
nt.(1) = 11
nt.(2) = 22
nt.(3) = 33
nt.(4) = 44
nt.(5) = 55
nt.(6) = 66
==========================
nt.(1) = 11
nt.(3) = 33
nt.(4) = 44
nt.(5) = 55
nt.(6) = 66
==========================
nt.(1) = 11
nt.(2) = 2222
nt.(3) = 33
nt.(4) = 44
nt.(5) = 55
nt.(6) = 66
==========================
nt.(1) = 11
nt.(5) = 55
nt.(6) = 66
==========================
nt.(1) = 11
nt.(3) = 3333
nt.(5) = 55
nt.(6) = 66
==========================
nt is empty
==========================
```

### 实践13-成员为复合变量，每个主键访问一行数据

```plsql
DECLARE
TYPE t1 IS TABLE OF emp%rowtype INDEX BY BINARY_INTEGER;
TYPE t2 IS TABLE OF dept%rowtype INDEX BY BINARY_INTEGER;
v1 t1;
v2 t2;
BEGIN
select * into v1(7900) from emp where empno=7900;
select * into v2(10) from dept where deptno=10; dbms_output.put_line(v1(7900).empno||v1(7900).ename); dbms_output.put_line(v2(10).dname);
END;
/
```

### 实践14-在块中使用自定义游标

```plsql
DECLARE
CURSOR c1 is select ename,sal from emp order by sal desc;
v1 c1%rowtype;
BEGIN
open c1;
fetch c1 into v1;
dbms_output.put_line(v1.ename || ': ' ||v1.sal);
fetch c1 into v1;
dbms_output.put_line(v1.ename || ': ' ||v1.sal);
close c1;
END;
/
```

### 实践15--在块中使用自定义游标和游标的属性

游标的属性:

前缀为游标的名称

* %isopen，测试该游标是否打开，返回真或假
* %rowcount，游标已经操作了多少行， 返回数值
* %found，游标是否找到记录，返回真或假
* %notfound，游标是否找到记录，返回真或假

```plsql
DECLARE
CURSOR c1 is select ename,sal from emp order by sal desc; v1 c1%rowtype;
n1 number(2);
BEGIN
if not c1%isopen then
open c1;
end if;
fetch c1 into v1;
n1:=c1%rowcount;
dbms_output.put_line(v1.ename||' '||v1.sal||' '||n1); close c1;
END;
/
```

### 实践16-在块中使用自定义游标和循环控制

```plsql
DECLARE
 CURSOR c1 is select ename,sal from emp order by sal desc;
 v1 c1%rowtype;
 n1 number(2);
BEGIN
 open c1;
 loop fetch c1 into v1;
 	exit when c1%notfound;
 	dbms_output.put_line(v1.ename||' '||v1.sal);
 	n1:=c1%rowcount;
 	end loop;
 close c1;
 dbms_output.put_line(n1);
END;
/

-- For 循环
DECLARE
 CURSOR c1 is select ename,sal from emp order by sal desc;
 n1 number(2);
BEGIN
 for v1 in c1 loop
   dbms_output.put_line(v1.ename||' '||v1.sal);
   n1:=c1%rowcount;
 end loop;
 dbms_output.put_line(n1);
 END;
 /
```

* `v1` 的数据类型为 `c1%rowtype`
* `c1` 自动 `open`,自动` fetch`,自动 `close`
* `for` 循环和`游标`的结合可以很方便的 处理游标内的每一行。

### 实践18-在块中使用自定义游标之带变量的游标

* 带变量的游标，每次打开游标的时候需要给定变量。

* 根据变量的不同，游标的内容将不同。
* 一般用于多层循环中内层循环的游标控制。

```plsql
DECLARE
 CURSOR c1(n1 number) is select ename,sal from emp where empno=n1;
 v1 c1%rowtype;
BEGIN
 open c1(7900);
 fetch c1 into v1;
 dbms_output.put_line(v1.ename||' '||v1.sal);
 close c1;
END;
/
```

## 课后练习

准备实验环境，建立一个表，其中一个列是空的，我们要将空列的值赋予相对应的部门名称。

```sql
conn scott/tiger
drop table t1 purge;
create table t1 as select ename,deptno from emp;
alter table t1 add(dname varchar2(18));
select * from t1;
```

执行结果

```sql
SCOTT@testdb>select * from t1;

ENAME	       DEPTNO DNAME
---------- ---------- ------------------
test1		   50
test		   50
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
JAMES		   30
FORD		   20
MILLER		   10
booboo		   50

17 rows selected.
```

答案：

```plsql
DECLARE
 CURSOR c1 is select * from t1 for update;
 v1 dept.dname%type;

BEGIN
 for n1 in c1 loop
   select dname into v1 from dept where deptno=n1.deptno;
   update t1 set dname=v1 WHERE CURRENT OF C1;
 end loop;
 END;
 /
```

检查

```sql
SCOTT@testdb>select * from t1;

ENAME	       DEPTNO DNAME
---------- ---------- ------------------
test1		   50 test
test		   50 test
SMITH		   20 RESEARCH
ALLEN		   30 SALES
WARD		   30 SALES
JONES		   20 RESEARCH
MARTIN		   30 SALES
BLAKE		   30 SALES
CLARK		   10 ACCOUNTING
SCOTT		   20 RESEARCH
KING		   10 ACCOUNTING
TURNER		   30 SALES
ADAMS		   20 RESEARCH
JAMES		   30 SALES
FORD		   20 RESEARCH
MILLER		   10 ACCOUNTING
booboo		   50 test

17 rows selected.
```
