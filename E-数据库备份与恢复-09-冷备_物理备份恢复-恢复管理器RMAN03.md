# RMAN备份概念

> 2019.12.15 BoobooWei

[TOC]

## 数据库备份（冷备）与RMAN备份的概念

### 数据库完全备份

> 此处只讨论冷备之物理备份-全备

按归档模式分为归档和非归档

| 归档模式 | 冷备分类      | 恢复状态   | 服务可用性         | 数据一致性 |
| :------- | :------------ | :--------- | :----------------- | :--------- |
| 非归档   | 离线冷备-copy | 完全恢复   | `shutdown`不能读写 | 一致       |
| 归档     | 在线热备-SQL  | 不完全恢复 | `open` 可读写      | 不一致     |
| 归档     | 在线热备-RMAN | 不完全恢复 | `open` 可读写      | 不一致     |
| 归档     | 离线冷备-RMAN | 完全恢复   | `mount` 不能读写   | 一致       |


### RMAN备份     

* RMAN使用服务器会话来完成备份操作，从RMAN客户端连接到服务器将产生一个服务器会话

* RMAN备份内容包括：整个数据库,表空间,数据文件,指定的数据文件,控制文件,归档日志文件,参数文件等

  ​     

### RMAN备份的类型

完整备份(full) 或增量备份(incremental)

一致性备份(consistent)或不一致性备份(inconsistent)

热备(open)或冷备(closed)，冷备时数据库必须处于mount状态

​               

#### 完整备份

一个或多个数据文件的一个完整副本,包含从备份开始处所有的数据块.完整备份不能作为增量的基础

   

#### 增量备份

> 注意：增量备份（通用）=差异增量（Oracle） 差异备份（通用）=累计增量（Oracle）
> 增量备份（通用）:相对于上一次的备份
> 差异备份（通用）:相对于上一次的全备


* 包含从最近一次备份以来被修改或添加的数据块.可以分为差异增量备份和累计增量备份

* 差异增量备份仅仅包含n级或n级以下被修改过的数据块。备份数据量小，恢复时间长。

* 累计增量备份仅仅包含n-1级或n-1级以下被修改过的数据块。备份数据量大，恢复时间短。

* 0级增量备份相当于一个完整备份,该备份包含所有已用的数据块文件,与完整备份的差异是完整备份不能用作级增量备份的基础

  ​		   

#### 一致性备份

* 备份所包含的各个文件中的所有修改都具备相同的系统变化编号(system change number，SCN)。

* 也就是说，备份所包含的各个文件中的所有数据均来自同一时间点。

* 一致性数据库完全备份(consis-tent whole database backup)进行还原(restore)后，不需要执行恢复操作(recovery)



#### 非一致性备份

* 在数据库处于打开(open)状态时，或数据库异常关闭(shut down abnormally)后，对一个或多个数据库文件进行的备份。非一致性备份需要在还原之后进行恢复操作

   

### 备份集与镜像副本

#### 备份集`backup`

是包含一个或多个数据文件,归档日志文件的二进制文件的集合.备份集由备份片组成,一个备份集中可以包含一个或多个备份片

可以通过filesperset参数来设置备份集中可包含的备份片数，

也可以设定参数maxpiecesize来制定每个备份片的大小。

备份集中空闲的数据块将不会被备份，因此备份集可以支持压缩。备份集支持增量备份，可以备份到磁盘或磁带。


#### 镜像副本`copy`

是数据文件或归档日志文件等的完整拷贝,未经过任何压缩等处理,不能备份到磁带,也不支持增量备份

恢复时可以立即使用实现快速恢复

等同于操作系统的复制命令

可以作为级增量备份

   

### 备份路径

可以备份到磁盘目录

可以备份到磁带

闪回区

   

### 备份限制

数据库必须处于mount或open状态

不能备份联机日志

在非归档模式下仅仅能作干净备份，即在干净关闭且启动到mount状态下备份

在归档模式下，current状态下数据文件可以备份


​       

## 使用RMAN进行备份

### 备份数据库

### 备份数据文件

### 备份表空间

### 备份控制文件

### 备份参数文件

### 备份归档日志文件

* 备份归档日志时仅仅备份归档过的数据文件(不备份联机重做日志文件)
* 备份归档日志时总是对归档日志做完整备份
* RMAN对归档日志备份前会自动做一次日志切换，且从一组归档日志中备份未损坏的归档日志
* RMAN会自动判断哪些归档日志需要进行备份
* 归档日志的备份集不能包含其它类型的文件

### 备份闪回区

### 总结：

