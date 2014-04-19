# Private class
# This class installs/configures redis server
class redis::server {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'redis::server::begin': } ->
  class { '::redis::server::install': } ->
  class { '::redis::server::config': } ~>
  class { '::redis::server::service': } ->
  anchor { 'redis::server::end': }
}
