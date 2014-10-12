# Quickstart controller class for nova neutron (OpenStack Networking)
class quickstack::neutron::controller (
  $admin_email                   = $quickstack::params::admin_email,
  $admin_password                = $quickstack::params::admin_password,
  $ceilometer_metering_secret    = $quickstack::params::ceilometer_metering_secret,
  $ceilometer_user_password      = $quickstack::params::ceilometer_user_password,
  $ceph_cluster_network          = '',
  $ceph_public_network           = '',
  $ceph_fsid                     = '',
  $ceph_images_key               = '',
  $ceph_volumes_key              = '',
  $ceph_mon_host                 = [ ],
  $ceph_mon_initial_members      = [ ],
  $cinder_backend_eqlx           = $quickstack::params::cinder_backend_eqlx,
  $cinder_backend_eqlx_name      = $quickstack::params::cinder_backend_eqlx_name,
  $cinder_backend_gluster        = $quickstack::params::cinder_backend_gluster,
  $cinder_backend_gluster_name   = $quickstack::params::cinder_backend_gluster_name,
  $cinder_backend_iscsi          = $quickstack::params::cinder_backend_iscsi,
  $cinder_backend_iscsi_name     = $quickstack::params::cinder_backend_iscsi_name,
  $cinder_backend_nfs            = $quickstack::params::cinder_backend_nfs,
  $cinder_backend_nfs_name       = $quickstack::params::cinder_backend_nfs_name,
  $cinder_backend_rbd            = $quickstack::params::cinder_backend_rbd,
  $cinder_backend_rbd_name       = $quickstack::params::cinder_backend_rbd_name,
  $cinder_db_password            = $quickstack::params::cinder_db_password,
  $cinder_multiple_backends      = $quickstack::params::cinder_multiple_backends,
  $cinder_gluster_shares         = $quickstack::params::cinder_gluster_shares,
  $cinder_nfs_shares             = $quickstack::params::cinder_nfs_shares,
  $cinder_nfs_mount_options      = $quickstack::params::cinder_nfs_mount_options,
  $cinder_san_ip                 = $quickstack::params::cinder_san_ip,
  $cinder_san_login              = $quickstack::params::cinder_san_login,
  $cinder_san_password           = $quickstack::params::cinder_san_password,
  $cinder_san_thin_provision     = $quickstack::params::cinder_san_thin_provision,
  $cinder_eqlx_group_name        = $quickstack::params::cinder_eqlx_group_name,
  $cinder_eqlx_pool              = $quickstack::params::cinder_eqlx_pool,
  $cinder_eqlx_use_chap          = $quickstack::params::cinder_eqlx_use_chap,
  $cinder_eqlx_chap_login        = $quickstack::params::cinder_eqlx_chap_login,
  $cinder_eqlx_chap_password     = $quickstack::params::cinder_eqlx_chap_password,
  $cinder_rbd_pool               = $quickstack::params::cinder_rbd_pool,
  $cinder_rbd_ceph_conf          = $quickstack::params::cinder_rbd_ceph_conf,
  $cinder_rbd_flatten_volume_from_snapshot
                                 = $quickstack::params::cinder_rbd_flatten_volume_from_snapshot,
  $cinder_rbd_max_clone_depth    = $quickstack::params::cinder_rbd_max_clone_depth,
  $cinder_rbd_user               = $quickstack::params::cinder_rbd_user,
  $cinder_rbd_secret_uuid        = $quickstack::params::cinder_rbd_secret_uuid,
  $cinder_user_password          = $quickstack::params::cinder_user_password,
  $cisco_nexus_plugin            = $quickstack::params::cisco_nexus_plugin,
  $cisco_vswitch_plugin          = $quickstack::params::cisco_vswitch_plugin,
  $controller_admin_host         = $quickstack::params::controller_admin_host,
  $pg_connection                 = $quickstack::params::pg_connection,
  $pg_director_server            = $quickstack::params::pg_director_server,
  $pg_director_server_port       = $quickstack::params::pg_director_server_port,
  $pg_username                   = $quickstack::params::pg_username,
  $pg_password                   = $quickstack::params::pg_password,
  $pg_servertimeout              = $quickstack::params::pg_servertimeout,
  $pg_enable_metadata_agent      = false,
  $pg_fw_src                     = $quickstack::params::pg_fw_src,
  $pg_fw_dest                    = $quickstack::params::pg_fw_dest,
  $controller_priv_host          = $quickstack::params::controller_priv_host,
  $controller_pub_host           = $quickstack::params::controller_pub_host,
  $glance_db_password            = $quickstack::params::glance_db_password,
  $glance_user_password          = $quickstack::params::glance_user_password,
  $glance_backend                = $quickstack::params::glance_backend,
  $glance_rbd_store_user         = $quickstack::params::glance_rbd_store_user,
  $glance_rbd_store_pool         = $quickstack::params::glance_rbd_store_pool,
  $heat_auth_encrypt_key         = $quickstack::params::heat_auth_encrypt_key,
  $heat_cfn                      = $quickstack::params::heat_cfn,
  $heat_cloudwatch               = $quickstack::params::heat_cloudwatch,
  $heat_db_password              = $quickstack::params::heat_db_password,
  $heat_user_password            = $quickstack::params::heat_user_password,
  $horizon_secret_key            = $quickstack::params::horizon_secret_key,
  $keystone_admin_token          = $quickstack::params::keystone_admin_token,
  $keystone_db_password          = $quickstack::params::keystone_db_password,
  $keystonerc                    = false,
  $neutron_metadata_proxy_secret = $quickstack::params::neutron_metadata_proxy_secret,
  $mysql_host                    = $quickstack::params::mysql_host,
  $mysql_root_password           = $quickstack::params::mysql_root_password,
  $neutron_core_plugin           = 'neutron.plugins.ml2.plugin.Ml2Plugin',
  $neutron_db_password           = $quickstack::params::neutron_db_password,
  $neutron_user_password         = $quickstack::params::neutron_user_password,
  $nexus_config                  = $quickstack::params::nexus_config,
  $nexus_credentials             = $quickstack::params::nexus_credentials,
  $nova_db_password              = $quickstack::params::nova_db_password,
  $nova_user_password            = $quickstack::params::nova_user_password,
  $nova_default_floating_pool    = $quickstack::params::nova_default_floating_pool,
  $ovs_vlan_ranges               = $quickstack::params::ovs_vlan_ranges,
  $provider_vlan_auto_create     = $quickstack::params::provider_vlan_auto_create,
  $provider_vlan_auto_trunk      = $quickstack::params::provider_vlan_auto_trunk,
  $enable_tunneling              = $quickstack::params::enable_tunneling,
  $tunnel_id_ranges              = '1:1000',
  $ml2_type_drivers              = ['vxlan', 'flat','vlan','gre','local'],
  $ml2_tenant_network_types      = ['vxlan', 'flat','vlan','gre'],
  $ml2_mechanism_drivers         = ['openvswitch','l2population'],
  $ml2_flat_networks             = ['*'],
  $ml2_network_vlan_ranges       = ['physnet1:1000:2999'],
  $ml2_tunnel_id_ranges          = ['20:100'],
  $ml2_vxlan_group               = '224.0.0.1',
  $ml2_vni_ranges                = ['10:100'],
  $ml2_security_group            = 'true',
  $ml2_firewall_driver           = 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
  $amqp_provider                 = $quickstack::params::amqp_provider,
  $amqp_host                     = $quickstack::params::amqp_host,
  $amqp_username                 = $quickstack::params::amqp_username,
  $amqp_password                 = $quickstack::params::amqp_password,
  $swift_shared_secret           = $quickstack::params::swift_shared_secret,
  $swift_admin_password          = $quickstack::params::swift_admin_password,
  $swift_ringserver_ip           = '192.168.203.1',
  $swift_storage_ips             = ['192.168.203.2', '192.168.203.3', '192.168.203.4'],
  $swift_storage_device          = 'device1',
  $tenant_network_type           = $quickstack::params::tenant_network_type,
  $verbose                       = $quickstack::params::verbose,
  $ssl                           = $quickstack::params::ssl,
  $freeipa                       = $quickstack::params::freeipa,
  $mysql_ca                      = $quickstack::params::mysql_ca,
  $mysql_cert                    = $quickstack::params::mysql_cert,
  $mysql_key                     = $quickstack::params::mysql_key,
  $amqp_ca                       = $quickstack::params::amqp_ca,
  $amqp_cert                     = $quickstack::params::amqp_cert,
  $amqp_key                      = $quickstack::params::amqp_key,
  $horizon_ca                    = $quickstack::params::horizon_ca,
  $horizon_cert                  = $quickstack::params::horizon_cert,
  $horizon_key                   = $quickstack::params::horizon_key,
  $amqp_nssdb_password           = $quickstack::params::amqp_nssdb_password,
) inherits quickstack::params {

  if str2bool_i("$ssl") {
    $qpid_protocol = 'ssl'
    $amqp_port = '5671'
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron?ssl_ca=${mysql_ca}"
  } else {
    $qpid_protocol = 'tcp'
    $amqp_port = '5672'
    $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  }

  if $neutron_core_plugin == 'neutron.plugins.plumgrid.plumgrid_plugin.plumgrid_plugin.NeutronPluginPLUMgridV2' {
    $neutron_db_manage_cmd = 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini stamp icehouse'
  } else {
    $neutron_db_manage_cmd = 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head'
  }

  class { 'quickstack::controller_common':
    admin_email                   => $admin_email,
    admin_password                => $admin_password,
    ceilometer_metering_secret    => $ceilometer_metering_secret,
    ceilometer_user_password      => $ceilometer_user_password,
    ceph_cluster_network          => $ceph_cluster_network,
    ceph_public_network           => $ceph_public_network,
    ceph_fsid                     => $ceph_fsid,
    ceph_images_key               => $ceph_images_key,
    ceph_volumes_key              => $ceph_volumes_key,
    ceph_mon_host                 => $ceph_mon_host,
    ceph_mon_initial_members      => $ceph_mon_initial_members,
    cinder_backend_eqlx           => $cinder_backend_eqlx,
    cinder_backend_eqlx_name      => $cinder_backend_eqlx_name,
    cinder_backend_gluster        => $cinder_backend_gluster,
    cinder_backend_gluster_name   => $cinder_backend_gluster_name,
    cinder_backend_iscsi          => $cinder_backend_iscsi,
    cinder_backend_iscsi_name     => $cinder_backend_iscsi_name,
    cinder_backend_nfs            => $cinder_backend_nfs,
    cinder_backend_nfs_name       => $cinder_backend_nfs_name,
    cinder_backend_rbd            => $cinder_backend_rbd,
    cinder_backend_rbd_name       => $cinder_backend_rbd_name,
    cinder_db_password            => $cinder_db_password,
    cinder_multiple_backends      => $cinder_multiple_backends,
    cinder_gluster_shares         => $cinder_gluster_shares,
    cinder_nfs_shares             => $cinder_nfs_shares,
    cinder_nfs_mount_options      => $cinder_nfs_mount_options,
    cinder_san_ip                 => $cinder_san_ip,
    cinder_san_login              => $cinder_san_login,
    cinder_san_password           => $cinder_san_password,
    cinder_san_thin_provision     => $cinder_san_thin_provision,
    cinder_eqlx_group_name        => $cinder_eqlx_group_name,
    cinder_eqlx_pool              => $cinder_eqlx_pool,
    cinder_eqlx_use_chap          => $cinder_eqlx_use_chap,
    cinder_eqlx_chap_login        => $cinder_eqlx_chap_login,
    cinder_eqlx_chap_password     => $cinder_eqlx_chap_password,
    cinder_rbd_pool               => $cinder_rbd_pool,
    cinder_rbd_ceph_conf          => $cinder_rbd_ceph_conf,
    cinder_rbd_flatten_volume_from_snapshot
                                  => $cinder_rbd_flatten_volume_from_snapshot,
    cinder_rbd_max_clone_depth    => $cinder_rbd_max_clone_depth,
    cinder_rbd_user               => $cinder_rbd_user,
    cinder_rbd_secret_uuid        => $cinder_rbd_secret_uuid,
    cinder_user_password          => $cinder_user_password,
    controller_admin_host         => $controller_admin_host,
    controller_priv_host          => $controller_priv_host,
    controller_pub_host           => $controller_pub_host,
    glance_db_password            => $glance_db_password,
    glance_user_password          => $glance_user_password,
    glance_backend                => $glance_backend,
    glance_rbd_store_user         => $glance_rbd_store_user,
    glance_rbd_store_pool         => $glance_rbd_store_pool,
    heat_auth_encrypt_key         => $heat_auth_encrypt_key,
    heat_cfn                      => $heat_cfn,
    heat_cloudwatch               => $heat_cloudwatch,
    heat_db_password              => $heat_db_password,
    heat_user_password            => $heat_user_password,
    horizon_secret_key            => $horizon_secret_key,
    keystone_admin_token          => $keystone_admin_token,
    keystone_db_password          => $keystone_db_password,
    keystonerc                    => $keystonerc,
    neutron_metadata_proxy_secret => $neutron_metadata_proxy_secret,
    mysql_host                    => $mysql_host,
    mysql_root_password           => $mysql_root_password,
    neutron                       => true,
    neutron_core_plugin           => $neutron_core_plugin,
    neutron_db_password           => $neutron_db_password,
    neutron_user_password         => $neutron_user_password,
    nova_db_password              => $nova_db_password,
    nova_user_password            => $nova_user_password,
    nova_default_floating_pool    => $nova_default_floating_pool,
    amqp_host                     => $amqp_host,
    amqp_username                 => $amqp_username,
    amqp_password                 => $amqp_password,
    swift_shared_secret           => $swift_shared_secret,
    swift_admin_password          => $swift_admin_password,
    swift_ringserver_ip           => $swift_ringserver_ip,
    swift_storage_ips             => $swift_storage_ips,
    swift_storage_device          => $swift_storage_device,
    verbose                       => $verbose,
    ssl                           => $ssl,
    freeipa                       => $freeipa,
    mysql_ca                      => $mysql_ca,
    mysql_cert                    => $mysql_cert,
    mysql_key                     => $mysql_key,
    amqp_ca                       => $amqp_ca,
    amqp_cert                     => $amqp_cert,
    amqp_key                      => $amqp_key,
    horizon_ca                    => $horizon_ca,
    horizon_cert                  => $horizon_cert,
    horizon_key                   => $horizon_key,
    amqp_nssdb_password           => $amqp_nssdb_password,
  }
  ->
  class { '::neutron':
    enabled               => true,
    verbose               => $verbose,
    allow_overlapping_ips => true,
    rpc_backend           => amqp_backend('neutron', $amqp_provider),
    qpid_hostname         => $amqp_host,
    qpid_port             => $amqp_port,
    qpid_protocol         => $qpid_protocol,
    qpid_username         => $amqp_username,
    qpid_password         => $amqp_password,
    rabbit_host           => $amqp_host,
    rabbit_port           => $amqp_port,
    rabbit_user           => $amqp_username,
    rabbit_password       => $amqp_password,
    core_plugin           => $neutron_core_plugin
  }
  ->
  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_user_password,
  }
  ->
  class { '::neutron::server::notifications':
    notify_nova_on_port_status_changes => true,
    notify_nova_on_port_data_changes   => true,
    nova_url                           => "http://${controller_priv_host}:8774/v2",
    nova_admin_auth_url                => "http://${controller_priv_host}:35357/v2.0",
    nova_admin_username                => "nova",
    nova_admin_password                => "${nova_user_password}",
  }
  ->
  # FIXME: This really should be handled by the neutron-puppet module, which has
  # a review request open right now: https://review.openstack.org/#/c/50162/
  # If and when that is merged (or similar), the below can be removed.
  exec { 'neutron-db-manage upgrade':
    #command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    command     => $neutron_db_manage_cmd,
    path        => '/usr/bin',
    user        => 'neutron',
    logoutput   => 'on_failure',
    before      => Service['neutron-server'],
    require     => [Neutron_config['database/connection'], Neutron_config['DEFAULT/core_plugin']],
  }

  class { '::neutron::server':
    auth_host        => $::ipaddress,
    auth_password    => $neutron_user_password,
    connection       => $sql_connection,
    sql_connection   => false,
  }

  if $neutron_core_plugin == 'neutron.plugins.ml2.plugin.Ml2Plugin' {

    neutron_config {
      'DEFAULT/service_plugins':
        value => join(['neutron.services.l3_router.l3_router_plugin.L3RouterPlugin',]),
    }
    ->
    class { '::neutron::plugins::ml2':
      type_drivers          => $ml2_type_drivers,
      tenant_network_types  => $ml2_tenant_network_types,
      mechanism_drivers     => $ml2_mechanism_drivers,
      flat_networks         => $ml2_flat_networks,
      network_vlan_ranges   => $ml2_network_vlan_ranges,
      tunnel_id_ranges      => $ml2_tunnel_id_ranges,
      vxlan_group           => $ml2_vxlan_group,
      vni_ranges            => $ml2_vni_ranges,
      enable_security_group => str2bool_i("$ml2_security_group"),
      firewall_driver       => $ml2_firewall_driver,
    }

    # If cisco nexus is part of ml2 mechanism drivers,
    # setup Mech Driver Cisco Neutron plugin class.
    if ('cisco_nexus' in $ml2_mechanism_drivers) {
      class { 'neutron::plugins::ml2::cisco::nexus':
        nexus_config        => $nexus_config,
      }
    }
  }

  if $neutron_core_plugin == 'neutron.plugins.cisco.network_plugin.PluginV2' {
    class { 'quickstack::neutron::plugins::cisco':
      neutron_db_password          => $neutron_db_password,
      neutron_user_password        => $neutron_user_password,
      ovs_vlan_ranges              => $ovs_vlan_ranges,
      cisco_vswitch_plugin         => $cisco_vswitch_plugin,
      nexus_config                 => $nexus_config,
      cisco_nexus_plugin           => $cisco_nexus_plugin,
      nexus_credentials            => $nexus_credentials,
      provider_vlan_auto_create    => $provider_vlan_auto_create,
      provider_vlan_auto_trunk     => $provider_vlan_auto_trunk,
      mysql_host                   => $mysql_host,
      mysql_ca                     => $mysql_ca,
      tenant_network_type          => $tenant_network_type,
    }
  }

  if $neutron_core_plugin == 'neutron.plugins.plumgrid.plumgrid_plugin.plumgrid_plugin.NeutronPluginPLUMgridV2' {
    neutron_config {
      'DEFAULT/service_plugins': ensure => absent,
    }->
    class { 'quickstack::neutron::plugins::plumgrid':
      pg_connection                 => $sql_connection,
      pg_director_server            => $pg_director_server,
      pg_director_server_port       => $pg_director_server_port,
      pg_username                   => $pg_username,
      pg_password                   => $pg_password,
      pg_servertimeout              => $pg_servertimeout,
      pg_enable_metadata_agent      => $pg_enable_metadata_agent,
      admin_password                => $admin_password,
      neutron_metadata_proxy_secret => $neutron_metadata_proxy_secret,      
      pg_fw_src                     => $pg_fw_src,
      pg_fw_dest                    => $pg_fw_dest,
    }
    
    nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
    nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}
    nova_config { 'DEFAULT/libvirt_cpu_mode': value => 'none'}
  }

  firewall { '001 neutron server (API)':
    proto    => 'tcp',
    dport    => ['9696'],
    action   => 'accept',
  }
}
