#!/bin/bash

#Init

Main () {
 read -n 1 -p "Do you want to reset your current google-drive-ocamlfuse mount point and/or credentials? [y/n]" start
 echo ""
 if [ "$start" = "y" ] ; then
    Reset_Ocamlfuse
 elif [ "$start" = "n" ] ; then
    echo "No reset, just init google-drive-ocamlfuse."
 else
    echo "Invalid input. Try again. [y/n]"
    read -n 1
 fi
 read -n 1 -p "Do you want to use your own OAuth API from Google? (If you dont know what this is, enter [n].) [y/n]" start
 echo ""
 if [ "$start" = "y" ] ; then
   Cred_manual
 elif [ "$start" = "n" ] ; then
   Cred_auto
 else
  echo "Invalid input. Try again. [y/n]"
  read -n 1
 fi

 read -n 1 -p "Do you want to create a bash script for automounting you GDrive on login? [y/n]" make_script
 echo ""
 if [ "$make_script" = "y" ] ; then
  create_autostart_script
 elif [ "$make_script" = "n" ] ; then
  echo "No script was created."
 else
  echo "Invalid input. Try again. [y/n]"
  read -n 1
 fi
}

Reset_Ocamlfuse () {
  rm -r ~/.gdfuse/
  echo ""
  echo "Reseted credentials and cache."
  echo ""
  read -n 1 -p "Do you want to remove your current google-drive-ocamlfuse mount point? [y/n]" del_dir
  echo ""
  if [ "$del_dir" = "y" ] ; then
    echo ""
    echo "Enter the path to your current mountpoint and press Enter:"
    read cur_path
    fusermount -u $cur_path
    echo "Directory Contents: (Expected is empty directroy)"
    echo ""
    ls $cur_path
    echo ""
    read -n 1 -p "Are you sure, you want to delete? [d] You can skip do delete this directory with [s]. [d/s]" rm_dir
    echo ""
    if [ "$rm_dir" = "d" ] ; then
      rm -r $cur_path
    elif  [ "$rm_dir" = "s" ] ; then
      echo "Deletion skipped. Only deleted credentials."
    fi
   else
   echo "Invalid input. Try again. [y/n]"
   read -n 1
  fi

}

Cred_manual () {
  xdg-open "https://console.developers.google.com/apis/credentials" &
  echo ""
  echo "Enter your OAuth client-id and Press enter:"
  read id
  echo ""
  echo "Enter your OAuth client key / secret and Press Enter:"
  read secret
  echo ""
  google-drive-ocamlfuse -headless -id $id -secret $secret
  Check_Mountpoint
  google-drive-ocamlfuse $MountPath
  Success
}

Cred_auto () {
  google-drive-ocamlfuse
  Check_Mountpoint
  google-drive-ocamlfuse $MountPath
  Success
}

Success () {
  echo ""
  echo "Your GDrive should now be synched with:"
  echo $MountPath
  echo ""
  echo "Content of mount point:"
  echo ""
  ls $MountPath
  echo ""
}

create_autostart_script () {
  cd ~/
  touch mount_gdrive.sh
  echo "#!/bin/bash" >> mount_gdrive.sh
  echo "google-drive-ocamlfuse " $MountPath >> mount_gdrive.sh
  chmod a+x ~/mount_gdrive.sh
  echo ""
  echo "Your mount script mount_gdrive.sh was created in your home directory:"
  echo ""
  ls ~/
  echo ""
  find mount_gdrive.sh
  echo ""
  echo "Add this script as a login script manually. Then Google Drive will automount on login."
}

Check_Mountpoint () {
echo "Enter full Path to Mountpoint and Press Enter:"
  read MountPath
  echo ""
  if [ -d "$MountPath" ]; then
    until find $MountPath -maxdepth 0 -empty ; do
        echo "The directory you specified is not empty. Enter a path to an empty directory and press Enter:"
        echo ""
        read MountPath
    done
    echo "Good to go. Directory speciefied and empty."
    echo ""
  else
    Create_Mountpoint
  fi
}

Create_Mountpoint () {
  mkdir $MountPath
  if [ -d "$MountPath" ]; then
    echo "Good to go. Directory was created. $MountPath"
    echo ""
  else
    echo "Directory could not be created. Please try again."
    echo ""
    Check_Mountpoint
  fi
}

Main
