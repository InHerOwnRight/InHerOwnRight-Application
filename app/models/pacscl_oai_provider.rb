require 'oai'
# not sure why this isn't being autoloaded in production.
# possibly because of how it is capitalized vs underscored and the addition of "model" to the path
require 'oai/provider/model/activerecord_wrapper'
class PacsclOaiProvider < OAI::Provider::Base
  repository_name 'PacsclOaiProvider'
  repository_url 'http://pacscl.neomind.com/oai'
  record_prefix 'oai:pacscl'
  admin_email 'admin@neomindlabs.com'
  source_model OAI::Provider::ActiveRecordWrapper.new(Record)
end