# Quickstack compute node configuration for neutron (OpenStack Networking)
class quickstack::neutron::compute (
  $admin_password              = $quickstack::params::admin_password,
  $ceilometer_metering_secret  = $quickstack::params::ceilometer_metering_secret,
  $ceilometer_user_password    = $quickstack::params::ceilometer_user_password,
  $cinder_backend_gluster      = $quickstack::params::cinder_backend_gluster,
  $controller_priv_host        = $quickstack::params::controller_priv_host,
  $controller_pub_host         = $quickstack::params::controller_pub_host,
  $enable_tunneling            = $quickstack::params::enable_tunneling,
  $mysql_host                  = $quickstack::params::mysql_host,
  $neutron_core_plugin         = $quickstack::params::neutron_core_plugin,
  $neutron_db_password         = $quickstack::params::neutron_db_password,
  $neutron_user_password       = $quickstack::params::neutron_user_password,
  $security_group_api          = $quickstack::params::security_group_api,
  $nova_db_password            = $quickstack::params::nova_db_password,
  $nova_user_password          = $quickstack::params::nova_user_password,
  $ovs_bridge_mappings         = $quickstack::params::ovs_bridge_mappings,
  $ovs_vlan_ranges             = $quickstack::params::ovs_vlan_ranges,
  $ovs_tunnel_iface            = 'em1',
  $qpid_host                   = $quickstack::params::qpid_host,
  $tenant_network_type         = $quickstack::params::tenant_network_type,
  $tunnel_id_ranges            = '1:1000',
  $ovs_vxlan_udp_port          = $quickstack::params::ovs_vxlan_udp_port,
  $ovs_tunnel_types            = $quickstack::params::ovs_tunnel_types,
  $verbose                     = $quickstack::params::verbose,
  $ssl                         = $quickstack::params::ssl,
  $mysql_ca                    = $quickstack::params::mysql_ca,
) inherits quickstack::params {

  if str2bool_i("$ssl") {
    $qpid_protocol = 'ssl'
    $qpid_port = '5671'
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron?ssl_ca=${mysql_ca}"
  } else {
    $qpid_protocol = 'tcp'
    $qpid_port = '5672'
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  }

  class { '::neutron':
    allow_overlapping_ips => true,
    rpc_backend           => 'neutron.openstack.common.rpc.impl_qpid',
    qpid_hostname         => $qpid_host,
    qpid_port             => $qpid_port,
    qpid_protocol         => $qpid_protocol,
    core_plugin           => $neutron_core_plugin
  }

  neutron_config {
    'database/connection': value => $sql_connection;
    'keystone_authtoken/auth_host':         value => $controller_priv_host;
    'keystone_authtoken/admin_tenant_name': value => 'services';
    'keystone_authtoken/admin_user':        value => 'neutron';
    'keystone_authtoken/admin_password':    value => $neutron_user_password;
  }

  if $neutron_core_plugin == 'neutron.plugins.plumgrid.plumgrid_plugin.plumgrid_plugin.NeutronPluginPLUMgridV2' {

    include nova::params

    class { 'nova::api':
      admin_password    => $nova_user_password,
      enabled           => true,
      auth_host         => $controller_priv_host,
      admin_tenant_name => $nova_admin_tenant_name,
    }

    nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
    nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}
    nova_config { 'DEFAULT/libvirt_cpu_mode': value => 'none'}

    # forward all ipv4 traffic
    # this is required for the vms to pass through the gateways
    # public interface
    Exec {
      path => $::path
    }

    sysctl::value { 'net.ipv4.ip_forward':
      value => '1'
    }

    # network.filters should only be included in the nova-network node package
    # Reference: https://wiki.openstack.org/wiki/Packager/Rootwrap
    nova::generic_service { 'network.filters':
      package_name   => $::nova::params::network_package_name,
      service_name   => $::nova::params::network_service_name,
    }

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

  } else {
  class { '::neutron::plugins::ovs':
    sql_connection      => $sql_connection,
    tenant_network_type => $tenant_network_type,
    network_vlan_ranges => $ovs_vlan_ranges,
    tunnel_id_ranges    => $tunnel_id_ranges,
    vxlan_udp_port      => $ovs_vxlan_udp_port,
  }

  class { '::neutron::agents::ovs':
    bridge_mappings     => $ovs_bridge_mappings,
    local_ip            => getvar(regsubst("ipaddress_${ovs_tunnel_iface}", '[.-]', '_', 'G')),
    enable_tunneling    => str2bool_i("$enable_tunneling"),
    tunnel_types     => $ovs_tunnel_types,
    vxlan_udp_port   => $ovs_vxlan_udp_port,
  }

  class { '::nova::network::neutron':
    neutron_admin_password    => $neutron_user_password,
    neutron_url               => "http://${controller_priv_host}:9696",
    neutron_admin_auth_url    => "http://${controller_priv_host}:35357/v2.0",
    security_group_api        => $security_group_api,
  }


  class { 'quickstack::compute_common':
    admin_password              => $admin_password,
    ceilometer_metering_secret  => $ceilometer_metering_secret,
    ceilometer_user_password    => $ceilometer_user_password,
    cinder_backend_gluster      => $cinder_backend_gluster,
    controller_priv_host        => $controller_priv_host,
    controller_pub_host         => $controller_pub_host,
    mysql_host                  => $mysql_host,
    nova_db_password            => $nova_db_password,
    nova_user_password          => $nova_user_password,
    qpid_host                   => $qpid_host,
    verbose                     => $verbose,
    ssl                         => $ssl,
    mysql_ca                    => $mysql_ca,
  }

  class {'quickstack::neutron::firewall::vxlan':
    port => $ovs_vxlan_udp_port,
  }
}
