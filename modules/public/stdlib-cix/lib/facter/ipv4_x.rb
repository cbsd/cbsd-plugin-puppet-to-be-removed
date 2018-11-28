require File.expand_path('../../helpers/ipaddrext', __FILE__)

# Linux
#ips = `/bin/hostname -I`.split(" ")

# FreeBSD
ips = `/sbin/ifconfig | /usr/bin/awk '/inet [0-9]+/{print $2}' |xargs`.split(" ")

meta = Facter.value('ec2_metadata')
unless meta.nil?
  if meta.key?('network')
    meta['network']['interfaces']['macs'].each_value do |mac|
      ips.concat(mac['local-ipv4s'].split("\n"))
      if mac['public-ipv4s']
        ips.concat(mac['public-ipv4s'].split("\n"))
        ips << meta['public-ipv4']
      end
    end
  end
  if meta.key?('public-ipv4')
    ips << meta['public-ipv4']
  end
  ips << meta['local-ipv4']
end

ips.uniq!
ips.sort!

ipsv4 = ips.select do |ip|
  begin
    IPAddrExt.new(ip).ipv4?
  rescue ArgumentError
  end
end

ipsv4.each_with_index do |ip, index|
  Facter.add("ipv4_" + index.to_s) do
    confine :kernel => :linux
    setcode do
      ip
    end
  end
end

Facter.add("ipv4_first_public") do
#  confine :kernel => :linux
  setcode do
    ipsv4.find {|ip| IPAddrExt.new(ip).public? }
  end
end

Facter.add("ipv4_all") do
#  confine :kernel => :linux
  setcode do
    ipsv4.join(',')
  end
end
