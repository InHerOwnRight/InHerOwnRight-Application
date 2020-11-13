Delayed::Worker.logger =  Logger.new(STDOUT)
Delayed::Worker.max_run_time = 48.hours
require 'delayed_rake.rb'
