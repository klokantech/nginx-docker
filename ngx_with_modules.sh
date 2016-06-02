#!/bin/bash
#
# see https://xdev.me/article/Recompile_Nginx_deb_package_with_a_new_module
set -e

apt-get -qq update
apt-get -qq -y install git wget
apt-get -qq -y build-dep nginx
apt-get -qq -y --no-install-recommends install libreadline-dev libncurses5-dev

TMPDIR="/tmp/nginx" #"/tmp/$(basename $0).$$"
mkdir $TMPDIR
cd $TMPDIR
# apt-get -qq source nginx

#our fork of bpaquet/ngx_http_enhanced_memcached_module with patch due problem with rewriting of headers
git clone https://github.com/klokantech/ngx_http_enhanced_memcached_module.git
#sed -i "s#./configure #./configure --add-module=$TMPDIR/ngx_http_enhanced_memcached_module #g" nginx-*/debian/rules
wget --no-verbose 'https://openresty.org/download/openresty-1.9.7.5.tar.gz'
tar xvf openresty-1.9.7.5.tar.gz

cd $TMPDIR/openresty-*
./configure \
    --prefix=/usr/local \
    --add-module=$TMPDIR/ngx_http_enhanced_memcached_module \
    --with-ipv6
make
make install
ldconfig
cd /

rm -r $TMPDIR

mkdir -p /etc/nginx/conf.d/
cp -r /usr/local/nginx/conf/* /etc/nginx/

# Download Lua script for http communication
wget -O /usr/local/lualib/resty/http.lua 'https://raw.githubusercontent.com/pintsized/lua-resty-http/master/lib/resty/http.lua'
wget -O /usr/local/lualib/resty/http_headers 'https://raw.githubusercontent.com/pintsized/lua-resty-http/master/lib/resty/http_headers.lua'

apt-get -qq -y remove git  make wget && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
