source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'activerecord-jdbcsqlite3-adapter'

gem 'jruby-openssl'
gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'


# the javascript engine for execjs gem
platforms :jruby do
  group :assets do
    gem 'therubyrhino'
  end
end

# custom gems required for the US-World-Coverage app
gem 'nokogiri', "~> 1.5.0"
gem "nytimes-articles", "~> 0.4.1"

