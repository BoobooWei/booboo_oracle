# 包Package

> 2020.01.29 BoobooWei


## 什么是包

[PL/SQL Packages](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/packages.htm#LNPLS009)


一种 包是一个架构对象，将逻辑上相关的PL / SQL类型，变量，常量，子程序，游标和异常进行分组。包被编译并存储在数据库中，许多应用程序可以在其中共享其内容。您可以将包裹视为应用。

一个包总是有一个 规范，它声明可以从包外部引用的公共项目。您可以将软件包规范视为应用程序编程接口（API）。有关包装规格的更多信息，请参见“包装规格”。

如果公共项包括游标或子程序，则该程序包还必须包含一个 身体。该主体必须为公共游标定义查询，并为公共子程序定义代码。主体还可以声明和定义私有项目，这些私有项目不能从包装外部引用，但是对于包装的内部工作而言是必需的。最后，主体可以具有一个初始化部分，一个语句来初始化变量并执行其他一次性设置步骤以及一个异常处理部分。您可以更改正文，而无需更改规范或对公共项的引用；因此，您可以将包装体视为黑匣子。有关包主体的更多信息，请参见“包主体”。

在程序包规范或程序包主体中，可以使用以下命令将程序包子程序映射到外部Java或C子程序： 调用规范，它将外部子程序名称，参数类型和返回类型映射到它们的SQL副本。有关详细信息，请参见“函数声明和定义”和“过程声明和定义”。

程序包规范的AUTHID 子句确定程序包中的子程序和游标是否以其定义程序（默认值）或调用程序的特权运行，以及是否在定义程序或调用程序的模式中解析了它们对架构对象的不合格引用。有关更多信息，请参见“调用者的权利和定义者的权利（AUTHID属性）”。

## 为什么使用包

软件包通过以下内容支持开发和维护可靠的可重用代码 特征：

### 模块化

包使您可以在命名的PL / SQL模块中封装与逻辑相关的类型，变量，常量，子程序，游标和异常。您可以使每个程序包易于理解，并使程序包之间的接口简单，清晰且定义明确。这种做法有助于应用程序开发。

### 简化应用设计

设计应用程序时，最初需要的只是包装规格中的接口信息。您可以在没有规范的情况下编写和编译规范。接下来，您可以编译引用程序包的独立子程序。在准备好完成应用程序之前，无需完全定义包主体。

### 信息隐藏

包使您可以在包规范中共享接口信息，并在包主体中隐藏实现细节。将实现细节隐藏在正文中具有以下优点：

您可以在不影响应用程序界面的情况下更改实施细节。

应用程序用户无法开发依赖于您可能想要更改的实现详细信息的代码。

### 新增功能

包公共变量和游标可以在会话的整个生命周期中持续存在。它们可以由环境中运行的所有子程序共享。它们使您可以跨事务维护数据，而无需将其存储在数据库中。（对于在程序包的生命周期内程序包公共变量和游标不持久的情况，请参阅“程序包状态”。）

### 更好的性能

首次调用程序包子程序时，Oracle数据库会将整个程序包加载到内存中。随后在同一软件包中调用其他子程序不需要磁盘I / O。

软件包可防止级联依赖性和不必要的重新编译。例如，如果更改包函数的主体，则Oracle数据库不会重新编译调用该函数的其他子程序，因为这些子程序仅取决于规范中声明的参数和返回值。

## 创建包的语法

[CREATE PACKAGE Statement](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/create_package.htm#LNPLS01371)

```plsql
CREATE [ OR REPLACE ] PACKAGE [ schema. ] package_name
   [ invoker_rights_clause ]
   { IS | AS } item_list_1 END [ package_name ] ;
```

[CREATE PACKAGE BODY Statement](https://docs.oracle.com/cd/E11882_01/appdev.112/e25519/create_package_body.htm#LNPLS01372)

```plsql
CREATE [ OR REPLACE ] PACKAGE BODY [ schema. ] package_name
{ IS | AS } declare_section [ initialize_section ]
END [ package_name ] ;
```

## 实践

```plsql
create or replace package pk1
is
procedure add_emp
(p_ename emp.ename%type,
p_job emp.job%type default 'CLERK',
p_mgr emp.mgr%type default 7698,
p_hiredate date default sysdate,
p_sal emp.sal%type default 1000,
p_comm emp.comm%type default null,
p_deptno emp.deptno%type default 30);
procedure get_ename
(p_empno in emp.empno%type,
p_ename out emp.ename%type,
p_sal out emp.sal%type);
procedure get_ename
(p_ename emp.ename%type,
p_job out emp.job%type,
p_hiredate out emp.hiredate%type);
procedure add_sal
(p_empno number,p_sal number);
end;
/

create or replace package body pk1
is
function valid_deptno
(p_deptno number)
return boolean
is
  v number;
begin
  select 1 into v from dept where deptno=p_deptno;
  return true;
exception
  when no_data_found then
    return false;
end;
procedure get_ename
(p_empno in emp.empno%type,
p_ename out emp.ename%type,
p_sal out emp.sal%type)
is
begin
  select ename,sal into p_ename,p_sal from emp where empno=p_empno;
end;
procedure get_ename
(p_ename emp.ename%type,
p_job out emp.job%type,
p_hiredate out emp.hiredate%type)
is
begin
  select job,hiredate into p_job,p_hiredate from emp where ename=p_ename;
end;
procedure add_sal
(p_empno number,p_sal number)
is
  v_old_sal emp.sal%type;
begin
  select sal into v_old_sal from emp where empno=p_empno;
  if p_sal<v_old_sal or p_sal is null then
    raise_application_error(-20000,'工资不能减少');
  else
    update emp set sal=p_sal where empno=p_empno;
  end if;
end;
procedure add_emp
(p_ename emp.ename%type,
p_job emp.job%type default 'CLERK',
p_mgr emp.mgr%type default 7698,
p_hiredate date default sysdate,
p_sal emp.sal%type default 1000,
p_comm emp.comm%type default null,
p_deptno emp.deptno%type default 30)
is
begin
  if valid_deptno(p_deptno) then
  insert into emp values
(seq_empno.nextval,
p_ename,
p_job,
p_mgr,
p_hiredate,
p_sal,
p_comm,
p_deptno);
  else
    raise_application_error(-20000,'部门不存在');
  end if;
end;
end;
/
```

```plsql
wrap iname=1.sql --> 1.plb
```

感觉像类
