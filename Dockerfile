FROM debian:8
ENV DEBIAN_FRONTEND noniteractive

RUN apt-key adv \
    --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
&& echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

COPY ngx_with_modules.sh /tmp/
RUN sh /tmp/ngx_with_modules.sh > /dev/null \
&& ln -sf /dev/stdout /var/log/nginx/access.log \
&& ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
