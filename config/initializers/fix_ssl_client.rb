require 'open-uri'
require 'net/https'

# You'll have to periodically update this file like this:
# #   curl -o lib/ca-bundle.crt https://curl.haxx.se/ca/ca-bundle.crt
# module Net
#   class HTTP
#     alias_method :original_use_ssl=, :use_ssl=
# 
#     def use_ssl=(flag)
#       self.ca_file = Rails.root.join('lib/ca-bundle.crt').to_s
#       # self.verify_mode = OpenSSL::SSL::VERIFY_PEER
#       self.verify_mode = OpenSSL::SSL::VERIFY_NONE
#       self.original_use_ssl = flag
#     end
#   end
# end

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE