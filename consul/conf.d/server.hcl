server = true
datacenter = "dc1"
data_dir = "/mnt/storage/consul/data"
ui_config {
  enabled = true
}
bind_addr = "{{GetInterfaceIP \"eth0\"}}"
client_addr = "0.0.0.0"
bootstrap_expect = 1
ports {
  grpc = 8502
}
connect {
  enabled = true
}
addresses {
  grpc = "127.0.0.1"
}
encrypt = "H9qcD0E/egcXkA3zIikcEwznl4ZFgy8UYALP+kkHR9k="

