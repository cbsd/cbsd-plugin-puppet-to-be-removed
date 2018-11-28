module Puppet::Parser::Functions
  newfunction(:foreman_get_hostnames, :type => :rvalue) do |args|
    raise Puppet::ParseError, "Foreman: Must supply a Hash with foreman data, not a #{args[0].class}" unless args[0].is_a? Hash
    raise Puppet::ParseError, "Foreman: Must supply an Array, not a #{args[1].class}" unless args[1].is_a? Array
    data_hash = args[0]
    host_filter = [args[1]].flatten.compact
    hostnames = []
    data_hash.keys.each do |host|
        if host_filter.empty? or host_filter.any? { |word| File.fnmatch(word, host) }
            hostnames << host
        end
    end
    return hostnames
  end
end
