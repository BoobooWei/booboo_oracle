### 子查询

[TOC]

#### 类型、语法和准则

| 序列                                        | 举例      |
| ------------------------------------------- | --------- |
| `rownum()`                                  | 1 2 3 4 5 |
| `rank() over (partition by order by)`       | 1 2 2 4 5 |
| `dense_rank() over (partition by order by)` | 1 2 2 3 4 |

```shell
select rank() over (partition by deptno order by sal desc) ord from emp;
# partition by 给结果集分组
# order by 给结果集排序
# rank() 在每个分组内部进行排名

select ename,sal,deptno from emp order by dbms_random.value();
# order by 排序
# dbms_random.value() 随即数

select * from (select rownum rn,a.* from (select * from emp order by sal desc) a) where rn between &p*5-4 and &p*5;
# &p 为自定义变量
```

* where 型
	- 单行 `= 、 != 、 > 、 < 、 <= 、 >=`等
	- 多行 `in、any、all`
* from 型
* exits 型

```shell
子查询3种{
	
	where 型{
		
		# 把内层查询的结果作为外层查询的比较条件
		# 查询最大、最贵商品
		
		查询最新的商品（以id最大为最新，不用order by）:{
			select goods_id,goods_name from goods where goods_id = (select max(goods_id) from goods);
		}
		每个栏目下最新的商品：{
			select cat_id,goods_id,goods_name from goods where goods_id in (select max(goods_id) from goods group by cat_id);	
		}
		每个栏目下最贵的商品：{
			select cat_id,goods_id,goods_name,shop_price from goods where shop_price in (select max(shop_price) from goods group by cat_id);
		}	
		
	}
	
	from 型{
		
		# 把内层查询的结果作为外层查询的临时表
		# 查询每个栏目下最新、最贵商品
		
		每个栏目下最新的商品：{
			select * from (select cat_id,goods_id,goods_name from goods order by cat_id,goods_id desc) as a group by cat_id;
		}
		
	}
	
	exits 型{
		
		# 把外层的查询结果，拿到内层，看内存查询是否成立
		# 查询有商品的栏目
		
		查有商品的栏目{
			select cat_id,cat_name from category where cat_id in (select cat_id from goods where cat_id in (select cat_id from category) group by cat_id);
			select cat_id,cat_name from category where exists (select * from goods where goods.cat_id = category.cat_id);
		}
	}
```

#### 案例

1. 工资高于BLAKE的？

```shell
SQL> select ename,sal from emp where sal > (select sal from emp where ename='BLAKE');

ENAME		  SAL
---------- ----------
JONES		 2975
SCOTT		 3000
KING		 5000
FORD		 3000
```

2. 工资最低的人？

```shell
SQL> select ename,sal from emp where sal = (select min(sal) from emp);

ENAME		  SAL
---------- ----------
SMITH		  800
```

3. 低于10部门最低工资的人？

```shell
SQL> select ename,sal from emp where sal < all (select sal from emp where deptno=10);

ENAME		  SAL
---------- ----------
WARD		 1250
MARTIN		 1250
ADAMS		 1100
JAMES		  950
SMITH		  800

SQL> select ename,sal from emp where sal < (select min(sal) from emp where deptno=10);

ENAME		  SAL
---------- ----------
SMITH		  800
WARD		 1250
MARTIN		 1250
ADAMS		 1100
JAMES		  950
```

4. 高于30部门最高工资的人？

```shell
SQL> select ename,sal from emp where sal > all (select sal from emp where deptno=30);

ENAME		  SAL
---------- ----------
JONES		 2975
SCOTT		 3000
FORD		 3000
KING		 5000

SQL> select ename,sal from emp where sal > (select max(sal) from emp where deptno=30);

ENAME		  SAL
---------- ----------
JONES		 2975
SCOTT		 3000
KING		 5000
FORD		 3000
```

5. 工资相同的人？

```shell
SQL> select a.ename,b.ename,a.sal from emp a ,emp b where a.sal=b.sal and a.ename!=b.ename; 

ENAME	   ENAME	     SAL
---------- ---------- ----------
MARTIN	   WARD 	    1250
WARD	   MARTIN	    1250
FORD	   SCOTT	    3000
SCOTT	   FORD 	    3000

```

6. blake的工资是smith的几倍？

```shell
SQL> select (select sal from emp where ename='BLAKE')/(select sal from emp where ename='SMITH') "B-S" from dual;

       B-S
----------
    3.5625
```

7. 每个部门工资最高的人？

