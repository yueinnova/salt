#!/bin/bash
# Install Basic Tools
# yum install -y wget
# yum install -y tree
# yum install -y net-tools

# config Aliyun sources

# Backup current sources
cd /etc/yum.repos.d/ &&
mkdir bak &&
mv CentOS-*.repo bak &&

# Fetch aliyun sources
wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &&
sed -i 's/$releasever/7/g' CentOS-Base.repo &&
wget http://mirrors.aliyun.com/repo/epel-7.repo &&

# active new sources
yum clean all &&
yum makecache &&

# import saltstack key and copy saltstack repo
cd /srv/salt/minions/conf/ &&
rpm --import SALTSTACK-GPG-KEY.pub &&
cp saltstack.repo /etc/yum.repos.d/ &&

yum clean expire-cache &&
yum update -y &&

# Install salt-master/salt-ssh
yum install salt-master salt-ssh -y &&

# deal with the firewall

# shut down firewall
systemctl disable firewalld.service &&
systemctl stop firewalld.service &&

# disable the selinux 
# (should add condition judgement: if enforce : disabled)
sed -i 's/=enforce/=disabled/g' /etc/sysconfig/selinux &&

# config the iptables
iptables -I INPUT -m state --state new -m tcp -p tcp --dport 4505 -j ACCEPT &&
iptables -I INPUT -m state --state new -m tcp -p tcp --dport 4506 -j ACCEPT &&

# config configureation file
# minion: /srv/salt/minions/conf/minion: add master ip
# master: /etc/salt/master: add master's interface id/set file roots
# roster: /etc/salt/roster: add minion's id/ip/username/passwd/sudo

# bind minion's ip/hostname in /etc/hosts

# copy yum.repos.d for minions.install
cp /etc/yum.repos.d /srv/salt/minion/conf/

# start salt-master
systemctl enable salt-master &&
systemctl start salt-master 

# restart and you're all set!
# Let's install salt-minion by salt-ssh: 
# salt-ssh '*' -i test.ping to test/init connectivity
# salt-ssh '*' state.sls minions.install to install the minion 

# halt --r




