#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/26
#
# 语法：
#  redisInstall.sh [-P] port
#
# 测试：
#  redisInstall.sh -P 6380
#
###############################

# 初始化变量
num=$#
ct=none
log=/tmp/reInstall_`date +%Y%m%d`.log
basefile=/home/redis/redis
USER=redis
GROUP=redis

function err(){
	ct="error，shell退出"
	
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $log 3 $ct

	exit 1
}

# 检查$?的返回值
function ckRc(){

	if [ ${RC} -ne 0 ]
	then
		
		ct="error，shell退出"
		
		./utils/printOut.sh 3 $ct
		./utils/putLog.sh $log 3 $ct
		
		exit 1
		
	fi

}

# 输出内容和记录log [info]
function pt1(){

	./utils/printOut.sh 1 $ct
	./utils/putLog.sh $log 1 $ct

}

if [ "$1" == "-P" ]
then
	# 判断是否为整数
	`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' $2`||err

	port=$2
	dir=/data/redis/$port
	pidfile=$dir/redis_$port.pid
	logfile=$dir/redis.log
	recnf=/data/redis/$port/redis.conf

else

	ct="参数输入有误，请检查输入的参数"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $log 3 $ct
	
	err

fi

# 安装依赖包
ct="开始安装依赖包lvm2 gcc automake autoconf libtool make"
pt1

yum install -y lvm2 gcc automake autoconf libtool make
RC=$?

# 检查$?返回值
ckRc

ct="依赖包安装完成"
pt1

# 修改系统参数
ct="开始修改系统参数"
pt1

chmod 666 /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/enabled

echo "net.ipv4.tcp_max_syn_backlog = 1024" >>/etc/sysctl.conf      
echo "net.core.somaxconn = 1024" >>/etc/sysctl.conf
echo "vm.overcommit_memory = 1" >>/etc/sysctl.conf

# 让修改生效
sysctl -p

ct="已完成修改"
pt1

# 创建用户，并赋予环境变量
id ${USER} >& /dev/null
RC=$?
if [ ${RC} -ne 0 ]
then

	ct="redis用户不存在，开始创建"
	pt1
	
#	groupadd ${GROUP}
	useradd ${USER}

	ct="redis用户已创建"
	pt1	
	
	# 环境变量
	ct="设置环境变量"
	pt1	
	
	echo 'export REDIS_HOME=/home/redis/redis/' >> /home/redis/.bash_profile
	echo 'export PATH=$REDIS_HOME/src:$PATH' >> /home/redis/.bash_profile
	source /home/redis/.bash_profile
	
else
	ct="redis用户已存在"
	pt1
	
	# 环境变量
	ct="检查环境变量"
	pt1	

	cat /home/mysql/.bash_profile|grep REDIS_HOME=/home/redis/redis/ >& /dev/null || echo 'export REDIS_HOME=/home/redis/redis/' >> /home/redis/.bash_profile && echo 'export PATH=$REDIS_HOME/src:$PATH' >> /home/redis/.bash_profile
	source /home/mysql/.bash_profile
	
fi

# 安装redis
ct="开始安装redis"
pt1	

tar zxf redis-3.2.5.tar.gz
mv redis-3.2.5 redis

mv redis /home/redis/

cd $basefile
pwd

# 安装
make

cd /root/testredis/
pwd

# 检查$?返回值
ckRc

# 把/home/redis/下的redis授权给redis用户
chown -R redis:redis /home/redis/redis

ct="安装完成"
pt1

# 创建redis工作目录
ct="开始创建redis工作目录"
pt1

mkdir -p $dir

# 检查$?返回值
#ckRc

ct="已完成创建"
pt1

# 修改配置文件
ct="创建redis.conf配置文件"
pt1

./utils/createReCnf.sh $recnf $dir $pidfile $logfile $port

# 检查$?返回值
#ckRc

chown -R redis:redis /data/redis

ct="已完成创建"
pt1

# 启动redis，并设置自启动
ct="启动redis，设置自启"
pt1

./utils/redisAutoStart.sh $recnf $basefile $port

ct="redis已启动，自启设置已完成"
pt1
