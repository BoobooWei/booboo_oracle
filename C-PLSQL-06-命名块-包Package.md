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
