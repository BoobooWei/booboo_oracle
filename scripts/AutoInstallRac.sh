#!/bin/bash
# centos6 install oracle 11.2.0.4 rac
# Usage: bash AutoInstallRac.sh 1|2
# 测试脚本，共享存储通过node1节点搭建iscsi实现。

echo_read(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

set_resource_plan(){

ssh_port=22
database_name=racdb # 数据库名称

node1_hostname=rac1 # 节点1 名称，主机名，实例名
node1_physic_ip=eth0:172.16.1.19 # 节点1 真实的物理网卡和地址
node1_public_ip=eth1:172.16.10.19 # 节点1 公共IP 网卡和地址
node1_public_vip=172.16.10.29 # 节点1 虚拟IP 网卡和地址
node1_private_ip=eth2:172.16.2.75 # 节点1 专用IP 网卡和地址
node1_domain_pub=(rac1 rac1.example.com) # 节点1 公共IP 域名
node1_domain_pub_v=(rac1-vip rac1-vip.example.com) # 节点1 虚拟IP 域名
node1_domain_pri=(rac1-priv rac1-priv.example.com) # 节点1 专用IP 域名


node2_hostname=rac2 # 节点2 名称，主机名，实例名
node2_physic_ip=eth0:172.16.1.20 # 节点2 真实的物理网卡和地址
node2_public_ip=eth1:172.16.10.20 # 节点2 公共IP 网卡和地址
node2_public_vip=172.16.10.30 # 节点2 虚拟IP 网卡和地址
node2_private_ip=eth2:172.16.2.76 # 节点2 专用IP 网卡和地址
node2_domain_pub=(rac2 rac2.example.com) # 节点2 公共IP 域名
node2_domain_pub_v=(rac2-vip rac2-vip.example.com) # 节点2 虚拟IP 域名
node2_domain_pri=(rac2-priv rac2-priv.example.com) # 节点2 专用IP 域名

scan_ip=172.16.10.88 # SCAN IP 地址
scan_name=rac-cluster-scan # SCAN名称

rac_dir=/alidata/ # rac和oracle安装最顶级目录
shared_storage=("/dev/vdb1" "/dev/vdb2") # 共享存储块设备


# 获取真实的物理网卡IP和网卡
node1_physic_ip_addr=${node1_physic_ip#*:}
node1_physic_ip_eth=${node1_physic_ip/:*}
node2_physic_ip_addr=${node2_physic_ip#*:}
node2_physic_ip_eth=${node2_physic_ip/:*}

# 获取专用IP和网卡
node1_private_ip_addr=${node1_private_ip#*:}
node1_private_ip_eth=${node1_private_ip/:*}
node2_private_ip_addr=${node2_private_ip#*:}
node2_private_ip_eth=${node2_private_ip/:*}

# 获取公共IP和网卡
node1_public_ip_addr=${node1_public_ip#*:}
node1_public_ip_eth=${node1_public_ip/:*}
node2_public_ip_addr=${node2_public_ip#*:}
node2_public_ip_eth=${node2_public_ip/:*}

# 交互式创建root用户无密钥登陆两个节点
rm -rf /root/.ssh/id_rsa
ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
for i in ${node1_physic_ip_addr} ${node2_physic_ip_addr}
do
    ssh-copy-id "-p ${ssh_port} root@${i}"
done


# 获取节点物理信息
node1_cpu=`lscpu| grep ^CPU\(s\): | awk '{print $2}'`
node2_cpu=`ssh ${node2_physic_ip_addr} -p ${ssh_port} lscpu| grep ^CPU\(s\): | awk '{print $2}'`

node1_mem=`cat /proc/meminfo | grep MemTotal| awk '{print $2 $3}'`
node2_mem=`ssh ${node2_physic_ip_addr} -p ${ssh_port} cat /proc/meminfo | grep MemTotal| awk '{print $2 $3}'`

node1_os=`cat /etc/redhat-release`
node2_os=`ssh ${node2_physic_ip_addr} -p ${ssh_port} cat /etc/redhat-release`

echo_read "节点信息"
printf "%-20s %-10s %-20s %-20s %-20s %-20s \n"  节点名称 数据库名称 处理器 内存 操作系统
printf "%-20s %-10s %-10s %-10s %-10s %-20s \n"  ${node1_hostname} ${database_name} ${node1_cpu} ${node1_mem} "${node1_os}"
printf "%-20s %-10s %-10s %-10s %-10s %-20s \n"  ${node2_hostname} ${database_name} ${node2_cpu} ${node2_mem} "${node2_os}"

echo_read "资源规划-全局参数配置"
printf "%-25s %-25s %-25s %-25s %-20s %-20s \n"  节点名称 公共IP-网卡 虚拟IP-网卡 专用IP-网卡 SCAN-IP SCAN名称
printf "%-20s %-20s %-20s %-20s %-20s %-20s \n"  ${node1_hostname} ${node1_public_ip_addr}-${node1_public_ip_eth} ${node1_public_vip}-${node1_public_vip_eth} ${node1_private_ip_addr}-${node1_private_ip_eth} ${scan_ip} ${scan_name}
printf "%-20s %-20s %-20s %-20s %-20s %-20s \n"  ${node2_hostname} ${node2_public_ip_addr}-${node2_public_ip_eth} ${node2_public_vip}-${node2_public_vip_eth} ${node2_private_ip_addr}-${node2_private_ip_eth}

echo_read "Oracle 软件组件"
printf "%-30s %-30s %-30s %-25s %-30s %-20s \n"  软件组件 操作系统用户 主组 辅助组 主目录 Oracle基目录/Oracle主目录
printf "%-30s %-20s %-20s %-30s %-20s %-20s \n"  "Grid Infrastructure" "grid  " "oinstall" "asmadmin、asmdba、asmoper" "/home/grid  " "/alidata/app/grid,/u01/app/11.2.0/grid"
printf "%-30s %-20s %-20s %-30s %-20s %-20s \n"  "Oracle RAC         " "oracle" "oinstall" "dba、oper、asmdba        " "/home/oracle" "/alidata/app/oracle,/alidata/app/oracle/product/11.2.0/dbhome_1"
}

set_oracle_comm_env(){
echo_read "Oracle RAM COMMON 环境配置 开始"
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
}

set_oracle_rac1_env(){
echo_read "rac1环境配置 开始"
echo_green "修改主机名"
sed -i "/HOSTNAME/d;1aHOSTNAME=${node1_hostname}" /etc/sysconfig/network
echo_green "设置oracle用户环境变量"
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
# autoinstall_rac_e
ENDF

echo_green "设置grid用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=/alidata/grid/app/grid
export ORACLE_HOME=/alidata/grid/app/11.2.0/grid
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM1
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
# autoinstall_rac_e
AENDF

echo_green "配置节点间的ssh信任"
echo_green "自动生成脚本文件，需要切换到grid用户手动执行/tmp/ssh_grid.sh"
cat > /tmp/ssh_grid.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} grid@${node2_physic_ip_addr}"
for i in ${node2_domain_pub[@]} ${node2_domain_pri[@]};do ssh \$i -p ${ssh_port} date;done
# ssh grid@${node2_physic_ip_addr} bash /tmp/ssh_grid.sh
# ssh oracle@${node2_physic_ip_addr} bash /tmp/ssh_oracle.sh
ENDF

cat /tmp/ssh_grid.sh


echo_green "自动生成脚本文件，需要切换到oracle用户手动执行/tmp/ssh_oracle.sh"
cat > /tmp/ssh_oracle.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} oracle@${node2_physic_ip_addr}"
for i in ${node2_domain_pub[@]} ${node2_domain_pri[@]};do ssh \$i -p ${ssh_port} date;done
# ssh grid@${node2_physic_ip_addr} bash /tmp/ssh_grid.sh
# ssh oracle@${node2_physic_ip_addr} bash /tmp/ssh_oracle.sh
ENDF


cat /tmp/ssh_oracle.sh
echo_read "rac1环境配置 开始"
}

set_oracle_rac2_env(){
echo_read "rac2环境配置 开始"
echo_green "修改主机名"
sed -i "/HOSTNAME/d;1aHOSTNAME=${node2_hostname}" /etc/sysconfig/network
echo_green "设置oracle用户环境变量"
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
# autoinstall_rac_e
ENDF

echo_green "设置grid用户环境变量"
sed -i '/autoinstall_rac_s/,/autoinstall_rac_e/d' /home/grid/.bash_profile
cat >> /home/grid/.bash_profile << AENDF
# autoinstall_rac_s
export ORACLE_BASE=/alidata/grid/app/grid
export ORACLE_HOME=/alidata/grid/app/11.2.0/grid
export PATH=\$ORACLE_HOME/bin:\$PATH:/usr/local/bin/
export ORACLE_SID=+ASM2
#export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#export NLS_LANG=AMERICAN_AMERICA.UTF8
# autoinstall_rac_e
AENDF

echo_green "配置节点间的ssh信任"
cat > /tmp/ssh_grid.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} grid@${node1_physic_ip_addr}"
for i in ${node1_domain_pub[@]} ${node1_domain_pub_v[@]} ${node1_domain_pri[@]};do ssh $i date;done
# ssh grid@${node1_physic_ip_addr} bash /tmp/ssh_grid.sh
# ssh oracle@${node1_physic_ip_addr} bash /tmp/ssh_oracle.sh
ENDF

cat > /tmp/ssh_oracle.sh << ENDF
ssh-keygen
ssh-copy-id "-p ${ssh_port} grid@${node1_physic_ip_addr}"
for i in ${node1_domain_pub[@]} ${node1_domain_pub_v[@]} ${node1_domain_pri[@]};do ssh $i date;done
# ssh grid@${node1_physic_ip_addr} bash /tmp/ssh_grid.sh
# ssh oracle@${node1_physic_ip_addr} bash /tmp/ssh_oracle.sh
ENDF

echo_read "rac2环境配置 结束"
}

set_n2n_node1(){
echo_read "安装配置N2N"
echo_green "下载N2N软件到目录 /software/patch"
mkdir -p /software/patch
cd /software/patch
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/n2n.tgz
cp /software/patch/n2n.tgz /alidata/
cd /alidata
tar -xvf n2n.tgz
cd /alidata/n2n/n2n_v2/
make && make install
echo_green "N2N 安装编译成功"
echo_green "N2N 配置公共IP 网卡和地址和 专用IP 网卡和地址"

supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a ${node1_public_ip_addr} -s 255.255.255.0 -E -c racnet1 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node1_public_ip_eth}  -r
/usr/sbin/edge -a ${node1_private_ip_addr} -s 255.255.255.0 -E -c racnet2 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node1_private_ip_eth}  -r

cat >> /etc/rc.local << "EOF"
supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a ${node1_public_ip_addr} -s 255.255.255.0 -E -c racnet1 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node1_public_ip_eth}  -r
/usr/sbin/edge -a ${node1_private_ip_addr} -s 255.255.255.0 -E -c racnet2 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node1_private_ip_eth}  -r
EOF
echo_read "安装配置N2N 结束"
}

