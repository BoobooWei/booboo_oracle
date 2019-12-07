# 恢复管理器Recover Manager

> 2019.12.07 BoobooWei

[toc]

## 操作实践

### 实践1-使用压缩备份集

```sql
使用压缩备份集：
RMAN> backup datafile 2;
RMAN> backup as compressed backupset datafile 2;

使用rman备份1号文件 : 备份成功后rman会自动启动controlfile + spfile的备份
RMAN> backup as compressed backupset datafile 1;
```


操作记录
```sql
RMAN> backup as compressed backupset datafile 1;

Starting backup at 07-DEC-19
using channel ORA_DISK_1
channel ORA_DISK_1: starting compressed full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00001 name=/u01/app/oracle/oradata/BOOBOO/system01.dbf
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_16_1_20191207.bkp tag=TAG20191207T231829 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
channel ORA_DISK_1: starting compressed full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
including current control file in backup set
including current SPFILE in backup set
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_17_1_20191207.bkp tag=TAG20191207T231829 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 07-DEC-19

RMAN> list backup;


List of Backup Sets
===================


BS Key  Type LV Size       Device Type Elapsed Time Completion Time
------- ---- -- ---------- ----------- ------------ ---------------
11      Full    48.14M     DISK        00:00:05     07-DEC-19      
        BP Key: 11   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T231829
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_16_1_20191207.bkp
  List of Datafiles in backup set 11
  File LV Type Ckp SCN    Ckp Time  Name
  ---- -- ---- ---------- --------- ----
  1       Full 449625     07-DEC-19 /u01/app/oracle/oradata/BOOBOO/system01.dbf

BS Key  Type LV Size       Device Type Elapsed Time Completion Time
------- ---- -- ---------- ----------- ------------ ---------------
12      Full    1.03M      DISK        00:00:02     07-DEC-19      
        BP Key: 12   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T231829
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_17_1_20191207.bkp
  SPFILE Included: Modification time: 23-NOV-19
  SPFILE db_unique_name: BOOBOO
  Control File Included: Ckp SCN: 449627       Ckp time: 07-DEC-19
```


### 实践2-使用备份集备份表空间


```sql
使用备份集备份表空间
RMAN> backup tablespace users;

查看归档日志
RMAN> list archivelog all;

使用备份集备份归档日志：目的是清理存档终点
RMAN> backup as compressed backupset archivelog all delete input;
```

### 实践3-使用备份集备份全库

```sql
使用备份集备份全库
RMAN> backup as compressed backupset database plus archivelog;
```

操作记录

```sql
RMAN> backup as compressed backupset database plus archivelog;


Starting backup at 07-DEC-19
current log archived
using channel ORA_DISK_1
channel ORA_DISK_1: starting compressed archived log backup set
channel ORA_DISK_1: specifying archived log(s) in backup set
input archived log thread=1 sequence=18 RECID=10 STAMP=1026430222
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_20_1_20191207.bkp tag=TAG20191207T233022 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 07-DEC-19

Starting backup at 07-DEC-19
using channel ORA_DISK_1
channel ORA_DISK_1: starting compressed full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00004 name=/u01/app/oracle/oradata/BOOBOO/users01.dbf
input datafile file number=00001 name=/u01/app/oracle/oradata/BOOBOO/system01.dbf
input datafile file number=00002 name=/u01/app/oracle/oradata/BOOBOO/sysaux01.dbf
input datafile file number=00003 name=/u01/app/oracle/oradata/BOOBOO/undotbs01.dbf
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_21_1_20191207.bkp tag=TAG20191207T233023 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
channel ORA_DISK_1: starting compressed full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
including current control file in backup set
including current SPFILE in backup set
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_22_1_20191207.bkp tag=TAG20191207T233023 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 07-DEC-19

Starting backup at 07-DEC-19
current log archived
using channel ORA_DISK_1
channel ORA_DISK_1: starting compressed archived log backup set
channel ORA_DISK_1: specifying archived log(s) in backup set
input archived log thread=1 sequence=19 RECID=11 STAMP=1026430232
channel ORA_DISK_1: starting piece 1 at 07-DEC-19
channel ORA_DISK_1: finished piece 1 at 07-DEC-19
piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_23_1_20191207.bkp tag=TAG20191207T233032 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 07-DEC-19

RMAN> list backup;


List of Backup Sets
===================


BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
15      1.10M      DISK        00:00:00     07-DEC-19      
        BP Key: 15   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T233022
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_20_1_20191207.bkp

  List of Archived Logs in backup set 15
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    18      448296     07-DEC-19 450036     07-DEC-19

BS Key  Type LV Size       Device Type Elapsed Time Completion Time
------- ---- -- ---------- ----------- ------------ ---------------
16      Full    53.91M     DISK        00:00:06     07-DEC-19      
        BP Key: 16   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T233023
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_21_1_20191207.bkp
  List of Datafiles in backup set 16
  File LV Type Ckp SCN    Ckp Time  Name
  ---- -- ---- ---------- --------- ----
  1       Full 450042     07-DEC-19 /u01/app/oracle/oradata/BOOBOO/system01.dbf
  2       Full 450042     07-DEC-19 /u01/app/oracle/oradata/BOOBOO/sysaux01.dbf
  3       Full 450042     07-DEC-19 /u01/app/oracle/oradata/BOOBOO/undotbs01.dbf
  4       Full 450042     07-DEC-19 /u01/app/oracle/oradata/BOOBOO/users01.dbf

BS Key  Type LV Size       Device Type Elapsed Time Completion Time
------- ---- -- ---------- ----------- ------------ ---------------
17      Full    1.03M      DISK        00:00:01     07-DEC-19      
        BP Key: 17   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T233023
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_22_1_20191207.bkp
  SPFILE Included: Modification time: 23-NOV-19
  SPFILE db_unique_name: BOOBOO
  Control File Included: Ckp SCN: 450044       Ckp time: 07-DEC-19

BS Key  Size       Device Type Elapsed Time Completion Time
------- ---------- ----------- ------------ ---------------
18      3.00K      DISK        00:00:00     07-DEC-19      
        BP Key: 18   Status: AVAILABLE  Compressed: YES  Tag: TAG20191207T233032
        Piece Name: /home/oracle/rmanbk/BOOBOO_3420951115_23_1_20191207.bkp

  List of Archived Logs in backup set 18
  Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
  ---- ------- ---------- --------- ---------- ---------
  1    19      450036     07-DEC-19 450049     07-DEC-19

```  

