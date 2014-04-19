Puppet-redis
==========

Overview
--------

This puppet module allows you to easily install and configure your redis instances.

Usage
-----

````
  class {
    'redis':
      daemonize                   => 'yes',
      pidfiledir                  => '/var/run/redis',
      pidfilename                 => 'redis-server.pid',
      port                        => 6379,
      timeout                     => 0,
      log_level                   => 'notice',
      logfile                     => '/opt/redis/logs/redis-server.log',
      databases                   => 16,
      saves                       => ['900', '1',
                                      '300','10',
                                      '60','10000'],
      stop_writes_on_bgsave_error => 'no',
      rdbcompression              => 'yes',
      rdbchecksum                 => 'yes',
      dbfilename                  => 'system_production.rdb',
      snapshot_dir                => '/opt/redis/data',
      slave_serve_stale_data      => 'yes',
      slave_read_only             => 'no',
      slave_priority              => 100,
      appendonly                  => 'no',
      appendfsync                 => 'everysec',
      no_appendfsync_on_rewrite   => 'no',
      auto_aof_rewrite_percentage => 100,
      auto_aof_rewrite_min_size   => '64mb',
      lua_time_limit              => 1000,
      slowlog_slower_than         => 10000,
      slowlog_max_len             => 128,
      hash_max_ziplist_entries    => 512,
      hash_max_ziplist_value      => 64,
      list_max_ziplist_entries    => 512,
      list_max_ziplist_value      => 64,
      set_max_intset_entries      => 512,
      zset_max_ziplist_entries    => 128,
      zset_max_ziplist_value      => 64,
      activerehashing             => 'yes',
      rename_commands             => ['keys',
                                      'forcekeys'],
      client_output_buffer_limits => ['normal','0 0 0',
                                      'slave','5294967296 3147483648 30',
                                      'pubsub',' 0 0 0'],
      manage_service              => true,
      shard_ident                 => '01'
  }
````

Contributors
------------

 * [Rhommel Lamas](https://www.twitter.com/rhoml)
