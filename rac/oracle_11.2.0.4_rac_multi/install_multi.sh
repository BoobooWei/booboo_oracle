#!/usr/bin/env bash
# bash install_multi.sh 1|2
# centos6.9 update kernel重启 yum install kernel-devel


echo_red(){
echo -e "\e[1;31m$1\033[0m"
}

echo_green(){
echo -e "\e[1;32m$1\033[0m"
}

common_configure(){
install_dir=/software/patch/
mkdir -p ${install_dir}

echo_green "下载组播代理工具"
cd ${install_dir}
curl -o multicast_proxy-master.zip https://codeload.github.com/aliyun/multicast_proxy/zip/master
unzip multicast_proxy-master.zip

echo_green "运行以下命令检查Kernel版本"
k=`uname -r | awk -F '.' '{print $1}'`
if [[ $k -ge 4 ]]
then
    echo_green "内核版本大于等于4.0，需要在代码目录执行以下命令安装patch"
    patch -p1 < multicast_kernel/patch/kernel_v4.0.patch
fi


echo_green "fix bug"
install_dir=/software/patch/
k_dir=`uname -r`
new_kernel=`rpm -ql kernel-devel|grep kernels| tail -n 1 |awk -F '/' '{print $1"/"$2"/"$3"/"$4"/"$5}'`
ln -fs ${new_kernel}  /lib/modules/${k_dir}/build


echo_green "运行命令生成安装包"
yum install rpm-build -y
yum install kernel-devel -y
cd ${install_dir}/multicast_proxy-master/multicast_kernel/
bash tmcc_client_auto_rpm.sh
bash tmcc_server_auto_rpm.sh

echo_green "开始安装"
cd ${install_dir}/multicast_proxy-master/multicast_kernel/
rpm -Uvh multi_server-1.1-1.x86_64.rpm
rpm -Uvh multi_client-1.1-1.x86_64.rpm

echo_green "启动服务"
service multis start
service multic start

echo_red "运行以下命令设置开机自动启动multis和multic服务"

chkconfig multis on --level 2345
chkconfig multis off --level 016

chkconfig multic on --level 2345
chkconfig multic off --level 016

}

multi_node1(){
echo_green "这里用224.0.0.251 作为组播组的地址，端口是42424，两个私有网络地址加入到这个组播组当中。"
#节点1：
multis_admin -A -m 224.0.0.251 -j ${node2_private_ip_addr} #配置组播服务端 节点2的privip
multic_admin -A -i ${node2_private_ip_addr} -p 42424 -m 224.0.0.251 #配置组播客户端 节点2的privip
#查看配置情况
multis_admin -L -m 224.0.0.251
service multis restart
service multic restart
#ip route add 224.0.0.0/24 via 172.16.2.160 dev eth1
cat /usr/local/etc/multi_server_startup_config
cat /usr/local/etc/multi_server_running_config
cat /usr/local/etc/multi_client_startup_config
cat /usr/local/etc/multi_client_running_config
}


multi_node2(){
echo_green "这里用224.0.0.251 作为组播组的地址，端口是42424，两个私有网络地址加入到这个组播组当中。"
#节点2：
multis_admin -A -m 224.0.0.251 -j ${node1_private_ip_addr} #配置组播服务端 节点1的privip
multic_admin -A -i ${node1_private_ip_addr} -p 42424 -m 224.0.0.251 #配置组播客户端 节点1的privip

#查看配置情况

multis_admin -L -m 224.0.0.251

service multis restart
service multic restart
#ip route add 224.0.0.0/24 via 172.16.2.160 dev eth1
cat /usr/local/etc/multi_server_startup_config
cat /usr/local/etc/multi_server_running_config
cat /usr/local/etc/multi_client_startup_config
cat /usr/local/etc/multi_client_running_config
}


source ${scripts_dir}/set_resource_plan.sh
common_configure
if [[ $1 == 1 ]]
then
    multi_node1
elif [[ $1 == 2 ]]
then
    multi_node2
fi
