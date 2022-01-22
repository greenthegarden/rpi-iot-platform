job "ingress" {

  region = "global"

  datacenters = [
    "dc1",
  ]

  type = "service"

  group "svc" {

    count = 1

    network {
      port "http" {
        static = 80
      }
    }

    restart {
      attempts = 5
      delay    = "15s"
    }

    task "app" {

      driver = "docker"

      config {
        image = "nginx:stable-alpine"

        mounts = [
          {
            type   = "bind"
            source = "local/ingress/nginx.conf"
            target = "/etc/nginx/nginx.conf"
          },
          {
            type   = "bind"
            source = "local/ingress/proxy.conf"
            target = "/etc/nginx/conf.d/proxy.conf"
          },
        ]

        ports = ["http"]

      }

      template {
        // source        = "/mnt/storage/nomad/jobs/ingress/tpl/nginx.conf.tpl"
        data = <<EOF
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF
        destination   = "local/ingress/nginx.conf"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }

      template {
        // source        = "/mnt/storage/nomad/jobs/ingress/tpl/proxy.conf.tpl"
        data = <<EOF
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
EOF
        destination   = "local/ingress/proxy.conf"
        change_mode   = "signal"
        change_signal = "SIGINT"
      }

      resources {
        cpu    = 100
        memory = 64
      }

      service {
        name = "ingress"
        port = "http"
      }
    }
  }
}