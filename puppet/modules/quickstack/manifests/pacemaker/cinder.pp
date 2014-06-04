class quickstack::pacemaker::cinder(
  $db_name           = 'cinder',
  $db_user           = 'cinder',

  $volume            = false,
  $volume_backend    = 'iscsi',

  $glusterfs_shares  = [],

  $nfs_shares        = [],
  $nfs_mount_options = undef,

  $db_ssl            = false,
  $db_ssl_ca         = undef,

  $qpid_heartbeat    = '60',

  $use_syslog        = false,
  $log_facility      = 'LOG_USER',

  $enabled           = true,
  $debug             = false,
  $verbose           = false,
) {

  include ::quickstack::pacemaker::common

  if (map_params('include_cinder') == 'true' and map_params("db_is_ready")) {

    include ::quickstack::pacemaker::qpid

    $cinder_user_password = map_params("cinder_user_password")
    $cinder_private_vip   = map_params("cinder_private_vip")
    $pcmk_cinder_group    = map_params("cinder_group")
    $db_host              = map_params("db_vip")
    $db_password          = map_params("cinder_db_password")
    $glance_host          = map_params("glance_admin_vip")
    $keystone_host        = map_params("keystone_admin_vip")
    $qpid_host            = map_params("qpid_vip")
    $qpid_port            = map_params("qpid_port")
    $qpid_username        = map_params("qpid_username")
    $qpid_password        = map_params("qpid_password")

    Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip'] -> Exec['cinder-manage db_sync']
    if (map_params('include_mysql') == 'true') {
      if str2bool_i("$hamysql_is_running") {
        Exec['mysql-has-users'] -> Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip']
      }
    }
    if (map_params('include_keystone') == 'true') {
      Exec['all-keystone-nodes-are-up'] -> Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip']
    }
    if (map_params('include_swift') == 'true') {
      Exec['all-swift-nodes-are-up'] -> Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip']
    }
    if (map_params('include_glance') == 'true') {
      Exec['all-glance-nodes-are-up'] -> Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip']
    }
    if (map_params('include_nova') == 'true') {
      Exec['all-nova-nodes-are-up'] -> Exec['i-am-cinder-vip-OR-cinder-is-up-on-vip']
    }

    Class['::quickstack::pacemaker::qpid']
    ->
    # assuming openstack-cinder-api and openstack-cinder-scheduler
    # always have same vip's for now
    quickstack::pacemaker::vips { "$pcmk_cinder_group":
      public_vip  => map_params("cinder_public_vip"),
      private_vip => map_params("cinder_private_vip"),
      admin_vip   => map_params("cinder_admin_vip"),
    }
    ->
    exec {"i-am-cinder-vip-OR-cinder-is-up-on-vip":
      timeout => 3600,
      tries => 360,
      try_sleep => 10,
      command => "/tmp/ha-all-in-one-util.bash i_am_vip $cinder_private_vip || /tmp/ha-all-in-one-util.bash property_exists cinder",
      unless => "/tmp/ha-all-in-one-util.bash i_am_vip $cinder_private_vip || /tmp/ha-all-in-one-util.bash property_exists cinder",
    }
    ->
    class {'::quickstack::cinder':
      user_password  => $cinder_user_password,
      bind_host      => map_params('local_bind_addr'),
      db_host        => $db_host,
      db_name        => $db_name,
      db_user        => $db_user,
      db_password    => $db_password,
      db_ssl         => $db_ssl,
      db_ssl_ca      => $db_ssl_ca,
      glance_host    => $glance_host,
      keystone_host  => $keystone_host,
      qpid_heartbeat => $qpid_heartbeat,
      qpid_host      => $qpid_host,
      qpid_port      => $qpid_port,
      qpid_username  => $qpid_username,
      qpid_password  => $qpid_password,
      use_syslog     => $use_syslog,
      log_facility   => $log_facility,
      enabled        => $enabled,
      debug          => $debug,
      verbose        => $verbose,
    }

    Class['::quickstack::cinder']
    ->
    class {"::quickstack::load_balancer::cinder":
      frontend_pub_host    => map_params("cinder_public_vip"),
      frontend_priv_host   => map_params("cinder_private_vip"),
      frontend_admin_host  => map_params("cinder_admin_vip"),
      backend_server_names => map_params("lb_backend_server_names"),
      backend_server_addrs => map_params("lb_backend_server_addrs"),
    }
    ->
    exec {"pcs-cinder-server-set-up":
      command => "/usr/sbin/pcs property set cinder=running --force",
    } ->
    exec {"pcs-cinder-server-set-up-on-this-node":
      command => "/tmp/ha-all-in-one-util.bash update_my_node_property cinder"
    } ->
    exec {"all-cinder-nodes-are-up":
      timeout   => 3600,
      tries     => 360,
      try_sleep => 10,
      command   => "/tmp/ha-all-in-one-util.bash all_members_include cinder",
    }
    ->
    quickstack::pacemaker::resource::lsb {'openstack-cinder-api':
      group => "$pcmk_cinder_group",
      clone => true,
    }
    ->
    quickstack::pacemaker::resource::lsb {'openstack-cinder-scheduler':
      group => "$pcmk_cinder_group",
      clone => true,
    }

    if str2bool_i("$volume") {
      Class['::quickstack::cinder']
      ->
      class {'::quickstack::cinder_volume':
        volume_backend    => $volume_backend,
        iscsi_bind_addr   => map_params('local_bind_addr'),
        glusterfs_shares  => $glusterfs_shares,
        nfs_shares        => $nfs_shares,
        nfs_mount_options => $nfs_mount_options,
      }
      ->
      Exec['pcs-cinder-server-set-up']

      Exec['all-cinder-nodes-are-up']
      ->
      quickstack::pacemaker::resource::lsb {'openstack-cinder-volume':
        group => "$pcmk_cinder_group",
        clone => true,
      }
    }
  }
}
