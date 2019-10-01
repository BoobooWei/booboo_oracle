【管理参数文件】
【参数文件】约束实例的行为！
什么是参数（初始化参数）：
控制数据库功能、属性的一些开关！有效的值写入内存当中！

查看所有的初始化参数：
select name,value from v$parameter;

*只有db_name没有默认值！

查看非默认值的初始化参数：当前实例的特征参数
select NAME from v$parameter where ISDEFAULT<>'TRUE';

动态参数：参数在内存中的当前值是可以改变的，修改参数的代价比较小，不需要停止数据库
select NAME,ISSYS_MODIFIABLE from v$parameter where ISSYS_MODIFIABLE<>'FALSE' order by 2;
DEFERRED : 参数修改后的新值对已持续连接无效
IMMEDIATE: 参数修改后的新值对所有会话立即生效

静态参数：参数在内存中的当前值不可以被修改
select NAME,ISSYS_MODIFIABLE from v$parameter where ISSYS_MODIFIABLE='FALSE';

非默认值的初始化参数被写入到【参数文件】，启动实例时读取参数文件中的特征参数值！

【参数文件】存放的位置：$ORACLE_HOME/dbs
【参数文件】的种类：
1.spfile(server parameter file)
二进制的
只能放在服务器端
脱离文进系统的束缚
spfile优先级高于pfile
只能使用sql命令修改参数值

2.pfile(parameter file)
ascii文件
可以放在服务器端也可以放在客户端
只能放在文件系统下
pfile历史更悠久
使用文本编辑器直接修改

【参数文件】命名规则：
spfile<$ORACLE_SID>.ora
spfile.ora
init<$ORACLE_SID>.ora

spfile启动的实例，如何修改动态参数内存中的值：
alter system set open_cursors=400 scope=memory;

spfile启动的实例，如何修改动态参数在参数文件中的值：
alter system set open_cursors=500 scope=spfile;

spfile启动的实例，如何修改动态参数内存中的值和参数文件中的值：
alter system set open_cursors=600 scope=both;
alter system set open_cursors=600;

spfile启动的实例，如何修改静态参数在参数文件中的值：
alter system set memory_max_target=1g scope=spfile;
如果静态参数的修改之后需要重新启动实例参能生效！
*参数文件中的参数值值有在实例启动时被读取一遍！

创建pfile：使用sys创建会话之后就可以使用的命令！不需要启动数据库！
create pfile from spfile;

pfile启动的实例，如何修改动态参数内存中的值：
alter system set open_cursors=400;

pfile启动的实例，如何修改动态参数在参数文件中的值：
使用文本编辑器直接修改参数文件！

pfile启动的实例，如何修改动态参数内存中的值和参数文件中的值：
alter system set open_cursors=500;
再使用文本编辑器修改参数文件！

pfile启动的实例，如何修改静态参数在参数文件中的值：
使用文本编辑器直接修改参数文件！

修改pfile的位置：
startup pfile='/home/oracle/orcl.ora'

修改spfile的位置：
vi $ORACLE_HOME/dbs/initorcl.ora
-------------------------------------
spfile='/home/oracle/2.ora'
-------------------------------------

将spfile写入字符设备（裸设备）：
制作二进制文件
dd if=/dev/zero of=/disk1 bs=1M count=10
将二进制文件初始化为块设备
losetup /dev/loop1 /disk1
将块设备初始化为字符设备（裸设备）
raw /dev/raw/raw1 /dev/loop1
chown oracle.oinstall /dev/raw/raw1

shut immediate
create spfile='/dev/raw/raw1' from pfile='/home/oracle/orcl.ora';

vi $ORACLE_HOME/dbs/initorcl.ora
-------------------------------------
spfile='/dev/raw/raw1'
-------------------------------------
startup

show parameter spfile

