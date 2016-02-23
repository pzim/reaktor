#! /bin/sh
#
# build_rpm.sh
# Copyright (C) 2016 Tim Hughes <thughes@thegoldfish.org>
#
# Distributed under terms of the MIT license.
#

[ -d bundle ] && rm -rf bundle
[ -d .bundle ] && rm -rf .bundle
[ -f Gemfile.lock ] && rm -f Gemfile.lock
yum -y install centos-release-SCL
yum -y install ruby193 \
    ruby193-ruby-devel \
    rpmdevtools \
    gcc \
    make \
    gcc-c++

git clean -dxf

source /opt/rh/ruby193/enable
gem install --no-ri --no-rdoc bundler fpm
bundle install --path vendor/bundle --without development test
bundle exec rake build

mkdir -p rpms
/opt/rh/ruby193/root/usr/local/share/gems/gems/fpm-1.4.0/bin/fpm \
    --rpm-auto-add-directories \
    --prefix /opt/rh/ruby193/root/usr/share/gems \
    --gem-bin-path /opt/rh/ruby193/root/usr/bin \
    --gem-package-name-prefix ruby193-rubygem \
    --maintainer "thughes@thegoldfish.org" \
    --package rpms/ \
    --epoch 1 \
    -s gem \
    -t rpm \
        ./pkg/reaktor-*.gem

bundle package

for X in ./vendor/cache/*
do
/opt/rh/ruby193/root/usr/local/share/gems/gems/fpm-1.4.0/bin/fpm \
    --rpm-auto-add-directories \
    --prefix /opt/rh/ruby193/root/usr/share/gems \
    --gem-bin-path /opt/rh/ruby193/root/usr/bin \
    --gem-package-name-prefix ruby193-rubygem \
    --maintainer "thughes@thegoldfish.org" \
    --package rpms/ \
    --epoch 1 \
    -s gem \
    -t rpm \
    $X
done