数据文件的备份集对于未使用的块可以执行增量备份，可以跳过未使用过的数据块来进行压缩备份
对于控制文件、归档日志文件、spfile文件则是简单的拷贝，并对其进行打包压缩而已

## 备份的其它特性

### 并发

> 并发：主要用于提高备份的速度，可以分为手动并发或自动并发

手动并发：通过分配多个通道并将文件指定到特定的通道


```sql
RMAN> run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
ackup incremental level=0
format '/u01/app/oracle/rmanbak/df_%d_%U'
(datafile 1 channel ch1 tag='sys')
(datafile 3 channel ch2 tag='aux')
(datafile 2,4,5,6 channel ch3 tag='other');
sql 'alter system archive log current';
release channel ch1;
release channel ch2;
release channel ch3;
}  
```


自动并发：使用configure配置并发度即可

```sql
RMAN> configure device type disk parallelism 3 backup type to backupset;
--下面的备份将自动启用个通道执行并发
RMAN>  backup database format '/u01/app/oralce/rmanbak/p3_%U';
```


### 复用备份

即将一个备份集复制多份，同一备份集，Oracle最多可复用个

手工指定：

```sql
RMAN> backup copies 2 datafile 4
2> format '/u01/app/oracle/rmanbak/d1/df_%U',
3> '/u01/app/oracle/rmanbak/d2/df_%U';  
```


自动指定：配置下列参数
```sql
RMAN> configure datafile backup copies for device type disk to 2;  --指定备份数据文件副本数
RMAN> configure archivelog backup copies for device type disk to 2;--指定备份日志文件副本数
```


### 备份备份集

```sql
bacup backupset
```


### 镜像备份

镜像备份时会检查数据文件中是否存在坏块，可以使用nochecksum来跳过坏块的检测

也可以指定maxcorrupt判断有多少个坏块时，Oracle将停止该镜像备份


```sql
RMAN> backup as copy
2> datafile 4 format '/u01/app/oracle/rmanbak/users.dbf' tag='users'
--以下命令等同于上一条
RMAN> copy datafile 4 to '/u01/app/oracle/rmanbak/user01.dbf';
RMAN> backup as copy
2> archivelog like 'o1_mf_1_118_6chl1byd_.arc'
3> format '/u01/app/oracle/rmanbak/arch_1015.bak';

--使用下面的configure命令将backup type设置为copy之后，则缺省的备份为镜像副本
RMAN> configure device type disk parallelism 1 backup type to copy;
RMAN> backup datafile 4  --由于上面的设置，则此命令备份的将是镜像副本
2> format '/u01/app/oracle/rmanbak/users.dbf.bak' tag=users;   
--使用并行度来执行镜像拷贝
RMAN> configure device type disk parallelism 4;
RMAN> backup as copy #3 files copied in parallel
2> (datafile 1 format '/u01/app/oracle/rmanbak/df1.bak')
3> (datafile 2 format '/u01/app/oracle/rmanbak/df2.bak')
4> (datafile 3  format '/u01/app/oracle/rmanbak/df3.bak');

```

镜像备份时指定子句DB_FILE_NAME_CONVERT来实现镜像路径转移，该子句也是一个初始化参数，用于primary db 到standby db
的数据文件的转换

```sql
DB_FILE_NAME_CONVERT = ('string1' , 'string2' , 'string3' , 'string4' ...)
用string2替换string1,string4替换string3
RMAN> backup as copy device type disk
2> db_file_name_convert('oradata/orcl','bk/rmbk')
3> tablespace users;       
```


### 压缩备份集   

```sql
RMAN> configure channel device type disk format '/u01/app/oracle/rmanbak/%d_%U.bak';
--下面的命令使用了参数as compressed来实现手动压缩
RMAN> backup as compressed backupset database;
RMAN> backup as compressed backupset datafile 4,5,6;
--下面使用configure命令配置自动压缩备份集功能，则后续的备份会自动使用压缩功能
RMAN> configure device type disk parallelism 4 backup type to compressed backupset;
--由于设置了自动压缩，则下面的命令将压缩备份的system表空间及控制文件、参数文件
RMAN> backup tablespace system tag=system;
```


### 使用tag标记

tag标记可以为备份集或映像副本指定一个有意义的名字，以备后续使用，其优点如下

* 为备份集或映像副本提供描述信息
* 能够在list 命令中使用更好的定位备份文件
* 能够在restore和switch命令中使用
* 同一个tag在多个备份集或多个映像副本中使用
* 当未指定tag标记时，则系统产生缺省的tag标记，其格式为：`TAGYYYYMMDDTHHMMSS`


