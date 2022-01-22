server {
  enabled = true
  bootstrap_expect = 1
}
// data_dir  = "/mnt/storage/nomad/conf"
// datacenter = "dc1"
// consul {
//   address = "127.0.0.1:8500"
// }
acl {
  enabled    = false
  token_ttl  = "30s"
  policy_ttl = "60s"
}
bind_addr = "0.0.0.0"
ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
// tls {
//   http = true
//   rpc  = true

//   ca_file   = "/nomad/conf.d/tls/nomad.service.consul.ca"
//   cert_file = "/nomad/conf.d/tls/nomad.service.consul.crt"
//   key_file  = "/nomad/conf.d/tls/nomad.service.consul.key"

//   verify_server_hostname = true
//   verify_https_client    = false
// }
