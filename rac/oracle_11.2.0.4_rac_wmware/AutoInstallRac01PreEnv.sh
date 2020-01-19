#!/bin/bash
# centos6 install oracle 11.2.0.4 rac 环境配置
# AutoInstallRac01PreEnv.sh
# Usage: bash AutoInstallRac.sh 1|2
# Auth: BoooBooWei 2020.01.09
# 测试脚本，共享存储通过node1节点搭建iscsi实现。

echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

source ${scripts_dir}/set_resource_plan.sh

check_user(){
username=`whoami`
echo_green "当前用户为 ${username}"
if [[ ${username} == $1 ]]
then
    echo_green "执行用户与要求一致"
else
    echo_red "执行用户与要求不一致，请切换用户为 $1"
fi
}

set_oracle_comm_env(){
echo_red "Oracle RAM COMMON 环境配置 开始"
echo_green "设置/etc/hosts文件"
cat > /etc/hosts << ENDF
# Public Network - (${node1_public_ip_eth})
${node1_public_ip_addr} ${node1_domain_pub[@]}
${node2_public_ip_addr} ${node2_domain_pub[@]}

# Private Interconnect - (${node1_private_ip_eth})
$node1_private_ip_addr ${node1_domain_pri[@]}
$node2_private_ip_addr ${node2_domain_pri[@]}

# Public Virtual IP
${node1_public_vip} ${node1_domain_pub_v[@]}
${node2_public_vip} ${node2_domain_pub_v[@]}

# scanIP
${scan_ip} ${scan_name}
ENDF

cat /etc/hosts

echo_green "配置/etc/sysctl.conf参数"
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


echo_green "配置/etc/security/limits.conf参数"
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


echo_green "配置/etc/pam.d/login参数"
sed -i '/session.*required.*pam_limits.so/d' /etc/pam.d/login
echo "session    required     pam_limits.so" >> /etc/pam.d/login


echo_green "关闭iptables & selinux"
service iptables stop;chkconfig iptables off; setenforce 0 &> /dev/null;sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config &> /dev/null


echo_green "配置 modprobe hangcheck-timer"
## hangcheck-计时器被加载到Linux内核中并检查系统是否挂起。它将设置一个计时器，并在特定的时间量之后检查该计时器。有一个用于检查挂起情况的可配置阈值，如果超过该阈值，计算机将重新启动。尽管Oracle CRS并不需要hangcheck-timer模块，但Oracle强烈建议使用它。
## hangcheck-timer模块使用了一个基于内核的计时器，该计时器周期性地检查系统任务调度程序，以捕获延迟，从而确定系统的运行状况。如果系统挂起或暂停，则计时器重置该节点。hangcheck-timer模块使用时间戳计数器(TSC) CPU寄存器，该寄存器在每个时钟信号处递增。由于此寄存器由硬件自动更新，因此TCS提供了更精确的时间度量。
/sbin/modprobe hangcheck-timer hangcheck_tick=30 hangcheck_margin=180
sed -i '/.* hangcheck-timer.*/d' /etc/rc.local
echo "/sbin/modprobe hangcheck-timer hangcheck_tick=30 hangcheck_margin=180" >> /etc/rc.local


echo_green "配置/etc/profile文件"
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


echo_green "创建用户及组"
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


echo_green "创建目录"
mkdir -p ${rac_dir}/oracle
mkdir -p ${rac_dir}/grid
mkdir -p ${rac_dir}/grid/app/grid
mkdir -p ${rac_dir}/grid/app/12.2.0/grid
mkdir -p ${rac_dir}/oracle/product/12.2.0/dbhome_1

chown -R grid:oinstall ${rac_dir}//grid
chown -R oracle:oinstall ${rac_dir}//oracle
chmod -R 775 ${rac_dir}/


echo_green "配置NTP"
/sbin/service ntpd stop
chkconfig ntpd off
mv /etc/ntp.conf /etc/ntp.conf.org


echo_green "swap分区150M"
dd if=/dev/zero of=/home/swap bs=1024 count=154000
mkswap /home/swap
swapon /home/swap
sed -i '/auto install rac start/,/auto install rac end/d' /etc/fstab
echo >> /etc/fatab << ENDF
# auto install rac start
/home/swap swap swap defaults 0 0
# auto install rac end
ENDF
}

