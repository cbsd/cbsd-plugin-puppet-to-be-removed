require File.expand_path('../../../helpers/ipaddrext', __FILE__)
Puppet::Functions.create_function(:foreman_get_ips) do
    def foreman_get_ips(data_hash, ip_type=['public', 'private'], host_filter=['*'], fact_filters={})
        if ip_type.is_a?(String)
            if ip_type.include?(',')
                ip_type = ip_type.split(',')
            elsif ['all', '*'].include?(ip_type)
                ip_type = ['public', 'private']
            else
                ip_type = [ip_type]
            end
        end
        raise ArgumentError.new("Unknown ip_type '#{ip_type.to_s}'") unless ip_type.all? {|t| ['public', 'private'].include?(t)}
        host_filter = [host_filter].flatten.compact
        host_filter = ['*'] if host_filter == ''
        ips = []
        data_hash.each do |host, params|
            next unless host_filter.any? { |word| File.fnmatch(word, host) }
            next unless fact_filters.all? { |key, value| params[key] == value }
            next unless params.has_key?('ipv4_all')
            params['ipv4_all'].split(',').each do |value|
                begin
                    addr = IPAddrExt.new(value)
                    if addr.ipv4?
                        if ip_type.include?('public') and addr.public?
                            ips << value
                        end
                        if ip_type.include?('private') and addr.private?
                            ips << value
                        end
                    end
                rescue ArgumentError
                    next
                end
            end
        end

        if ips.length < 1
            raise Puppet::Error, "foreman_get_ips(host_filter=#{host_filter}, fact_filters=#{fact_filters}) ip_type=#{ip_type}) returned nothing. Looks useless or dangerous"
        end
        return ips.uniq.sort
    end
end
