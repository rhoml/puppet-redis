# private class
class redis::server::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file {
    '/etc/security/limits.d/redis.conf':
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/pam/security/limits.d/redis.conf'
  }

  sysctl {
    'vm.overcommit_memory':
      ensure    => 'present',
      permanent => 'yes',
      value     => '1';

    'fs.file-max':
      ensure    => 'present',
      permanent => 'yes',
      value     => '100000'
  }

  if $redis::manage_packages {
    package { 'redis-server':
      ensure => $redis::manage_packages_version,
    }
  }
  else {

    group {
      'redis':
        ensure => 'present',
        system => true,
    }

    user {
      'redis':
        ensure     => 'present',
        comment    => 'Redis system user',
        shell      => '/bin/false',
        gid        => 'redis',
        system     => true,
        require    => group['redis'],
    }

    file {
      $redis::install_dir:
        ensure  => 'directory',
        owner   => 'redis',
        group   => 'redis',
        require => [User['redis'],Group['redis']],
        before  => Exec['download-redis-package'],
    }

    file {
      "${redis::install_dir}/etc":
        ensure  => 'directory',
        owner   => 'redis',
        group   => 'redis',
        require => File["${redis::install_dir}"],
    }

      exec {
        'download-redis':
          command => "curl -O ${redis::pkg_url}/redis-${redis::version}.tar.gz 2> /dev/null",
          path    => ['/usr/bin', '/bin'],
          cwd     => '/usr/src',
          alias   => 'download-redis-package',
          creates => "/usr/src/redis-${redis::version}.tar.gz",
      }

      exec {
        "tar -zxvf redis-${redis::version}.tar.gz":
          path      => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
          cwd       => '/usr/src',
          creates   => "/usr/src/redis-${redis::version}",
          alias     => 'untar-redis-source',
          subscribe => Exec['download-redis']
      }

      exec {
        'make clean && touch .clean':
          path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
          cwd      => "/usr/src/redis-${redis::version}",
          creates  => "/usr/src/redis-${redis::version}/.clean",
          alias    => 'make-clean-redis',
          require  => Exec['untar-redis-source'],
          before   => Exec['make-install-redis'],
      }

      exec {
        "make && make PREFIX=${redis::install_dir} install && chown redis.redis -R ${redis::install_dir}":
          path     => [ '/bin/', '/sbin/' ,'/usr/bin/','/usr/sbin/' ],
          cwd      => "/usr/src/redis-${redis::version}",
          require  => [Package['tcl8.5'],Exec['untar-redis-source']],
          creates  => "${redis::install_dir}/bin/redis-server",
          alias    => 'make-install-redis',
      }
  }
}
