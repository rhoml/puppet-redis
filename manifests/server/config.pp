# private class
# Configures redis server
class redis::server::config(
    $saves = $redis::saves,
  ) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  datacat { 'redis::server':
    owner    => downcase("$redis::user"),
    group    => downcase("$redis::group"),
    mode     => '0400',
    path     => "$redis::install_dir/etc/$redis::config_file",
    template => 'redis/settings.cfg.erb',
  }

  # Includes section
  redis::server::setting {
    'includes':
      value => $redis::includes;
  }

  # General section
  redis::server::setting {
    'daemonize':
      value => $redis::daemonize;

    'pidfile':
      value => "${redis::pidfiledir}/${redis::pidfilename}";

    'port':
      value => $redis::port;

    'tcp-backlog':
      value => $redis::tcp_backlog;

    'bind':
      value => $redis::bind;

    'unixsocket':
      value => $redis::unixsocket;

    'unixsocketperm':
      value => $redis::unixsocketperm;

    'timeout':
      value => $redis::timeout;

    'tcp-keepalive':
      value => $redis::tcp_keepalive;

    'loglevel':
      value => $redis::log_Level;

    'logfile':
      value => $redis::logfile;

    'syslog-enabled':
      value => $redis::syslog_enabled;

    'syslog-ident':
      value => $redis::syslog_ident;

    'syslog-facility':
      value => $redis::sysglog_facility;

    'databases':
      value => $redis::databases;
  }

  # Snapshotting section
  $redis::saves.slice(2) |$x| {
    redis::server::setting {
      "save ${$x[0]}":
        value   => "${$x[1]}",
    }
  }

  redis::server::setting {
    'stop-writes-on-bgsave-error':
      value => $redis::stop_writes_on_bgsave_error;

    'rdbcompression':
      value => $redis::rdbcompression;

    'rdbchecksum':
      value => $redis::rdbchecksum;

    'dbfilename':
      value => $redis::dbfilename;

    'dir':
      value => $redis::snapshot_dir;
  }

  # Replication section
  redis::server::setting {
    'slaveof':
      value => $redis::slaveof;

    'masterauth':
      value => $redis::masterauth;

    'slave-serve-stale-data':
      value => $redis::slave_serve_stale_data;

    'slave-read-only':
      value => $redis::slave_read_only;

    'repl-ping-slave-period':
      value => $redis::repl_ping_slave_period;

    'repl-timeout':
      value => $redis::repl_timeout;

    'repl-disable-tcp-nodelay':
      value => $redis::repl_disable_tcp_nodelay;

    'repl-backlog-size':
      value => $redis::repl_backlog_size;

    'repl-backlog-ttl':
      value => $redis::repl_backlog_ttl;

    'slave-priority':
      value => $redis::slave_priority;

    'min-slaves-to-write':
      value => $redis::min_slaves_to_write;

    'min-slaves-max-lag':
      value => $redis::min_slaves_max_lag;
  }
  # Security section
  $redis::rename_commands.slice(2) |$z| {
    redis::server::setting {
      "rename-command ${$z[0]}":
        value   => "${$z[1]}",
    }
  }

  redis::server::setting {
    'requirepass':
      value => $redis::requirepass,
  }

  # Limits section
  redis::server::setting {
    'maxclients':
      value => $redis::maxclients;

    'maxmemory':
      value => $redis::maxmemory;

    'maxmemory-policy':
      value => $redis::maxmemory_policy;

    'maxmemory-samples':
      value => $redis::maxmemory_samples;
  }

  # Append only mode section
  redis::server::setting {
    'appendonly':
      value => $redis::appendonly;

    'appendfilename':
      value => $redis::appendfilename;

    'appendfsync':
      value => $redis::appendfsync;

    'no-appendfsync-on-rewrite':
      value => $redis::no_appendfsync_on_rewrite;

    'auto-aof-rewrite-percentage':
      value => $redis::auto_aof_rewrite_percentage;

    'auto-aof-rewrite-min-size':
      value => $redis::auto_aof_rewrite_min_size;
  }

  # Lua scripting section
  redis::server::setting {
    'lua-time-limit':
      value => $redis::lua_time_limit,
  }

  # Slow log section
  redis::server::setting {
    'slowlog-log-slower-than':
      value => $redis::slowlog_slower_than;

    'slowlog-max-len':
      value => $redis::slowlog_max_len;
  }

  # Event notification section
  redis::server::setting {
    'notify-keyspace-events':
      value => $redis::notify_keyspace_events,
  }

  # Advanced config section
  redis::server::setting {
    'hash-max-ziplist-entries':
      value => $redis::hash_max_ziplist_entries;

    'hash-max-ziplist-value':
      value => $redis::hash_max_ziplist_value;

    'list-max-ziplist-entries':
      value => $redis::list_max_ziplist_entries;

    'list-max-ziplist-value':
      value => $redis::list_max_ziplist_value;

    'set-max-intset-entries':
      value => $redis::set_max_intset_entries;

    'zset-max-ziplist-entries':
      value => $redis::zset_max_ziplist_entries;

    'zset-max-ziplist-value':
      value => $redis::zset_max_ziplist_value;

    'activerehashing':
      value => $redis::activerehashing;

    'hz':
      value => $redis::hz;

    'aof-rewrite-incremental-fsync':
      value => $redis::aof_rewrite_incremental_fsync;
  }

  $redis::client_output_buffer_limits.slice(2) |$y| {
    redis::server::setting {
      "client-output-buffer-limit ${$y[0]}":
        value => "${$y[1]}",
    }
  }

  file {
    "${redis::install_dir}/logs":
      ensure => 'directory',
      owner  => downcase("$redis::user"),
      group  => downcase("$redis::group"),
      mode   => '0700',
  }

  file {
    "/etc/init.d/redis-server-${redis::port}":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('redis/init/redis.erb'),
  }

  file {
    $redis::snapshot_dir:
      ensure => 'directory',
      mode   => '0755',
      owner  => downcase("$redis::user"),
      group  => downcase("$redis::user")
  }

  anchor { 'redis::server::config::begin': }
  anchor { 'redis::server::config::end': }
}
