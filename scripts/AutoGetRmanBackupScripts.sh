#!/bin/bash

# 在线热备-RMAN备份脚本生成器
# Author: BooBooWei
# Date	: 2020-01-03

read -p '指定备份目录 [ default /home/oracle/rmbk ]:' rmbk_dir
if [ -z ${rmbk_dir} ]
then
	rmbk_dir="/home/oracle/rmbk"
	echo "备份目录为：${rmbk_dir}"
else
	echo "备份目录为：${rmbk_dir}"
fi

read -p '执行备份文件子目录 [ default YYYYMMDD ]:' dirname
if [ -z ${dirname} ]
then
	dirname="date +'%Y%m%d'"
	echo "备份子目录为：${dirname}"
else
	echo "备份子目录为：${dirname}"
fi

read -p '开始生成脚本，请按回车键'

# 创建目录
mkdir -p ${rmbk_dir}
echo "${rmbk_dir}目录创建  OK"

# 准备备份脚本
## 1. 获取环境变量导入脚本
echo '获取 oracle 用户环境变量  OK'
env | sed -n '/oracle/p;/ORACLE/p' >> ${rmbk_dir}/rmbk.sh

## 2. 导入其他内容
echo  '生成备份脚本rmbk.sh  OK'
cat >> ${rmbk_dir}/rmbk.sh << ENDF
rmbk_dir=${rmbk_dir}
dirname=\`${dirname}\`
mkdir -p \${rmbk_dir}/\${dirname}
week=\`date +'%w'\`

if [[ \${week} == 0 ]]
then
	level=0
else
	level=1
fi

rman target / log=${rmbk_dir}/bak_inc\${level}.log append cmdfile=${rmbk_dir}/rmanbk_inc\${level}

#del old folders
find ${rmbk_dir} -type d -mtime +13 -exec ls -d {} \\;
find ${rmbk_dir} -mtime +13 -exec rm -rf {} \\;

ENDF

echo '生成RMAN level0脚本  OK'
# rman level0
cat >> ${rmbk_dir}/rmanbk_inc0 << ENDF
run {
configure retention policy to recovery window of 14 days;
configure controlfile autobackup on;
allocate channel ch1 type disk;
backup as compressed backupset  incremental level 0
format '${rmbk_dir}/%T/incr0_%d_%U'
tag 'day_incr0'
database plus archivelog delete input;
crosscheck backup;
crosscheck archivelog all;
delete noprompt obsolete;
delete noprompt  expired backup;
delete noprompt  expired archivelog all;
release channel ch1;
}
ENDF

echo '生成RMAN level1脚本  OK'
# rman level1
cat >> ${rmbk_dir}/rmanbk_inc1 << ENDF
run {
configure retention policy to recovery window of 14 days;
configure controlfile autobackup on;
allocate channel ch1 type disk;
backup as compressed backupset  incremental level 1
format '${rmbk_dir}/%T/incr1_%d_%U'
tag 'day_incr1'
database plus archivelog delete input;
crosscheck backup;
crosscheck archivelog all;
delete noprompt obsolete;
delete noprompt  expired backup;
delete noprompt  expired archivelog all;
release channel ch1;
}
ENDF

# configure crontab
echo '配置Crontab  OK'
echo "30 22 * * * /bin/bash ${rmbk_dir}/rmbk.sh" | crontab