```shell
SQL> select deptno,ename,sal from emp where sal in (select max(sal) from emp group by deptno) order by deptno ;

    DEPTNO ENAME	     SAL
---------- ---------- ----------
	10 KING 	    5000
	20 FORD 	    3000
	20 SCOTT	    3000
	30 BLAKE	    2850

SQL> select ename,deptno,sal,rank () over (partition by deptno order by sal desc) Ord from emp;

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
KING		   10	    5000	  1
CLARK		   10	    2450	  2
MILLER		   10	    1300	  3
SCOTT		   20	    3000	  1
FORD		   20	    3000	  1
JONES		   20	    2975	  3
ADAMS		   20	    1100	  4
SMITH		   20	     800	  5
BLAKE		   30	    2850	  1
ALLEN		   30	    1600	  2
TURNER		   30	    1500	  3

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
MARTIN		   30	    1250	  4
WARD		   30	    1250	  4
JAMES		   30	     950	  6

14 rows selected.

SQL> select * from (select ename,deptno,sal,rank () over (partition by deptno order by sal desc) Ord from emp) where ord<=1;

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
KING		   10	    5000	  1
SCOTT		   20	    3000	  1
FORD		   20	    3000	  1
BLAKE		   30	    2850	  1

```

8. 每个部门工资最高的前2个人？

```shell
SQL> select * from (select ename,deptno,sal,rank () over (partition by deptno order by sal desc) Ord from emp) where ord<=2;

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
KING		   10	    5000	  1
CLARK		   10	    2450	  2
SCOTT		   20	    3000	  1
FORD		   20	    3000	  1
BLAKE		   30	    2850	  1
ALLEN		   30	    1600	  2

6 rows selected.
```


9. 工资最高的前5行？ 

```shell
SQL> select * from (select ename,deptno,sal,rank () over (order by sal desc) ord from emp) where ord <=5 ;

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
KING		   10	    5000	  1
SCOTT		   20	    3000	  2
FORD		   20	    3000	  2
JONES		   20	    2975	  4
BLAKE		   30	    2850	  5

SQL> select * from (select ename,deptno,sal from emp order by sal desc) where rownum < 6;

ENAME	       DEPTNO	     SAL
---------- ---------- ----------
KING		   10	    5000
SCOTT		   20	    3000
FORD		   20	    3000
JONES		   20	    2975
BLAKE		   30	    2850


```

10. 工资6～10名？

```shell
SQL> select * from (select ename,deptno,sal,rank () over (order by sal desc) ord from emp) where ord between 6 and 10 ;

ENAME	       DEPTNO	     SAL	ORD
---------- ---------- ---------- ----------
CLARK		   10	    2450	  6
ALLEN		   30	    1600	  7
TURNER		   30	    1500	  8
MILLER		   10	    1300	  9
WARD		   30	    1250	 10
MARTIN		   30	    1250	 10

6 rows selected.
```

11. 随机从表中取出3行数据？

```shell
SQL> select ename,sal,deptno from emp order by dbms_random.value();

ENAME		  SAL	  DEPTNO
---------- ---------- ----------
SMITH		  800	      20
FORD		 3000	      20
BLAKE		 2850	      30
CLARK		 2450	      10
TURNER		 1500	      30
ALLEN		 1600	      30
MILLER		 1300	      10
JONES		 2975	      20
MARTIN		 1250	      30
KING		 5000	      10
SCOTT		 3000	      20

ENAME		  SAL	  DEPTNO
---------- ---------- ----------
ADAMS		 1100	      20
WARD		 1250	      30
JAMES		  950	      30

14 rows selected.

SQL> select * from (select ename,sal,deptno from emp order by dbms_random.value()) where rownum <= 3;

ENAME		  SAL	  DEPTNO
---------- ---------- ----------
WARD		 1250	      30
MARTIN		 1250	      30
TURNER		 1500	      30

SQL> select * from (select ename,sal,deptno from emp order by dbms_random.value()) where rownum <= 3;

ENAME		  SAL	  DEPTNO
---------- ---------- ----------
SCOTT		 3000	      20
MILLER		 1300	      10
WARD		 1250	      30
```

12. 查询雇员的姓名，工资，税，(1级不缴税，2-->2% ,3-->3%,4-->4%,5-->5%)

```shell
SQL> select ename,sal,grade,decode(grade,1,0,2,sal*0.02,3,sal*0.03,4,sal*0.04,5,sal*0.05) T from emp,salgrade where emp.sal between salgrade.losal and salgrade.hisal;

ENAME		  SAL	   GRADE	  T
---------- ---------- ---------- ----------
SMITH		  800	       1	  0
JAMES		  950	       1	  0
ADAMS		 1100	       1	  0
WARD		 1250	       2	 25
MARTIN		 1250	       2	 25
MILLER		 1300	       2	 26
TURNER		 1500	       3	 45
ALLEN		 1600	       3	 48
CLARK		 2450	       4	 98
BLAKE		 2850	       4	114
JONES		 2975	       4	119

ENAME		  SAL	   GRADE	  T
---------- ---------- ---------- ----------
SCOTT		 3000	       4	120
FORD		 3000	       4	120
KING		 5000	       5	250

14 rows selected.

```

