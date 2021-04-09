#!/bin/bash
# Program:
#  log记录
# v0.2 by alex.zhao -2021/03/01
#
# 语法：
#  redisAutoStart.sh [recnf] [basefile] [port]
#
#
#
###############################

# 初始化变量
recnf=$1
basefile=$2
port=$3
serv=redis$port.service
pidfile=/data/redis/$port/redis_$port.pid

# 创建systemctl文件
cat > /etc/systemd/system/$serv <<EOF
[Unit]
Description=redis
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
Type=forking
User=redis
Group=redis
PIDFile=$pidfile
ExecStart=$basefile/src/redis-server $recnf
LimitNOFILE = 65535
Restart=always
RestartSec=1
StartLimitInterval=0

EOF

chmod 766 /etc/systemd/system/$serv

systemctl daemon-reload

systemctl start $serv && systemctl enable $serv
systemctl status $serv