set_oracle_rac1_env(){
echo_red "rac1环境配置 开始"
echo_green "修改主机名"
sed -i "/HOSTNAME/d;1aHOSTNAME=${node1_hostname}" /etc/sysconfig/network
echo_green "设置oracle用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/oracle/.bash_profile
cat >> /home/oracle/.bash_profile << ENDF
# autoinstall_rac_s
export PATH
export ORACLE_BASE=${oracle_oracle_base}
export ORACLE_HOME=${oracle_oracle_home}
export ORACLE_SID=${database_name}1
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=\$ORACLE_HOME/bin:\$PATH:\$HOME/bin
# autoinstall_rac_e
ENDF

echo_green "设置grid用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=${grid_oracle_base}
export ORACLE_HOME=${grid_oracle_home}
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM1
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
# autoinstall_rac_e
AENDF

echo_green "配置节点间的ssh信任"
cat > /tmp/ssh_grid_oracle.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} ${node1_physic_ip_addr}"
ssh-copy-id "-p ${ssh_port} ${node2_physic_ip_addr}"
for i in ${node1_domain_pub[@]} ${node1_domain_pri[@]} ${node2_domain_pub[@]} ${node2_domain_pri[@]};do ssh \$i -p ${ssh_port} date;done
ENDF

echo_red "rac1环境配置 结束"
}

set_oracle_rac2_env(){
echo_red "rac2环境配置 开始"
echo_green "修改主机名"
sed -i "/HOSTNAME/d;1aHOSTNAME=${node2_hostname}" /etc/sysconfig/network
echo_green "设置oracle用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/oracle/.bash_profile
cat >> /home/oracle/.bash_profile << ENDF
# autoinstall_rac_s
export PATH
export ORACLE_BASE=${oracle_oracle_base}
export ORACLE_HOME=${oracle_oracle_home}
export ORACLE_SID=${database_name}2
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=\$ORACLE_HOME/bin:\$PATH:\$HOME/bin
# autoinstall_rac_e
ENDF

echo_green "设置grid用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=${grid_oracle_base}
export ORACLE_HOME=${grid_oracle_home}
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM2
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
# autoinstall_rac_e
AENDF

echo_green "配置节点间的ssh信任"
cat > /tmp/ssh_grid_oracle.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} ${node1_physic_ip_addr}"
ssh-copy-id "-p ${ssh_port} ${node2_physic_ip_addr}"
for i in ${node1_domain_pub[@]} ${node1_domain_pri[@]} ${node2_domain_pub[@]} ${node2_domain_pri[@]};do ssh \$i -p ${ssh_port} date;done
ENDF

echo_red "rac2环境配置 结束"
}

set_isscsi_node1(){
echo_red "配置存储target-测试使用"
echo_green "服务端（rac1)"
yum install -y scsi-target-utils &> /dev/null
cat >> /etc/tgt/targets.conf << ENDF
<target iqn.2020-001.com.iscsi:oracle>
backing-store ${shared_storage[0]}
backing-store ${shared_storage[1]}
</target>
ENDF

service tgtd start
chkconfig tgtd on
tgtadm --lld iscsi --mode target --op show

echo_green "配置存储客户端-测试使用(rac1)"
yum install -y iscsi-initiator-utils lsscsi  &> /dev/null
iscsiadm -m discovery -t st -p ${node1_physic_ip_addr}
iscsiadm -m node -l
cat >> /etc/udev/rules.d/60-raw.rules << ENDF
ACTION=="add", KERNEL=="sda", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb", RUN+="/bin/raw /dev/raw/raw2 %N"
KERNEL=="raw[1-2]", MODE="0660", GROUP="asmadmin", OWNER="grid"
ENDF

start_udev
lsscsi
ls -l  /dev/raw
}

set_isscsi_node2(){
echo_red "配置存储客户端-测试使用(rac2)"
yum install -y iscsi-initiator-utils lsscsi  &> /dev/null
iscsiadm -m discovery -t st -p ${node1_physic_ip_addr}
iscsiadm -m node -l

cat >> /etc/udev/rules.d/60-raw.rules << ENDF
ACTION=="add", KERNEL=="sda", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb", RUN+="/bin/raw /dev/raw/raw2 %N"
KERNEL=="raw[1-2]", MODE="0660", GROUP="asmadmin", OWNER="grid"
ENDF

start_udev
lsscsi
ls -l /dev/raw
}

