# csf::install
class csf::install inherits csf {
  # this installs csf and reloads it
  if $::operatingsystem == 'CentOS' and versioncmp($::operatingsystemmajrelease, '7') < 0 {
    package { 'iptables-ipv6':
      ensure => installed,
      before => Exec['csf-install'],
    }
  }

  if ! defined(Package['iptables']) {
    package { 'iptables':
      ensure => installed,
      before => Exec['csf-install'],
    }
  }

  if ! defined(Package['perl']) {
    package { 'perl':
      ensure => installed,
      name   => 'perl',
    }
  }

  exec { 'csf-install':
    cwd     => '/tmp',
    command => "/usr/bin/curl -o csf.tgz ${::csf::download_location} && tar -xzf csf.tgz && cd csf && sh install.sh",
    creates => '/usr/sbin/csf',
    notify  => Service['csf'],
    require => Package['perl'],
  }

  # make sure testing is disabled, we trust puppet enough
  csf::config { 'TESTING': value => '0' }

  # make sure puppet masters are always accessible
  csf::ipv4::output { '8140': require => Exec['csf-install'], }
}
