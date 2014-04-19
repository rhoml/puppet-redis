# private class
class redis::server::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $redis::manage_service == true {
    service { "redis-server-${redis::port}":
      ensure     => 'running',
      hasrestart => true,
      hasstatus  => true,
      enable     => $redis::manage_service,
    }
  }
}
