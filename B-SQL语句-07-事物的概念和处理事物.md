### 事务的概念和事务事物

[toc]

#### 数据库事务

Oracle服务器基于事务保证数据的一致性。当改变数据的时候,事务给你更加灵活的控制,并且在发生用户进程错误或者系统错误的情况下,保证事件中数据的一致性。

事务是由保证对数据改变一致性的DML语句组成。举例来说,两个帐户之间的资金转帐应当保证借方帐户和贷方帐户之间数额一样。两个动作应该同时成功或者失败。没有借方贷方不能够提交。

#### 事务的类型

|类型| 描述|
|:--|:--|
|数据操纵语言(DML)| 由一定数量的 DML 命令组成, Oracle服务器将他们视为单一实体或者一个逻辑单元|
|数据定义语言(DDL)| 只由一个 DDL 语言组成|
|数据控制语言(DCL)| 只有一个 DCL 语言组成|


#### 事务何时开始和结束?

当遇到第一个 DML 命令事务开始,遇到下面的情况事务结束:

1. COMMIT 或者 ROLLBACK 命令被执行
2. 一个 DDL 命令,比如 CREATE 被执行
3. 一个DCL命令被执行
4. 用户退出 iSQL*Plus
5. 机器发生错误或者系统崩溃

在一个事务结束后,下一个执行的 SQL 命令自动开始一个新的事务。

DDL命令或者DCL命令是自动提交的,因此是显式的结束一个事务。

#### 外在事务控制命令

你可以使用 COMMIT, SAVEPOINT 和 ROLLBACK 命令控制事务的逻辑.

|命令| 描述|
|:--|:--|
|COMMIT |通过对当前所有未决的数据永久性改变,结束事务|
|SAVEPOINT name| 对当前的事务做一个检查点|
|ROLLBACK| 通过放弃所有未决的数据改变 ROLLBACK当前的事务|
|ROLLBACK TO SAVEPOINT name|ROLLBACK TO SAVEPOINT回退当前的事务到指定的检查点。因此在你即将回退到的检查点之后创建的检查点和所作的改变都会被放弃|

注意: SAVEPOINT 不是一个标准的 ANSI SQL.

#### 回退改变到标记处

你可以使用 SAVEPOINT 命令在当前会话中创建一个标记,将一个事务分成几个部分。你可以使用 ROLLBACK TO SAVEPOINT 丢弃所有未决的改变到标记处。

如果你创建的第二个检查点的名称和第一个相同,那么早前的检查点就会被删除。

#### 隐式事务处理

|状态| 环境|
|:--|:--|
|自动提交||
|自动回退||

> 注意:在 iSQL*Plus 中第三个命令 AUTOCOMMIT 可以将其关闭或者打开。如果设置成为打开的状态,每个独立的 DML 命令只要一执行就会被提交。你不能回退这个变化。如果设置成关, COMMIT 命令仍旧需要显式的执行。当你执行 DDL 命令或者当你退出iSQL*Plus ,COMMIT命令就会被执行。

> 系统失败:当由于一个系统的错误导致一个事务中断,整个事务将会被自动回退。这个将会阻止对数据不期望的改变发生,并将表恢复到最后一次提交前的状态。通过这种方式, Oracle 服务器保证数据的完整性。

在 iSQL*Plus ,单击 Exit 按钮完成从一个会话中的正常退出。使用 SQL*Plus ,通过在提示符下面输入 EXIT 命令完成一个正常的退出。关闭窗口被认为是一个不正常的退出。

#### 提交改变

直到事务提交之前,事务期间对数据所做的改变都是临时的。

在 COMMIT 或者 ROLLBACK 命令执行前数据的状态是:

1. 数据操作主要影响数据库的缓冲区;因此先前的数据状态可以被恢复。
2. 当前的用户通过查询表可以预览对数据操作的结果。
3. 其他的用户不能够浏览当前用户对数据操作的结果。 Oracle 服务器制定的读一致性是确保每个用户看到的是自上一次提交后的数据。
4. 受影响的行被锁定;其他的用户不能够改变受影响行的数据。

