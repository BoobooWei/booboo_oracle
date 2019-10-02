# 物理结构_口令文件

> 2019.10.01 BoobooWei

[TOC]

##  用户安全审核的两种方式

### 数据库审核

使用数据字典记录用户名和口令，例如：

```sql
conn scott/tiger
```

### 外部审核

数据库管理员执行常规数据库用户不应该执行的特殊操作（例如，关闭或启动数据库）。Oracle数据库为数据库管理员用户名提供了更安全的身份验证方案。

您可以在强身份验证，**操作系统身份验证**或**密码文件**之间进行选择，以对数据库管理员进行身份验证。不同的选择适用于本地（在数据库所在的计算机上）管理数据库，以及从单个远程客户端管理许多不同的数据库计算机。

强大的身份验证使您可以集中控制`SYSDBA`和`SYSOPER`访问多个数据库。如果担心密码文件安全性，站点具有非常严格的安全性要求，或者您要将身份管理与数据库分开，请考虑使用这种类型的身份验证进行数据库管理。

数据库管理员的操作系统身份验证通常涉及将其操作系统用户名放在一个特殊的组中，或赋予其特殊的处理权限。（在UNIX系统上，该组是**dba**组。）

该 数据库使用密码文件来跟踪已被授予`SYSDBA`和`SYSOPER`特权的数据库用户名，从而启用以下操作：

- `SYSOPER`让数据库管理员执行`STARTUP`，`SHUTDOWN`，`ALTER DATABASE OPEN/MOUNT`，`ALTER DATABASE BACKUP`，`ARCHIVE LOG`，和`RECOVER`，并且包括`RESTRICTED SESSION`特权。
- `SYSDBA`包含带有的所有系统特权`ADMIN OPTION`以及`SYSOPER`系统特权。许可证`CREATE DATABASE`和基于时间的恢复。

#### 操作系统审核

操作系统审核(匿名登录sys用户)：需要用户属于dba组，需要连接到操作系统本地，例如：

```sql
conn / as sysdba
```

##### 实践——关闭操作系统审核

* 将用户移出dba组, 不能使用匿名登录 `gpasswd -d oracle dba`
* 操作系统审核的优先级别高于口令文件，不关闭操作系统审核是不会使用口令文件审核的

操作记录

```bash
[root@oratest ~]# id oracle
uid=501(oracle) gid=502(oinstall) groups=502(oinstall),501(dba)
[root@oratest ~]# gpasswd -d oracle dba
Removing user oracle from group dba
[root@oratest ~]# id oracle
uid=501(oracle) gid=502(oinstall) groups=502(oinstall)


[oracle@oratest ~]$ sqlplus /nolog

SQL*Plus: Release 11.2.0.4.0 Production on Tue Oct 1 05:08:08 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

SQL> conn / as sysdba
ERROR:
ORA-01017: invalid username/password; logon denied
```



#### 口令文件审核

口令文件审核，例如

```sql
conn sys/Oracle11g as sysdba
```

* 口令文件的位置和名字：`$ORACLE_HOME/dbs/orapw<$ORACLE_SID>`
* 重新创建口令文件：当口令文件损坏，或者sys口令丢失`orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=oracle force=y`
* 只要能够登录操作系统，就可以使用sys登录数据库！
  

##### 实践——通过口令文件登录

```bash
[oracle@oratest dbs]$ cd $ORACLE_HOME/dbs/
[oracle@oratest dbs]$ ll orapw${ORACLE_SID}
-rw-r-----. 1 oracle oinstall 1536 Jun  6 15:51 orapwdbtest
[oracle@oratest dbs]$ file orapw${ORACLE_SID}
orapwdbtest: data

[oracle@oratest dbs]$ sqlplus /nolog

SQL*Plus: Release 11.2.0.4.0 Production on Tue Oct 1 05:15:27 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

SQL> conn sys/oracle as sysdba
Connected.
```

##### 实践——修改口令文件

```bash
[oracle@oratest dbs]$ rm -rf orapwdbtest
[oracle@oratest dbs]$ orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=oracle force=y
[oracle@oratest dbs]$ ll orapw${ORACLE_SID}
-rw-r----- 1 oracle oinstall 1536 Oct  1 05:17 orapwdbtest
[oracle@oratest dbs]$ file orapw${ORACLE_SID}
orapwdbtest: data
```

*口令文件会被覆盖，因此可以不执行rm操作。*