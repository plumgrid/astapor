# Quickstack compute node configuration for neutron (OpenStack Networking)
class quickstack::neutron::compute (
  $admin_password               = $quickstack::params::admin_password,
  $agent_type                   = 'ovs',
  $auth_host                    = '127.0.0.1',
  $ceilometer                   = 'true',
  $ceilometer_metering_secret   = $quickstack::params::ceilometer_metering_secret,
  $ceilometer_user_password     = $quickstack::params::ceilometer_user_password,
  $ceph_cluster_network         = '',
  $ceph_public_network          = '',
  $ceph_fsid                    = '',
  $ceph_images_key              = '',
  $ceph_volumes_key             = '',
  $ceph_mon_host                = [ ],
  $ceph_mon_initial_members     = [ ],
  $ceph_osd_pool_default_size   = '',
  $ceph_osd_journal_size        = '',
  $cinder_backend_gluster       = $quickstack::params::cinder_backend_gluster,
  $cinder_backend_nfs           = 'false',
  $cinder_backend_rbd           = 'false',
  $glance_backend_rbd           = 'false',
  $glance_host                  = '127.0.0.1',
  $nova_host                    = '127.0.0.1',
  $enable_tunneling             = $quickstack::params::enable_tunneling,
  $mysql_host                   = $quickstack::params::mysql_host,
  $neutron_db_password          = $quickstack::params::neutron_db_password,
  $neutron_user_password        = $quickstack::params::neutron_user_password,
  $neutron_host                 = '127.0.0.1',
  $neutron_metadata_proxy_secret = $quickstack::params::neutron_metadata_proxy_secret,
  $enable_plumgrid              = 'false',
  $nova_db_password             = $quickstack::params::nova_db_password,
  $nova_user_password           = $quickstack::params::nova_user_password,
  $ovs_bridge_mappings          = $quickstack::params::ovs_bridge_mappings,
  $ovs_bridge_uplinks           = $quickstack::params::ovs_bridge_uplinks,
  $ovs_vlan_ranges              = $quickstack::params::ovs_vlan_ranges,
  $ovs_tunnel_iface             = 'eth1',
  $ovs_tunnel_network           = '',
  $ovs_l2_population            = 'True',
  $amqp_provider                = $quickstack::params::amqp_provider,
  $amqp_host                    = $quickstack::params::amqp_host,
  $amqp_port                    = '5672',
  $amqp_ssl_port                = '5671',
  $amqp_username                = $quickstack::params::amqp_username,
  $amqp_password                = $quickstack::params::amqp_password,
  $tenant_network_type          = $quickstack::params::tenant_network_type,
  $tunnel_id_ranges             = '1:1000',
  $ovs_vxlan_udp_port           = $quickstack::params::ovs_vxlan_udp_port,
  $ovs_tunnel_types             = $quickstack::params::ovs_tunnel_types,
  $verbose                      = $quickstack::params::verbose,
  $ssl                          = $quickstack::params::ssl,
  $security_group_api		= 'neutron',
  $mysql_ca                     = $quickstack::params::mysql_ca,
  $libvirt_images_rbd_pool      = 'volumes',
  $libvirt_images_rbd_ceph_conf = '/etc/ceph/ceph.conf',
  $libvirt_inject_password      = 'false',
  $libvirt_inject_key           = 'false',
  $libvirt_images_type          = 'rbd',
  $rbd_user                     = 'volumes',
  $rbd_secret_uuid              = '',
  $private_iface                = '',
  $private_ip                   = '',
  $private_network              = '',
) inherits quickstack::params {

  if str2bool_i("$ssl") {
    $qpid_protocol = 'ssl'
    $real_amqp_port = $amqp_ssl_port
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron?ssl_ca=${mysql_ca}"
  } else {
    $qpid_protocol = 'tcp'
    $real_amqp_port = $amqp_port
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  }

  class { '::neutron':
    allow_overlapping_ips => true,
    rpc_backend           => amqp_backend('neutron', $amqp_provider),
    qpid_hostname         => $amqp_host,
    qpid_port             => $real_amqp_port,
    qpid_protocol         => $qpid_protocol,
    qpid_username         => $amqp_username,
    qpid_password         => $amqp_password,
    rabbit_host           => $amqp_host,
    rabbit_port           => $real_amqp_port,
    rabbit_user           => $amqp_username,
    rabbit_password       => $amqp_password,
    verbose               => $verbose,
  }
  ->
  class { '::neutron::server::notifications':
    notify_nova_on_port_status_changes => true,
    notify_nova_on_port_data_changes   => true,
    nova_url                           => "http://${nova_host}:8774/v2",
    nova_admin_auth_url                => "http://${auth_host}:35357/v2.0",
    nova_admin_username                => "nova",
    nova_admin_password                => "${nova_user_password}",
  }

  neutron_config {
    'database/connection':                  value => $sql_connection;
    'keystone_authtoken/auth_host':         value => $auth_host;
    'keystone_authtoken/admin_tenant_name': value => 'services';
    'keystone_authtoken/admin_user':        value => 'neutron';
    'keystone_authtoken/admin_password':    value => $neutron_user_password;
  }

  if $enable_plumgrid == 'true' {

    include nova::params

    firewall { '001 nova metadata incoming':
      proto  => 'tcp',
      dport  => ['8775'],
      action => 'accept',
    }

    # Install the nova-api
    nova::generic_service { 'api':
      enabled      => true,
      package_name => $::nova::params::api_package_name,
      service_name => $::nova::params::api_service_name,
    }

    nova_config {
      'neutron/service_metadata_proxy': value => true;
      'neutron/metadata_proxy_shared_secret':
        value => $neutron_metadata_proxy_secret;
    }

    nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
    nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}

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
  if downcase("$agent_type") == 'ovs' {
    class { '::neutron::plugins::ovs':
      sql_connection      => $sql_connection,
      tenant_network_type => $tenant_network_type,
      network_vlan_ranges => $ovs_vlan_ranges,
      tunnel_id_ranges    => $tunnel_id_ranges,
      vxlan_udp_port      => $ovs_vxlan_udp_port,
    }

    neutron_plugin_ovs { 'AGENT/l2_population': value => "$ovs_l2_population"; }

    $local_ip = find_ip("$ovs_tunnel_network","$ovs_tunnel_iface","")
    class { '::neutron::agents::ovs':
      bridge_uplinks      => $ovs_bridge_uplinks,
      bridge_mappings     => $ovs_bridge_mappings,
      local_ip            => $local_ip,
      enable_tunneling    => str2bool_i("$enable_tunneling"),
      tunnel_types     => $ovs_tunnel_types,
      vxlan_udp_port   => $ovs_vxlan_udp_port,
    }
  }

  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_user_password,
    neutron_url            => "http://${neutron_host}:9696",
    neutron_url_timeout    => "150",
    neutron_admin_auth_url => "http://${auth_host}:35357/v2.0",
    security_group_api     => $security_group_api,
  }


  class { 'quickstack::compute_common':
    admin_password               => $admin_password,
    auth_host                    => $auth_host,
    ceilometer                   => $ceilometer,
    ceilometer_metering_secret   => $ceilometer_metering_secret,
    ceilometer_user_password     => $ceilometer_user_password,
    ceph_cluster_network         => $ceph_cluster_network,
    ceph_public_network          => $ceph_public_network,
    ceph_fsid                    => $ceph_fsid,
    ceph_images_key              => $ceph_images_key,
    ceph_volumes_key             => $ceph_volumes_key,
    ceph_mon_host                => $ceph_mon_host,
    ceph_mon_initial_members     => $ceph_mon_initial_members,
    ceph_osd_pool_default_size   => $ceph_osd_pool_default_size,
    ceph_osd_journal_size        => $ceph_osd_journal_size,
    cinder_backend_gluster       => $cinder_backend_gluster,
    cinder_backend_nfs           => $cinder_backend_nfs,
    cinder_backend_rbd           => $cinder_backend_rbd,
    glance_backend_rbd           => $glance_backend_rbd,
    glance_host                  => $glance_host,
    mysql_host                   => $mysql_host,
    nova_db_password             => $nova_db_password,
    nova_host                    => $nova_host,
    nova_user_password           => $nova_user_password,
    amqp_provider                => $amqp_provider,
    amqp_host                    => $amqp_host,
    amqp_port                    => $amqp_port,
    amqp_ssl_port                => $amqp_ssl_port,
    amqp_username                => $amqp_username,
    amqp_password                => $amqp_password,
    verbose                      => $verbose,
    ssl                          => $ssl,
    mysql_ca                     => $mysql_ca,
    libvirt_images_rbd_pool      => $libvirt_images_rbd_pool,
    libvirt_images_rbd_ceph_conf => $libvirt_images_rbd_ceph_conf,
    libvirt_inject_password      => $libvirt_inject_password,
    libvirt_inject_key           => $libvirt_inject_key,
    libvirt_images_type          => $libvirt_images_type,
    rbd_user                     => $rbd_user,
    rbd_secret_uuid              => $rbd_secret_uuid,
    private_iface                => $private_iface,
    private_ip                   => $private_ip,
    private_network              => $private_network,
  }

  class {'quickstack::neutron::firewall::gre':}

  class {'quickstack::neutron::firewall::vxlan':
    port => $ovs_vxlan_udp_port,
  }
}
