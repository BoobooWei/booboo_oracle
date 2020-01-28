# PLSQL-命名块-函数

> 2020.01.28 BoobooWei

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [PLSQL-命名块-函数](#plsql-命名块-函数)   
   - [创建自定义函数语法](#创建自定义函数语法)   
   - [使用自定义函数](#使用自定义函数)   
   - [实践](#实践)   
      - [实践1-根据工资等级交税](#实践1-根据工资等级交税)   
      - [实践2-获取指定部门的工资总和](#实践2-获取指定部门的工资总和)   
      - [实践3-使用函数校验部门存在否](#实践3-使用函数校验部门存在否)   
      - [实践4-部门存在才可以添加新雇员](#实践4-部门存在才可以添加新雇员)   
      - [实践4-确定性函数（确定返回值函数）](#实践4-确定性函数（确定返回值函数）)   

<!-- /MDTOC -->


通过 PL / SQL 实现自定义函数，注意：函数一定要有返回值！

## 创建自定义函数语法

```plsql
create or replace function tax(p_sal number)
return number
is
begin
  return p_sal*0.05;
end;
/
```

## 使用自定义函数

```PLSQL
select ename,sal,tax(sal) from emp;
```

## 实践

### 实践1-根据工资等级交税

要求：
* 按照以下等级交税

```
grade 1 --> 0
grade 2 --> 0.05
grade 3 --> 0.07
grade 4 --> 0.1
grade 5 --> 0.12
```

```PLSQL
create or replace function tax(p_sal number)
return number
is
  v_grade number;
  v_tax number;
begin
  select grade into v_grade from salgrade where p_sal between losal and hisal;
  v_tax := case v_grade when 1 then 0
                        when 2 then p_sal*0.05
                        when 3 then p_sal*0.07
                        when 4 then p_sal*0.1
                        when 5 then p_sal*0.05
          else null end;
  return v_tax;
end;
/
```


### 实践2-获取指定部门的工资总和

```PLSQL
create or replace function subtotal(p_deptno number)
return number
is
  v_total number;
begin
  select sum(sal) into v_total from emp where deptno=p_deptno;
  return v_total;
end;
/
```

### 实践3-使用函数校验部门存在否

* 校验部门存在否
* return boolean


```PLSQL
create or replace function valid_deptno(p_deptno number)
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
/
```

### 实践4-部门存在才可以添加新雇员

```PLSQL
create or replace procedure add_emp
(p_ename emp.ename%type,
p_job emp.job%type default 'CLERK',
p_mgr emp.mgr%type default 7698,
p_hiredate date default sysdate,
p_sal emp.sal%type default 1000,
p_comm emp.comm%type default null,
p_deptno emp.deptno%type default 30
)
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
/

create or replace function get_ename
(p_empno number,
p_ename out varchar2)
return number
is
  v_sal number;
begin
  select ename,sal into p_ename,v_sal from emp where empno=p_empno;
  return v_sal;
end;
/

var g_ename varchar2(10)
var g_sal number
exec :g_sal:=get_ename(7369,:g_ename);
```




### 实践4-确定性函数（确定返回值函数）

```PLSQL
create or replace function test_wait
(p_char varchar2)
return varchar2
is
begin
  dbms_lock.sleep(1);
  return p_char;
end;
/

select * from t01 where test_wait(x)='A';

create or replace function test_wait_2
(p_char varchar2)
return varchar2 deterministic
is
begin
  dbms_lock.sleep(1);
  return p_char;
end;
/
```
