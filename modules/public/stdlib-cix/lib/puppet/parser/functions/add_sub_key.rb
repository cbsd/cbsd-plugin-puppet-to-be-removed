# Accept hash end subkey
# Convert hash { somkey => []}  to { somkey => {subkey => []}}

module Puppet::Parser::Functions
    newfunction(:add_sub_key, :type => :rvalue) do |args|
        hash   = args[0]
        subkey = args[1]
        result = {}
        hash.each do |key, value|
            result[key] = {}
            result[key][subkey] = hash[key]
        end
        return result
    end
end