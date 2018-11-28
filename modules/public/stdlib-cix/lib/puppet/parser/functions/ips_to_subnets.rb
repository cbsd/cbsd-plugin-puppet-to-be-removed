require 'ipaddr'
def compact(ips, p=32)
    nets = []
    elems = 2**(32-p) # кол-во элементов в текущей подсети
    nelems = 2*elems # кол-во элементов в след подсети
    # если предполагаемый элемент
    return nets | compact(ips, p-1) if ips[nelems-1] and ips[0] == ips[nelems-1].mask(p-1)
    nets << ips[0].mask(p)
    nets = nets | compact(ips.slice(elems..-1), 32) if ips[elems]
    return nets
end
module Puppet::Parser::Functions
    newfunction(:ips_to_subnets, :type => :rvalue) do |args|
        raise Puppet::ParseError, "ips_to_subnets: 1st argument must be Array, not a #{args[0].class}" unless args[0].is_a? Array
        raise Puppet::ParseError, "ips_to_subnets: 2st argument must be Array, not a #{args[1].class}" unless args[1].is_a? Array
        ips    = args[0].uniq
        filters = args[1].uniq
        ips = ips - filters
        return [] if ips.empty?
        ips.map!{|ip| IPAddr.new(ip)}.sort!
        return compact(ips).map{|net| net.to_s + '/' + net.instance_variable_get("@mask_addr").to_s(2).count('1').to_s} #слегка опизденелый способ получить текущий префикс...
    end
end