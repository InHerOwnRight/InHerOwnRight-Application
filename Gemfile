source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.0'
gem "activejob", ">= 5.0.7.1"
gem "iso639"
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'aws-sdk-s3'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'blacklight_range_limit'
gem 'bootstrap', '~> 4.0'
gem 'progress_bar'
gem 'sunspot_rails'
gem 'devise'
gem 'oai'
gem 'haml', '~> 5.0', '>= 5.0.1'
gem 'high_voltage', '~> 3.0'
gem 'redcarpet', '~> 3.4'
gem 'dotenv-rails'
gem "mini_magick"
gem "friendly_id"
gem 'blacklight-maps', github: 'boston-library/blacklight-maps', branch: 'update-to-blacklight-7'
gem 'httparty'

gem 'sentry-raven'

# gem 'carpetbomb'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'open3'
gem 'railties'
gem 'letter_opener'
gem 'riiif'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'solr_wrapper', '>= 0.3'
  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'blacklight', ' ~> 7.0'
gem 'blacklight-spotlight', github: 'projectblacklight/spotlight'
group :development, :test do
end

gem 'rsolr', '>= 1.0'
gem 'popper_js'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'devise-guests', '~> 0.6'
gem 'friendly_id'
gem 'sitemap_generator'
gem 'blacklight-gallery', '~> 1.1'
gem 'blacklight-oembed', '~> 1.0'
gem 'devise_invitable'
gem 'listen', '~> 3.1.5'
gem 'carrierwave-aws'
gem 'postmark-rails'
gem 'mailcatcher'
