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

    service {
      name = "web"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/myapp`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
      
    }

    task "nginx" {

      driver = "docker"

      config {
        image = "nginx:stable-alpine"

        mount {
          type   = "bind"
          source = "local/ingress/nginx.conf"
          target = "/etc/nginx/nginx.conf"
          readonly = true
        }

        // mount {
        //   type   = "bind"
        //   source = "local/ingress/proxy.conf"
        //   target = "/etc/nginx/conf.d/proxy.conf"
        //   readonly = true
        // }

        ports = ["http"]

      }

      template {
        change_mode   = "signal"
        change_signal = "SIGINT"
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
      }

      template {
        change_mode   = "signal"
        change_signal = "SIGINT"
        // source        = "/mnt/storage/nomad/jobs/ingress/tpl/proxy.conf.tpl"
        data = <<EOF
server {
  listen 80;
  server_name iot.localdomain;
  {{ range service "emqx-edge" }}
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
      }

      resources {
        cpu    = 100
        memory = 64
      }


    }
  }
}