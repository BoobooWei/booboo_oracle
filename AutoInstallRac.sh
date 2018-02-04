#!/bin/bash

# rac1 		172.25.0.12	10.25.0.12	
# rac2 		172.25.0.13	10.25.0.13
# openfiler 	172.25.0.14	10.25.0.14

# 创建无密钥登陆
#for i in `seq 12 14`;do ssh-copy-id root@172.25.0.$i;done

# 0.手动解析

shoudong_jiexi(){
cat > hosts << ENDF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# Public Network - (eth0)
172.25.0.12 rac1.example.com rac1
172.25.0.13 rac2.example.com rac2

# Private Interconnect - (eth1)
10.25.0.12 rac1-priv.exampl.com rac1-priv
10.25.0.13 rac2-priv.exampl.com rac2-priv

# Public Virtual IP (eth0:xx)
172.25.0.15 rac1-vip.example.com rac1-vip
172.25.0.16 rac2-vip.example.com rac2-vip
ENDF

for i in `seq 12 14`;do scp hosts root@172.25.0.$i:/etc/hosts;done

}


# 1.所有节点都要关闭防火墙和SeLinux
disable_selinux_and_iptables(){
for i in `seq 12 14`;do ssh root@172.25.0.$i "service iptables stop;chkconfig iptables off; setenforce 0 &> /dev/null;sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config &> /dev/null";done
}

# 2.每个节点都要有至少两个物理网卡
# 3.所有节点的public IP指定网关
# 4.安装集群之前VIP不能ping通

set_network(){
for i in `seq 12 13`;do 

hwaddr0=`ssh root@172.25.0.$i "ip addr | sed -n '/eth0/,+1p'" | grep ether | awk '{print $2}'`
hwaddr1=`ssh root@172.25.0.$i "ip addr | sed -n '/eth1/,+1p'" | grep ether | awk '{print $2}'`

cat > eth0.$i << ENDF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
IPADDR=172.25.0.$i
NETMASK=255.255.255.0
HWADDR=$hwaddr0
GATEWAY=172.25.0.254
DNS1=172.25.0.12
ENDF

cat > eth1.$i << ENDF
DEVICE=eth1
BOOTPROTO=static
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.25.0.$i
NETMASK=255.255.255.0
HWADDR=$hwaddr1
ENDF

scp eth0.$i root@172.25.0.$i:/etc/sysconfig/network-scripts/ifcfg-eth0
scp eth1.$i root@172.25.0.$i:/etc/sysconfig/network-scripts/ifcfg-eth1
ssh root@172.25.0.$i "service network restart"
ssh root@172.25.0.$i "ifconfig" |grep -A 1 ^eth

done

}


# 5.创建用户并设置系统参数
add_user(){

cat > add_user << ENDF
#创建组:
groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
groupadd -g 504 asmadmin
groupadd -g 505 asmdba
groupadd -g 506 asmoper
#创建用户
useradd -u 502 -g oinstall -G dba,asmadmin,asmdba,asmoper grid
useradd -u 501 -g oinstall -G dba,oper,asmdba,asmadmin oracle
#修改用户口令
echo grid | passwd --stdin grid
echo oracle | passwd --stdin oracle
# 修改grid用户配置文件
cat >> /home/grid/.bashrc << ENDFC
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/grid
export ORACLE_OWNER=oracle
export ORACLE_SID=+ASM1 #rac2节点为ORACLE_SID=+ASM2
export ORACLE_TERM=vt100
export THREADS_FLAG=native
export LD_LIBRARY_PATH=\\\${ORACLE_HOME}/lib:\\\${LD_LIBRARY_PATH}
export PATH=\\\${ORACLE_HOME}/bin:\\\${PATH}
export LANG=en_US
alias sqlplus='rlwrap sqlplus'
alias lsnrctl='rlwrap lsnrctl'
alias asmcmd='rlwrap asmcmd'
ENDFC

# 修改oracle用户配置文件
cat >> /home/oracle/.bashrc << ENDFR
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\\\${ORACLE_BASE}/product/11.2.0/db_1
export ORACLE_OWNER=oracle
export ORACLE_SID=orcl1
export ORACLE_TERM=vt100
export THREADS_FLAG=native
export LD_LIBRARY_PATH=\\\${ORACLE_HOME}/lib:\\\${LD_LIBRARY_PATH}
export PATH=\\\${ORACLE_HOME}/bin:\\\${PATH}
export EDITOR=vi
export SQLPATH=/home/oracle
export LANG=en_US
alias sqlplus='rlwrap sqlplus'
alias lsnrctl='rlwrap lsnrctl'
alias rman='rlwrap rman'
alias dgmgrl='rlwrap dgmgrl'
ENDFR

# 修改主机shell限制
cat >> /etc/security/limits.conf << ENDFL
#grid & oracle configure shell parameters
grid soft nofile 65536
grid hard nofile 65536
grid soft nproc 16384
grid hard nproc 16384

oracle soft nofile 65536
oracle hard nofile 65536
oracle soft nproc 16384
oracle hard nproc 16384
ENDFL

# 修改主机内核参数
cat >> /etc/sysctl.conf << ENDFS
kernel.shmmax = 4294967296
kernel.shmmni = 4096
kernel.shmall = 2097152
kernel.sem = 250 32000 100 128
fs.file-max = 6815744
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
ENDFS

# 使内核参数生效
/sbin/sysctl -p
ENDF
for i in 12 13 ;do
scp add_user root@172.25.0.$i:/tmp/
ssh root@172.25.0.$i "bash /tmp/add_user"
done
}


