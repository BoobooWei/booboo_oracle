declare
  --私有变量声明
begin
  --代码主体
exception
  --异常处理
end;
/

set serveroutput on
declare
  v_message varchar2(50);
begin
  v_message := 'My First PL/Sql Block!';
  dbms_output.put_line(v_message);
end;
/

declare
  v_count CONSTANT number:=10;
begin
  dbms_output.put_line(v_count);
end;
/

declare
  v_dd date not null:=to_date('2016-09-20','yyyy-mm-dd');
begin
  dbms_output.put_line(v_dd);
end;
/

if条件判断：
declare
  v_flag number:=8000;
begin
  if v_flag<1000 then
    dbms_output.put_line('1');
  elsif v_flag>=1000 and v_flag<2000 then
    dbms_output.put_line('2');
  else
    dbms_output.put_line('3');
  end if;
end;
/

case分枝选择：
declare
  v_grade char:=upper('&p_grade');
  v_mess varchar2(30);
begin
  v_mess := case v_grade when 'A' then 'Excellent!'
                         when 'B' then '很好'
                         when 'C' then '好'
                         when 'D' then '一般'
           else '没有这样的等级' end;
  dbms_output.put_line(v_mess);
end;
/

循环遍历：
1.基本loop循环
declare
  v_count number:=0;
begin
  loop
    v_count:=v_count+1;
    exit when v_count>10;
    dbms_output.put_line(v_count);
  end loop;
end;
/

2.while循环
declare
  v_count number:=0;
begin
  while v_count<10 loop
    v_count:=v_count+1;
    dbms_output.put_line(v_count);
  end loop;
end;
/

3.for循环
begin
  for i in 1..10 loop
    dbms_output.put_line(i);
  end loop;
end;
/

begin
  for i in reverse 1..10 loop
    dbms_output.put_line(i);
  end loop;
end;
/

4.循环嵌套:
begin
  for i in 1..10 loop
    dbms_output.put(i||' ');
  end loop;
    dbms_output.put_line('');
end;
/

begin
  for m in 1..9 loop
    for n in 1..m loop
      dbms_output.put(n||'*'||m||'='||n*m||' ');
    end loop;
      dbms_output.put_line('');
  end loop;
end;
/

隔天取值
set serverout on
declare
  v date;
begin
  for i in 1..10 loop
    if mod(i,2)=1 then
      select to_date('2009-01-01','yyyy-mm-dd')+i into v from dual;
    end if;
  end loop;
end;
/

复合变量：
1.数组:保存表中一列数据
declare
  type empno_list is varray (5) of number;
  v_test empno_list;
begin
  v_test := empno_list();
  v_test.extend;
  v_test(1):='7369';
  v_test.extend(2);
  v_test(2):='7566';
  v_test(3):='7499';
  dbms_output.put_line(v_test(3));
  dbms_output.put_line(v_test.count);
end;
/

declare
  type empno_list is varray (5) of number;
  v_test empno_list;
begin
  v_test := empno_list();
  v_test.extend;
  select empno into v_test(1) from emp where ename='SCOTT';
  dbms_output.put_line(v_test(1));
end;
/

declare
  type ename_list is varray (100) of varchar2(10);
  v_test ename_list;
begin
  v_test := ename_list();
  select ename bulk collect into v_test from emp;
  for i in 1..v_test.count loop
    dbms_output.put_line(v_test(i));
  end loop;
end;
/
2.record：保存表中一行数据
declare
  type dept_record is record
  (deptno number(2),
   dname varchar2(10),
   loc varchar2(13));
  r_dept dept_record;
begin
  select * into r_dept from dept where deptno=10;
  dbms_output.put_line(r_dept.dname||' '||r_dept.loc);
end;
/

动态声明record：
declare
  r_dept dept%rowtype;
begin
  select * into r_dept from dept where deptno=10;
  dbms_output.put_line(r_dept.dname||' '||r_dept.loc);
end;
/

3.plsql表
declare
  type dept_table is table of varchar2(10) index by binary_integer;
  v_dept dept_table;
begin
  v_dept(100):='Beijing';
  v_dept(-1):='Shanghai';
  v_dept(0):='Shenzhen';
  dbms_output.put_line(v_dept(-1));
end;
/

declare
  type dept_table is table of dept%rowtype index by binary_integer;
  v_dept dept_table;
begin
  v_dept(100).loc:='Beijing';
  v_dept(-1).loc:='Shanghai';
  v_dept(0).loc:='Shenzhen';
  dbms_output.put_line(v_dept(-1).loc);
end;
/

declare
  v_count number;
  type dept_table is table of dept%rowtype index by binary_integer;
  v_dept dept_table;
begin
  select count(*) into v_count from dept;
  for i in 1..v_count loop
    select * into v_dept(i) from dept where deptno=i*10;
    dbms_output.put_line(v_dept(i).loc);
  end loop;
end;
/

非pl/sql变量:
var b1 number
begin
  select sal into :b1 from emp where ename='ALLEN';
end;
/

游标变量：声明 --> 打开 --> 获取 --> 关闭
declare
  cursor c1 is select * from dept;
  r1 c1%rowtype;
begin
  open c1;
  fetch c1 into r1;
  dbms_output.put_line(r1.loc);
  fetch c1 into r1;
  dbms_output.put_line(r1.loc);
  close c1;
end;
/

游标名字%rowcount
游标名字%found
游标名字%notfound
游标名字%isopen

declare
  cursor c1 is select * from dept;
  r1 c1%rowtype;
begin
  open c1;
  loop
    fetch c1 into r1;
    exit when c1%notfound;
    dbms_output.put_line(c1%rowcount);
    dbms_output.put_line(r1.loc);
  end loop;
  close c1;
end;
/

declare
  cursor c1 is select * from dept;
  r1 c1%rowtype;
begin
  open c1;
  loop
    fetch c1 into r1;
    exit when c1%rowcount>2;
    dbms_output.put_line(c1%rowcount);
    dbms_output.put_line(r1.loc);
  end loop;
  close c1;
end;
/

游标for循环
declare
  cursor c1 is select * from dept;
begin
  for r1 in c1 loop
    dbms_output.put_line(r1.loc);
  end loop;
end;
/



