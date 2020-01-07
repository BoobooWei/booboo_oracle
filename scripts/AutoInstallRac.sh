#!/bin/bash
# centos6 install oracle 11.2.0.4 rac
# Usage: bash AutoInstallRac.sh 1|2

# 资源规划-全局参数配置
set_resource_plan(){
## 节点主机名，公网ip，内网ip，外网虚拟ip，scan-ip
node1_hostname=rac1
node1_public_ip=eth0:172.16.10.19
node1_public_vip=172.16.10.29
node1_private_ip=eth1:172.16.2.75
scan_ip=172.16.10.88
scan_name=rac-cluster

node2_hostname=rac2
node2_public_ip=eth0:172.16.10.20
node2_public_vip=172.16.10.30
node2_private_ip=eth1:172.16.2.76

## 路径
rac_dir=/alidata/
grid_dir=/home/grid/
oracle_dir=/home/oracle/

## swap_count= 期待的swap大小(G) / bs=1024
swap_count=$((16*1024*1024*1024/1024))
#16777216

## 共享存储
shared_storage=("/dev/vdb1" "/dev/vdb2")


# 获取内网ip和网卡
node1_private_ip_addr=${node1_private_ip#*:}
node1_private_ip_eth=${node1_private_ip/:*}
node2_private_ip_addr=${node2_private_ip#*:}
node2_private_ip_eth=${node2_private_ip/:*}

# 获取外网ip和网卡
node1_public_ip_addr=${node1_public_ip#*:}
node1_public_ip_eth=${node1_public_ip/:*}
node2_public_ip_addr=${node2_public_ip#*:}
node2_public_ip_eth=${node2_public_ip/:*}



# 手动创建root用户无密钥登陆两个节点
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
for i in ${node1_private_ip_addr} ${node2_private_ip_addr}
do
    ssh-copy-id root@${i}
done
}

# rac common 环境配置
set_oracle_comm_env(){
# 1 设置root环境参数
sed -i '/PS1/d;1aexport PS1=[`whoami`@`hostname`:'$PWD']"# "' /root/.bash_profile
# 2 修改主机名
# 3 软件安装
yum groupinstall -y "Desktop"
yum groupinstall -y "Desktop Platform"
yum groupinstall -y "Desktop Platform Development"
yum groupinstall -y "Fonts"
yum groupinstall -y "General Purpose Desktop"
yum groupinstall -y "Graphical Administration Tools"
yum groupinstall -y "Graphics Creation Tools"
yum groupinstall -y "Input Methods"
yum groupinstall -y "X Window System"
yum groupinstall -y "Chinese Support [zh]"
yum groupinstall -y "Internet Browser"
yum install libaio-devel -y
yum install compat-libstdc++-33 -y
yum install elfutils-libelf-devel -y
yum install tcl -y
yum install expect -y
yum install glibc -y
yum install libc.so.6 -y
yum install libcap.so.1 -y
yum install unixODBC-devel -y
yum install sysstat -y
yum install make -y
yum install unzip -y
yum install lrzsz -y
yum install libstdc++-devel -y
yum install gcc-c++ -y
yum install smartmontools -y
yum install subversion gcc-c++ openssl-devel -y
yum install bind bind-chroot bind-util bind-libs -y
yum install tigervnc-server -y
# 4 配置swap
## 4.1 清楚当前的swap配置
for i in `sed -n '/swap/p' /etc/fstab | awk '{print $1}'`; do swapoff $i; done
sed -i '/swap/d' /etc/fstab
## 4.2 配置新的swap分区

# 5 配置操作系统参数
# 5.1 配置/etc/sysctl.conf参数
sed -i '/kernel.shmmax/d;/kernel.shmmni/d;/kernel.shmall/d;/kernel.sem/d;/fs.file-max/d;/fs.aio-max-nr/d;/net.ipv4.ip_local_port_range/d;/net.core.rmem_default/d;/net.core.rmem_max/d;/net.core.wmem_default/d;/net.core.wmem_max/d;' /etc/sysctl.conf
cat > /etc/sysctl.conf << ENDFS
kernel.shmmax = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 )
kernel.shmmni = 4096
kernel.shmall = $(expr `cat /proc/meminfo | sed -n '1p'|awk '{print $2}'` \* 1024 / `getconf PAGESIZE`)
kernel.sem = 250 32000 100 128
fs.file-max = 6815744
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
ENDFS
/sbin/sysctl -p
# 5.2 配置/etc/security/limits.conf参数
sed -i '/grid*/d;/oracle*/d' /etc/security/limits.conf
cat >> /etc/security/limits.conf << ENDFL
#grid & oracle configure shell parameters
grid    soft    nproc   2047
grid    hard    nproc   16384
grid    soft    nofile  1024
grid    hard    nofile  65536
oracle  soft    nproc   2047
oracle  hard    nproc   16384
oracle  soft    nofile  1024
oracle  hard    nofile  65536
ENDFL

# 5.3 配置/etc/pam.d/login参数
sed -i '/session.*required.*pam_limits.so/d' /etc/pam.d/login
echo "session    required     pam_limits.so" >> /etc/pam.d/login
# 5.4 关闭iptables & selinux
service iptables stop;chkconfig iptables off; setenforce 0 &> /dev/null;sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config &> /dev/null
# 5.5 设置主机启动级别为5 图形界面
sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab
# 5.6 配置 modprobe hangcheck-timer
## hangcheck-计时器被加载到Linux内核中并检查系统是否挂起。它将设置一个计时器，并在特定的时间量之后检查该计时器。有一个用于检查挂起情况的可配置阈值，如果超过该阈值，计算机将重新启动。尽管Oracle CRS并不需要hangcheck-timer模块，但Oracle强烈建议使用它。
## hangcheck-timer模块使用了一个基于内核的计时器，该计时器周期性地检查系统任务调度程序，以捕获延迟，从而确定系统的运行状况。如果系统挂起或暂停，则计时器重置该节点。hangcheck-timer模块使用时间戳计数器(TSC) CPU寄存器，该寄存器在每个时钟信号处递增。由于此寄存器由硬件自动更新，因此TCS提供了更精确的时间度量。
/sbin/modprobe hangcheck-timer hangcheck_tick=30 hangcheck_margin=180
sed -i '/.* hangcheck-timer.*/d' /etc/rc.local
echo "/sbin/modprobe hangcheck-timer hangcheck_tick=30 hangcheck_margin=180" >> /etc/rc.local
# 5.7 配置/etc/profile文件
sed -i '/USER = "grid"/,+10d' /etc/profile
cat >> /etc/profile << ENDF
if [ \$USER = "oracle" ] || [ \$USER = "grid" ]; then
if [ \$SHELL = "/bin/ksh" ]; then
ulimit -u 16384
ulimit -n 65536
else
ulimit -u 16384 -n 65536
fi

umask 022
fi
ENDF

# 6 创建用户及组
## 检查是否存在501-506的用户
sed -n '/:50[16]:/p' /etc/passwd
groupadd -g 501 oinstall
groupadd -g 502 asmadmin
groupadd -g 503 asmdba
groupadd -g 504 asmoper
groupadd -g 505 dba
groupadd -g 506 oper
/usr/sbin/useradd -u 501 -g oinstall -G dba,asmdba,oper oracle
/usr/sbin/useradd -u 502 -g oinstall -G asmadmin,asmdba,asmoper,dba grid
echo "oracle" | passwd --stdin oracle
echo "grid" | passwd --stdin grid


# 7 创建目录
mkdir -p ${rac_dir}/oracle
mkdir -p ${rac_dir}/grid
mkdir -p ${rac_dir}/grid/app/grid
mkdir -p ${rac_dir}/grid/app/12.2.0/grid
mkdir -p ${rac_dir}/oracle/product/12.2.0/dbhome_1

chown -R grid:oinstall ${rac_dir}//grid
chown -R oracle:oinstall ${rac_dir}//oracle
chmod -R 775 ${rac_dir}/

# 8 设置oracle用户环境变量

# 9 设置grid用户环境变量

# 10 设置/etc/hosts文件
cat > /etc/hosts << ENDF
# Public Network - (${node1_public_ip_eth})
${node1_public_ip_addr} ${node1_hostname}.example.com ${node1_hostname}
${node2_public_ip_addr} ${node2_hostname}.example.com ${node2_hostname}

# Private Interconnect - (${node1_private_ip_eth})
$node1_private_ip_addr ${node1_hostname}-priv.example.com ${node1_hostname}-priv
$node2_private_ip_addr ${node2_hostname}-priv.example.com ${node2_hostname}-priv

# Public Virtual IP
${node1_public_vip} ${node1_hostname}-vip.example.com ${node1_hostname}-vip
${node2_public_vip} ${node2_hostname}-vip.example.com ${node2_hostname}-vip

# scanIP
${scan_ip} ${scan_name}
ENDF

# 11 获取安装包
mkdir -p /software/database
mkdir -p /software/grid
mkdir -p /software/patch
cd /software/grid
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_3of7.zip
unzip p13390677_112040_Linux-x86-64_3of7.zip

cd /software/database
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_1of7.zip
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_2of7.zip
unzip p13390677_112040_Linux-x86-64_1of7.zip
unzip p13390677_112040_Linux-x86-64_2of7.zip
chown -R oracle:oinstall /software/database
chown -R grid:oinstall   /software/grid

cd /software/patch
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/n2n.tgz
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracleasmlib-2.0.4-1.el6.x86_64.rpm
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/cvuqdisk-1.0.9-1.rpm
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracleasm-support-2.1.8-1.el6.x86_64.rpm
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/kmod-oracleasm-2.0.8-15.el6_9.x86_64.rpm
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-30.x86_64.rpm

# 13 配置NTP
/sbin/service ntpd stop
chkconfig ntpd off
mv /etc/ntp.conf /etc/ntp.conf.org

}

# rac1环境配置
set_oracle_rac1_env(){
# 2 修改主机名
sed -i "/HOSTNAME/d;1aHOSTNAME=${node1_hostname}" /etc/sysconfig/network
# 8 设置oracle用户环境变量
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/oracle/.bash_profile
cat >> /home/oracle/.bash_profile << ENDF
# autoinstall_rac_s
export PATH
export ORACLE_BASE=/alidata/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=${node1_hostname}
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=\$ORACLE_HOME/bin:\$PATH:\$HOME/bin
export PS1=[\`whoami\`@\`hostname\`:'\$PWD']"# "
# autoinstall_rac_e
ENDF

# 9 设置grid用户环境变量
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=/alidata/grid/app/grid
export ORACLE_HOME=/alidata/grid/app/11.2.0/grid
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM1
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PS1=[\`whoami\`@\`hostname\`:'\$PWD']"# "
# autoinstall_rac_e
AENDF
}

# rac2环境配置
set_oracle_rac2_env(){
# 2 修改主机名
sed -i "/HOSTNAME/d;1aHOSTNAME=${node2_hostname}" /etc/sysconfig/network
# 8 设置oracle用户环境变量
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/oracle/.bash_profile
cat >> /home/oracle/.bash_profile << ENDF
# autoinstall_rac_s
export PATH
export ORACLE_BASE=/alidata/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=${node2_hostname}
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=\$ORACLE_HOME/bin:\$PATH:\$HOME/bin
export PS1=[\`whoami\`@\`hostname\`:'\$PWD']"# "
# autoinstall_rac_e
ENDF

# 9 设置grid用户环境变量
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=/alidata/grid/app/grid
export ORACLE_HOME=/alidata/grid/app/11.2.0/grid
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM2
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PS1=[\`whoami\`@\`hostname\`:'\$PWD']"# "
# autoinstall_rac_e
AENDF
}

others(){
# 以下部分手动
# 12 配置N2N
# 忽略

# 14 VNC可以不需要配置，控制台登陆图形化界面

# 15 配置DNS
cp /software/patch/n2n.tgz /alidata/
cd /alidata
tar -xvf n2n.tgz
cd /alidata/n2n/n2n_v2/
make && make install

# rac1
supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a 172.16.10.19 -s 255.255.255.0 -E -c racnet1 -k Password -l 172.16.1.19:22087 -d eth2  -r

cat >> /etc/rc.local << "EOF"
supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a 172.16.10.19 -s 255.255.255.0 -E -c racnet1 -k Password -l 172.16.1.19:22087 -d eth2  -r

# rac2
supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a 172.16.10.20 -s 255.255.255.0 -E -c racnet1 -k Password -l 172.16.1.19:22087 -d eth2  -r

cat >> /etc/rc.local << "EOF"
supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a 172.16.10.20 -s 255.255.255.0 -E -c racnet1 -k Password -l 172.16.1.19:22087 -d eth2  -r
EOF



# 16 配置节点间的ssh信任
# su - grid
# su - oracle
ssh-keygen
ssh-copy-id rac1
ssh-coyy-id rac2
for i in rac1 rac2 rac1-priv rac2-priv rac1.example.com rac2.example.com rac1-priv.example.com rac2-priv.example.com ;do ssh $i date;done

# 17 配置存储
# 一下为测试使用
# 服务端（rac1）
yum install -y scsi-target-utils
cat >> /etc/tgt/targets.conf << ENDF
<target iqn.2020-001.com.iscsi:oracle>
backing-store ${shared_storage[0]}
backing-store ${shared_storage[1]}
</target>
ENDF

service tgtd start
chkconfig tgtd on
tgtadm --lld iscsi --mode target --op show

# 客户端（rac1 rac2）

yum install -y iscsi-initiator-utils lsscsi
iscsiadm -m discovery -t st -p 172.16.2.75
iscsiadm -m node -l

vi /etc/udev/rules.d/60-raw.rules
ACTION=="add", KERNEL=="sda", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb", RUN+="/bin/raw /dev/raw/raw2 %N"
KERNEL=="raw[1-2]", MODE="0660", GROUP="asmadmin", OWNER="grid"


start_udev


# 18 grid安装验证
cd /lib64/
ln -s libcap.so.2.16 libcap.so.1

crs_stat -t

# 19 创建DATA 磁盘组
asmca

}

set_resource_plan
set_oracle_comm_env
if [[ $1 == 1 ]]
then
    set_oracle_rac1_env
elif [[ $1 == 2 ]]
then
    set_oracle_rac2_env
fi


