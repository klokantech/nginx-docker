#!/bin/bash
#
# see https://xdev.me/article/Recompile_Nginx_deb_package_with_a_new_module

apt-get update -y
apt-get install -y git
apt-get build-dep -y nginx

TMPDIR="/tmp/nginx" #"/tmp/$(basename $0).$$"
mkdir $TMPDIR
cd $TMPDIR
apt-get source nginx

git clone https://github.com/klokantech/ngx_http_enhanced_memcached_module.git
sed -i "s#./configure #./configure --add-module=$TMPDIR/ngx_http_enhanced_memcached_module #g" nginx-*/debian/rules

cd $TMPDIR/nginx-*
dpkg-buildpackage -uc -b -j4

dpkg -i $TMPDIR/nginx_*.deb

rm -r $TMPDIR

apt-get remove -y git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*