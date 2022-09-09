#!/bin/bash

#Thanks to tedboundros. https://github.com/tedboudros/tplink-ub500-linux-patch-guide Just used his description to make this script.

# Initialization

FIX_UB_500_BT_Stick () {
echo -e "This Script is intended to fix the not working BT Stick UB 500 by TP-Link"
echo -e ""
echo -e "As descrbed in https://askubuntu.com/questions/1370663/bluetooth-scan-doesnt-detect-any-device-on-ubuntu-21-10"
echo -e ""
echo -e "This scripts guides you through all necessary steps. However, please take care. This can break your system, or at least  break your bluetooth."
echo -e ""
echo -e "\033[33mStep 1: Download and extract Linux kernel source file."
echo -e "\033[0m"
echo -e ""
echo -e "Your Kernel-Version: "
version=$(uname -r)
echo $version
echo -e "If not 5.15, change script and restart! (Just search and replace 5.15 with your Version, as long as it is a 5.x)"
read -n 1 -p "Do you want to continue? [y/n]" start
  if [ "$start" = "y" ] ; then
    cd /home/max/
    mkdir FIX_UB_500_BT_Stick
    cd FIX_UB_500_BT_Stick
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.tar.xz
    tar xpvf linux-5.15.tar.xz
    echo -e "\033[33mDownload location and files:"
    echo -e "\033[0m"
    pwd
    ls
    echo -e "\033[33mLocation of files to be changed:"
    echo -e "\033[0m"
    cd linux-5.15/drivers/bluetooth
    pwd
    echo -e "\033[33mStep 2: Edit btusb.c"
    echo -e "\033[31m"
    echo "Add:"
    echo -e "\033[0m"
    echo "/* Tp-Link UB500 */"
    echo "{ USB_DEVICE(0x2357, 0x0604), .driver_info = BTUSB_REALTEK },"
    echo -e "\033[33m"
    echo "Under the section"
    echo -e "\033[0m"
    echo "static const struct usb_device_id blacklist_table[]"
    echo -e "\033[33m"
    echo "After"
    echo -e "\033[0m"
    echo "/* Silicon Wave based devices */"
    echo -e "\033[33m"
    echo "in btusb.c"
    echo ""
    echo "It should look something like this:"
    echo -e "\033[0m"
    echo "/* Silicon Wave based devices */"
    echo "{ USB_DEVICE(0x0c10, 0x0000), .driver_info = BTUSB_SWAVE },"
    echo "/* Tp-Link UB500 */"
    echo "{ USB_DEVICE(0x2357, 0x0604), .driver_info = BTUSB_REALTEK }, "
    echo "{ }/* Terminating entry */"
    echo ""
    echo -e "\033[31m Safe and close KWrite."
    sleep 5
    kwrite btusb.c
    read -n 1 -p "Did you change the file and want to continue? [y/n]" filechange1
    if [ "$filechange1" = "y" ]; then
      echo -e "\033[33m"
      echo "Ok, continuing."
      echo -e "\033[0m"
    elif [ "$filechange1" = "n" ];then
      sudo rm -r /home/max/FIX_UB_500_BT_Stick
      exit
    else
      echo -e "\033[31mDid you change the file and want to continue? [y/n]; Press ctrl+c to abort."
      echo -e "\033[0m"
      read -n 1
    fi
    echo -e "\033[33mStep 3: Edit hci_ldisc.c"
    echo -e "\033[0m"
    echo -e ""
    File="hci_ldisc.c"
    if grep -q "void **cookie, unsigned long offset)" "$File"; then
      echo -e "\033[33mStep not necessary. File already correct."
      echo -e "\033[0m"
    else
      echo -e "\033[33mChange:"
      echo -e "\033[0m"
      echo "static ssize_t hci_uart_tty_read(struct tty_struct *tty, struct file *file,"
      echo "                 unsigned char __user *buf, size_t nr)"
      echo ""
      echo -e "\033[33minto"
      echo -e "\033[0m"
      echo "static ssize_t hci_uart_tty_read(struct tty_struct *tty, struct file *file,"
      echo "                 unsigned char __user *buf, size_t nr, "
      echo "                 void **cookie, unsigned long offset) "
      echo -e "\033[33m"
      echo "in hci_ldisc.c"
      echo ""
      echo "Safe and Close KWrite. (This step might not be necessary for some versions)"
      sleep 5
      kwrite hci_ldisc.c
      read -n 1 -p "Did you change the file and want to continue? [y/n]" filechange2
      if [ "$filechange2" = "y" ]; then
        echo -e "\033[33m"
        echo "Ok, continuing."
        echo -e "\033[0m"
      elif [ "$filechange2" = "n" ];then
        sudo rm -r /home/max/FIX_UB_500_BT_Stick
        exit
      else
      echo -e "\033[31mDid you change the file and want to continue? [y/n];"
        read -n 1
      fi
    fi
    echo -e "\033[33mStep 4: Compile modules."
    echo -e "\033[0m"
    make -C /lib/modules/$(uname -r)/build M=$(pwd) clean
    echo -e "\033[33mMake 1 done."
    echo -e "\033[0m"
    cp /usr/src/linux-headers-$(uname -r)/.config ./
    cp /usr/src/linux-headers-$(uname -r)/Module.symvers Module.symvers
    make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
    echo -e "\033[33mMake 2 done."
    echo -e "\033[33mStep 5: Replace the old module."
      echo -e "\033[0m"
    sudo cp btusb.ko /lib/modules/$(uname -r)/kernel/drivers/bluetooth
    echo -e "\033[33mCopied to current Kernel"
    echo -e ""
    echo -e "\033[33mStep 6: Load new btusb."
    echo -e "\033[0m"
    sudo modprobe -r btusb
    sudo modprobe -v btusb
    echo -e "\033[33mModprobe done"
    echo -e "\033[0m"


    if [[ ! -f "/lib/firmware/rtl_bt/rtl8761b_fw.bin" ]]
    then
        echo -e "\033[33mStep 7: Download Firmware for UB500 from Realteks GIT."
        read -n 1 -p "The FW for the UB500 BT-Dongle is not present in /lib/firmware/rtl_bt/. /n Do you wish to download the file from Realteks Git and copy it to your system? [y/n]" FW_Install
          if [ "$FW_Install" = "y" ]; then
            echo -e "\033[33m"
            echo "Ok, continuing."
            echo -e "\033[0m"
            cd /home/max/FIX_UB_500_BT_Stick
            mkdir FW
            cd FW
            wget https://github.com/Realtek-OpenSource/android_hardware_realtek/raw/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_fw
            sudo cp /home/max/FIX_UB_500_BT_Stick/FW/rtl8761b_fw /lib/firmware/rtl_bt/rtl8761b_fw.bin
            if [[ -f "/lib/firmware/rtl_bt/rtl8761b_fw.bin" ]]; then
              echo -e "\033[33mFW was successfully copied. Reboot and try your bluetooth stick. It should work now."
            else
              echo -e "\033[33mSomething went wrong.You will have to download the FW yourself and place it in the folder /lib/firmware/rtl_bt/ with the name rtl8761b_fw.bin /n You'll find the file in this Repo: https://github.com/Realtek-OpenSource/android_hardware_realtek/raw/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_config /n If you placed the file there, reboot and your UB500 should work now."
            fi
          elif [ "$fFW_Install" = "n" ];then
            sudo rm -r /home/max/FIX_UB_500_BT_Stick
            echo -e "\033[33mFW was not downloaded. You will have to download the FW yourself and place it in the folder /lib/firmware/rtl_bt/ with the name rtl8761b_fw.bin /n You'll find the file in this Repo: https://github.com/Realtek-OpenSource/android_hardware_realtek/raw/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_config /n If you placed the file there, reboot and your UB500 should work now."
            echo -e "\033[0m"
            exit
          else
          echo -e "\033[31mDownload the FW? [y/n];"
            read -n 1
          fi
    else
      echo -e "\033[33mIt looks like, /lib/firmware/rtl_bt/rtl8761b_fw.bin already exists. No further steps needed. Reboot and try your UB500 BT-Stick."
    fi
    sudo rm -r /home/max/FIX_UB_500_BT_Stick
    echo -e "\033[33mDeleted downloaded files and dircetory /home/max/FIX_UB_500_BT_Stick"
    echo -e "\033[0m"
  elif [ "$start" = "n" ];then
    sudo rm -r /home/max/FIX_UB_500_BT_Stick
    exit
  else
    echo -e "\033[33mYou have entered an invallid selection!"
    echo -e "\033[33mPlease try again!"
    echo -e ""
    echo -e "\033[31mPress any key to continue..."
    read -n 1

  fi
  }

FIX_UB_500_BT_Stick
