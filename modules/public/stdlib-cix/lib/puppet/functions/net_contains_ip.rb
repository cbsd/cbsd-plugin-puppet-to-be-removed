require 'ipaddr'
Puppet::Functions.create_function(:net_contains_ip) do
    def net_contains_ip(nets, ip)
    # Return most specific net containing ip or nil
        ip = IPAddr.new(ip)
        nets = nets.sort_by { |net| -get_prefix(net) }
        return nets.find { |net| IPAddr.new(net).include?(ip) }
    end

    def get_prefix(net)
        ip, prefix = net.split('/')
        return prefix.nil? ? 32 : prefix.to_i
    end
end