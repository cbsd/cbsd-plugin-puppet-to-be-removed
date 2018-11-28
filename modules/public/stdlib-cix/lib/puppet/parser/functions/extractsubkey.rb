module Puppet::Parser::Functions
    newfunction(:extractsubkey, :type => :rvalue) do |args|
        hash   = args[0]
        subkey = args[1]
        result = {}
        hash.each_key do |key|
            result[key] = hash[key][subkey]
        end
        return result
    end
end