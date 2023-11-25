Список дисков в Virtualbox и удаление диска.
```sh
VBoxManage list hdds
VBoxManage closemedium <UUID>
```

Детали(информация) о рейд массиве
```sh
mdadm --detail /dev/md127
mdadm --detail --scan --verbose
cat /proc/mdstat
```

# Сломать/починить RAID

    mdadm /dev/md127 --fail /dev/sde
    cat /proc/mdstat

Удалим “сломанный” диск из массива:

    mdadm /dev/md127 --remove /dev/sde

Представим, что мы вставили новый диск в сервер и теперь нам нужно добавить его в RAID. Делается это так:

    mdadm /dev/md127 --add /dev/sde
    
    cat /proc/mdstat
    mdadm -D /dev/md127

# Создать GPT-таблицу и 5 разделов, смонтировать их в системе
Создаем таблицу разделов GPT на RAID.

    parted -s /dev/md127 mklabel gpt

Создаём разделы на массиве:

    parted /dev/md127 mkpart primary ext4 0% 20%
    parted /dev/md127 mkpart primary ext4 20% 40%
    parted /dev/md127 mkpart primary ext4 40% 60%
    parted /dev/md127 mkpart primary ext4 60% 80%
    parted /dev/md127 mkpart primary ext4 80% 100%

Далее можно создать на этих разделах файловые системы

    for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md127p$i; done

И смонтировать их по каталогам:

    mkdir -p /raid/part{1,2,3,4,5}
    for i in $(seq 1 5); do mount /dev/md127p$i /raid/part$i; done

Проверяем:

    df -h
