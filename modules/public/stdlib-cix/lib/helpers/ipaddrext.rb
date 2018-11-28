require 'ipaddr'

class IPAddrExt < IPAddr
    RangesPrivate =
    [
        IPAddr.new("10.0.0.0/8"),
        IPAddr.new("172.16.0.0/12"),
        IPAddr.new("192.168.0.0/16"),
    ]
    RangesLoopback = [
        IPAddr.new("127.0.0.1/8"),
    ]
    RangesAutodiscovery = [
        IPAddr.new("169.254.0.0/16"),
    ]
    def private?
        RangesPrivate.each do |network|
            return true if network.include?(self)
        end
        return false
    end

    def loopback?
        RangesLoopback.each do |network|
            return true if network.include?(self)
        end
        return false
    end
    def autodiscovery?
        RangesAutodiscovery.each do |network|
            return true if network.include?(self)
        end
        return false
    end
    def public?
        return false if self.private?
        return false if self.loopback?
        return false if self.autodiscovery?
        return true
    end
end
