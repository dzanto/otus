#### Установка по инструкции с офф сайта openzfs
https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html

#### Создать пул
```sh
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
```

#### Информация о пулах
```sh
[root@zfs vagrant]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   106K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   106K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   105K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   106K   480M        -         -     0%     0%  1.00x    ONLINE  -

[root@zfs vagrant]# zpool status
pool: otus1
state: ONLINE
config:

    NAME        STATE     READ WRITE CKSUM
    otus1       ONLINE       0     0     0
    mirror-0  ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0

errors: No known data errors
```

#### Добавление разных алгоритмов сжатия в файловые системы:
```sh
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
```

#### Проверить алгоритмы сжатия

    zfs get all | grep compression

#### Скачаем один и тот же текстовый файл во все пулы: 
```sh
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```

`wget flag: -P,  --directory-prefix=PREFIX   save files to PREFIX/..`

#### Проверим размер и степень сжатия файлов:
```sh
ls -lh /otus*
zfs list
zfs get all | grep compressratio | grep -v ref
```
`grep flag: -v, --invert-match Invert the sense of matching, to select non-matching lines.`

```sh
[root@zfs vagrant]# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.81x                  -
otus2  compressratio         2.22x                  -
otus3  compressratio         3.64x                  -
otus4  compressratio         1.00x                  -
```

## Определение настроек пула
```sh
wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'

tar -xzvf archive.tar.gz
```

Проверим, возможно ли импортировать данный каталог в пул:
```sh
[root@zfs ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though some features will not be available without an explicit 'zpool upgrade'.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE

```

Сделаем импорт данного пула
```sh
[root@zfs ~]# zpool import -d zpoolexport/ otus
[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done, the pool may no longer be accessible by software that does not support the features. See zpool-features(5) for details.
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```

```sh
[root@zfs ~]# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      7625182752994425857            -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
otus  feature@redaction_bookmarks    disabled                       local
otus  feature@redacted_datasets      disabled                       local
otus  feature@bookmark_written       disabled                       local
otus  feature@log_spacemap           disabled                       local
otus  feature@livelist               disabled                       local
otus  feature@device_rebuild         disabled                       local
otus  feature@zstd_compress          disabled                       local
```

Просмотр отдельных параметров:

    zfs get available otus
    zfs get readonly otus
    zfs get recordsize otus
    zfs get compression otus
    zfs get checksum otus

## Работа со снапшотом, поиск сообщения от преподавателя

    wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"


Восстановим файловую систему из снапшота
    zfs receive otus/test@today < otus_task2.file

Найдем файл
```sh
[root@zfs test]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message

[root@zfs test]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```
