require 'resolv'
module Puppet::Parser::Functions
    newfunction(:resolv_array, :type => :rvalue) do |args|
        names = args.flatten.compact
        ips = []
        names.each do |name|
            begin
                resolved = Resolv.getaddresses(name)
            rescue Exception => e
                raise Puppet::ParseError, "Failed to resolve '#{name}': #{e}"
            end
            raise Puppet::ParseError, "Failed to resolve '#{name}'" if resolved.empty?
            ips = ips | resolved
        end
        return ips.sort.uniq
    end
end
