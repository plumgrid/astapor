# Configure the neutron server to use the plumgrid plugin.
# === Parameters
#
class quickstack::neutron::plugins::plumgrid (
  $pg_controller                 = false,
  $pg_compute                    = false,
  $pg_connection                 = undef,
  $pg_director_server            = undef,
  $pg_director_server_port       = '443',
  $pg_username                   = undef,
  $pg_password                   = undef,
  $pg_servertimeout              = '99',
  $pg_enable_metadata_agent      = false,
  $admin_password                = $quickstack::pacemaker::keystone::admin_password,
  $controller_priv_host          = $quickstack::pacemaker::params::keystone_admin_vip,
  $nova_metadata_ip              = $quickstack::pacemaker::params::local_bind_addr,
  $nova_metadata_port            = '8775',
  $metadata_proxy_shared_secret  = $quickstack::pacemaker::params::neutron_metadata_proxy_secret,
) inherits quickstack::params {

  nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
  nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}

  if $pg_controller {
    nova_config { 'DEFAULT/libvirt_cpu_mode': value => 'none'}
    neutron_config {
      'DEFAULT/service_plugins': ensure => absent,
    }->
    class { '::neutron::plugins::plumgrid':
     pg_connection                => $pg_connection,
     pg_director_server           => $pg_director_server,
     pg_director_server_port      => $pg_director_server_port,
     pg_username                  => $pg_username,
     pg_password                  => $pg_password,
     pg_servertimeout             => $pg_servertimeout,
     pg_enable_metadata_agent     => $pg_enable_metadata_agent,
     admin_password               => $admin_password,
     controller_priv_host         => $controller_priv_host,
     nova_metadata_ip             => $nova_metadata_ip,
     nova_metadata_port           => $nova_metadata_port,
     metadata_proxy_shared_secret => $metadata_proxy_shared_secret,
    }
  }

  if $pg_compute {
    # forward all ipv4 traffic
    # this is required for the vms to pass through the gateways
    # public interface
    sysctl::value { 'net.ipv4.ip_forward':
      value => '1'
    }

    class { '::nova::api':
      enabled                              => true,
      admin_password                       => $quickstack::neutron::compute::nova_user_password,
      auth_host                            => $quickstack::neutron::compute::nova_host,
      neutron_metadata_proxy_shared_secret => $metadata_proxy_shared_secret,
    }

    class {'::quickstack::firewall::nova':}

    class { 'libvirt':
      qemu_config => {
              cgroup_device_acl => { value => ["/dev/null","/dev/full","/dev/zero",
              "/dev/random","/dev/urandom","/dev/ptmx",
              "/dev/kvm","/dev/kqemu",
              "/dev/rtc","/dev/hpet","/dev/net/tun"] },
               clear_emulator_capabilities => { value => 0 },
               user => { value => "root" },
        },
    }

    file { "/etc/sudoers.d/ifc_ctl_sudoers":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => 0440,
      content => "nova ALL=(root) NOPASSWD: /opt/pg/bin/ifc_ctl_pp *\n",
      require => [ Package[$::nova::params::compute_package_name], ],
    }
  }
}
