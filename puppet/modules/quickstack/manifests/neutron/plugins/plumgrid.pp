# Configure the neutron server to use the plumgrid plugin.
# === Parameters
#
class quickstack::neutron::plugins::plumgrid (
  $package_ensure           = 'installed',
  $pg_connection            = $quickstack::params::pg_connection,
  $pg_director_server       = $quickstack::params::pg_director_server,
  $pg_director_server_port  = $quickstack::params::pg_director_server_port,
  $pg_username              = $quickstack::params::pg_username,
  $pg_password              = $quickstack::params::pg_password,
  $pg_servertimeout         = $quickstack::params::pg_servertimeout,
  $pg_enable_metadata_agent = $quickstack::params::pg_enable_metadata_agent,
  $pg_fw_src                = $quickstack::params::pg_fw_src,
  $pg_fw_dest               = $quickstack::params::pg_fw_dest,
) inherits quickstack::params {

  if $pg_fw_src != undef {
    firewall { '001 plumgrid rpc':
      proto       => 'tcp',
      action      => 'accept',
      state       => ['NEW'],
      destination => $pg_fw_dest,
      source      => $pg_fw_src,
      before      => Class['::neutron::plugins::plumgrid'],
    }
  }
  class { '::neutron::plugins::plumgrid':
   package_ensure          => $package_ensure,
   connection              => $pg_connection,
   pg_director_server      => $pg_director_server,
   pg_director_server_port => $pg_director_server_port,
   pg_username             => $pg_username,
   pg_password             => $pg_password,
   pg_servertimeout        => $pg_servertimeout,
   enable_metadata_agent   => $pg_enable_metadata_agent,
  }

}
