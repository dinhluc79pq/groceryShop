client_body_buffer_size 128k;
proxy_buffer_size 512k;
proxy_buffers 4 512k;
proxy_busy_buffers_size 512k;
client_max_body_size 30m;
large_client_header_buffers 4 32k;
fastcgi_read_timeout 600;
proxy_read_timeout 600;