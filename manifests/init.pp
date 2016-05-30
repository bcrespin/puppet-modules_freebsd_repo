#
class freebsd_repo (
  $disable_default_repo   = $freebsd_repo::params::disable_default_repo,
  $repo_url               = $freebsd_repo::params::repo_url,
  $repo_type              = $freebsd_repo::params::repo_type,
  $repo_sign_type         = $freebsd_repo::params::repo_sign_type,
  $repo_sign_path         = $freebsd_repo::params::repo_sign_path,
  $repo_sign_path_content = $freebsd_repo::params::repo_sign_path_content,
  $repo_template          = $freebsd_repo::params::repo_template,
  $repo_name              = $freebsd_repo::params::repo_name,
  $repo_enabled           = $freebsd_repo::params::repo_enabled,
) inherits freebsd_repo::params
{
  # setup the pkg repos as we want
  $repo_type_real = upcase($repo_type)
  $repo_sign_type_real = upcase($repo_sign_type)
  validate_re($repo_type_real,['NONE','SRV'])
  validate_re($repo_sign_type_real,['NONE','FINGERPRINTS','PUBKEY'])
  validate_bool($disable_default_repo)
  validate_bool($repo_enabled)

  $pkg_repo_path = '/usr/local/etc/pkg/repos'

  exec { "${pkg_repo_path}" :
    path    => ['/sbin/','/bin/','/usr/sbin','/usr/bin'],
    command => "mkdir -p ${pkg_repo_path}",
    unless  => "test -d ${pkg_repo_path}",
  }


  exec {'pkg_update' :
    path        => ['/usr/local/sbin','/sbin/','/usr/sbin','/usr/bin'],
    command     => 'pkg update',
  #  refreshonly => true,
  }

  if ($disable_default_repo)
  {
    file { "${pkg_repo_path}/FreeBSD.conf" :
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      content => "FreeBSD : { enabled: NO }\n",
      require => Exec [ "${pkg_repo_path}"],
      notify  => Exec ['pkg_update'],
    }
  }

  if ($repo_sign_type_real != 'NONE' )
  {
    if ($repo_sign_type_real == 'PUBKEY' and $repo_sign_path_content != '')
    {
      file { $repo_sign_path :
        ensure  => file,
        path    => $repo_sign_path,
        owner   => 'root',
        group   => 'wheel',
        mode    => '0644',
        content => $repo_sign_path_content,
        notify  => Exec ['pkg_update'],
      }
    }

    if ($repo_sign_type_real == 'FINGERPRINTS' and $repo_sign_path_content != '')
    {
      file { $repo_sign_path :
        ensure  => directory,
        path    => $repo_sign_path,
        owner   => 'root',
        group   => 'wheel',
        mode    => '0755',
        content => $repo_sign_path_content,
        purge   => false,
        notify  => Exec ['pkg_update'],
      }
    }

    file { "${pkg_repo_path}/${repo_name}.conf":
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      content => template($repo_template),
      require => Exec [ "${pkg_repo_path}"],
      notify  => Exec ['pkg_update'],
    }
  }
}

