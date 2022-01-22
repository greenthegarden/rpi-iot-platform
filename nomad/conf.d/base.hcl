region = "global"
datacenter = "dc1"

// advertise {
//     http = "{{GetInterfaceIP \"eth0\"}}"
//     rpc = "{{GetInterfaceIP \"eth0\"}}"
//     serf = "{{GetInterfaceIP \"eth0\"}}"
// }

consul {
    # The address to the Consul agent.
    address = "127.0.0.1:8500"
    # The service name to register the server and client with Consul.
    // server_service_name = "nomad"
    // client_service_name = "nomad-clients"

    # Enables automatically registering the services.
    // auto_advertise = true

    # Enabling the server and client to bootstrap using Consul.
    // server_auto_join = true
    // client_auto_join = true
}

data_dir = "/mnt/storage/nomad/data"

log_level = "INFO"
enable_syslog = true

// vault {
//     # Enable vault integration
//     enabled     = true
//     address     = "http://vault.service.consul:8200"
//     token       = "NOMAD_VAULT_TOKEN"
//     create_from_role = "nomad-cluster"
// }