require 'yaml'
Puppet::Functions.create_function(:toyaml) do
    def toyaml(data)
        data.to_yaml line_width:120
    end
end