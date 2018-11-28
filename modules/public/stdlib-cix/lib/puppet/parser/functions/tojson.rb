require 'json'
module Puppet::Parser::Functions
    newfunction(:tojson, :type => :rvalue) do |args|
        JSON.pretty_generate(args[0])
    end
end