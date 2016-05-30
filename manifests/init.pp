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
)
{
  # setup the pkg repos as we want
  $repo_type_real = upcase($freebsd_repo::repo_type)
  $repo_sign_real = upcase($freebsd_repo::repo_sign)
  validate_re($repo_type_real,['NONE','SRV'])
  validate_re($repo_sign_real,['NONE','FINGERPRINTS','PUBKEY'])
  validate_bool($disable_default_repo)
  validate_bool($repo_enabled)

  if ($disable_default_repo)
  {
    file { '/usr/local/etc/pkg/repo/FreeBSD.conf' :
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      content => 'FreeBSD : { enabled: NO }'
    }
  }

  if ($freebsd_repo::repo_sign_type_real != 'NONE' )
  {
    if ($freebsd_repo::repo_sign_type_real == 'PUBKEY' and $repo_sign_path_content != '')
    {
      file { $repo_sign_path :
        ensure  => file,
        path    => $repo_sign_path,
        owner   => 'root',
        group   => 'wheel',
        mode    => '0644',
        content => $repo_sign_path_content,
      }
    }

    if ($freebsd_repo::repo_sign_type_real == 'FINGERPRINTS' and $repo_sign_path_content != '')
    {
      file { $repo_sign_path :
        ensure  => directory,
        path    => $repo_sign_path,
        owner   => 'root',
        group   => 'wheel',
        mode    => '0755',
        content => $repo_sign_path_content,
        purge   => false
      }
    }

    file { $repo_name :
      ensure  => file,
      path    => "/usr/local/etc/pkg/repos/${repo_name}.conf",
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      content => template($repo_template),
    }
  }
}
