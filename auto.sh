#!/bin/bash
# Install Basic Tools
# yum install -y wget
# yum install -y tree

# config aliyun sources

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

# roster: /etc/salt/roster: add minion's id/ip/username/passwd/sudo
# bind minion's ip/hostname in /etc/hosts

# copy yum.repos.d for minions.install
cp -r /etc/yum.repos.d/ /srv/salt/minions/

# start salt-master
systemctl enable salt-master &&
systemctl start salt-master &&

# config configureation file
# minion: /srv/salt/minions/conf/minion: add master ip
# master: /etc/salt/master: add master's interface ip

# Take the 1st parameter as the master's ip addr
# set the /etc/salt/master
sed -i "15c interface: $1" /etc/salt/master &&

# set the /srv/salt/minions/conf/minion
sed -i "1c master: $1" /srv/salt/minions/conf/minion && 

# roster: /etc/salt/roster: add minion's id/ip/username/passwd/sudo
USERNAME="salt"
PASSWORD="salt"
basepath=$(cd `dirname $0`; pwd)

for i in "cat $basepath/host_ip.txt | awk '{print $1}'"
do
        echo "$i:" >> /etc/salt/roster 
        echo "  host: $i" >> /etc/salt/roster
        echo "  user: $USERNAME" >>/etc/salt/roster
        echo "  passwd: $PASSWORD" >>/etc/salt/roster
        echo "  sudo: True" >>/etc/salt/roster
#        echo "  timeout: 10" >>/etc/salt/roster
done

# bind minion's ip/hostname in /etc/hosts
awk '{print $0}' $basepath/host_ip.txt >> /etc/hosts

# restart and you're all set!
# halt --r

# Let's install salt-minion by salt-ssh: 
# salt-ssh '*' -i test.ping to test/init connectivity
# salt-ssh '*' state.sls minions.install to install the minion 
