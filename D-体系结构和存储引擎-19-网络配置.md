
```bash
服务器端的配置：
配置监听程序
vi $ORACLE_HOME/network/admin/listener.ora
----------------------------------------------------------------------------
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 1521))
    )
  )
----------------------------------------------------------------------------

启动监听程序：
lsnrctl stop LISTENER
lsnrctl start LISTENER
lsnrctl status LISTENER

注册实例到监听程序：
SQL> alter system register;

(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.25.0.10)(PORT=1521)))
Service "cctv" has 1 instance(s).
  Instance "cctv", status READY, has 1 handler(s) for this service...

客户端的配置：
配置服务命名
vi $ORACLE_HOME/network/admin/tnsnames.ora
----------------------------------------------------------------------------
teach =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cctv)
    )
  )
----------------------------------------------------------------------------

联网测试：
sqlplus scott/tiger@teach

配置实例的静态注册
vi $ORACLE_HOME/network/admin/listener.ora
----------------------------------------------------------------------------
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = cctv) # show parameter db_unique_name
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = cctv) # echo $ORACLE_SID
    )
  )
----------------------------------------------------------------------------

修改监听的端口号：
vi $ORACLE_HOME/network/admin/listener.ora
----------------------------------------------------------------------------
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 7788))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = cctv) # show parameter db_unique_name
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = cctv) # echo $ORACLE_SID
    )
  )
----------------------------------------------------------------------------

修改监听的名字
vi $ORACLE_HOME/network/admin/listener.ora
----------------------------------------------------------------------------
L2 =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 7788))
    )
  )

SID_LIST_L2 =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = cctv) # show parameter db_unique_name
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = cctv) # echo $ORACLE_SID
    )
  )
----------------------------------------------------------------------------
lsnrctl stop L2
lsnrctl start L2
lsnrctl status L2

共享服务器：
alter system set shared_servers=5;
alter system set shared_server_sessions=20;
show parameter dispatchers
select * from v$dispatcher;
alter system set dispatchers='(ADDRESS=(PROTOCOL=tcp)(HOST=172.25.0.10)(PORT=14597)(DISPATCHERS=5))';
alter system set local_listener='(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.25.0.10)(PORT=7788)))';

修改客户端，以共享方式连接服务器：
----------------------------------------------------------------------------
test =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 7788))
    (CONNECT_DATA =
      (SERVER = SHARED)
      (SERVICE_NAME = cctv)
    )
  )
----------------------------------------------------------------------------

select sid,username,server from v$session where username='SCOTT';

客户端的故障转移配置：
----------------------------------------------------------------------------
fail =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.25.0.10)(PORT = 7788))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = cctv)
      (FAILOVER_MODE =
        (TYPE = select)
        (METHOD = basic)
        (RETRIES = 180)
        (DELAY = 5) 
      )
    )
  )
----------------------------------------------------------------------------
```