使用 COMMIT 命令可以使所有未决的改变永久化。在 COMMIT 命令执行之后:
1. 数据的改变被写入到数据库中
1. 先前数据的状态永久性的丢失
3. 所有的用户可以浏览事务的结果
4. 受影响行上面的锁被释放;对于其他用户来说,该行现在可以被执行新的数据修改。
5. 所有的检查点被清除

#### 回退改变

通过执行 ROLLBACK 命令回退所有未决的改变。 ROLLBACK 命令执行后:
1. 数据的改变被撤销
2. 先前的数据状态被还原
3. 受影响的行上面的锁被释放


#### 语句级回退

如果执行的语句检测到一个错误,事务的一部分可以通过隐式回退被丢弃。如果单独的一个DML语句在事务期间失败,它的影响通过语句级的回退被撤销。但是事务中先前的DML语句所做的改变不会被丢弃。他们会被用户显式的提交或者回退。

Oracle 服务器在任何的数据定义语言(DDL)执行后都会执行一个隐式的提交。因此,即使你的DDL语句没有执行成功,你也不能回退先前的语句,因为服务器已经执行了一个提交。

通过执行 COMMIT 或者 ROLLBACK 命令显式的终结你的事务。

#### 读一致性

数据库用户访问数据库有两种方式:
1. 读操作( SELECT 命令)
2. 写操作( INSERT, UPDATE 和 DELETE 命令)

你需要读一致性以便下面的发生:

1. 数据库读和写被确保数据的一致性视图
2. 读取不会看到数据正在被修改的进程
3. 写将会确保对数据库的操作一致性
4. 一个写入所作的改变不会破坏或者和其他的写入冲突

读一致性的目的就是在DML操作开始之前,确保每个用户看到的是最后一次提交后数据存在的状态。


#### 读一致性的执行

读一致性是自动执行的。它保存数据库拷贝的一部分在回退段中。当一个插入,更新或者删除操作被执行,数据库会在数据被改变并写入到回退段之前做一个数据的拷贝。

所有的读取,除了执行改变的那个,仍旧看到变化开始之前的数据库存在的状态;他们看到的是回退段中数据的快照。

在改变被提交给数据库之前,只有修改数据的用户能够看到数据库的改变。其他的所有人看到的都是回退段中的快照。这个可以保证读取到数据一致的数据读取不会经历改变。

当一个DML语句被提交,对数据库所做的改变多于任何执行 SELECT 命令的用户都是看见的。被“老的”数据占用的回退段中的空间被释放以便重新使用。

如果事务被回退,改变将会被撤销
1. 原始的,回退段中旧有的数据将会被写回到表中
2. 所有的用户看到的是事务开始之前的数据库存在的状态


#### 什么是锁?

锁是一种机制,防止访问同一个资源的事物之间的破坏性的冲突。同一个资源或者是一个用户的对象(比如说表和视图)或者对于用户不可见的系统对象(比如共享的数据结构或者数据字典行)

Oracle 数据库是如何锁数据的?

锁是自动执行,不需要用户干预的。对于SQL命令隐式锁是必需的,这取决于所需的操作。

除了 SELECT 命令隐式锁对所有的SQL命令都发生。

用户可以手动锁定数据,这个称为显示锁。



#### DML 锁

当执行数据操纵语言(DML)操作的时候, Oracle 服务器通过 DML 锁提供数据同时访问,DML 锁发生在两个级别:
1. DML操作期间在表级共享锁是自动获得的。共享锁模式,几个事务可以取得同一资源的共享锁。
2. 被DML命令修改的每行自动获得一个独占锁。独占锁防止被修改的行被其他的事务修改,直到该事务被提交或者回滚。该锁确保没有其他的用户在同一时间修改同一行,并覆盖掉被另一个用户所作的还没有提交的改变。

注意: DDL 发生在当你修改数据库对象的时候,比如说一张表。


#### 应用示例

1. 事务的提交和回滚

