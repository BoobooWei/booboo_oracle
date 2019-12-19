# 创建scott学习环境


```shell
/alidata/app/oracle/product/11.2.0/dbhome_1/rdbms/admin/utlsampl.sql
sqlplus / as sysdba
> conn system/oracle;
> @utlsampl.sql;

sqlplus / as sysdba
> conn scott/tiger;
```

练习

```shell
[oracle@db admin]$ ll utlsampl.sql
-rw-r--r-- 1 oracle oinstall 3676 Jun  2  2006 utlsampl.sql
[oracle@db admin]$ pwd
/alidata/app/oracle/product/11.2.0/dbhome_1/rdbms/admin
[oracle@db admin]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Thu Apr 11 16:36:14 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL> conn system/oracle;
Connected.
SQL> @utlsampl.sql;
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
[oracle@db admin]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Thu Apr 11 16:37:16 2019

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL> conn scott/tiger;
Connected.
```
