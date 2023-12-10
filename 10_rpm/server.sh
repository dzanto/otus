sudo yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc \
perl-IPC-Cmd

sudo wget https://nginx.org/packages/rhel/8/SRPMS/nginx-1.24.0-1.el8.ngx.src.rpm -P /root/
sudo rpm -i /root/nginx-1.*

sudo wget https://github.com/openssl/openssl/archive/refs/tags/openssl-3.2.0.zip -P /root/
sudo unzip /root/openssl-3.2.0.zip -d /root/
sudo yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

sudo sed -i 's/--with-debug/--with-openssl=\/root\/openssl-openssl-3.2.0/g' /root/rpmbuild/SPECS/nginx.spec

sudo rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

sudo yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.24.0-1.el8.ngx.x86_64.rpm

sudo systemctl enable nginx --now

sudo mkdir /usr/share/nginx/html/repo

sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.24.0-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/

sudo wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm

sudo createrepo /usr/share/nginx/html/repo/

sudo sed -i '/        index  index.html index.htm;/a \        autoindex on;' /etc/nginx/conf.d/default.conf

sudo nginx -s reload

sudo tee /etc/yum.repos.d/otus.repo &>/dev/null <<EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

sudo yum install percona-orchestrator.x86_64 -y