13. 部门总工资和部门上缴个税总和

```shell
SQL> select deptno,sum(sal),sum(T) from (select deptno,ename,sal,grade,decode(grade,1,0,2,sal*0.02,3,sal*0.03,4,sal*0.04,5,sal*0.05) T from emp,salgrade where emp.sal between salgrade.losal and salgrade.hisal) group by deptno;

    DEPTNO   SUM(SAL)	  SUM(T)
---------- ---------- ----------
	30	 9400	     257
	20	10875	     359
	10	 8750	     374
```

14. 比WARD奖金低的人？

```shell
SQL> select ename,comm from emp where nvl(comm,0) < (select comm from emp where ename='WARD');

ENAME		 COMM
---------- ----------
SMITH
ALLEN		  300
JONES
BLAKE
CLARK
SCOTT
KING
TURNER		    0
ADAMS
JAMES
FORD

ENAME		 COMM
---------- ----------
MILLER

12 rows selected.

```

15. 奖金最高的前两名雇员？

```shell
SQL> select * from (select ename,comm from emp order by nvl(comm,0) desc) where rownum <= 2;

ENAME		 COMM
---------- ----------
MARTIN		 1400
WARD		  500


SQL> select * from (select ename,nvl(comm,0),rank () over (order by nvl(comm,0) desc) ord from emp) where ord <= 2;

ENAME	   NVL(COMM,0)	      ORD
---------- ----------- ----------
MARTIN		  1400		1
WARD		   500		2
```

16. 工资高于本部门平均工资的人？

```shell
SQL> select e.deptno,e.ename,e.sal from emp e,(select deptno,avg(sal) asal from emp group by deptno) b where e.deptno=b.deptno and e.sal > b.asal; 

    DEPTNO ENAME	     SAL
---------- ---------- ----------
	30 BLAKE	    2850
	30 ALLEN	    1600
	20 FORD 	    3000
	20 SCOTT	    3000
	20 JONES	    2975
	10 KING 	    5000

6 rows selected.
```


#### 课后练习


```shell

select deptno,ename, sal 
from emp
where sal in (select max(sal) from emp group by deptno) or
sal in (select max(sal) 
       from (select sal,deptno 
             from emp where sal not in 
                      (select max(sal) from emp group by deptno)) group by deptno)
order by 1;

select ename,deptno,sal from emp e where (select count(*) from emp where sal>e.sal and deptno=e.deptno)<2;

select count(*) from emp where sal>800 and deptno=20;

select * from (select ename,deptno,sal,rank () over (partition by deptno order by sal desc) Ord from emp) where ord<=2;

select ename,deptno,sal,row_number () over (partition by deptno order by sal desc) Ord from emp;

select * from (select rownum rn,a.* from (select ename,sal from emp order by sal desc) a) where rn between 6 and 10;

select * from (select * from emp order by dbms_random.value()) where rownum<=3;

查询雇员的姓名，工资，税，(1级不缴税，2-->2% ,3-->3%,4-->4%,5-->5%)
select 
  e.ename,
  e.sal,
  (sal*decode(s.grade,1,0,2,0.02,3,0.03,4,0.04,5,0.05,0)) tax
from emp e,salgrade s 
where e.sal between s.losal and s.hisal;

部门总工资和部门上缴个税总和
select deptno,sum(sal),sum(tax)
from
(select 
  e.sal,
  (sal*decode(s.grade,1,0,2,0.02,3,0.03,4,0.04,5,0.05,0)) tax,
  deptno
from emp e,salgrade s 
where e.sal between s.losal and s.hisal)
group by deptno;

比WARD奖金低的人？
select ename,comm from emp where NVL(comm,0)<(select comm from emp where ename='WARD');

select ename,comm from emp where comm<(select comm from emp where ename='WARD') or comm is null;

奖金最高的前两名雇员？
select * from (select ename,comm from emp order by comm desc nulls last) where rownum<=2;

select * from (select ename,comm from emp where comm is not null order by comm desc) where rownum<=2;

工资高于本部门平均工资的人？

使用替代变量进行分页查询
select * from (select rownum rn,a.* from (select * from emp order by sal desc) a)
where rn between &p*5-4 and &p*5;
```


