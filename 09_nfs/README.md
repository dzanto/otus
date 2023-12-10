### Настраиваем сервер NFS 
- Устанавливаем сервер NFS
```sh
sudo yum install nfs-utils 
```

- включаем firewall
```sh
systemctl enable firewalld --now
```

- разрешаем в firewall доступ к сервисам NFS 
```sh
firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent 
firewall-cmd --reload

``` 
- включаем сервер NFS (для конфигурации NFSv3 over UDP он не требует дополнительной настройки, однако вы можете ознакомиться с умолчаниями в файле __/etc/nfs.conf__) 
```sh
systemctl enable nfs --now 
```

- проверяем наличие слушаемых портов 2049/udp, 2049/tcp, 20048/udp,  20048/tcp, 111/udp, 111/tcp
```sh
ss -tnplu 
```

- создаём и настраиваем директорию, которая будет экспортирована в будущем 
```sh
mkdir -p /srv/share/upload 
chown -R nfsnobody:nfsnobody /srv/share 
chmod 0777 /srv/share/upload 
```

- создаём в файле __/etc/exports__ структуру, которая позволит экспортировать ранее созданную директорию 
```sh
echo "/srv/share 192.168.56.11/32(rw,sync,root_squash)" | sudo tee /etc/exports
```

- экспортируем ранее созданную директорию 
```sh
exportfs -r 
``` 
- проверяем экспортированную директорию следующей командой
```sh
exportfs -s 
``` 
Вывод: 
```sh
[root@nfss vagrant]# exportfs -s
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

### Настраиваем клиент NFS 
- Устанавливаем
```sh
yum install nfs-utils 
```

- включаем firewall
```sh
systemctl enable firewalld --now 
systemctl status firewalld 
```

- добавляем в __/etc/fstab__ строку
```sh
echo "192.168.56.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" | sudo tee -a /etc/fstab
```

и выполняем 
```sh
sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target
```

Происходит автоматическая генерация systemd units в каталоге `/run/systemd/generator/`, которые производят монтирование при первом обращении к катаmcлогу `/mnt/` - заходим в директорию `/mnt/` и проверяем успешность монтирования
```sh
mount | grep mnt 
``` 
При успехе вывод должен примерно соответствовать этому
```sh 
[vagrant@nfsc upload]$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=48,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=33567)
192.168.56.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)
```

Обратите внимание на `vers=3` и `proto=udp`, что соотвествует NFSv3  over UDP, как того требует задание.
### Проверка работоспособности 
Проверяем сервер: 
- проверяем экспорты `exportfs -s` 
- проверяем работу RPC `showmount -a 192.168.56.10`
Проверяем клиент: 
- проверяем работу RPC `showmount -a 192.168.56.10`
- проверяем статус монтирования `mount | grep mnt` 

### Альтренативный Vagrantfile 
```ruby 
Vagrant.configure(2) do |config| 
 config.vm.box = "centos/7" 
 config.vm.box_version = "2004.01" 
 config.vm.provider "virtualbox" do |v| 
 v.memory = 256 
 v.cpus = 1 
 end 
 config.vm.define "nfss" do |nfss| 
 nfss.vm.network "private_network", ip: "192.168.50.10",  virtualbox__intnet: "net1" 
 nfss.vm.hostname = "nfss" 
 nfss.vm.provision "shell", path: "nfss_script.sh"  end 
 config.vm.define "nfsc" do |nfsc| 
 nfsc.vm.network "private_network", ip: "192.168.50.11",  virtualbox__intnet: "net1" 
 nfsc.vm.hostname = "nfsc" 
 nfsc.vm.provision "shell", path: "nfsc_script.sh"  end 
end 
```
