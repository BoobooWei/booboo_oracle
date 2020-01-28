# 存储过程`procedure`

> 2020.01.29 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [存储过程`procedure`](#存储过程procedure)   
   - [定义存储过程](#定义存储过程)   
   - [调用存储过程](#调用存储过程)   
   - [实践](#实践)   
      - [实践1-带有导入型形式参数](#实践1-带有导入型形式参数)   
      - [实践2-带有导出型形式参数的](#实践2-带有导出型形式参数的)   
      - [实践3-导入/导出型的形式参数](#实践3-导入导出型的形式参数)   
      - [实践4-带有default值的形式参数](#实践4-带有default值的形式参数)   
   - [形参赋值](#形参赋值)   
   - [存储过程中的事务处理风格](#存储过程中的事务处理风格)   
      - [自治事务](#自治事务)   
      - [调用者模式](#调用者模式)   
      - [动态sql语句](#动态sql语句)   

<!-- /MDTOC -->

## 定义存储过程

```plsql
create or replace procedure add_sal
is
  --变量声明
begin
  update emp set sal=sal*1.1;
end;
/
```

## 调用存储过程

```plsql
begin
  add_sal;
end;
/

execute add_sal;
exec add_sal;
```

执行结果

```plsql
SQL> create or replace procedure booboo
  2  is
  3  begin
  4  dbms_output.put_line('+++++++');
  5  end;
  6  /

  SQL> begin
    2  booboo;
    3  end;
    4  /
  +++++++

  PL/SQL procedure successfully completed.

  SQL> execute booboo;
  +++++++

  PL/SQL procedure successfully completed.

  SQL> exec booboo;
  +++++++

  PL/SQL procedure successfully completed.
```


## 实践

### 实践1-带有导入型形式参数

根据雇员编号涨工资

```plsql
create or replace procedure add_sal
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
/
exec add_sal(7369,700);
drop procedure add_sal;
```


查看程序源代码：

```plsql
select text from user_source where name='ADD_SAL';
```

### 实践2-带有导出型形式参数的

1. 编写匿名块进行测试

```plsql
/* 测试 */
declare
  v_empno emp.empno%type:=&p_empno;
  v_ename emp.ename%type;
  v_sal emp.sal%type;
begin
  select ename,sal into v_ename,v_sal from emp where empno=v_empno;
  dbms_output.put_line(v_ename||' '||v_sal);
end;
/
```

2. 创建存储过程 `get_ename`

```plsql
/* 创建存储过程 get_ename */
create or replace procedure get_ename
(p_empno in emp.empno%type,
p_ename out emp.ename%type,
p_sal out emp.sal%type)
is
begin
  select ename,sal into p_ename,p_sal from emp where empno=p_empno;
end;
/
```

3. 调用存储过程

调用方法1:

```plsql
declare
  g_ename emp.ename%type;
  g_sal emp.sal%type;
begin
  get_ename(7900,g_ename,g_sal);
  dbms_output.put_line(g_ename||' '||g_sal);
end;
/
```

调用方法2:

```plsql
var g_ename varchar2(10)
var g_sal number
exec get_ename(7900,:g_ename,:g_sal);
```

### 实践3-导入/导出型的形式参数


```plsql
create or replace procedure get_emp
(g_test in out varchar2)
is
begin
 select ename into g_test from emp where empno=g_test;
end;
/

declare
  v1 varchar2(10):=7839;
begin
  get_emp(v1);
  dbms_output.put_line(v1);
end;
/
```


### 实践4-带有default值的形式参数

```plsql
create or replace procedure add_emp
(p_ename emp.ename%type,
p_job emp.job%type default 'CLERK',
p_mgr emp.mgr%type default 7698,
p_hiredate date default sysdate,
p_sal emp.sal%type default 1000,
p_comm emp.comm%type default null,
p_deptno emp.deptno%type default 30)
is
begin
  insert into emp values
(seq_empno.nextval,
p_ename,
p_job,
p_mgr,
p_hiredate,
p_sal,
p_comm,
p_deptno);
end;
/
```

## 形参赋值

形参赋值的位置表示法：
```plsql
exec add_emp('Tom','SALESMAN');
```

形参赋值的名称表示法：
```plsql
exec add_emp(p_ename=>'Tom',p_job=>'SALESMAN',p_deptno=>20);
```

形参赋值的混合表示法：
```plsql
exec add_emp('Tom','SALESMAN',p_sal=>2000,p_mgr=>7839);
```

## 存储过程中的事务处理风格

```plsql
create or replace procedure add_sal
(p_empno number,p_sal number)
is
  v_old_sal emp.sal%type;
begin
  select sal into v_old_sal from emp where empno=p_empno;
  if p_sal<v_old_sal or p_sal is null then
    raise_application_error(-20000,'工资不能减少');
  else
    update emp set sal=p_sal where empno=p_empno;
    commit;
  end if;
end;
/
```

### 自治事务

```plsql
create or replace procedure add_sal
(p_empno number,p_sal number)
is
  pragma autonomous_transaction;
  v_old_sal emp.sal%type;
begin
  select sal into v_old_sal from emp where empno=p_empno;
  if p_sal<v_old_sal or p_sal is null then
    raise_application_error(-20000,'工资不能减少');
  else
    update emp set sal=p_sal where empno=p_empno;
    commit;
  end if;
end;
/
```

### 调用者模式

```plsql
create or replace procedure add_sal
(p_empno number,p_sal number)
authid current_user
is
  pragma autonomous_transaction;
  v_old_sal emp.sal%type;
begin
  select sal into v_old_sal from emp where empno=p_empno;
  if p_sal<v_old_sal or p_sal is null then
    raise_application_error(-20000,'工资不能减少');
  else
    update emp set sal=p_sal where empno=p_empno;
    commit;
  end if;
end;
/

declare
  v_empno number;
  v_time timestamp;
begin
  delete emp where empno=7369
  returning empno,current_timestamp into v_empno,v_time;
  dbms_output.put_line(v_empno||' '||v_time);
end;
/
```

### 动态sql语句

```plsql
create or replace procedure test_create
(t_name varchar2)
is
  v_sql varchar2(1000);
begin
  v_sql:='create table '||t_name||' (x int)';
  execute immediate v_sql;
end;
/

declare
  p_deptno number:=50;
  p_dname varchar2(10):='APP';
  p_loc varchar2(13):='BJ';
begin
  execute immediate 'insert into dept values (:1,:2,:3)' using p_deptno,p_dname,p_deptno;
end;
/

create or replace procedure test_create
(v_sql varchar2)
is

begin
  execute immediate v_sql;d
end;
/
```
