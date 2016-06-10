# get OS 
### MacOS
### Ubuntu / Debian
### Centos / Redhat

# Install library
apt-get install -y lua5.1 liblua5.1-0 liblua5.1-0-dev

# Clone Module
git clone https://github.com/openresty/lua-nginx-module.git
git clone https://github.com/openresty/set-misc-nginx-module.git
git clone https://github.com/simpl/ngx_devel_kit.git
# Compile
./configure --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --add-module=/usr/src/ModSecurity-nginx_refactoring/nginx/modsecurity --with-ld-opt=-Wl,-E --add-module=/opt/sources/ngx_devel_kit --add-module=/opt/sources/set-misc-nginx-module --add-module=/opt/sources/lua-nginx-module

# Install
make 
make install

