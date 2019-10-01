启动数据库的三个阶段：

第一个阶段：nomount
shutdown --> nomount
startup nomount

SQL> select status from v$instance;

STATUS
------------
STARTED

做了什么？
  分配实例，写跟踪文件
需要什么？
  参数文件，审计路径，诊断路径
我们能做什么？
  查看参数
  修改参数
  查看内存分配
    select * from v$pgastat;
    select * from v$sgainfo;
  查看后台进程
    select name from v$bgprocess where paddr<>'00';
  *可以创建数据库
  可以重建控制文件
～～～～～～～～～～～～～～～～
第二个阶段：mount
shutdown --> mount
startup mount
nomount --> mount
alter database mount;

SQL> select status from v$instance;

STATUS
------------
MOUNTED

做了什么？
  加载控制文件的信息到内存！
需要什么？
  控制文件
我们能做什么？
  备份、还原、恢复数据库
  对数据文件进行offline
  移动文件（联机日志、数据文件、临时文件、块跟踪文件）
  打开和关闭归档模式
  打开和关闭闪回数据库的功能
  删除数据库
～～～～～～～～～～～～～～～～
第三个阶段：open
shutdown --> open
startup
nomount --> open
alter database mount;
alter database open;
mount --> open
alter database open;

做了什么？
  校验所有的联机日志文件和数据文件的存在否及有效性！
需要什么？
  联机日志文件和数据文件
我们能做什么？
 。。。。
#############################################
停库四中模式：
1.正常停库
shutdown normal = shutdown
普通会话的连接不允许建立
等待查询结束
等待事务结束
强制产生检查点（数据同步）
关闭联机日志文件和数据文件
关闭控制文件
关闭实例

2.事务级停库
shutdown transactional
普通会话的连接不允许建立
不等待查询（查询被杀掉）
等待事务结束
强制产生检查点（数据同步）
关闭联机日志文件和数据文件
关闭控制文件
关闭实例

3.立即停库:生产库最常用的方式
shutdown immediate
普通会话的连接不允许建立
不等待查询（查询被杀掉）
事务被回退（rollback）
强制产生检查点（数据同步）
关闭联机日志文件和数据文件
关闭控制文件
关闭实例

4.强制停库
shutdown abort
相当于拔电源

startup force = shutdown abort + startup
startup force nomount = shutdown abort + startup nomount
startup force mount = shutdown abort + startup mount

停止后是脏库！重新启动数据库时需要实例恢复！

