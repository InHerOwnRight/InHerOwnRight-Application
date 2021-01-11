source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activejob', '>= 5.0.7.1'
gem 'aws-sdk-s3'
gem 'blacklight', '= 7.8'
gem 'blacklight-gallery', '~> 1.1'
gem 'blacklight-maps', github: 'boston-library/blacklight-maps', branch: 'update-to-blacklight-7'
gem 'blacklight-oembed', '~> 1.0'
gem 'blacklight_range_limit'
gem 'blacklight-spotlight', github: 'projectblacklight/spotlight'
gem 'bootstrap', '~> 4.0'
gem 'carrierwave-aws'
gem 'coffee-rails', '~> 4.2'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'devise'
gem 'devise_invitable'
gem 'friendly_id'
gem 'haml', '~> 5.0', '>= 5.0.1'
gem 'high_voltage', '~> 3.0'
gem 'httparty'
gem "iso639"
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'letter_opener'
gem 'listen', '~> 3.1.5'
gem 'mailcatcher'
gem 'mini_magick'
gem 'oai'
gem 'open3'
gem 'pg'
gem 'popper_js'
gem 'postmark-rails'
gem 'progress_bar'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.2.0'
gem 'railties'
gem 'redcarpet', '~> 3.5'
gem 'riiif'
gem 'rsolr', '>= 1.0'
gem 'sass-rails'
gem 'sentry-raven'
gem 'sitemap_generator'
gem 'sunspot_rails'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry'
  gem 'solr_wrapper', '>= 0.3'
  gem 'dotenv-rails'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
