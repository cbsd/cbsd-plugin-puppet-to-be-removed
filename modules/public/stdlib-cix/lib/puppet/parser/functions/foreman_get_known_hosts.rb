require 'ipaddr'
module Puppet::Parser::Functions
    newfunction(:foreman_get_known_hosts, :type => :rvalue) do |args|
        raise Puppet::ParseError, "Foreman: Must supply a Hash to foreman(), not a #{args[0].class}" unless args[0].is_a? Hash
        data_hash  = args[0]
        host_filter = [args[1]].flatten.compact
        sshkeys = {}
        data_hash.each do |host, params|
            if host_filter.empty? or host_filter.any? { |word| File.fnmatch(word, host) }
                if params.has_key?('sshrsakey')
                    sshkeys[host] = {
                        'key'  => params['sshrsakey'],
                        'type' => 'ssh-rsa',
                        'host_aliases' => params['ipv4_all'].split(','),
                    }
                end
            end
        end
        return sshkeys
    end
end