```sql
RMAN> backup as compressed backupset datafile 1,2,3 tag='Monthly_full_bak';
RMAN> backup as compressed backupset tablespace users tag='Weekly_full_bak';
RMAN> list backupset tag=monthly_full_bak; 
```


### 增量备份

差异增量备份将备份自上次增量备份以来所有发生改变的数据块

累计增量备份将备份自上次级增量备份以来所有改变过的数据块


```sql
--下面启用级增量备份
RMAN> run{
2> allocate channel ch1 type disk;
3> backup incremental level 0 database
4> format '/u01/app/oracle/rmanbak/db_%d_%U'
5> tag=db_inc_0;
6> release channel ch1;
7> }
SQL> select sid,sofar,totalwork from v$session_longops;  --查询备份情况
--下面启用级差异增量备份
RMAN> run{
2> allocate channel ch1 type disk;
3> backup incremental level 1 database
4> format '/u01/app/oracle/rmanbak/db1_%d_%U'
5> tag=db_inc_1;
6> release channel ch1;
7> }
--下面启用级累计增量备份
RMAN> run{
2> allocate channel ch1 type disk;
3> backup incremental level 1 cumulative database
4> format '/u01/app/oracle/rmanbak/dbc_%d_%U'
5> tag=db_inc_c_1;
6> release channel ch1;
7> }
```


### 启用块变化跟踪

启用块变化跟踪即是指定一个文件用于记录数据文件中哪些块发生了变化，在RAMN进行增量备份时，仅仅需读取该文件来备份这些

发生变化的块，从而减少了备份时间和I/O资源。

使用下面的命令来启用块变化跟踪`ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '<dir>'`

```sql
SQL> alter database enable block change tracking
  2  using file '/u01/app/oracle/oradata/orcl/blk_ch_trc.trc';

SQL> ho ls -lht /u01/app/oracle/oradata/orcl/blk_ch_trc.trc
-rw-r----- 1 oracle oinstall 12M Oct 15 19:41 /u01/app/oracle/oradata/orcl/blk_ch_trc.trc

SQL> select * from v$block_change_tracking;
STATUS     FILENAME                                           BYTES
---------- --------------------------------------------- ----------
ENABLED    /u01/app/oracle/oradata/orcl/blk_ch_trc.trc     11599872
SQL> alter database disable block change tracking; --disable后块变化跟踪文件被自动删除
SQL>  select * from v$block_change_tracking;
STATUS     FILENAME                                           BYTES
---------- --------------------------------------------- ----------
DISABLED       
```

### 备份保留策略

保留策略主要是保留备份副本的一些规则,通常用于满足恢复或其他的需要(比如磁盘空间或磁带空间大小限制)

备份保留策略分为冗余和恢复窗口，这两种保留策略互不兼容，要么使用前者，要么使用后者

#### 备份冗余

* 默认为，可以通过RMAN> configure retention policy to redundancy 2;来修改
* 当为时，RMAN会为每个数据文件、归档日志、控制文件生成一个备份。可以使用report obsolete命令查看备份数多于的备份
* 并使用delete obsolete来删除过时的备份

   
#### 恢复窗口       

* 恢复窗口允许完成恢复到过去某个时间点的时点恢复，通常设定为多少天
* 使用命令RMAN> configure retention policy to recovery window of 7 days  #更新retention单词错误@20150128,感谢网友snowfoxxz
* 该命令将确保具有足够的数据文件和归档日志来执行能够返回一个星期中任意时间点的不完全恢复，且允许删除随着时间推移而变为废弃的备份，即应当满足该条件：SYSDATE - BACKUP CHECKPOINT TIME >= 7
* 对于大于天但是是恢复所需要的备份依然会被保留

   
#### 清除备份保留策略

```sql
RMAN> configure retention policy clear;
```


#### 注意`obsolete` 与 `expired`

* `obsolete`：是指根据保留策略来确定该备份是否在恢复的时候需要，如不在需要或有更新的备份来替代，则该备份集被置为`obsolete`，即废弃的备份集或镜像副本。

* `expired`: 是指执行`crosscheck`时，根据存储仓库中记录的备份信息来定位备份集或镜像副本，而找不到对应的备份集或镜像副本，则这些备份集或镜像副本被置为expired。


### 验证数据文件逻辑坏块

使用`BACKUP ... VALIDATE`验证数据文件逻辑坏块，损坏的坏块将被记录到`v$database_block_corruption`视图

```sql
BACKUP VALIDATE CHECK LOGICAL DATABASE ARCHIVELOG ALL;
```


