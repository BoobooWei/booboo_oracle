# 02-逻辑备份恢复_EXPDP和IMPDP数据泵

*逻辑备份和恢复*

> 2019.11.14 BoobooWei

[toc]

## 数据泵组件

Oracle数据泵由三个不同的部分组成：

- 命令行客户端，`expdp`以及`impdp`
- 该`DBMS_DATAPUMP`PL / SQL程序包（也称为数据泵API）
- 该`DBMS_METADATA`PL / SQL程序包（也称为元数据API）

数据泵客户端`expdp`和分别`impdp`调用数据泵导出实用程序和数据泵导入实用程序。

在`expdp`和`impdp`客户机使用规定的程序`DBMS_DATAPUMP`PL / SQL包来执行导出和导入命令，使用在命令行中输入的参数。这些参数支持导出和导入完整数据库或数据库子集的数据和元数据。

移动元数据时，数据泵将使用`DBMS_METADATA`PL / SQL软件包提供的功能。该`DBMS_METADATA`包提供了用于提取，操作和重新创建字典元数据的集中式工具。

在`DBMS_DATAPUMP`和`DBMS_METADATA`PL / SQL程序包可独立使用的数据泵客户。

> 注意：
>
> 所有数据泵的导出和导入处理，包括读取和写入转储文件，都是在指定数据库连接字符串选择的系统（服务器）上完成的。**这意味着对于非特权用户，数据库管理员（DBA）必须为在该服务器文件系统上读写的数据泵文件创建目录对象。**
>
> 也可以看看：
>
> * [*《 Oracle数据库PL / SQL软件包和类型参考*](https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/toc.htm)》中有关`DBMS_DATAPUMP`和`DBMS_METADATA`软件包的描述
>
> - [*《 Oracle数据库SecureFiles和大型对象开发人员指南》*](https://docs.oracle.com/cd/E11882_01/appdev.112/e18294/adlob_bfile_ops.htm#ADLOB45842)中有关创建目录对象时要考虑的准则的信息

### 数据泵如何移动数据？

有关Data Pump如何将数据移入和移出数据库的信息，请参阅以下部分：

- [使用数据文件复制来移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CEGFEEJE)
- [使用直接路径移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJAFDGIC)
- [使用外部表移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJABAHDJ)
- [使用常规路径移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJAGCCAJ)
- [使用网络链接导入移动数据](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_overview.htm#CJABHJHD)

> 注意：
>
> 数据泵不使用 禁用唯一索引。要将数据加载到表中，必须删除索引或重新启用索引。

### 数据泵导出和导入操作的必需角色

许多数据泵的导出和导入操作都要求用户`DATAPUMP_EXP_FULL_DATABASE`扮演一个角色和/或一个`DATAPUMP_IMP_FULL_DATABASE`角色。当您运行数据库创建过程中的标准脚本时，会自动为Oracle数据库定义这些角色。（请注意，尽管这些角色的名称中包含单词FULL，但实际上对于所有导出和导入模式（不仅是完全模式），都需要这些角色。）

该`DATAPUMP_EXP_FULL_DATABASE`角色仅影响导出操作。该`DATAPUMP_IMP_FULL_DATABASE`角色影响导入操作和使用Import `SQLFILE`参数的操作。这些角色允许执行导出和导入的用户执行以下操作：

- 在其架构范围之外执行操作
- 监视其他用户启动的作业
- 非特权用户无法引用的导出对象（例如表空间定义）和导入对象（例如目录定义）

这些是强大的角色。在向用户授予这些角色时，数据库管理员应谨慎行事。

尽管`SYS`没有为架构分配任何这些角色，但是由Data Pump执行的所有需要这些角色的安全检查也都授予了对该`SYS`架构的访问权限。

> 也可以看看：
> [*《 Oracle数据库安全指南》*](https://docs.oracle.com/cd/E11882_01/network.112/e36292/authorization.htm#DBSEG4414)中有关Oracle数据库安装中预定义角色的更多信息


## expdp导出步骤

### 1 创建逻辑目录

* 第一步：在服务器上创建真实的目录；（注意：第三步创建逻辑目录的命令不会在OS上创建真正的目录，所以要先在服务器上创建真实的目录。）`mkdir /home/oracle/expbk`

* 第二步：用sys管理员登录sqlplus `sqlplus / as sysdba`

* 第三步：创建逻辑目录`SQL> create directory data_dir as '/home/oracle/expbk';`

* 第四步：查看管理员目录，检查是否存在`select * from dba_directories;`

  ```sql
  SQL> select * from dba_directories;

  OWNER                          DIRECTORY_NAME
  ------------------------------ ------------------------------
  DIRECTORY_PATH
  --------------------------------------------------------------------------------
  SYS                            DATA_DIR
  /home/oracle/dmp/user
  ```


* 第五步：用sys管理员给你的指定用户赋予在该目录的操作权限 `SQL> grant read,write on directory data_dir to user;`


### 2 `expdp`的五种导出方式

#### 第一种：`full=y`全量导出数据库

```bash
expdp user/passwd@orcl dumpfile=expdp.dmp directory=data_dir full=y logfile=expdp.log;
```

#### 第二种：`schemas`按用户导出

```bash
expdp user/passwd@orcl schemas=user dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第三种：`tablespace`按表空间导出

```bash
expdp sys/passwd@orcl tablespace=tbs1,tbs2 dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第四种：`tables`导出表

```bash
expdp user/passwd@orcl tables=table1,table2 dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

#### 第五种：`query`按查询条件导

```bash
expdp user/passwd@orcl tables=table1 query='where number=1234' dumpfile=expdp.dmp directory=data_dir logfile=expdp.log;
```

### 3 `impdp`导入步骤

（1）如果不是同一台服务器，需要先将上面的dmp文件下载到目标服务器上，具体命令参照：http://www.cnblogs.com/promise-x/p/7452972.html

（2）参照“expdp导出步骤”里的前三步，建立逻辑目录；

（3）用impdp命令导入，对应五种方式：

#### 第一种：`full=y`全量导入数据库

```bash
impdp user/passwd directory=data_dir dumpfile=expdp.dmp full=y;
```

#### 第二种：`schemas`按用户导出后同名用户导入

```bash
impdp A/passwd schemas=A directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

#### 第三种：`tablespaces`导入表空间

同用户：

```bash
impdp sys/passwd tablespaces=tbs1 directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

跨用户：将表空间TBS01、TBS02、TBS03导入到表空间A_TBS，将用户B的数据导入到A，并生成新的oid防止冲突；

```bash
impdp A/passwd remap_tablespace=TBS01:A_TBS,TBS02:A_TBS,TBS03:A_TBS remap_schema=B:A FULL=Y transform=oid:n 
directory=data_dir dumpfile=expdp.dmp logfile=impdp.log
```

#### 第四种：`tables`导入表

同用户：

```bash
impdp A/passwd tables=table1,table2 dumpfile=expdp.dmp logfile=impdp.log;
```

跨用户：从A用户中把表table1和table2导入到B用户中

```bash
impdp B/passwd tables=A.table1,A.table2 remap_schema=A:B directory=data_dir dumpfile=expdp.dmp logfile=impdp.log;
```

#### 第五种：追加数据；

```bash
impdp sys/passwd directory=data_dir dumpfile=expdp.dmp schemas=system table_exists_action=replace logfile=impdp.log; 
--table_exists_action:导入对象已存在时执行的操作。有效关键字:SKIP,APPEND,REPLACE和TRUNCATE
```


## 逻辑备份恢复工具对比

[Oracle 官网帮助](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_legacy.htm#SUTIL960)

| 工具区别   | `exp\imp`         | `expdp\impdp`     |
| ---------- | ----------------- | ----------------- |
| 使用位置   | 服务器/客户端都可 | 只能服务端        |
| 影响因素   | 网络、磁盘        | 磁盘              |
| 备份速度   | 更慢              | 更快              |
| 恢复速度   | 更慢              | 更快              |
| 数据库版本 |                   | `oracle 10g 之后` |