set_n2n_node2(){
echo_read "安装配置N2N 开始"
echo_green "下载N2N软件到目录 /software/patch"
mkdir -p /software/patch
cd /software/patch
wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/oracle/n2n.tgz
cp /software/patch/n2n.tgz /alidata/
cd /alidata
tar -xvf n2n.tgz
cd /alidata/n2n/n2n_v2/
make && make install
echo_green "N2N 安装编译成功"
echo_green "N2N 配置公共IP 网卡和地址和 专用IP 网卡和地址"

supernode -l 22087 >/dev/null 2>&1 &
/usr/sbin/edge -a ${node2_public_ip_addr} -s 255.255.255.0 -E -c racnet1 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node2_public_ip_eth}  -r
/usr/sbin/edge -a ${node2_private_ip_addr} -s 255.255.255.0 -E -c racnet2 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node2_private_ip_eth}  -r

cat >> /etc/rc.local << "EOF"
/usr/sbin/edge -a ${node2_public_ip_addr} -s 255.255.255.0 -E -c racnet1 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node2_public_ip_eth}  -r
/usr/sbin/edge -a ${node2_private_ip_addr} -s 255.255.255.0 -E -c racnet2 -k Password -l ${node1_physic_ip_addr}:22087 -d ${node2_private_ip_eth}  -r
EOF
echo_read "安装配置N2N 结束"
}