# 配置grid用户和oracle用户的信任关系
set_rsa(){
cat >  gridrsafile << ENDF
#grid
ssh-keygen -t rsa -P "" -f /home/grid/.ssh/id_rsa
for i in 12 13 ;do ssh-copy-id grid@172.25.0.\${i} ;done
ssh rac1 date
ssh rac2 date
ssh rac1-priv date
ssh rac2-priv date
ENDF
cat > oraclersafile << ENDF
#oracle
ssh-keygen -t rsa -P "" -f /home/oracle/.ssh/id_rsa
for i in 12 13;do ssh-copy-id oracle@172.25.0.\${i} ;done
ssh rac1 date
ssh rac2 date
ssh rac1-priv date
ssh rac2-priv date
ENDF

#for i in 12 13; do scp gridrsafile oraclersafile root@172.25.0.$i:/tmp;done
#for i in 12 13; do ssh grid@172.25.0.$i "bash /tmp/gridrsafile";done
#for i in 12 13; do ssh oracle@172.25.0.$i "bash /tmp/oraclersafile";done
}


# 6.配置NTP


# 7.配置DNS
con_dns(){

cat > con_dns << ENDF
yum -y install bind bind-chroot caching-nameserver

cd /var/named/chroot/etc
cp -p named.caching-nameserver.conf named.conf
sed -i 's/{ .*; };/{ any; };/' named.conf 
cat > /etc/named.rfc1912.zones << ENDFN
zone "." IN {
	type hint;
	file "/dev/null";
};

zone "localdomain" IN {
	type master;
	file "localdomain.zone";
	allow-update { none; };
};

zone "localhost" IN {
	type master;
	file "localhost.zone";
	allow-update { none; };
};

zone "0.0.127.in-addr.arpa" IN {
	type master;
	file "named.local";
	allow-update { none; };
};

zone "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" IN {
        type master;
	file "named.ip6.local";
	allow-update { none; };
};

zone "255.in-addr.arpa" IN {
	type master;
	file "named.broadcast";
	allow-update { none; };
};

zone "0.in-addr.arpa" IN {
	type master;
	file "named.zero";
	allow-update { none; };
};

zone "oracle.com" IN {
        type master;
        file "oracle.com.zone";
        allow-update { none; };
}; 

zone "0.25.172.in-addr.arpa" IN {
        type master;
        file "0.25.172.local";
        allow-update { none; };
};
ENDFN
cp -p /var/named/named.local /var/named/chroot/var/named/oracle.com.zone
cp -p /var/named/named.local /var/named/chroot/var/named/0.25.172.local 

cat > /var/named/chroot/var/named/oracle.com.zone << ENDFO
\\\$TTL    86400
@               IN SOA  dns.oracle.com.      root.oracle.com. (
                                        42              ; serial (d. adams)
                                        3H              ; refresh
                                        15M             ; retry
                                        1W              ; expiry
                                        1D )            ; minimum
@       IN      NS      dns.oracle.com.
rac1    IN      A       172.25.0.12
rac2    IN      A       172.25.0.13
scan    IN      A       172.25.0.141
scan    IN      A       172.25.0.142
scan    IN      A       172.25.0.143 
ENDFO

cat > /var/named/chroot/var/named/0.25.172.local << ENDFP
\\\$TTL    86400
@       IN      SOA     dns.oracle.com. root.oracle.com.  (
                                      1997022700 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
@       IN      NS      dns.oracle.com.
12       IN      PTR     rac1.oracle.com.
13       IN      PTR     rac2.oracle.com.
141     IN      PTR     scan.oracle.com.
142     IN      PTR     scan.oracle.com.
143     IN      PTR     scan.oracle.com. 
ENDFP

#重新启动服务
service named restart
chkconfig named on
ENDF

scp con_dns root@172.25.0.12:/tmp
ssh root@172.25.0.12 "bash /tmp/con_dns"

#配置客户端：rac1 & rac2
cat > resolv << ENDF
cat > /etc/resolv.conf << ENDFC
search oracle.com
nameserver 172.25.0.12
ENDFC


# 域名解析测试：
nslookup scan.oracle.com
nslookup 172.25.0.141
nslookup 172.25.0.142
nslookup 172.25.0.143

ENDF

for i in 12 13 ;do scp resolv root@172.25.0.$i:/tmp; ssh root@172.25.0.$i "bash /tmp/resolv";done


}

# 8.配置共享存储
# 9.创建相关目录：

mk_dir(){
cat > mk_dir << ENDF
mkdir -p /u01/grid
chown -R grid:oinstall /u01/grid
mkdir -p /u01/app/oracle
chown -R oracle:oinstall /u01/app/
chmod -R 775 /u01/
ENDF
scp mk_dir root@172.25.0.12:/tmp 
ssh root@172.25.0.12 "bash /tmp/mk_dir"
scp mk_dir root@172.25.0.13:/tmp
ssh root@172.25.0.13 "bash /tmp/mk_dir"
}

shoudong_jiexi
disable_selinux_and_iptables
set_network
add_user
set_rsa
con_dns
mk_dir
