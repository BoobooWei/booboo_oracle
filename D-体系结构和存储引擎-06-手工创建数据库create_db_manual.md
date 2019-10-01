手工创建数据库：db01

1.修改系统环境变量
export ORACLE_SID=db01

2.创建口令文件
orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=oracle

3.创建参数文件
vi $ORACLE_HOME/dbs/initdb01.ora
--------------------------------------------------
db_name='db01'
sga_target=800m
compatible=11.2.0.4.0
control_files='/home/oracle/db01/control01.crl'
audit_file_dest='/home/oracle/db01/adump'
diagnostic_dest='/home/oracle/db01'
db_recovery_file_dest_size=4g
db_recovery_file_dest='/home/oracle/db01'
undo_tablespace=undo01
--------------------------------------------------

4.创建相关目录：
mkdir -p /home/oracle/db01/
mkdir -p /home/oracle/db01/adump

5.创建spfile启动实例到nomount
sqlplus / as sysdba
create spfile from pfile;
startup nomount

6.创建数据库
create database db01
datafile '/home/oracle/db01/system01.dbf' size 200m autoextend on next 50m extent management local
sysaux datafile '/home/oracle/db01/sysaux01.dbf' size 100m autoextend on next 50m
default temporary tablespace temp tempfile '/home/oracle/db01/temp01.dbf' size 50m
undo tablespace undo01 datafile '/home/oracle/db01/undo01.dbf' size 50m
character set zhs16gbk
national character set al16utf16
logfile
group 1 '/home/oracle/db01/redo01.log' size 50m,
group 2 '/home/oracle/db01/redo02.log' size 50m;

7.构造数据字典和PL/SQL运行环境
@?/rdbms/admin/catalog
@?/rdbms/admin/catproc
