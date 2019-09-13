require 'oai'

module OAI
  class Client
    # This was copied from /usr/local/rvm/gems/ruby-2.3.8/gems/oai-0.4.0/lib/oai/client.rb in order to customize the faraday connection timeout.
    def initialize(base_url, options={})
       @base = URI.parse base_url
       @debug = options.fetch(:debug, false)
       @parser = options.fetch(:parser, 'rexml')
       @headers = options.fetch(:headers, {})

       @http_client = options.fetch(:http) do
         Faraday.new(:url => @base.clone) do |builder|
           follow_redirects = options.fetch(:redirects, true)
           if follow_redirects
             count = follow_redirects.is_a?(Fixnum) ? follow_redirects : 5

             require 'faraday_middleware'
             builder.response :follow_redirects, :limit => count
           end
           builder.adapter :net_http
           builder.options.timeout = 120 #https://github.com/lostisland/faraday/issues/812#issuecomment-414258614
           builder.options.open_timeout = 120 #https://github.com/lostisland/faraday/issues/812#issuecomment-414258614
         end
       end

       # load appropriate parser
       case @parser
       when 'libxml'
         begin
           require 'rubygems'
           require 'xml/libxml'
         rescue
           raise OAI::Exception.new("xml/libxml not available")
         end
       when 'rexml'
         require 'rexml/document'
         require 'rexml/xpath'
       else
         raise OAI::Exception.new("unknown parser: #{@parser}")
       end
     end
   end
end
