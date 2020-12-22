# Efficient automatic backup
An efficient way to take backups automaticly.  

In this reposetory you can find information and code how to use a Raspberry Pi with an external drive as NAS and automatic backup your PC daily to this drive. This can help you even in case of ransomware.  
Data will be transfed efficiently with the tool [Unison](https://www.cis.upenn.edu/~bcpierce/unison/) and stored on the efficient btrfs.  

***Important:***  
This system do not raise any claim to replace backups to an additional **and disconnected** drive. I recommend to back up the disk of the NAS regulary too.

## What do will need

In general you will need a linux server in your network to save your files on an external drive. In my case this is a Raspberry Pi.
The system is tested on:
- Raspberry Pi 4
- 4 TB Seagate IronWolf
- appropriate HDD housing (Sharkoon Swift Case Pro USB 3.0 works fine but there are many appropiated housings)

## How does it works

## Install

Install [Raspbian (aka Raspberry Pi OS)](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit) on the Raspberry Pi. (I recommend Raspbian Lite) I won't be decent to connect the Rasperry via WiFi to your Computer. The Data rates will be really poor. In general the network connection will be the bottleneck, even if you use a USB 3.0 to SATA adapter.

### Install requirements
After setting up the base functions you need to install (`#apt-get install`):
- [Unison](https://packages.debian.org/buster/unison) (package: unison)
- [BTRFS Tools](https://packages.debian.org/buster/btrfs-progs) (package: btrfs-tools)

### Set up drive
Set up your drive with a [btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) filesystem. This is an efficient CoR filesystem which we will need to take snapshots of your backed up data. If we simple copy the data on an non CoW filesystem (as ext4 or exFAT) our drive will running out of space very fast. ([More infos about CoW](https://en.wikipedia.org/wiki/Copy-on-write))  
On a fresh disk you can do this for example by `mkfs.btrfs /dev/sda1`.  
Now mount your drive to your preferd position in file system. I recommend to do this via [fstab](https://help.ubuntu.com/community/Fstab). This will prevent you from doing this on every reboot. 

### Set up direcory structure
Set up directory stucture on new drive. I placed my btrfs subvolumes to be backed up in a directory and created a new folder in the first one to store the snapshots. 
```
Backups
|- BackupVolumen1
|- BackupVolumen2
...
|- BackupVolumenN
|- snapshots
    |- BackupVolumen1 - 20201222
    |- BackupVolumen2 - 20201222
    ...
    |- BackupVolumenN - 20201222
    |- BackupVolumen1 - 20201221
    ...
    
```

### Setup automatic backup script
Now clone this repository and create a crontab entry for the  `btrfs-daily-backup.sh` script, so it runns daily.  
Now every day a snapshot of the configured subvolumens will be taken and older snapshots will be automaticly removed. (You can configure that in the script)

### Setup SSH
If not yet done configure SSH server. This will be necessary for unison file sync. I strongly advise you to do ssh authtication **only** via public-keys and disable auth via password. I is sensible to create a user only for your computer so that no software or user on your PC is able to delete or alter snapshots.

### Setup your PC
Install [unison](https://www.cis.upenn.edu/~bcpierce/unison/) on your PC. It requires the same version as on the server. So perhaps the version is not available via your package managment or you need different versions. In this case you can simply download a version from [the github project](https://github.com/bcpierce00/unison) and copy it to your favourite folder. `/usr/bin` was my choice.  
Now set up a crontab entry that synchronizes your files regularly. (e.g. very 10 minutes) Use the `-batch` argument for that.  
Best practise is to use [Unison profiles](https://www.cis.upenn.edu/~bcpierce/unison/download/releases/stable/unison-manual.html#profile) for that. On first synchronisation and even on conflicts run Unison manual without the `-batch` argument to decide on conflicts.

### Ready
Don't forget to backup the nas regularly.