### oracle的pause命令 

> 暂停屏幕输出


```shell
# 查看当前pause的状态为off
SQL> show pause;
PAUSE is OFF

# 将pasue设置为开启状态 on
SQL> set pause on;
SQL> show pause;
PAUSE is ON and set to ""

# 查看当前设置的pagesize的大小，即每页显示多少行
SQL> show pagesize;
pagesize 14

# 修改pagesize为10，每页显示10行
SQL> set pagesize 10;

# 执行查询语句
SQL> select rownum rn,ename,sal from emp;
# 需要输入enter健

	RN ENAME	     SAL
---------- ---------- ----------
	 1 SMITH	     800
	 2 ALLEN	    1600
	 3 WARD 	    1250
	 4 JONES	    2975
	 5 MARTIN	    1250
	 6 BLAKE	    2850
	 7 CLARK	    2450
# 需要输入enter健

	RN ENAME	     SAL
---------- ---------- ----------
	 8 SCOTT	    3000
	 9 KING 	    5000
	10 TURNER	    1500
	11 ADAMS	    1100
	12 JAMES	     950
	13 FORD 	    3000
	14 MILLER	    1300

14 rows selected.
```


### oracle的sqlplus执行shell命令

> spool

```shell
# 执行shell命令 pwd 打印当前路径
SQL> host pwd
/home/oracle

# 执行shell命令 free 查看当前内存使用情况
SQL> host free
             total       used       free     shared    buffers     cached
Mem:       2058756     937308    1121448          0      49720     683304
-/+ buffers/cache:     204284    1854472
Swap:      4095992          0    4095992
```


### oracle的保存执行的sql语句

```shell
# 在但前目录下创建booboo.lst文件保存sql
SQL> spool booboo append
# 执行sql查询
SQL> select * from (select ename,nvl(comm,0),rank () over (order by nvl(comm,0) desc) ord from emp) where ord <= 2;


ENAME	   NVL(COMM,0)	      ORD
---------- ----------- ----------
MARTIN		  1400		1
WARD		   500		2
# 执行sql查询
SQL> select deptno,sum(sal),sum(T) from (select deptno,ename,sal,grade,decode(grade,1,0,2,sal*0.02,3,sal*0.03,4,sal*0.04,5,sal*0.05) T from emp,salgrade where emp.sal between salgrade.losal and salgrade.hisal) group by deptno;


    DEPTNO   SUM(SAL)	  SUM(T)
---------- ---------- ----------
	30	 9400	     257
	20	10875	     359
	10	 8750	     374
# 关闭spool
SQL> spool off

# 查看当前目录下的文档
SQL> host ls
booboo.lst  rlwrap-0.30-1.el5.i386.rpm

# 打印booboo.lst到屏幕上
SQL> host cat booboo.lst
SQL> select * from (select ename,nvl(comm,0),rank () over (order by nvl(comm,0) desc) ord from emp) where ord <= 2;

ENAME      NVL(COMM,0)        ORD                                               
---------- ----------- ----------                                               
MARTIN            1400          1                                               
WARD               500          2                                               

SQL> select deptno,sum(sal),sum(T) from (select deptno,ename,sal,grade,decode(grade,1,0,2,sal*0.02,3,sal*0.03,4,sal*0.04,5,sal*0.05) T from emp,salgrade where emp.sal between salgrade.losal and salgrade.hisal) group by deptno;

    DEPTNO   SUM(SAL)     SUM(T)                                                
---------- ---------- ----------                                                
        30       9400        257                                                
        20      10875        359                                                
        10       8750        374                                                

SQL> spool off
SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options


[oracle@oracle0 ~]$ ls
booboo.lst  rlwrap-0.30-1.el5.i386.rpm
[oracle@oracle0 ~]$ cat booboo.lst 
SQL> select * from (select ename,nvl(comm,0),rank () over (order by nvl(comm,0) desc) ord from emp) where ord <= 2;

ENAME      NVL(COMM,0)        ORD                                               
---------- ----------- ----------                                               
MARTIN            1400          1                                               
WARD               500          2                                               

SQL> select deptno,sum(sal),sum(T) from (select deptno,ename,sal,grade,decode(grade,1,0,2,sal*0.02,3,sal*0.03,4,sal*0.04,5,sal*0.05) T from emp,salgrade where emp.sal between salgrade.losal and salgrade.hisal) group by deptno;

    DEPTNO   SUM(SAL)     SUM(T)                                                
---------- ---------- ----------                                                
        30       9400        257                                                
        20      10875        359                                                
        10       8750        374                                                

SQL> spool off

```

