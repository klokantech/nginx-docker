#!/bin/bash
#
# see https://xdev.me/article/Recompile_Nginx_deb_package_with_a_new_module
set -e

apt-get -qq update
apt-get -qq -y install git
apt-get -qq -y build-dep nginx

TMPDIR="/tmp/nginx" #"/tmp/$(basename $0).$$"
mkdir $TMPDIR
cd $TMPDIR
apt-get -qq source nginx

#our fork of bpaquet/ngx_http_enhanced_memcached_module with patch due problem with rewriting of headers
git clone https://github.com/klokantech/ngx_http_enhanced_memcached_module.git
sed -i "s#./configure #./configure --add-module=$TMPDIR/ngx_http_enhanced_memcached_module #g" nginx-*/debian/rules

cd $TMPDIR/nginx-*
dpkg-buildpackage -uc -b -j4

dpkg -i $TMPDIR/nginx_*.deb

rm -r $TMPDIR

apt-get -qq -y remove git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