### 实践4-使用rman的备份片在新的节点还原恢复数据库

```sql
使用rman的备份片在新的节点还原恢复数据库：
将备份片拷贝到远程
scp DB01_1555978772_{16..19}_1_20161011.bkp oracle@172.25.5.11:/home/oracle/zjz/

修改环境变量：
export ORACLE_SID=db01
启动实例到nomount
rman target /
RMAN> startup nomount
还原参数文件
strings DB01_1555978772_18_1_20161011.bkp | grep db_name
RMAN> restore spfile from '/home/oracle/zjz/DB01_1555978772_18_1_20161011.bkp';
使用正确的spfile重新启动实例
RMAN> shutdown abort
RMAN> startup nomount
还原控制文件
RMAN> restore controlfile from '/home/oracle/zjz/DB01_1555978772_18_1_20161011.bkp';
装载数据库
RMAN> alter database mount;
重新注册备份片 : after oracle 10g
RMAN> catalog start with '/home/oracle/zjz/';
还原数据库
RMAN> restore database;
恢复数据库
RMAN> recover database;
打开数据库
RMAN> alter database open resetlogs;
```


### 实践5-使用rman将数据文件恢复到新的位置

```sql
run{
set newname for datafile 5 to '/u01/app/oracle/oradata/db01/tbs01.dbf';
restore datafile 5;
switch datafile 5;
recover datafile 5;
}

run{
set newname for datafile 1 to '/u01/app/oracle/oradata/db01/system01.dbf';
set newname for datafile 5 to '/u01/app/oracle/oradata/db01/tbs01.dbf';
set newname for tempfile 1 to '/u01/app/oracle/oradata/db01/temp01.dbf';
restore datafile 1;
restore datafile 5;
switch datafile all;
switch tempfile all;
recover database;
}
```


### 实践6-使用种子备份

```sql
cd $ORACLE_HOME/assistants/dbca/templates/
Seed_Database.ctl --> 控制文件镜像备份
Seed_Database.dfb --> rman全库备份片
```


还原数据库：db02

使用存储过程还原数据文件：

```sql
declare
  devtype varchar2(256);
  done boolean;
begin
  devtype :=dbms_backup_restore.deviceallocate(type=>'',ident=>'c1');
  dbms_backup_restore.restoresetdatafile;
  dbms_backup_restore.restoredatafileto(dfnumber=>5,toname=>'/home/oracle/example01.dbf');
  dbms_backup_restore.restorebackuppiece(done=>done,handle=>'/u01/app/oracle/product/11.2.0/db_1/assistants/dbca/templates/example01.dfb');
  dbms_backup_restore.devicedeallocate;
end;
/
```

## 总结

1. `copy` 和 `backup` 的区别：前者是快照，后者是备份
2. `backup datafile 1;` 和 `backup as compressed backupset datafile 1;` 的区别：前者只备份指定的数据文件，后者会同时备份`spfile`和`controlfile`且做压缩
3. 备份全库`backup as compressed backupset database plus archivelog;` 重点掌握