# 启动数据库的三个阶段

> 2019.10.06 BoobooWei

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [启动数据库的三个阶段](#启动数据库的三个阶段)
	- [第一个阶段：nomount](#第一个阶段nomount)
		- [命令](#命令)
		- [做了什么？](#做了什么)
		- [需要什么？](#需要什么)
		- [我们能做什么？](#我们能做什么)
	- [第二个阶段：mount](#第二个阶段mount)
		- [命令](#命令)
		- [做了什么？](#做了什么)
		- [需要什么？](#需要什么)
		- [我们能做什么？](#我们能做什么)
	- [第三个阶段：open](#第三个阶段open)
		- [命令](#命令)
		- [做了什么？](#做了什么)
		- [需要什么？](#需要什么)
		- [我们能做什么？](#我们能做什么)
	- [停库四种模式](#停库四种模式)
		- [正常停库](#正常停库)
			- [命令](#命令)
			- [流程](#流程)
		- [事务级停库](#事务级停库)
			- [命令](#命令)
			- [流程](#流程)
		- [立即停库:生产库最常用的方式](#立即停库生产库最常用的方式)
			- [命令](#命令)
			- [流程](#流程)
		- [强制停库](#强制停库)
			- [命令](#命令)
			- [流程](#流程)
	- [查看当前数据库实例状态](#查看当前数据库实例状态)
	- [总结](#总结)

<!-- /TOC -->

* [启动和关闭](https://docs.oracle.com/cd/B28359_01/server.111/b28310/start.htm#i1006091)

## 第一个阶段：nomount

### 命令

`shutdown --> nomount`命令：`startup nomount`

查看实例状态：

```bash
SQL> select status from v$instance;

STATUS
------------
STARTED
```

### 做了什么？

* 分配实例

* 写跟踪文件

### 需要什么？

* 参数文件
* 审计路径
* 诊断路径

### 我们能做什么？

* 查看参数

* 修改参数

* 查看内存分配

  ```sql
  select * from v$pgastat;
  select * from v$sgainfo;
  ```
* 看后台进程

  ```sql
  select name from v$bgprocess where paddr<>'00';
  ```

* 可以创建数据库(重点)
* 可以重建控制文件

## 第二个阶段：mount

### 命令

`shutdown --> mount`命令：`startup mount`

`nomount --> mount`命令：`alter database mount;`

查看实例状态：

```bash
SQL> select status from v$instance;

STATUS
------------
MOUNTED
```

### 做了什么？
* 加载控制文件的信息到内存！
### 需要什么？

* 控制文件

### 我们能做什么？

* 备份、还原、恢复数据库

* 对数据文件进行offline

* 移动文件（联机日志、数据文件、临时文件、块跟踪文件）

* 打开和关闭归档模式

* 打开和关闭闪回数据库的功能

* 删除数据库

  ```sql
  startup restrict exclusive force mount;
  drop database;
  ```



## 第三个阶段：open

### 命令

`shutdown --> open`命令：`startup`

`nomount --> open`命令：`alter database mount;`

`mount --> open`命令：`alter database open;`

### 做了什么？

* 校验所有的联机日志文件和数据文件的存在否及有效性！

### 需要什么？

* 联机日志文件
* 数据文件

### 我们能做什么？

。。。。


## 停库四种模式

### 正常停库

#### 命令

`shutdown normal = shutdown`

#### 流程

* 普通会话的连接不允许建立
* 等待查询结束
* 等待事务结束
* 强制产生检查点（数据同步）
* 关闭联机日志文件和数据文件
* 关闭控制文件
* 关闭实例

### 事务级停库

#### 命令

`shutdown transactional`

#### 流程

* 普通会话的连接不允许建立
* 不等待查询（查询被杀掉）
* 等待事务结束
* 强制产生检查点（数据同步）
* 关闭联机日志文件和数据文件
* 关闭控制文件
* 关闭实例

### 立即停库:生产库最常用的方式

#### 命令

`shutdown immediate`

#### 流程

* 普通会话的连接不允许建立
* 不等待查询（查询被杀掉）
* 事务被回退（rollback）
* 强制产生检查点（数据同步）
* 关闭联机日志文件和数据文件
* 关闭控制文件
* 关闭实例

### 强制停库

#### 命令

`shutdown abort`

#### 流程

* 相当于拔电源

* 停止后是脏库！重新启动数据库时需要实例恢复！

```
startup force = shutdown abort + startup
startup force nomount = shutdown abort + startup nomount
startup force mount = shutdown abort + startup mount
```

## 查看当前数据库实例状态

```sql
select status from v$instance;

--从v$fixed_table视图中获取和instance有关的视图
SQL> col name format a30
SQL> select * from v$fixed_table where name like '%INSTANCE';

NAME				OBJECT_ID TYPE	 TABLE_NUM     CON_ID
------------------------------ ---------- ----- ---------- ----------
GV$TEMPFILE_INFO_INSTANCE      4294955937 VIEW	     65537	    0
V$TEMPFILE_INFO_INSTANCE       4294955938 VIEW	     65537	    0
GV$INSTANCE		       4294951325 VIEW	     65537	    0
V$INSTANCE		       4294951066 VIEW	     65537	    0
```

## 总结

| 停库的方式               | 新会话 | 非活动会话 | 事务       | 检查点 | 停止数据库 | 数据一致性 |
| ------------------------ | ------ | ---------- | ---------- | ------ | ---------- | ---------- |
| `shutdown normal`        | 不接受 | `等待结束` | 等待结束   | 产生   | 停止       | Yes        |
| `shutdown transactional` | 不接受 | 不等待     | `等待结束` | 产生   | 停止       | Yes        |
| `shutdown immediate`     | 不接受 | 不等待     | 不等待结束 | `产生` | 停止       | Yes        |
| `shutdown abort`         | 不接受 | 不等待     | 不等待结束 | 不产生 | `停止`     | No         |
