Facter.add('container_type') do
  confine :virtual => 'lxc'
  confine :kernel => :linux
  type = `/bin/cat /proc/1/environ | /bin/awk -F\= '{ print $2}' | tr -d '\n'`
  setcode do
    type
  end
end
