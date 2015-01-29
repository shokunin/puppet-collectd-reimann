class unix_base::common inherits unix_base {

  if $::osfamily == 'Debian' {

    file { '/var/tmp/update':
      ensure => present,
      notify => Exec['apt-get-update-tmp'],
    }

    exec { 'apt-get-update-tmp':
      refreshonly => true,
      command     => '/usr/bin/apt-get update && /usr/bin/apt-get -y upgrade',
    }

  }

#################################################
# Set any packages by OS
  if $::operatingsystem == "CentOS" {
    $vim_pkg = 'vim-enhanced'
    $git_pkg = 'git'
    $extra_packages = []
  }

  if $::operatingsystem == "Ubuntu" {
    $vim_pkg = 'vim'
    $git_pkg = 'git-core'
    $extra_packages = ['build-essential', 'libssl-dev', 'pkg-config']
  }
#################################################

  # diagnostic packages

  package { 'lsof' :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

  package { 'sysstat' :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

  package { 'iotop' :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

  package { 'tree' :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

# Nice to haves

  package { $vim_pkg :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

  package { $git_pkg :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

  package { $extra_packages :
    ensure  => installed,
    require => Exec['apt-get-update-tmp'],
  }

}
