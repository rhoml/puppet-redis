# = Class to manage dependencies
class redis::dependencies {
  case $::operatingsystem {
    Ubuntu,Debian: { require redis::dependencies::ubuntu }
    default:       { notify('We do not support this OS') }
  }
}