set_oracle_pre_install(){
echo_red "依赖软件包安装和Oracle RAC软件下载 开始"
echo_green "依赖软件包安装"
yum groupinstall -y "Desktop"  &> /dev/null
yum groupinstall -y "Desktop Platform"  &> /dev/null
yum groupinstall -y "Desktop Platform Development"  &> /dev/null
yum groupinstall -y "Fonts"  &> /dev/null
yum groupinstall -y "General Purpose Desktop"  &> /dev/null
yum groupinstall -y "Graphical Administration Tools"  &> /dev/null
yum groupinstall -y "Graphics Creation Tools"  &> /dev/null
yum groupinstall -y "Input Methods"  &> /dev/null
yum groupinstall -y "X Window System"  &> /dev/null
yum groupinstall -y "Chinese Support [zh]"  &> /dev/null
yum groupinstall -y "Internet Browser"  &> /dev/null
yum install libaio-devel -y  &> /dev/null
yum install compat-libstdc++-33 -y  &> /dev/null
yum install elfutils-libelf-devel -y  &> /dev/null
yum install tcl -y  &> /dev/null
yum install expect -y  &> /dev/null
yum install glibc -y  &> /dev/null
yum install libc.so.6 -y  &> /dev/null
yum install libcap.so.1 -y  &> /dev/null
yum install unixODBC-devel -y  &> /dev/null
yum install sysstat -y  &> /dev/null
yum install make -y  &> /dev/null
yum install unzip -y  &> /dev/null
yum install lrzsz -y  &> /dev/null
yum install libstdc++-devel -y  &> /dev/null
yum install gcc-c++ -y  &> /dev/null
yum install smartmontools -y  &> /dev/null
yum install subversion gcc-c++ openssl-devel -y  &> /dev/null
yum install bind bind-chroot bind-util bind-libs -y  &> /dev/null
yum install tigervnc-server -y  &> /dev/null

echo_green "设置主机启动级别为5，即图形界面"
sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab

echo_green "Oracle RAC软件下载"
mkdir -p /software/database
mkdir -p /software/grid
mkdir -p /software/patch

echo_green "Oracle 集群软件 开始下载解压"
cd /software/grid
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_3of7.zip  &> /dev/null
unzip p13390677_112040_Linux-x86-64_3of7.zip  &> /dev/null
echo_green "Oracle 集群软件 下载解压完成"

echo_green "Oracle 数据库软件 开始下载解压"
cd /software/database
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_1of7.zip  &> /dev/null
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/p13390677_112040_Linux-x86-64_2of7.zip  &> /dev/null
unzip p13390677_112040_Linux-x86-64_1of7.zip  &> /dev/null
unzip p13390677_112040_Linux-x86-64_2of7.zip  &> /dev/null
chown -R oracle:oinstall /software/database
chown -R grid:oinstall   /software/grid
echo_green "Oracle 数据库软件 下载解压完成"

echo_green "Oracle 其他软件 开始下载解压"
cd /software/patch
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracleasmlib-2.0.4-1.el6.x86_64.rpm  &> /dev/null
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/cvuqdisk-1.0.9-1.rpm  &> /dev/null
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/oracleasm-support-2.1.8-1.el6.x86_64.rpm  &> /dev/null
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/kmod-oracleasm-2.0.8-15.el6_9.x86_64.rpm  &> /dev/null
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/pdksh-5.2.14-30.x86_64.rpm  &> /dev/null
echo_green "Oracle 其他软件 下载解压完成"

echo_green "添加软连接/lib64/libcap.so.1"
ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1

echo_green "安装依赖包pdksh 和 cvuqdisk"
rpm -ivh /software/patch/cvuqdisk-1.0.9-1.rpm &> /dev/null
rpm -ivh /software/patch/pdksh-5.2.14-30.x86_64.rpm &> /dev/null

echo_green "依赖软件包安装和Oracle RAC软件下载 结束"
}

echo_red "开始时间："
date +'%Y%m%d %H:%M:%S'
check_user root
set_oracle_comm_env
set_oracle_pre_install
if [[ $1 == 1 ]]
then
    set_oracle_rac1_env
    set_isscsi_node1
elif [[ $1 == 2 ]]
then
    set_oracle_rac2_env
    set_isscsi_node2
fi

source ${scripts_dir}/get_resource_plan.sh
echo_red "搭建GRID前还需要手动执行以下操作："
echo_green "1.重启服务器完成主机名的变更。"
echo_green "2.切换到grid用户手动执行/tmp/ssh_grid_oracle.sh"
echo_green "3.切换到oracle用户手动执行/tmp/ssh_grid_oracle.sh"
echo_red "结束时间："
date +'%Y%m%d %H:%M:%S'
