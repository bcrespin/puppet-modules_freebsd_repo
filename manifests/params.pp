#
class freebsd_repo::params {
  $disable_default_repo   = true,
  $repo_url               = "pkg+http://pkg.home/\${ABI}/latest",
  $repo_type              = 'NONE',
  $repo_sign_type         = 'FINGERPRINTS',
  $repo_sign_path         = '/usr/local/share/key/pkg',
  $repo_sign_path_content = '',
  $repo_template          = 'freebsd_repo/freebsd_repo.conf.erb',
  $repo_name              = 'myrepo',
  $repo_enabled           = true,
}
