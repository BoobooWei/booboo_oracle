# PLSQL-异常处理_匿名块

> 2020.01.28 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [PLSQL-异常处理_匿名块](#plsql-异常处理_匿名块)   
   - [异常处理](#异常处理)   
      - [异常处理程序的优点](#异常处理程序的优点)   
      - [异常处理的语法](#异常处理的语法)   
      - [异常的分类](#异常的分类)   
      - [处理内部定义异常](#处理内部定义异常)   
         - [语法](#语法)   
         - [案例](#案例)   
      - [处理系统预定义异常](#处理系统预定义异常)   
         - [语法](#语法)   
         - [案例](#案例)   
      - [处理自定义异常](#处理自定义异常)   
         - [语法](#语法)   
         - [RAISE声明](#raise声明)   
         - [RAISE_APPLICATION_ERROR过程](#raise_application_error过程)   
         - [案例-RAISE](#案例-raise)   
         - [案例2-RAISE_APPLICATION_ERROR](#案例2-raise_application_error)   
      - [课后练习](#课后练习)   
         - [练习1-使用函数`sqlerrm`打印`ORA-`消息描述](#练习1-使用函数sqlerrm打印ora-消息描述)   
         - [练习2-处理系统预定义异常](#练习2-处理系统预定义异常)   
         - [练习3-处理内部定义异常`ORA-02291`](#练习3-处理内部定义异常ora-02291)   
         - [练习4-综合练习](#练习4-综合练习)   
         - [练习5-处理自定义异常](#练习5-处理自定义异常)   

<!-- /MDTOC -->

## 异常处理

官方文档

[PL/SQL Error Handling](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#LNPLS007)

[Exception Declaration](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exception_declaration.htm#LNPLS01387)

### 异常处理程序的优点

使用异常处理程序进行错误处理可以使程序更易于编写和理解，并减少未处理异常的可能性。

如果没有异常处理程序，则必须检查所有可能发生的错误（可能发生的任何地方），然后进行处理。很容易忽略可能的错误或可能发生的地方，尤其是在无法立即检测到错误的情况下（例如，在您将其用于计算之前，可能无法检测到错误的数据）。错误处理代码分散在整个程序中。

使用异常处理程序，您不必知道每个可能的错误或任何可能发生的错误。您只需要在可能发生错误的每个块中包括一个异常处理部分。在异常处理部分，您可以包括针对特定错误和未知错误的异常处理程序。如果该块中任何地方（包括子块内部）发生错误，则由异常处理程序进行处理。错误处理代码隔离在块的异常处理部分中。

在[示例11-3中](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#BABFBHGA)，过程使用单个异常处理程序来处理预定义的异常`NO_DATA_FOUND`，该异常可能发生在两个`SELECT` `INTO`语句中的任何一个中。

### 异常处理的语法

异常（PL / SQL运行时错误）可能源于设计错误，编码错误，硬件故障和许多其他来源。您无法预期所有可能的异常，但是可以编写异常处理程序，可让您的程序在存在的情况下继续运行。

任何PL / SQL块都可以具有一个异常处理部分，该部分可以具有一个或多个异常处理程序。例如，异常处理部分可能具有以下语法：

```PLSQL
EXCEPTION
  WHEN ex_name_1 THEN statements_1                  -异常处理
  WHEN ex_name_2 OR ex_name_3 THEN statements_2   -异常处理
  WHEN OTHERS THEN statements_3                       -例外处理程序
END;
```

在前面的语法示例中，`ex_name_``n`是异常的名称，并且`statements_``n`是一个或多个语句。（有关完整的语法和语义，请参阅[“异常处理程序”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exception_handler.htm#i33826)。）

当块的可执行部分中引发异常时，可执行部分将停止并将控制权转移到异常处理部分。如果`ex_name_1`有人提出来，那`statements_1`就跑。如果任一`ex_name_2`或被`ex_name_3`提出，然后`statements_2`运行。如果引发了其他任何异常，请`statements_3`运行。

运行异常处理程序后，控制权将转移到封闭块的下一条语句。如果没有封闭块，则：

- 如果异常处理程序在子程序中，则控制在调用后的语句处返回到调用程序。
- 如果异常处理程序位于匿名块中，则控制权将转移到主机环境（例如，SQL * Plus）

如果在没有异常处理程序的块中引发了异常，则该异常将传播。也就是说，异常会在连续的封闭块中重现，直到一个块具有针对它的处理程序或没有封闭块为止（有关更多信息，请参见[“异常传播”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i3365)）。如果没有用于异常的处理程序，则PL / SQL将未处理的异常错误返回给调用者或宿主环境，该错误确定结果（有关更多信息，请参见[“未处理的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i1889)）。

### 异常的分类

- **内部定义**

  运行时系统隐式（自动）引发内部定义的异常。内部定义的异常的示例是ORA-00060（在等待资源时检测到死锁）和ORA-27102（内存不足）。

  内部定义的异常始终具有错误代码，但没有名称，除非PL / SQL给它一个或您给它一个。

  有关更多信息，请参见[“内部定义的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#BABIIEFC)。

- **预定义**

  预定义的异常是内部定义的异常，PL / SQL已为其指定了名称。例如，ORA-06500（PL / SQL：存储错误）具有预定义的名称`STORAGE_ERROR`。

  有关更多信息，请参见[“预定义的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i9355)。

- **用户自定义**

  您可以在任何PL / SQL匿名块，子程序或程序包的声明部分中声明自己的异常。例如，您可以声明一个名称`insufficient_funds`为标记透支银行帐户的异常。

  您必须显式引发用户定义的异常。

  有关更多信息，请参见[“用户定义的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i3329)。

| 类别       | 定义者   | 有错误代码     | 有名字         | 隐式提高 | 明确提出                                                     |
| :--------- | :------- | :------------- | :------------- | :------- | :----------------------------------------------------------- |
| 内部定义   | 运行系统 | 总是           | 仅当您分配一个 | 是       | 可选[脚1 ](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#BABDABEJ) |
| 预定义     | 运行系统 | 总是           | 总是           | 是       | 可选的[Footref 1](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#sthref888) |
| 用户自定义 | 用户     | 仅当您分配一个 | 总是           | 没有     | 总是                                                         |

脚注1 有关详细信息，请参见[“使用RAISE语句引发内部定义的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i3355)。

对于命名异常，您可以编写特定的异常处理程序，而不是使用`OTHERS`异常处理程序对其进行处理。特定的异常处理程序比异常处理程序更有效`OTHERS`，因为后者必须调用一个函数来确定要处理的异常。有关详细信息，请参见[“错误代码和错误消息检索”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i8845)。

### 处理内部定义异常

**内部定义的异常**（ORA- *n*错误）在[*Oracle数据库错误消息中*](https://docs.oracle.com/cd/E11882_01/server.112/e17766/toc.htm)进行了描述。运行时系统隐式（自动）引发它们。

内部定义的异常没有名称，除非PL / SQL给它一个（请参阅[“预定义的异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i9355)）或您给它一个。

如果您知道数据库操作可能会引发没有名称的特定内部定义的异常，请给它们命名，以便您可以专门为其编写异常处理程序。否则，您只能使用`OTHERS`异常处理程序来处理它们。

给一个 将其命名为内部定义的异常，请在相应的匿名块，子程序或程序包的声明部分中执行以下操作。（要确定适当的块，请参见[“异常传播”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#i3365)。）

#### 语法

1. 声明名称。

   异常名称声明具有以下语法：

   ```
   exception_name EXCEPTION;
   ```

   有关语义信息，请参见[“异常声明”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exception_declaration.htm#CJABADFA)。

2. 将名称与内部定义的异常的错误代码相关联。

   语法为：

   ```
   PRAGMA EXCEPTION_INIT（exception_name，error_code）
   ```

   有关语义信息，请参见[“ EXCEPTION_INIT](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exceptioninit_pragma.htm#i33787)语法[”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exceptioninit_pragma.htm#i33787)。

注意：

具有用户声明的名称的内部定义的异常仍然是内部定义的异常，而不是用户定义的异常。

#### 案例

`deadlock_detected`内部定义的异常ORA-00060（在等待资源时检测到死锁）提供了名称，并在异常处理程序中使用了该名称。

```plsql
DECLARE
  deadlock_detected EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
BEGIN
  ...
EXCEPTION
  WHEN deadlock_detected THEN
    ...
END;
/
```

### 处理系统预定义异常

**预定义异常**是具有预定义名称的内部定义的异常，PL / SQL在包中全局声明了预定义名称`STANDARD`。运行时系统隐式（自动）引发预定义的异常。因为预定义的异常具有名称，所以您可以为其专门编写异常处理程序。

[表11-3](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#CIHHGGDI)列出了预定义的异常的名称和错误代码。

表11-3 PL / SQL预定义的异常

| **例外名称**              | 错误代码 |
| :------------------------ | :------- |
| `ACCESS_INTO_NULL`        | `-6530`  |
| `CASE_NOT_FOUND`          | `-6592`  |
| `COLLECTION_IS_NULL`      | `-6531`  |
| `CURSOR_ALREADY_OPEN`     | `-6511`  |
| `DUP_VAL_ON_INDEX`        | `-1`     |
| `INVALID_CURSOR`          | `-1001`  |
| `INVALID_NUMBER`          | `-1722`  |
| `LOGIN_DENIED`            | `-1017`  |
| `NO_DATA_FOUND`           | `+100`   |
| `NO_DATA_NEEDED`          | `-6548`  |
| `NOT_LOGGED_ON`           | `-1012`  |
| `PROGRAM_ERROR`           | `-6501`  |
| `ROWTYPE_MISMATCH`        | `-6504`  |
| `SELF_IS_NULL`            | `-30625` |
| `STORAGE_ERROR`           | `-6500`  |
| `SUBSCRIPT_BEYOND_COUNT`  | `-6533`  |
| `SUBSCRIPT_OUTSIDE_LIMIT` | `-6532`  |
| `SYS_INVALID_ROWID`       | `-1410`  |
| `TIMEOUT_ON_RESOURCE`     | `-51`    |
| `TOO_MANY_ROWS`           | `-1422`  |
| `VALUE_ERROR`             | `-6502`  |
| `ZERO_DIVIDE`             | `-1476`  |

#### 语法
```PLSQL
exception
  when no_data_found then
```


#### 案例

```plsql
declare
  v_ename emp.ename%type;
  v_sal emp.sal%type;
/*
-1:未选定行
*/
  v_err number;
begin
  select ename,sal into v_ename,v_sal from emp where empno=&p_empno;
  v_err:=0;
  dbms_output.put_line(v_err);
exception
  when no_data_found then
    v_err:=-1;
    dbms_output.put_line(v_err);
end;
/
```

运行结果

```
ACCESS_INTO_NULL -6530
CASE_NOT_FOUND -6592
COLLECTION_IS_NULL -6531
CURSOR_ALREADY_OPEN -6511
DUP_VAL_ON_INDEX -1
INVALID_CURSOR -1001
INVALID_NUMBER -1722
LOGIN_DENIED -1017
NO_DATA_FOUND +100
NO_DATA_NEEDED -6548
NOT_LOGGED_ON -1012
PROGRAM_ERROR -6501
ROWTYPE_MISMATCH -6504
SELF_IS_NULL -30625
STORAGE_ERROR -6500
SUBSCRIPT_BEYOND_COUNT -6533
SUBSCRIPT_OUTSIDE_LIMIT -6532
SYS_INVALID_ROWID -1410
TIMEOUT_ON_RESOURCE -51
TOO_MANY_ROWS -1422
VALUE_ERROR -6502
```

### 处理自定义异常

您可以在任何PL / SQL匿名块，子程序或程序包的声明部分中声明自己的异常。

#### 语法

异常名称声明具有以下语法：

```
exception_name EXCEPTION;
```

有关语义信息，请参见[“异常声明”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exception_declaration.htm#CJABADFA)。

您必须显式引发用户定义的异常。有关详细信息，请参见[“显式引发异常”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/errors.htm#BABFHFBI)。

#### RAISE声明

的 `RAISE`语句显式引发异常。在异常处理程序之外，您必须指定异常名称。在异常处理程序内部，如果省略了异常名称，则该`RAISE`语句将重新引发当前的异常。

#### RAISE_APPLICATION_ERROR过程

您可以调用 `RAISE_APPLICATION_ERROR``DBMS_STANDARD`仅在存储的子程序或方法中执行过程（在包中定义）。通常，您调用此过程来引发用户定义的异常，并将其错误代码和错误消息返回给调用者。

要调用`RAISE_APPLICATION_ERROR`，请使用以下语法：

```
RAISE_APPLICATION_ERROR（error_code，消息 [，{TRUE | FALSE}]）；
```

您必须使用分配`error_code`给用户定义的异常`EXCEPTION_INIT`实用 语法为：

```
PRAGMA EXCEPTION_INIT（exception_name，error_code）
```

有关语义信息，请参见[“ EXCEPTION_INIT](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exceptioninit_pragma.htm#i33787)语法[”](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/exceptioninit_pragma.htm#i33787)。

#### 案例-RAISE

```plsql
DECLARE
  salary_too_high   EXCEPTION;
  current_salary    NUMBER := 20000;
  max_salary        NUMBER := 10000;
  erroneous_salary  NUMBER;
BEGIN

  BEGIN
    IF current_salary > max_salary THEN
      RAISE salary_too_high;   -- raise exception
    END IF;
  EXCEPTION
    WHEN salary_too_high THEN  -- start handling exception
      erroneous_salary := current_salary;
      DBMS_OUTPUT.PUT_LINE('Salary ' || erroneous_salary ||' is out of range.');
      DBMS_OUTPUT.PUT_LINE ('Maximum salary is ' || max_salary || '.');
      RAISE;  -- reraise current exception (exception name is optional)
  END;

EXCEPTION
  WHEN salary_too_high THEN    -- finish handling exception
    current_salary := max_salary;

    DBMS_OUTPUT.PUT_LINE (
      'Revising salary from ' || erroneous_salary ||
      ' to ' || current_salary || '.'
    );
END;
/
```

Result:

```plsql
Salary 20000 is out of range.
Maximum salary is 10000.
Revising salary from 20000 to 10000.
```

#### 案例2-RAISE_APPLICATION_ERROR

```plsql
CREATE PROCEDURE account_status (
  due_date DATE,
  today    DATE
) AUTHID DEFINER
IS
BEGIN
  IF due_date < today THEN                   -- explicitly raise exception
    RAISE_APPLICATION_ERROR(-20000, 'Account past due.');
  END IF;
END;
/

DECLARE
  past_due  EXCEPTION;                       -- declare exception
  PRAGMA EXCEPTION_INIT (past_due, -20000);  -- assign error code to exception
BEGIN
  account_status ('1-JUL-10', '9-JUL-10');   -- invoke procedure
EXCEPTION
  WHEN past_due THEN                         -- handle exception
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
END;
/
```

Result:

```
ORA-20000: Account past due.
```

### 课后练习

#### 练习1-使用函数`sqlerrm`打印`ORA-`消息描述

```plsql
/* 使用函数sqlerrm打印ORA-消息描述：*/
declare
  errm varchar2(1000);
begin
  for errno in 20000..20999 loop
    errm:=sqlerrm(-errno);
    dbms_output.put_line(errm);
  end loop;
end;
/
```

#### 练习2-处理系统预定义异常

* 捕获到`no_data_found`；则输出`-1`：
* 捕获到`too_many_row`；则输出`查询返回太多行`;
* 捕获到其他异常，则输出`未知错误`。

```plsql
declare
  v_ename emp.ename%type;
  v_sal emp.sal%type;
  v_err number;
begin
  update emp set deptno=80 where empno=7839;
  select ename,sal into v_ename,v_sal from emp where deptno=&p_deptno;
  v_err:=0;
    dbms_output.put_line(v_err);
exception
  when no_data_found then
    v_err:=-1;
    dbms_output.put_line(v_err);
  when too_many_rows then
    dbms_output.put_line('查询返回太多行');
  when others then
    dbms_output.put_line('未知错误');
end;
/
```

#### 练习3-处理内部定义异常`ORA-02291`

```bash
[oracle@NB-flexgw1 ~]$ oerr ora 2291
02291, 00000,"integrity constraint (%s.%s) violated - parent key not found"
// *Cause: A foreign key value has no matching primary key value.
// *Action: Delete the foreign key or add a matching primary key.
```

如果捕获到异常`ORA-02291`则输出：外键取值错误；

```sqlplus
declare
  myerr exception;
  pragma exception_init(myerr,-2291);
  v_ename emp.ename%type;
  v_sal emp.sal%type;
  v_err number;
begin
  update emp set deptno=80 where empno=7839;
  select ename,sal into v_ename,v_sal from emp where deptno=&p_deptno;
  v_err:=0;
    dbms_output.put_line(v_err);
exception
  when no_data_found then
    v_err:=-1;
    dbms_output.put_line(v_err);
  when too_many_rows then
    dbms_output.put_line('查询返回太多行');
  when myerr then
    dbms_output.put_line('外键取值错误');
end;
/
```

#### 练习4-综合练习

* 获取部门编号为1的员工姓名

  ```sqlplus
  SCOTT@testdb>select ename from emp where empno=1;

  no rows selected
  ```

* 删除部门表中所有的行

  ```plsql
  SCOTT@testdb>delete dept;
  delete dept
  *
  ERROR at line 1:
  ORA-02292: integrity constraint (SCOTT.FK_DEPTNO) violated - child record found
  ```

* 更新员工表中部门编号为7839的部门编号，手动输入

* 打印员工表中部门编号为手动输入的编号的员工工资

```plsql
/* 异常处理的作用 */
declare
  v_sal number;
begin
  declare
    myerr exception;
    pragma exception_init(myerr,-2292);
    v_deptno number:=&p_deptno;
    v_ename varchar2(10);
  begin
   select ename into v_ename from emp where empno=1;/* 因为不存在empno=1的行，该行会触发异常no_data_found */
    delete dept;/* dept表存在外键，该动作会会触发异常 ORA-02292*/
    update emp set deptno=v_deptno where empno=7839;
  exception
    when myerr then
      dbms_output.put_line('ORA-02292');
    when others then
      dbms_output.put_line('unknown error');  
      dbms_output.put_line(sqlcode||' ; '||sqlerrm);  
  end;
  select sal into v_sal from emp where empno=&p_empno;
  dbms_output.put_line(v_sal);
end;
/
```

出现异常时不会继续往下执行，会跳出当前块，因此`delete`	和`update`语句都没有执行；而`select sal into v_sal from emp where empno=&p_empno;`语句执行成功。

运行结果

```plsql
Enter value for p_deptno: 1
old   7:     v_deptno number:=&p_deptno;
new   7:     v_deptno number:=1;
Enter value for p_empno: 8000
old  20:   select sal into v_sal from emp where empno=&p_empno;
new  20:   select sal into v_sal from emp where empno=8000;
unknown error
100 ; ORA-01403: no data found
1888

PL/SQL procedure successfully completed.
```

我们调整一下代码

```plsql
/* 异常处理的作用 */
declare
  v_sal number;
begin
  declare
    myerr exception;
    pragma exception_init(myerr,-2292);
    v_deptno number:=&p_deptno;
    v_ename varchar2(10);
  begin
    delete dept;/* dept表存在外键，该动作会会触发异常 ORA-02292*/
    update emp set deptno=v_deptno where empno=7839;
  exception
    when myerr then
      dbms_output.put_line('ORA-02292');
    when others then
      dbms_output.put_line('unknown error');  
      dbms_output.put_line(sqlcode||' ; '||sqlerrm);  
  end;
  select sal into v_sal from emp where empno=&p_empno;
  dbms_output.put_line(v_sal);
end;
/
```

执行结果

```plsql
Enter value for p_deptno: 1
old   7:     v_deptno number:=&p_deptno;
new   7:     v_deptno number:=1;
Enter value for p_empno: 8000
old  19:   select sal into v_sal from emp where empno=&p_empno;
new  19:   select sal into v_sal from emp where empno=8000;
ORA-02292
1888
```

成功触发了`ORA-02292`异常。



#### 练习5-处理自定义异常



```plsql
/* 使用自定义异常 */
declare
  myerr exception;
  pragma exception_init(myerr,-20000);
  v_empno number:=&p_empno;
  v_sal number:=&p_sal;
begin
  if v_sal<1000 then
    raise_application_error(-20000,'自定义错误！');
  else
    update emp set sal=v_sal where empno=v_empno;
  end if;
exception
  when myerr then
    dbms_output.put_line('工资太少!');
end;
/
```
