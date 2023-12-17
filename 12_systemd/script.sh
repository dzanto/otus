### Создать сервис и таймер

# Из файла /etc/sysconfig/watchlog будет брать переменные
cat << EOF > /etc/sysconfig/watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF

cat << EOF > /var/log/watchlog.log
Файл с произвольным содержимым.
И ключевым словом ALERT
EOF

cat << EOF > /opt/watchlog.sh
#!/bin/bash
WORD=\$1
LOG=\$2
DATE=\`date\`
if grep \$WORD \$LOG &> /dev/null
then
    # Команда logger отправляет лог в системный журнал
    logger "$DATE: I found word, Master!"
else
    exit 0
fi
EOF

chmod +x /opt/watchlog.sh

# создадим service
cat << EOF > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF

# создадим timer
cat << EOF > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 5 second
OnUnitActiveSec=5
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start watchlog.timer
sleep 10
tail -n 20 /var/log/messages

### Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл.

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

sed -i 's/#SOCKET/SOCKET/g' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/g' /etc/sysconfig/spawn-fcgi

cat << EOF > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl start spawn-fcgi
systemctl status spawn-fcgi

### Дополнить Юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами

mkdir /etc/systemd/system/httpd.service.d

# используем шаблон /usr/lib/systemd/system/httpd.service
# добавляем параметр %I - значение после @ в имени сервиса httpd@first
cat << EOF > /etc/systemd/system/httpd.service.d/override.conf
[Service]
EnvironmentFile=/etc/sysconfig/httpd-%I
EOF

cat << EOF > /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
EOF

cat << EOF > /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
EOF

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf

sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/second.conf

echo "PidFile /var/run/httpd-second.pid" >> /etc/httpd/conf/second.conf

systemctl start httpd@first
systemctl status httpd@first

systemctl start httpd@second
systemctl status httpd@second
ss -tlpn
