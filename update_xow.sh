#!/bin/bash
cd /home/max/xow/
sudo systemctl stop xow
sudo systemctl disable xow
sudo make uninstall
git clone https://github.com/medusalix/xow
make BUILD=RELEASE
sudo make install
sudo systemctl enable xow
sudo systemctl start xow
