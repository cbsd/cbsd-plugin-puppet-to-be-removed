module Puppet::Parser::Functions
    newfunction(:merge_arrays, :type => :rvalue) do |args|
        result = []
        args.each do |arg|
            result = result | arg
        end
        begin
            return result.sort!
        rescue
            return result
        end
    end
end