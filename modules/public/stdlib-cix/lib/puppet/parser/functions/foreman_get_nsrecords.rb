require 'ipaddr'
module Puppet::Parser::Functions
    newfunction(:foreman_get_nsrecords, :type => :rvalue) do |args|
        raise Puppet::ParseError, "Foreman: Must supply a Hash to foreman(), not a #{args[0].class}" unless args[0].is_a? Hash
        data_hash   = args[0]
        networks    = args[1]
        host_filter = [args[2]].flatten.compact
        netobjs     = []
        networks.each do |network|
            netobjs << IPAddr.new(network)
        end
        nsrecords = []
        data_hash.each do |host, params|
            if host_filter.empty? or host_filter.any? { |word| File.fnmatch(word, host) }
                if params.has_key?('ipv4_all')
                    params['ipv4_all'].split(',').each do |ip_str|
                        ip = IPAddr.new(ip_str)
                        if netobjs.any? { |net| net.include?(ip) }
                            nsrecords << {'ip' => ip_str, 'name' => params['hostname']}
                        end
                    end
                end
            end
        end
        return nsrecords.sort_by { |k| k['name'] }
    end
end
