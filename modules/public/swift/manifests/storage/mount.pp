#
# Usage
#   swift::storage::mount
#
#
# === Parameters:
#
# [*device*]
#   (mandatory) An array of devices (prefixed or not by /dev)
#
# [*mnt_base_dir*]
#   (optional) The directory where the flat files that store the file system
#   to be loop back mounted are actually mounted at.
#   Defaults to '/srv/node', base directory where disks are mounted to
#
# [*loopback*]
#   (optional) Define if the device must be mounted as a loopback or not
#   Defaults to false.
#
# [*fstype*]
#   (optional) The filesystem type.
#   Defaults to 'xfs'.
#
define swift::storage::mount(
  $device,
  $mnt_base_dir = '/srv/node',
  $loopback     = false,
  $fstype       = 'xfs'
) {

  include ::swift::deps

  if($loopback){
    $options = 'noatime,nodiratime,nobarrier,loop'
  } else {
    $options = 'noatime,nodiratime,nobarrier'
  }

  if($fstype == 'xfs'){
    $fsoptions = 'logbufs=8'
  } else {
    $fsoptions = 'user_xattr'
  }

  # the directory that represents the mount point
  # needs to exist
  file { "${mnt_base_dir}/${name}":
    ensure  => directory,
    owner   => 'swift',
    group   => 'swift',
    require => Anchor['swift::config::begin'],
    before  => Anchor['swift::config::end'],
  }

  mount { "${mnt_base_dir}/${name}":
    ensure  => present,
    device  => $device,
    fstype  => $fstype,
    options => "${options},${fsoptions}",
    require => File["${mnt_base_dir}/${name}"],
  }

  # double checks to make sure that things are mounted
  exec { "mount_${name}":
    command   => "mount ${mnt_base_dir}/${name}",
    path      => ['/bin'],
    require   => Mount["${mnt_base_dir}/${name}"],
    unless    => "grep ${mnt_base_dir}/${name} /etc/mtab",
    # TODO - this needs to be removed when I am done testing
    logoutput => true,
    before    => Anchor['swift::config::end'],
  }

  exec { "fix_mount_permissions_${name}":
    command     => "chown -R swift:swift ${mnt_base_dir}/${name}",
    path        => ['/usr/sbin', '/bin'],
    subscribe   => Exec["mount_${name}"],
    refreshonly => true,
    before      => Anchor['swift::config::end'],
  }

  # mounting in linux and puppet is broken and non-atomic
  # we have to mount, check mount with executing command,
  # fix ownership and on selinux systems fix context.
  # It would be definitely nice if passing options uid=,gid=
  # would be possible as context is. But, as there already is
  # chown command we'll just restorecon on selinux enabled
  # systems :(
  if (str2bool($::selinux) == true) {
    exec { "restorecon_mount_${name}":
      command     => "restorecon ${mnt_base_dir}/${name}",
      path        => ['/usr/sbin', '/sbin'],
      subscribe   => Exec["mount_${name}"],
      before      =>  [Exec["fix_mount_permissions_${name}"],Anchor['swift::config::end']],
      refreshonly => true,
    }
  }
}
