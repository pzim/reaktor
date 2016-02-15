#! /bin/sh
#
# runinvagrant.sh
# Copyright (C) 2016 Tim Hughes <thughes@thegoldfish.org>
#
# Distributed under terms of the MIT license.
#


export PATH=/vagrant/bin:$PATH
source /opt/rh/ruby193/enable
god -c /vagrant/god/reaktor.god -D

