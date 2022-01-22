server {
  listen 80;
  server_name consul.iot.localdomain;
  {{ range service "consul" }}
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

server {
  listen 80;
  server_name nomad.iot.localdomain;
  {{ range service "nomad" }}
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
