Для получения доступа необходим GUI VirtualBox. При выборе ядра загрузки нажать `e`.

### Попасть в систему без пароля несколькими способами

#### Способ 1. init=/bin/sh
- В конце строки начинающейся с linux добавляем init=/bin/sh и нажимаем сtrl-x.
- Рутовая файловая система монтируется в режиме Read-Only. Перемонтировать в
режим Read-Write командой:
```sh
mount -o remount,rw /
```
- Проверить вывод команды:
```sh
mount | grep root
```

#### Способ 2. rd.break
- В конце строки начинающейся с linux добавляем rd.break и нажимаем сtrl-x.
- Попадаем в emergency mode. Рутовая файловая система монтируется в режиме Read-Only, но мы не в ней.
```sh
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
```

#### Способ 3. rw init=/sysroot/bin/sh
- В строке начинающейся с linux заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-x.
- В целом то же самое что и в прошлом примере, но файловаā система сразу
смонтирована в режим Read-Write
- В прошлых примерах тоже можно заменить ro на rw

### Установить систему с LVM, после чего переименовать VG

```sh
[root@server vagrant]# vgs
  VG      #PV #LV #SN Attr   VSize   VFree
  vg_main   1   2   0 wz--n- <36.00g    0 

[root@server vagrant]# vgrename vg_main OtusRoot
  Volume group "vg_main" successfully renamed to "OtusRoot"
```

- правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменяем старое название на новое.
```sh
sed -i 's/vg_main/OtusRoot/g' /etc/fstab
sed -i 's/vg_main/OtusRoot/g' /etc/default/grub
sed -i 's/vg_main/OtusRoot/g' /boot/grub2/grub.cfg
```
- Пересоздаем initrd image, чтобý он знал новое название Volume Group
```sh
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```

### Добавить модуль в initrd


https://gist.githubusercontent.com/lalbrekht/e51b2580b47bb5a150bd1a002f16ae85/raw/80060b7b300e193c187bbcda4d8fdf0e1c066af9/gistfile1.txt

https://gist.githubusercontent.com/lalbrekht/ac45d7a6c6856baea348e64fac43faf0/raw/69598efd5c603df310097b52019dc979e2cb342d/gistfile1.txt