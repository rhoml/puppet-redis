# = private class
# = Class to manage ubuntu and debian packages
class redis::dependencies::ubuntu {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ! defined(Package['build-essential']) {
    package {
      'build-essential':
        ensure   => 'installed',
        provider => 'aptitude',
    }
  }

  if ! defined(Package['tcl8.5']) {
    package {
      'tcl8.5':
        ensure   => 'installed',
        provider => 'aptitude',
    }
  }
  if ! defined(Package['libredis-perl']) {
    package {
      'libredis-perl':
        ensure   => 'installed',
        provider => 'aptitude',
    }
  }

  if ! defined(Packege['python-magic']) {
    package {
      'python-magic':
        ensure   => 'installed',
        provider => 'aptitude',
    }
  }
}