```shell
SQL> insert into booboo select * from emp where empno=900;

1 row created.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10

SQL> roll back;
Rollback complete.
SQL> select * from booboo;

no rows selected

SQL> insert into booboo select * from emp where empno=900;

1 row created.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10

SQL> savepoint t1;

Savepoint created.

SQL> insert into booboo select * from emp where empno=7782;

1 row created.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10

SQL> savepoint t2;

Savepoint created.

SQL> insert into booboo select * from emp where empno=7839;

1 row created.

SQL> savepoint t3;

Savepoint created.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10

SQL> insert into booboo select * from emp where empno=7934;

1 row created.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10
      7934 MILLER     CLERK	      7782 23-JAN-82	   1300 		   10

SQL> rollback to savepoint t3;

Rollback complete.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10
      7839 KING       PRESIDENT 	   17-NOV-81	   5000 		   10

SQL> rollback to savepoint t2;

Rollback complete.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450 		   10

SQL> rollback to savepoint t1;

Rollback complete.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10

```

2. 读一致性


oracle默认的事务隔离级别为RC 已提交读，还支持串行读

事务未提交时，只有事务内部可见

```shell
# oracle做任何操作都会有一个时间
# 比如用户9：00开始查询，9：30才结束查询，在9：15进行了写操作，写操作对9点查询来说不应该读到
# oracle中通过SCN（system change number）系统变更号来做标记，就相当于时间，伴随着所有操作
# SCN是oracle中顺序增长的一个数字，用来精确区别操作的先后顺序，使用6字节 48位 来记录

SQL> conn / as sysdba
Connected.
SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1290680

SQL> /

CURRENT_SCN
-----------
    1290699

SQL> /

CURRENT_SCN
-----------
    1290702

# scn_to_timestamp()函数可以将scn转换日期时间

SQL> select scn_to_timestamp(1290702) from dual;

SCN_TO_TIMESTAMP(1290702)
---------------------------------------------------------------------------
02-AUG-17 11.38.03.000000000 AM

SQL> select to_char(scn_to_timestamp(1290702),'YYYY-mm-dd HH:MM:SS') from dual;

TO_CHAR(SCN_TO_TIME
-------------------
2017-08-02 11:08:03


# 如果scn比select的scn高，则不读取，来实现一致性读



# 会话1
SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10

# 会话2
SQL> update booboo set sal=1 where empno=900;

1 row updated.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	      1       8000	   10

# 会话1
SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	   7000       8000	   10

# 会话2
SQL> commit;

Commit complete.

# 会话1
SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	      1       8000	   10


```

3. 锁机制

```shell
# 会话1
SQL> update booboo set sal=2 where empno=900;

1 row updated.

SQL> select * from booboo;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
       900 booboo     dba	      7782 31-JUL-17	      2       8000	   10

# 会话2
SQL> update booboo set sal=1 where empno=9
出现 dengda

```



##  SCN

```sql
set linesize 200
column name format a50
select file#,name,checkpoint_change#,to_char(scn_to_timestamp(checkpoint_change#),'YYYY-mm-dd HH:MM:SS') hm from v$datafile;
select group#,first_change#,to_char(scn_to_timestamp(first_change#),'YYYY-mm-dd HH:MM:SS') hm from v$log;
select name,current_scn,to_char(scn_to_timestamp(current_scn),'YYYY-mm-dd HH:MM:SS') hm from v$database;
```



```ssql

SQL> select group#,first_change#,to_char(scn_to_timestamp(first_change#),'YYYY-mm-dd HH:MM:SS') hm from v$log;

    GROUP# FIRST_CHANGE# HM
---------- ------------- -------------------
	 1	  276076 2019-11-24 03:11:09
	 2	  197609 2019-11-10 03:11:09
	 3	  224760 2019-11-10 04:11:15

SQL> select name,current_scn,to_char(scn_to_timestamp(current_scn),'YYYY-mm-dd HH:MM:SS') hm from v$database;

NAME	  CURRENT_SCN HM
--------- ----------- -------------------
BOOBOO	       276342 2019-11-24 03:11:39

```



