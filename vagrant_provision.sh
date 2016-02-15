#! /bin/sh
#
# vagrant_provision.sh
# Copyright (C) 2016 Tim Hughes <tim.hughes@lmax.com>
#
# Distributed under terms of the MIT license.
#
set -e

sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm || :

sudo yum -y install centos-release-SCL redis git sendmail || :
sudo yum -y install --nogpgcheck ruby193 || :
sudo chkconfig redis on
sudo service redis start
sudo chkconfig iptables off
sudo service iptables stop
#sudo yum -y install /vagrant/pkg/*.rpm
