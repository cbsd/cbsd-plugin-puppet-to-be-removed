module Puppet::Parser::Functions
    newfunction(:prefix_array, :type => :rvalue) do |args|
        raise Puppet::ParseError, "First arg mast be string, not a #{args[0].class}" unless args[0].is_a? String
        raise Puppet::ParseError, "Second arg mast be array of strings, not a #{args[1].class}" unless args[1].is_a? Array
        prefix = args[0]
        arr    = args[1]
        return arr.map {|item| "#{prefix}#{item}"}
    end
end