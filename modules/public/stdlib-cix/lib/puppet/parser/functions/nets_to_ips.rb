require 'ipaddr'
module Puppet::Parser::Functions
    newfunction(:nets_to_ips, :type => :rvalue) do |args|
        nets = [args[0]].flatten.compact.uniq
        ips = nets.map { |net| IPAddr.new(net).to_range.to_a.map {|ip| ip.to_s } }
        return ips.flatten.compact.uniq
    end
end