server {
  listen 80;
  server_name iot.localdomain;
  {{ range service "traefik" }}
  set $upstream {{ .Address }}:{{ .Port }};
  {{ end }}
  location / {
            proxy_pass          http://$upstream;
            proxy_set_header    Host $host;
            proxy_set_header    X-Real-IP $remote_addr;
            proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header    X-Forwarded-Host $server_name;
            proxy_read_timeout  90;
  }
}
