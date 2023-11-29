```
[vagrant@otuslinux ~]$ lsblk
NAME                MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda                   8:0    0  37G  0 disk 
├─sda1                8:1    0   1G  0 part /boot
└─sda2                8:2    0  36G  0 part 
  ├─vg_main-lv_root 252:0    0  32G  0 lvm  /
  └─vg_main-lv_swap 252:1    0   4G  0 lvm  [SWAP]
sdb                   8:16   0  10G  0 disk 
sdc                   8:32   0   2G  0 disk 
sdd                   8:48   0   1G  0 disk 
sde                   8:64   0   1G  0 disk
```

sudo dnf install -y xfsdump

```
[root@otuslinux vagrant]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```

```
[root@otuslinux vagrant]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
```

```
[root@otuslinux vagrant]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
```

```
[root@otuslinux vagrant]# mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=0 inobtcount=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=25600, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

```
mount /dev/vg_root/lv_root /mnt
```

```
[root@otuslinux vagrant]# xfsdump -J - /dev/vg_main/lv_root | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS

[root@otuslinux vagrant]# ls /mnt
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  vagrant  var
```

```
[root@otuslinux vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux vagrant]# chroot /mnt/
[root@otuslinux /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
device-mapper: reload ioctl on osprober-linux-vg_main-lv_root (252:3) failed: Device or resource busy
Command failed.
done
```