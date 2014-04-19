# == Class: redis
#
# This module manages Redis installation and initial configuration.
#
# === Authors
#
# Rhommel Lamas <roml@rhommell.com>
#
# === LICENSE
#
# Copyright (c) 2014 Rhommel Lamas
#
class redis (
  $activerehashing             = 'yes',
  $appendonly                  = 'no',
  $appendfsync                 = 'everysec',
  $appendfilename              = 'appendonly.aof',
  $auto_aof_rewrite_percentage = 100,
  $auto_aof_rewrite_min_size   = '64mb',
  $bind_address                = undef,
  $client_output_buffer_limits = [],
  $config_file                 = 'redis.conf',
  $custom_install_dir          = '/opt/redis',
  $daemonize                   = 'no',
  $databases                   = 16,
  $dbfilename                  = 'dump.rdb',
  $group                       = 'redis',
  $hash_max_ziplist_entries    = 512,
  $hash_max_ziplist_value      = 64,
  $hz                          = 10,
  $includes                    = undef,
  $list_max_ziplist_entries    = 512,
  $list_max_ziplist_value      = 64,
  $log_level                   = 'notice',
  $logfile                     = '/opt/redis/logs/redis-server.log',
  $lua_time_limit              = 5000,
  $manage_packages             = false,
  $manage_packages_version     = '2.2.12-1build1',
  $manage_service              = false,
  $master                      = true,
  $masterauth                  = undef,
  $maxclients                  = undef,
  $maxmemory                   = undef,
  $maxmemory_policy            = undef,
  $maxmemory_samples           = undef,
  $min_slaves_max_lag          = undef,
  $min_slaves_to_write         = undef,
  $no_appendfsync_on_rewrite   = 'no',
  $notify_keyspace_events      = '',
  $notify_redis                = false,
  $pidfiledir                  = '/var/run/redis',
  $pidfilename                 = 'redis-server.pid',
  $pkg_url                     = 'http://s3.amazonaws.com/repository.3scale.net.us-east-1/redis',
  $port                        = 6379,
  $rename_commands             = [],
  $repl_backlog_ttl            = undef,
  $repl_backlog_size           = undef,
  $repl_disable_tcp_nodelay    = 'no',
  $repl_ping_slave_period      = undef,
  $repl_timeout                = undef,
  $requirepass                 = undef,
  $rdbchecksum                 = 'yes',
  $rdbcompression              = 'yes',
  $rewrite_incremental_fsync   = 'yes',
  $saves                       = [],
  $set_max_intset_entries      = 512,
  $shard_ident                 = '001',
  $slave                       = false,
  $slave_read_only             = 'yes',
  $slave_priority              = 100,
  $slave_serve_stale_data      = 'yes',
  $slaveof                     = undef,
  $slowlog_max_len             = 128,
  $slowlog_slower_than         = 10000,
  $snapshot_dir                = '/mnt/redis-data',
  $stop_writes_on_bgsave_error = 'yes',
  $syslog_enabled              = 'no',
  $syslog_ident                = undef,
  $syslog_facility             = 'local0',
  $tcp_keepalive               = 0,
  $tcp_backlog                 = 511,
  $timeout                     = 0,
  $unixsocket                  = undef,
  $unixsocketperm              = undef,
  $user                        = 'redis',
  $version                     = '2.8.8',
  $zset_max_ziplist_entries    = 128,
  $zset_max_ziplist_value      = 64,
) {

  include redis::dependencies

  # Validate Bools.
  validate_bool($master,$slave,$notify_redis,$manage_packages,$manage_service)

  if $client_output_buffer_limits != undef {
    validate_array($client_output_buffer_limits)
  }

  # Validate absolute paths.
  if $logfile != '' {
    validate_absolute_path($logfile)
  }

  if $unixsocket != undef {
    validate_absolute_path($unixsocket)
  }

  validate_absolute_path($pidfiledir,$snapshot_dir)

  # Validate String
  validate_string($config_file)

  if $syslog_ident != undef {
    validate_string($syslog_ident)
  }

  if $shard_ident != undef {
    validate_string($shard_ident)
  }

  # Validate array.
  if $includes != undef {
    validate_string($includes)
  }

  if $saves != undef {
    validate_array($saves)
  }

  if $rename_commands != undef {
    validate_array($rename_commands)
  }

  validate_re($activerehashing, [ '^yes$', '^no$' ],
    'activerehashing must be \'yes\' or \'no\'.')

  validate_re($rewrite_incremental_fsync, [ '^yes$', '^no$' ],
    'rewrite_incremental_fsync must be \'yes\' or \'no\'.')

  validate_re($auto_aof_rewrite_min_size,'^\d+(bytes|mb|gb)$',
    'auto_aof_rewrite_min_size must be with the format \'43mb\'.')

  validate_re($appendonly, [ '^yes$', '^no$' ],
    'appendonly must be \'yes\' or \'no\'.')

  validate_re($appendfsync, ['^always$','^no$','^everysec$'],
  'appendfsync must be \'yes\' or \'no\'.')

  if $appendfilename != undef {
    validate_re($appendfilename, '^([a-zA-Z0-9]+).aof$',
      'Only allowed filenames with letters and numbers and .aof extension on appendfilename.')
  }

  validate_re($no_appendfsync_on_rewrite, [ '^yes$', '^no$' ],
    'no_appendfsync_on_rewrite must be \'yes\' or \'no\'.')

  if $notify_keyspace_events != '' {
    validate_re($notify_keyspace_events,['^(K)?(E)?(g)?(\$)?(l)?(s)?(h)?(z)?(x)?(e)?(A)?$'],
      'notify_keyspace only accepts one or none of each of this options KEg$lshzxeA, refer to https://github.com/antirez/redis/blob/2.8/redis.conf#L580')
  }

  if $bind_address != undef {
    validate_re($bind_address,['^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$'],
      'You must provide a valid ip on bind_address.')
  }

  validate_re($daemonize, ['^yes$','^no$'],
  'daemonize must be \'yes\' or \'no\'.')

  validate_re($log_level, ['^notice$','^debug$','^verbose$','^warning$'],
  'log_level must be \'notice\', \'debug\',\'verbose\', or \'warning\'.')

  validate_re($syslog_enabled, [ '^yes$', '^no$' ],
  'syslog_enabled must be \'yes\' or \'no\'.')

  validate_re($syslog_facility, ['^local[0-7]$','^user$'],
  'Must be user or local0-local7.')

  if !is_integer($hash_max_ziplist_entries) {
    fail('hash_max_ziplist_entries must be an integer.')
  }

  if !is_integer($hash_max_ziplist_value) {
    fail('hash_max_ziplist_value must be an integer.')
  }

  if !is_integer($hz) {
    fail('hz must be an integer.')
  }

  if !is_integer($hash_max_ziplist_value) {
    fail('hash_max_ziplist_value must be an integer.')
  }

  if !is_integer($hash_max_ziplist_entries) {
    fail('hash_max_ziplist_entries must be an integer.')
  }

  if !is_integer($list_max_ziplist_value) {
    fail('list_max_ziplist_value must be an integer.')
  }

  if !is_integer($set_max_intset_entries) {
    fail('set_max_intset_entries must be an integer.')
  }

  if !is_integer($zset_max_ziplist_entries) {
    fail('zset_max_ziplist_entries must be an integer.')
  }

  if !is_integer($zset_max_ziplist_value) {
    fail('zset_max_ziplist_value must be an integer.')
  }

  if !is_integer($auto_aof_rewrite_percentage) {
    fail('auto_aof_rewrite_percentage must be an integer.')
  }

  if !is_integer($databases) {
    fail('databases must be an integer.')
  }

  if !is_integer($port) {
    fail('port must be an integer.')
  }

  if !is_integer($tcp_keepalive) {
    fail('tcp_keepalive must be an integer.')
  }

  if !is_integer($tcp_backlog) {
    fail('tcp_backlog should be an integer.')
  }

  if !is_integer($timeout) {
    fail('timeout should be an integer.')
  }

  # We will setup unixsockerperm only if unixsocket exists.
  if $unixsocket != undef {
    if !is_integer($unixsocketperm) {
      fail('unixsocketperm should be an integer.')
    }
  }

  if $maxclients != undef {
    if !is_integer($maxclients) {
      fail('maxclients should be an integer.')
    }
  }

  if $maxmemory != undef {
    if !is_integer($maxmemory) {
      fail('maxmemory should be an integer.')
    }

    if $maxmemory > to_bytes($::memoryfree_mb) {
      fail('Check maxmemory because you don\'t have this much free RAM.')
    }
  }

  if $maxmemory_policy != undef {
    validate_re($maxmemory_policy, ['^volatile-lru$',
                                    '^allkeys-lru$',
                                    '^volatile-random$',
                                    '^allkeys-random$',
                                    '^volatile-ttl$',
                                    '^noeviction$'],
      'maxmemory_policy must be \'volatile-lru\',\'allkeys-lru\',\'volatile-random\',\'allkeys-random\',\'volatile-ttl\',\'noeviction\'.')
  }

  if $maxmemory_samples != undef {
    if !is_integer($maxmemory_samples) {
      fail('maxmemory_samples must be an integer.')
    }
  }

  if !is_integer($lua_time_limit) {
    fail('lua_time_limit must be an integer.')
  }

  if !is_integer($slowlog_slower_than) {
    fail('slowlog_slower_than must be an integer.')
  }

  if !is_integer($slowlog_max_len) {
    fail('slowlog_max_len must be an integer.')
  }

  validate_re($user, '^(\w+)(-?)(\w+)?$',
    'user')

  validate_re($group, '^(\w+)(-?)(\w+)?$',
    'group')

  validate_re($dbfilename, '^(\S+).rdb$',
    'dbfilename only allows filenames with letters and numbers and .rdb extension.')

  validate_re($rdbchecksum, [ '^yes$', '^no$' ],
    'rdbchecksum must be \'yes\' or \'no\'.')

  validate_re($rdbcompression, [ '^yes$', '^no$' ],
    'rdbcompression must be \'yes\' or \'no\'.')

  validate_re($stop_writes_on_bgsave_error, [ '^yes$', '^no$' ],
    'stop_writes_on_bgsave_error must be \'yes\' or \'no\'.')

  if $repl_ping_slave_period != undef {
    if !is_integer($repl_ping_slave_period) {
      fail('repl_ping_slave_period must be an integer.')
    }
  }

  if $repl_timeout != undef {
    if !is_integer($repl_timeout) {
      fail('repl_timeout must be an integer.')
    }
  }

  validate_re($slave_read_only, [ '^yes$', '^no$' ],
    'slave_read_only should be \'yes\' or \'no\'.')

  if $slaveof != undef {
  validate_re($slaveof, [ '^([a-zA-Z0-9]+.)+([a-zA-Z0-9]+?.)(com|net|internal) \d+$' ],
    'slaveof syntax should be \'hostname.ltd port\'.')
  }

  if !is_integer($slave_priority) {
    fail('slave_priority must be an integer.')
  }

  validate_re($slave_serve_stale_data, [ '^yes$', '^no$' ],
    'slave_serve_stale_data must be \'yes\' or \'no\'.')

  if $min_slaves_max_lag != undef {
    if !is_integer($min_slaves_max_lag) {
      fail('min_slaves_max_lag must be an integer.')
    }
  }

  if $min_slaves_to_write != undef {
    if !is_integer($min_slaves_to_write) {
      fail('min_slaves_to_write must be an integer.')
    }
  }

  if $repl_backlog_ttl != undef {
    if !is_integer($repl_backlog_ttl) {
      fail('repl_backlog_ttl must be an integer.')
    }
  }

  if $repl_backlog_size != undef {
    validate_re($repl_backlog_size,'^\d+(bytes|mb|gb)$',
      'repl_backlog_size must be with the format \'43mb\'.')
  }

  validate_re($repl_disable_tcp_nodelay, [ '^yes$', '^no$' ],
    'repl_disable_tcp_nodelay must be \'yes\' or \'no\'.')

  validate_re($version, ['^\d+.\d+.\d+$'], 'Wrong version format.')

  if $manage_packages == true {
    $install_dir = '/etc/redis'
  } else {
    validate_absolute_path($custom_install_dir)

    $install_dir = $custom_install_dir
  }

  anchor { 'redis::begin': }
    class { '::redis::server': } ->
    class { '::redis::tools': } ->
  anchor {'redis::end':}

}