## 备份相关的动态性能视图及监控

### 相关视图

```sql
v$backup_files
v$backup_set
v$backup_piece
v$backup_redolog
v$backup_spfile
v$backup_device
v$rman_configuration
v$archived_log
v$backup_corruption
v$copy_corruption
v$database_block_corruption
v$backup_datafile
```


### 查看channel对应的server sessions

使用`set command id`命令

查询`v$process`和`v$session`判断哪一个会话与之对应的RMAN通道

```sql
SQL> select sid,username,client_info from v$session where client_info is not null;
	   SID USERNAME                       CLIENT_INFO
---------- ------------------------------ ------------------------------
	   146 SYS                            rman channel=ORA_DISK_1
	   148 SYS                            rman channel=ORA_DISK_2
	   150 SYS                            rman channel=ORA_DISK_3
--下面使用了set command id命令
RMAN> run{
2> allocate channel ch1 type disk;
3> set command id to 'rman';
4> backup as copy datafile 4
5> format '/u01/app/oracle/rmanbak/dd_%U';
6> }

SQL> select sid,username,client_info from v$session
  2   where client_info is not null;
	   SID USERNAME                       CLIENT_INFO
---------- ------------------------------ ------------------------------
	   140 SYS                            id=rman
SQL> select sid,spid,client_info
  2  from v$process p ,v$session s
  3  where p.addr = s.paddr
  4  and client_info like '%id=%';
	   SID SPID         CLIENT_INFO
---------- ------------ ------------------------------
	   140 5002         id=rman 

--查看rman完整的进度      
SQL> select sid,serial#,context,sofar,totalwork,
  2  round(sofar/totalwork*100,2) "% Complete"
  3  from v$session_longops
  4   where opname like 'RMAN:%'
  5  and opname not like 'RMAN:aggregate%'
  6  and totalwork!=0;    
--通过如下SQL获得rman用来完成备份操作的服务进程的SID与SPID信息：
select sid, spid, client_info
  from v$process p, v$session s
 where p.addr = s.paddr
   and client_info like '%id=rman%'
```


### Linux下的rman自动备份

备份脚本+crontab

bak_inc0 ：0级增量备份，每周日使用级增量进行备份

bak_inc1 ：1级增量备份，每周三使用级增量备份，备份从周日以来到周三所发生的数据变化

bak_inc2 ：2级增量备份，备份每天发生的差异增量。如从周日到周一的差异，从周一到周二的差异


```bash
--下面是级增量的脚本，其余级与级依法炮制，所不同的是备份级别以及tag标记

[oracle@oradb scripts]$ cat bak_inc0
run {
allocate channel ch1 type disk;
backup as compressed backupset  incremental level 0
format '/u01/oracle/bk/rmbk/incr0_%d_%U'
tag 'day_incr0'
database plus archivelog delete input;
release channel ch1;
}
```


逐个测试脚本

```bash
[oracle@oradb bk]$ rman target / log=/u01/oracle/bk/log/bak_inc0.log /
> cmdfile=/u01/oracle/bk/scripts/bak_inc0.rcv
RMAN> 2> 3> 4> 5> 6> 7> 8> 9>
[oracle@oradb bk]$
```


编辑crontab

```bash
[root@oradb ~]# whoami
root
[root@oradb ~]# crontab -e -u oracle
45 23 * * 0 rman target / log=/u01/oracle/bk/log/bak_inc0.log append cmdfile = /u01/oracle/bk/scripts/bak_inc0.rcv

45 23 * * 1 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile = /u01/oracle/bk/scripts/bak_inc2.rcv

45 23 * * 2 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile = /u01/oracle/bk/scripts/bak_inc2.rcv

45 23 * * 3 rman target / log=/u01/oracle/bk/log/bak_inc1.log append cmdfile = /u01/oracle/bk/scripts/bak_inc1.rcv

45 23 * * 4 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile = /u01/oracle/bk/scripts/bak_inc2.rcv

45 23 * * 5 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile = /u01/oracle/bk/scripts/bak_inc2.rcv

45 23 * * 6 rman target / log=/u01/oracle/bk/log/bak_inc2.log append cmdfile = /u01/oracle/bk/scripts/bak_inc2.rcv

"/tmp/crontab.XXXXInBzgR" 7L, 791C written
crontab: installing new crontab
```



保存之后重启crontab

```bash
[root@oradb ~]# service crond restart
Stopping crond: [  OK  ]
Starting crond: [  OK  ]
```


检查自动备份是否成功执行



 



 

​     
