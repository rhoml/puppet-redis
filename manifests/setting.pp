# private define - redis::setting
define redis::setting($setting, $value, $target, $order = '50') {
  datacat_fragment {
    "redis::setting ${title}":
      target => $target,
      order  => $order,
      data   => hash([ $setting, $value ]),
  }
}
