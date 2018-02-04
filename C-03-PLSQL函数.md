######
#函数#
######
函数一定要有返回值！

create or replace function tax 
(p_sal number)
return number
is
begin
  return p_sal*0.05;
end;
/

select ename,sal,tax(sal) from emp;

grade 1 --> 0
grade 2 --> 0.05
grade 3 --> 0.07
grade 4 --> 0.1
grade 5 --> 0.12

create or replace function tax 
(p_sal number)
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

获取指定部门的工资总和
create or replace function subtotal
(p_deptno number)
return number
is
  v_total number;
begin
  select sum(sal) into v_total from emp where deptno=p_deptno;
  return v_total;
end;
/

使用函数校验部门存在否 return boolean
create or replace function valid_deptno
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
/

将校验本门存在否的函数引入到add_emp代码中，值有函数为true才可以添加新雇员
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

确定性函数（确定返回值函数）：
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

####
#包#
####
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

wrap iname=1.sql --> 1.plb 

#######
#触发器#
#######
表级别的触发器
create or replace trigger sec_dept
before delete on dept
begin
  dbms_output.put_line('ok');
end;
/

create or replace trigger sec_dept
after delete on dept
begin
  dbms_output.put_line('ok');
end;
/

create or replace trigger sec_emp
before insert or update or delete on emp
declare
  pragma autonomous_transaction;
begin
  if inserting then
    dbms_output.put_line('有数据被插入');
  elsif updating then
    dbms_output.put_line('有数据被修改');
  elsif deleting then 
    dbms_output.put_line('有数据被删除');
  end if;
  commit;
end;
/

ORA-04092: cannot COMMIT in a trigger

SELECT TRIGGER_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,TABLE_NAME,STATUS FROM USER_TRIGGERS;

ALTER TRIGGER sec_emp DISABLE;
ALTER TRIGGER sec_emp ENABLE;

select text from user_source where name='SEC_EMP';

create or replace procedure test_emp
(p_empno number)
is
begin
  execute immediate 'insert into emp (empno) values (:1)' using p_empno;
end;
/

create or replace trigger sec_emp_delete
before delete on emp
declare
  v_user varchar2(30);
begin
  select sys_context('userenv','session_user') into v_user from dual;
  if v_user<>'SCOTT' then
    raise_application_error(-20000,'雇员不能被解雇！');
  end if;
end;
/

行级触发器：
create or replace trigger sec_emp
before insert or update or delete on emp for each row
declare
  pragma autonomous_transaction;
begin
  if inserting then
    dbms_output.put_line('有数据被插入');
  elsif updating then
    dbms_output.put_line('有数据被修改');
  elsif deleting then 
    dbms_output.put_line('有数据被删除');
  end if;
  commit;
end;
/

create or replace trigger sec_emp
before update on emp for each row
begin
  dbms_output.put_line(:old.sal||' '||:new.sal);
end;
/

create table d as select * from dept;
create table e as select * from emp;

在周六和周日禁止对emp表insert、update、delete

DDL触发器：
create table log_ddl 
(LOGON_FROM VARCHAR2(10),
LOGON_TIME TIMESTAMP,
action varchar2(10),
OBOWNER VARCHAR2(10),
OBTYPE VARCHAR2(10),
OBNAME VARCHAR2(10));

CREATE OR REPLACE TRIGGER trigger_drop
before drop
ON schema
begin
  insert into scott.log_ddl values 
(SYS.LOGIN_USER,
CURRENT_TIMESTAMP,
'DROP',
SYS.DICTIONARY_OBJ_OWNER,
SYS.DICTIONARY_OBJ_TYPE,
SYS.DICTIONARY_OBJ_NAME);
end;
/

create table log_on (username varchar2(15),action varchar2(10),logon_time timestamp);

create or replace trigger logon_scott
after logon on schema
declare
  v_user varchar2(15); 
begin
  select sys_context('userenv','current_user') into v_user from dual;
  insert into log_on values (v_user,'logon',current_timestamp);
end;
/

create or replace trigger logoff_scott
before logoff on schema
declare
  v_user varchar2(15); 
begin
  select sys_context('userenv','current_user') into v_user from dual;
  insert into log_on values (v_user,'logoff',current_timestamp);
end;
/

conn / as sysdba
CREATE OR REPLACE TRIGGER TRIGGER_RESTRICT_LOGON
AFTER LOGON ON DATABASE
DECLARE
 RESTRICTED_USER VARCHAR2(32) := 'SCOTT';
 ALLOWED_IP      VARCHAR2(16) := '172.25.4.11';
 LOGON_USER      VARCHAR2(32);
 CLIENT_IP       VARCHAR2(16);
BEGIN
 LOGON_USER := SYS_CONTEXT('USERENV','SESSION_USER');
 CLIENT_IP  := NVL(SYS_CONTEXT('USERENV','IP_ADDRESS'), 'NULL');
  IF LOGON_USER = RESTRICTED_USER AND CLIENT_IP <> ALLOWED_IP THEN
   RAISE_APPLICATION_ERROR(-20001, RESTRICTED_USER || ' is not allowed to connect from ' || CLIENT_IP ||' ip address!');
 END IF;
END;
/

