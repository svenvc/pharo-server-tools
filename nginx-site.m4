
# Nginx configuration for Unanym Expressive System

upstream expressivesystem {

    server 127.0.0.1:_PROXY_PORT_;
}

server {

    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _HOST_PREFIX_.objectguild.com;

    root /var/www/_SERVICE_NAME_/html;
    index index.html;

    location = / {
        rewrite ^.*$ /app.html?_SERVICE_NAME_ permanent;
    }

    charset utf-8;

    access_log /var/www/_SERVICE_NAME_/logs/access.log;
    error_log /var/www/_SERVICE_NAME_/logs/error.log;

    # Adapted example from: https://www.nginx.com/blog/websocket-nginx/
    # Additional context: https://docs.nginx.com/nginx/deployment-guides/load-balance-third-party/node-js/#configuring-load-balancing-of-websocket-traffic

    location /io {
        proxy_pass http://expressivesystem;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;

        # Set timeout for WebSocket connections
        proxy_connect_timeout 14400s;
        proxy_send_timeout 14400s;
        proxy_read_timeout 14400s;
    }

    ssl_certificate /etc/letsencrypt/live/_HOST_PREFIX_.objectguild.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/_HOST_PREFIX_.objectguild.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # include /etc/nginx/snippets/security_headers.conf;

    # favicon.ico
    location = /favicon.ico {
        log_not_found off;
        access_log    off;
    }

    # robots.txt
    location = /robots.txt {
        log_not_found off;
        access_log    off;
    }

    # gzip
    gzip            on;
    gzip_vary       on;
    gzip_proxied    any;
    gzip_comp_level 6;
    gzip_types      text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;
}
server {

    listen 80;
    listen [::]:80;
    server_name _HOST_PREFIX_.objectguild.com;

    if ($host = _HOST_PREFIX_.objectguild.com) {
        return 301 https://$host$request_uri;
    }

    return 404;
}
