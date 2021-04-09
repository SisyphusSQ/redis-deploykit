#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/26
#
# 语法：
#  multiDeploy.sh [-P] port
#
# 测试：
#  multiDeploy.sh -P 6381
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

# 检查该端口是否已被创建
if [ -d $dir ]
then

	ct="该端口下，已有mysql实例。请检查。"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $log 3 $ct
	
	err

fi

# 创建redis工作目录
ct="开始创建redis工作目录"
pt1

mkdir -p $dir

# 检查$?返回值
ckRc

ct="已完成创建"
pt1

# 修改配置文件
ct="创建redis.conf配置文件"
pt1

./utils/createReCnf.sh $recnf $dir $pidfile $logfile $port

# 检查$?返回值
ckRc

chown -R redis:redis /data/redis

ct="已完成创建"
pt1

# 启动redis，并设置自启动
ct="启动redis，设置自启"
pt1

./utils/redisAutoStart.sh $recnf $basefile $port

ct="redis已启动，自启设置已完成"
pt1



