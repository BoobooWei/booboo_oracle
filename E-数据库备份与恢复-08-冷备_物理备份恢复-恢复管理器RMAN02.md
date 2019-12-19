# 恢复管理器Recover Manager

> 2019.12.07 - BoobooWei

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [恢复管理器Recover Manager](#恢复管理器recover-manager)
	- [操作实践](#操作实践)
		- [实践1-使用压缩备份集](#实践1-使用压缩备份集)
		- [实践2-使用备份集备份表空间](#实践2-使用备份集备份表空间)
		- [实践3-使用备份集备份全库](#实践3-使用备份集备份全库)
		- [实践4-使用rman的备份片在新的节点还原恢复数据库](#实践4-使用rman的备份片在新的节点还原恢复数据库)
			- [清空数据库](#清空数据库)
			- [rman恢复脚本](#rman恢复脚本)
		- [实践5-使用rman将数据文件恢复到新的位置](#实践5-使用rman将数据文件恢复到新的位置)
		- [实践6-使用种子备份](#实践6-使用种子备份)
	- [总结](#总结)

<!-- /TOC -->


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

> 2019.12.15

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


#### 清空数据库

```SQL
shutdown immediate;
startup restrict exclusive force mount;
drop database;
```

#### rman恢复脚本

```bash
#!/bin/bash
# auth:booboowei
# date:20191215
# script_name:rman_recover_full_database.sh

# 指定全备份路径
rmanbk=/home/oracle/rmanbk/
# 指定SID的bash启动参数文件
sid_file=/home/oracle/.bash_profile

get_variables(){
# 通过RMAN恢复
echo "Get SID and RMAN backup file of spfile and controlfile."
cd $rmanbk
for i in `ls`;do db_name=`strings $i | grep db_name`; if [[ $db_name != '' ]];then file=$i;sid=`echo $db_name | awk -F '=' '{print $2}' |awk -F "'" '{print $2}'`;fi;done
echo "SID       :"$sid
echo "RMAN FILE :"$file
echo
}


clean_database(){
echo "Set SID and Clean up database."
# 设置SID
sed -i "s/.*ORACLE_SID.*/export ORACLE_SID=${sid}/" ${sid_file}
source ${sid_file}
# 清空数据库

echo -e "shutdown immediate;\nstartup restrict exclusive force mount;\ndrop database;\nexit;" > /tmp/clean_database.sql
sqlplus / as sysdba @/tmp/clean_database.sql
}


recover_database(){
cat > /tmp/rman_recover_database.sql << ENDF
run{
startup nomount;
restore spfile from "${rmanbk}/${file}";
startup force nomount;
restore controlfile from "${rmanbk}/${file}";
alter database mount;
catalog start with "${rmanbk}";
restore database;
recover database;
alter database open resetlogs;
}
ENDF

rman target / @/tmp/rman_recover_database.sql
echo "alter database open resetlogs;" | sqlplus / as sysdba
}

get_variables
clean_database
recover_database
```

操作记录
```SQL
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.

SQL> startup restrict exclusive force mount;
ORACLE instance started.

Total System Global Area  229683200 bytes
Fixed Size		    2251936 bytes
Variable Size		  171967328 bytes
Database Buffers	   50331648 bytes
Redo Buffers		    5132288 bytes
Database mounted.
SQL> drop database;

Database dropped.

Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
```


通过rman全备份恢复操作记录

```SQL
[oracle@oratest rmanbk]$ pwd
/home/oracle/rmanbk
[oracle@oratest rmanbk]$ ll
total 57648
-rw-r----- 1 oracle oinstall    18432 Dec 15 09:35 BOOBOO_3420951115_28_1_20191215.bkp
-rw-r----- 1 oracle oinstall 57892864 Dec 15 09:35 BOOBOO_3420951115_29_1_20191215.bkp
-rw-r----- 1 oracle oinstall  1114112 Dec 15 09:35 BOOBOO_3420951115_30_1_20191215.bkp
-rw-r----- 1 oracle oinstall     3072 Dec 15 09:35 BOOBOO_3420951115_31_1_20191215.bkp
[oracle@oratest rmanbk]$ for i in `ls`;do db_name=`strings $i | grep db_name`; if [[ $db_name != '' ]];then echo $i;echo $db_name;fi;done
BOOBOO_3420951115_30_1_20191215.bkp
*.db_name='BOOBOO'

[oracle@oratest rmanbk]$ rman target /

Recovery Manager: Release 11.2.0.4.0 - Production on Sun Dec 15 10:18:03 2019

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database (not started)

run{
startup nomount;
restore spfile from "/home/oracle/rmanbk/BOOBOO_3420951115_30_1_20191215.bkp";
startup force nomount;
restore controlfile from "/home/oracle/rmanbk/BOOBOO_3420951115_30_1_20191215.bkp";
alter database mount;
catalog start with '/home/oracle/rmanbk/';
restore database;
recover database;
alter database open resetlogs;
11> };

startup failed: ORA-01078: failure in processing system parameters
LRM-00109: could not open parameter file '/u01/app/oracle/product/11.2.0.4/dbs/initBOOBOO.ora'

starting Oracle instance without parameter file for retrieval of spfile
Oracle instance started

Total System Global Area    1068937216 bytes

Fixed Size                     2260088 bytes
Variable Size                281019272 bytes
Database Buffers             780140544 bytes
Redo Buffers                   5517312 bytes

Starting restore at 15-DEC-19
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=170 device type=DISK

channel ORA_DISK_1: restoring spfile from AUTOBACKUP /home/oracle/rmanbk/BOOBOO_3420951115_30_1_20191215.bkp
channel ORA_DISK_1: SPFILE restore from AUTOBACKUP complete
Finished restore at 15-DEC-19

Oracle instance started

Total System Global Area     229683200 bytes

Fixed Size                     2251936 bytes
Variable Size                171967328 bytes
Database Buffers              50331648 bytes
Redo Buffers                   5132288 bytes

Starting restore at 15-DEC-19
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=170 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
output file name=/u01/app/oracle/product/11.2.0.4/dbs/cntrlBOOBOO.dbf
Finished restore at 15-DEC-19

database mounted
released channel: ORA_DISK_1

searching for all files that match the pattern /home/oracle/rmanbk/

List of Files Unknown to the Database
=====================================
File Name: /home/oracle/rmanbk/BOOBOO_3420951115_30_1_20191215.bkp
File Name: /home/oracle/rmanbk/BOOBOO_3420951115_31_1_20191215.bkp

Do you really want to catalog the above files (enter YES or NO)? yes
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /home/oracle/rmanbk/BOOBOO_3420951115_30_1_20191215.bkp
File Name: /home/oracle/rmanbk/BOOBOO_3420951115_31_1_20191215.bkp

Starting restore at 15-DEC-19
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=170 device type=DISK

channel ORA_DISK_1: starting datafile backup set restore
channel ORA_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_DISK_1: restoring datafile 00001 to /u01/app/oracle/oradata/BOOBOO/system01.dbf
channel ORA_DISK_1: restoring datafile 00002 to /u01/app/oracle/oradata/BOOBOO/sysaux01.dbf
channel ORA_DISK_1: restoring datafile 00003 to /u01/app/oracle/oradata/BOOBOO/undotbs01.dbf
channel ORA_DISK_1: restoring datafile 00004 to /u01/app/oracle/oradata/BOOBOO/users01.dbf
channel ORA_DISK_1: reading from backup piece /home/oracle/rmanbk/BOOBOO_3420951115_29_1_20191215.bkp
channel ORA_DISK_1: piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_29_1_20191215.bkp tag=TAG20191215T093531
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:15
Finished restore at 15-DEC-19

Starting recover at 15-DEC-19
using channel ORA_DISK_1

starting media recovery

channel ORA_DISK_1: starting archived log restore to default destination
channel ORA_DISK_1: restoring archived log
archived log thread=1 sequence=27
channel ORA_DISK_1: reading from backup piece /home/oracle/rmanbk/BOOBOO_3420951115_31_1_20191215.bkp
channel ORA_DISK_1: piece handle=/home/oracle/rmanbk/BOOBOO_3420951115_31_1_20191215.bkp tag=TAG20191215T093540
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
archived log file name=/home/oracle/arc_booboo_dest1/1_27_1023917451.dbf thread=1 sequence=27
unable to find archived log
archived log thread=1 sequence=28
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 12/15/2019 10:18:53
RMAN-06054: media recovery requesting unknown archived log for thread 1 with sequence 28 and starting SCN of 452643

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

1. `copy` 和 `backup` 的区别：前者是快照包含空闲块，后者是备份不包含空闲块，前者恢复速度更快，相当于手动在线的热备，后者可压缩和增量备份。
2. `backup datafile 1;` 和 `backup as compressed backupset datafile 1;` 的区别：前者只备份指定的数据文件，后者会同时备份`spfile`和`controlfile`且做压缩
3. 备份全库`backup as compressed backupset database plus archivelog;` 重点掌握
4. RMAN备份恢复脚本:[rman_recover_full_database.sh](scripts/rman_recover_full_database.sh)
5. 学到此处会发现RMAN的功能非常强大，知识点非常多，我的建议是，首先了解RMAN能做什么；其次掌握工作中需要RMAN做什么（A. 通过RMAN做生产数据备份计划；B. 通过RMAN搭建DG；）下节课我们会开始学习冷备计划的制定和实施