set_isscsi_node1(){
echo_read "配置存储target-测试使用"
echo_green "服务端（rac1)"
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

echo_green "配置存储客户端-测试使用(rac1)"
yum install -y iscsi-initiator-utils lsscsi
iscsiadm -m discovery -t st -p ${node1_physic_ip_addr}
iscsiadm -m node -l
cat >> /etc/udev/rules.d/60-raw.rules << ENDF
ACTION=="add", KERNEL=="sda", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb", RUN+="/bin/raw /dev/raw/raw2 %N"
KERNEL=="raw[1-2]", MODE="0660", GROUP="asmadmin", OWNER="grid"
ENDF

start_udev

}

set_isscsi_node2(){
echo_read "配置存储客户端-测试使用(rac2)"
yum install -y iscsi-initiator-utils lsscsi
iscsiadm -m discovery -t st -p ${node1_physic_ip_addr}
iscsiadm -m node -l

cat >> /etc/udev/rules.d/60-raw.rules << ENDF
ACTION=="add", KERNEL=="sda", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb", RUN+="/bin/raw /dev/raw/raw2 %N"
KERNEL=="raw[1-2]", MODE="0660", GROUP="asmadmin", OWNER="grid"
ENDF

start_udev
}

set_oracle_pre_install(){
echo_read "依赖软件包安装和Oracle RAC软件下载 开始"
echo_green "依赖软件包安装"
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

echo_green "设置主机启动级别为5，即图形界面"
sed -i 's/id:3:initdefault:/id:5:initdefault:/' /etc/inittab

echo_green "Oracle RAC软件下载"
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

echo_green "添加软连接/lib64/libcap.so.1"
ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1

echo_green "安装依赖包pdksh 和 cvuqdisk"
rpm -ivh /software/patch/cvuqdisk-1.0.9-1.rpm
rpm -ivh /software/patch/pdksh-5.2.14-30.x86_64.rpm

echo_green "依赖软件包安装和Oracle RAC软件下载 结束"
}


others(){
#图形化安装grid
#检查grid状态
crs_stat -t
#创建DATA 磁盘组
asmca
}

set_resource_plan
set_oracle_comm_env
if [[ $1 == 1 ]]
then
    set_oracle_rac1_env
    set_n2n_node1
    set_isscsi_node1
elif [[ $1 == 2 ]]
then
    set_oracle_rac2_env
    set_n2n_node1
    set_isscsi_node2
fi
set_oracle_pre_install


