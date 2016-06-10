# get OS 
### MacOS
### Ubuntu / Debian
### Centos / Redhat

# Install library

# Clone Module

# Compile

# Install


cd /opt/sources/


git clone https://github.com/openresty/lua-nginx-module.git

git clone https://github.com/openresty/set-misc-nginx-module.git

git clone https://github.com/simpl/ngx_devel_kit.git


cd /opt/sources/nginx-1.10.1

./configure --prefix=/opt/nginx --with-http_stub_status_module --with-http_realip_module --user=www-data --group=www-data --without-http_uwsgi_module --without-http_scgi_module --with-http_gzip_static_module --without-http_ssi_module --without-http_geo_module --without-http_map_module --with-http_perl_module  --with-http_gzip_static_module --with-http_secure_link_module  --with-http_ssl_module --add-module=/opt/sources/ngx_devel_kit --add-module=/opt/sources/modsecurity-2.9.1/nginx/modsecurity --add-module=/opt/sources/set-misc-nginx-module --add-module=/opt/sources/lua-nginx-module



=============================

worker_processes  1;


events {

    worker_connections  1024;

}


http {

    include       mime.types;

    default_type  application/octet-stream;

    sendfile        on;


    keepalive_timeout  65;

    # Mod Security

    ModSecurityEnabled on;

    ModSecurityConfig modsecurity.conf;


    server {

        listen       80;

        server_name  localhost;

        set $badurl "$http_host$request_uri";

        set_encode_base64 $badurl;

        location / {

            root   html;

            index  index.html index.htm;

        }

        error_page 403 /page-403.html;

        location = /page-403.html {

            allow all;

            return 302 http://analytics.admicro.local/403.html?badurl=$badurl;

        }


    }


}