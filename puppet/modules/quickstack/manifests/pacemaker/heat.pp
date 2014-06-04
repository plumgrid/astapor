class quickstack::pacemaker::heat(
  $db_name             = 'heat',
  $db_user             = 'heat',

  $db_ssl              = false,
  $db_ssl_ca           = undef,

  $qpid_heartbeat      = '60',

  $use_syslog          = false,
  $log_facility        = 'LOG_USER',

  $enabled             = true,
  $debug               = false,
  $verbose             = false,
) {

  include ::quickstack::pacemaker::common

  if (map_params('include_heat') == 'true' and map_params("db_is_ready")) {

    include ::quickstack::pacemaker::qpid

    $heat_db_password        = map_params("heat_db_password")
    $heat_cfn_enabled        = map_params("heat_cfn_enabled")
    $heat_cloudwatch_enabled = map_params("heat_cloudwatch_enabled")
    $heat_group              = map_params("heat_group")
    $heat_cfn_group          = map_params("heat_cfn_group")
    $heat_private_vip        = map_params("heat_private_vip")

    Exec['i-am-heat-vip-OR-heat-is-up-on-vip'] -> Exec<| title == 'heat-manage db_sync' |>
    if (map_params('include_mysql') == 'true') {
      if str2bool_i("$hamysql_is_running") {
        Exec['mysql-has-users'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
      }
    }
    if (map_params('include_keystone') == 'true') {
      Exec['all-keystone-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }
    if (map_params('include_swift') == 'true') {
      Exec['all-swift-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }
    if (map_params('include_glance') == 'true') {
      Exec['all-glance-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }
    if (map_params('include_nova') == 'true') {
      Exec['all-nova-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }
    if (map_params('include_cinder') == 'true') {
      Exec['all-cinder-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }
    if (map_params('include_neutron') == 'true') {
      Exec['all-neutron-nodes-are-up'] -> Exec['i-am-heat-vip-OR-heat-is-up-on-vip']
    }

    Class['::quickstack::pacemaker::qpid']
    ->
    quickstack::pacemaker::vips { "$heat_group":
      public_vip  => map_params("heat_public_vip"),
      private_vip => map_params("heat_private_vip"),
      admin_vip   => map_params("heat_admin_vip"),
    }
    ->
    exec {"i-am-heat-vip-OR-heat-is-up-on-vip":
      timeout => 3600,
      tries => 360,
      try_sleep => 10,
      command => "/tmp/ha-all-in-one-util.bash i_am_vip $heat_private_vip || /tmp/ha-all-in-one-util.bash property_exists heat",
      unless => "/tmp/ha-all-in-one-util.bash i_am_vip $heat_private_vip || /tmp/ha-all-in-one-util.bash property_exists heat",
    }
    ->
    class {'::quickstack::heat':
      heat_user_password      => map_params("heat_user_password"),
      heat_cfn_user_password  => map_params("heat_cfn_user_password"),
      auth_encryption_key     => map_params("heat_auth_encryption_key"),
      bind_host               => map_params("local_bind_addr"),
      db_host                 => map_params("db_vip"),
      db_name                 => $db_name,
      db_user                 => $db_user,
      db_password             => $heat_db_password,
      db_ssl                  => $db_ssl,
      db_ssl_ca               => $db_ssl_ca,
      keystone_host           => map_params("keystone_admin_vip"),
      qpid_heartbeat          => $qpid_heartbeat,
      qpid_host               => map_params("qpid_vip"),
      qpid_port               => map_params("qpid_port"),
      qpid_username           => map_params("qpid_username"),
      qpid_password           => map_params("qpid_password"),
      cfn_host                => map_params("heat_cfn_admin_vip"),
      cloudwatch_host         => map_params("heat_admin_vip"),
      use_syslog              => $use_syslog,
      log_facility            => $log_facility,
      enabled                 => $enabled,
      debug                   => $debug,
      verbose                 => $verbose,
      heat_cfn_enabled        => $heat_cfn_enabled,
      heat_cloudwatch_enabled => $heat_cloudwatch_enabled,
      # don't start heat-engine on all hosts, let pacemaker start it on one
      heat_engine_enabled     => false,
    }
    ->
    class {"::quickstack::load_balancer::heat":
      frontend_heat_pub_host              => map_params("heat_public_vip"),
      frontend_heat_priv_host             => map_params("heat_private_vip"),
      frontend_heat_admin_host            => map_params("heat_admin_vip"),
      frontend_heat_cfn_pub_host          => map_params("heat_cfn_public_vip"),
      frontend_heat_cfn_priv_host         => map_params("heat_cfn_private_vip"),
      frontend_heat_cfn_admin_host        => map_params("heat_cfn_admin_vip"),
      backend_server_names                => map_params("lb_backend_server_names"),
      backend_server_addrs                => map_params("lb_backend_server_addrs"),
      heat_cfn_enabled                    => $heat_cfn_enabled,
      heat_cloudwatch_enabled             => $heat_cloudwatch_enabled,
    }
    ->
    exec {"pcs-heat-server-set-up":
      command => "/usr/sbin/pcs property set heat=running --force",
    }
    ->
    exec {"pcs-heat-server-set-up-on-this-node":
      command => "/tmp/ha-all-in-one-util.bash update_my_node_property heat"
    }
    ->
    exec {"all-heat-nodes-are-up":
      timeout   => 3600,
      tries     => 360,
      try_sleep => 10,
      command   => "/tmp/ha-all-in-one-util.bash all_members_include heat",
    }
    ->
    quickstack::pacemaker::resource::lsb {'openstack-heat-api':
      group => "$heat_group",
      clone => true,
    }
    ->
    quickstack::pacemaker::resource::lsb {'openstack-heat-engine':
      group => "$heat_group",
      clone => false,
    }

    if str2bool_i($heat_cfn_enabled) {
      Class['::quickstack::pacemaker::qpid']
      ->
      quickstack::pacemaker::vips {"$heat_cfn_group":
        public_vip  => map_params("heat_cfn_public_vip"),
        private_vip => map_params("heat_cfn_private_vip"),
        admin_vip   => map_params("heat_cfn_admin_vip"),
      }
      ->
      Exec["i-am-heat-vip-OR-heat-is-up-on-vip"]

      Exec["all-heat-nodes-are-up"]
      ->
      quickstack::pacemaker::resource::lsb {"openstack-heat-api-cfn":
        group => "$heat_cfn_group",
        clone => true,
      }
    }

    if str2bool_i($heat_cloudwatch_enabled) {
      Exec["all-heat-nodes-are-up"]
      ->
      quickstack::pacemaker::resource::lsb {"openstack-heat-api-cloudwatch":
        group => "$heat_group",
        clone => true,
      }
    }
  }
}
