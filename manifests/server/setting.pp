# Define - redis::server::setting
define redis::server::setting($setting = $name, $value, $order = '30') {
  redis::setting { "redis::server::setting ${title}":
    setting => $setting,
    value   => $value,
    target  => [ 'redis::server' ],
    order   => $order,
  }
}
