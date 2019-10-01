异常处理:
捕获系统预定义异常
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

declare
  v_ename emp.ename%type;
  v_sal emp.sal%type;
/*
-1:未选定行
*/
  v_err number;
begin
  select ename,sal into v_ename,v_sal from emp where deptno=&p_deptno;
  v_err:=0;
    dbms_output.put_line(v_err);
exception
  when no_data_found then
    v_err:=-1;
    dbms_output.put_line(v_err);
end;
/

处理非预定义异常：
declare
  myerr exception;
  pragma exception_init(myerr,-2291);
  v_ename emp.ename%type;
  v_sal emp.sal%type;
/*
-1:未选定行
*/
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

异常处理的作用
declare
  v_sal number;
begin
  declare
    myerr exception;
    pragma exception_init(myerr,-2291);
    v_deptno number:=&p_deptno;
    v_ename varchar2(10);
  begin
    select ename into v_ename from emp where empno=1;
    delete dept;
    update emp set deptno=v_deptno where empno=7839;
  exception
    when myerr then
      dbms_output.put_line('外键取值错误');
    when others then
--      dbms_output.put_line('未知错误');  
      dbms_output.put_line(sqlcode||' ; '||sqlerrm);  
  end;

  select sal into v_sal from emp where empno=&p_empno;
  dbms_output.put_line(v_sal);
end;
/

使用函数sqlerrm打印ORA-消息描述：
declare
  errm varchar2(1000);
begin
  for errno in 20000..20999 loop
    errm:=sqlerrm(-errno);
    dbms_output.put_line(errm);
  end loop;
end;
/

使用自定义异常：
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
----------------------------------------------------------------
#######
#命名块#
#######
1.存储过程：procedure
--匿名块
begin
  update emp set sal=sal*1.1;
end;
/

--将匿名块创建成 procedure : add_sal
create or replace procedure add_sal
is
  --变量声明
begin
  update emp set sal=sal*1.1;
end;
/

调用命名块：
begin
  add_sal;
end;
/

execute add_sal;
exec add_sal;

根据雇员编号涨工资：
declare
  v_empno emp.empno%type := &p_empno;
  v_sal emp.sal%type := &p_sal;
begin
  update emp set sal=v_sal where empno=v_empno;
end;
/

declare
  v_empno emp.empno%type := &p_empno;
  v_sal emp.sal%type := &p_sal;
  v_old_sal emp.sal%type;
begin
  select sal into v_old_sal from emp where empno=v_empno;
  if v_sal<v_old_sal or v_sal is null then
    raise_application_error(-20000,'工资不能减少');
  else
    update emp set sal=v_sal where empno=v_empno;
  end if;
end;
/

带有导入型形式参数的procedure：
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

查看程序源代码：
select text from user_source where name='ADD_SAL';

带有导出型形式参数的procedure：
declare
  v_empno emp.empno%type:=&p_empno;
  v_ename emp.ename%type;
  v_sal emp.sal%type;
begin
  select ename,sal into v_ename,v_sal from emp where empno=v_empno;
  dbms_output.put_line(v_ename||' '||v_sal);
end;
/

create or replace procedure get_ename
(p_empno in emp.empno%type,
p_ename out emp.ename%type,
p_sal out emp.sal%type)
is
begin
  select ename,sal into p_ename,p_sal from emp where empno=p_empno;
end;
/

declare
  g_ename emp.ename%type;
  g_sal emp.sal%type;
begin
  get_ename(7900,g_ename,g_sal);
  dbms_output.put_line(g_ename||' '||g_sal);
end;
/

var g_ename varchar2(10)
var g_sal number
exec get_ename(7900,:g_ename,:g_sal);
print

导入/导出型的形式参数：
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

var b1 varchar2(10)

带有default值的形式参数
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

形参赋值的位置表示法：
exec add_emp('Tom','SALESMAN');
形参赋值的名称表示法：
exec add_emp(p_ename=>'Tom',p_job=>'SALESMAN',p_deptno=>20);
形参赋值的混合表示法：
exec add_emp('Tom','SALESMAN',p_sal=>2000,p_mgr=>7839);

存储过程中的事务处理风格：
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

自治事务：
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

调用者模式：
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

动态sql语句：
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





