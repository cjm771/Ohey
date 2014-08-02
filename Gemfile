ruby '2.1.2'

source 'https://rubygems.org'


gem 'rails', '4.1.4'
gem 'bcrypt-ruby', '~> 3.1.2'

group :development, :test do
	gem 'sqlite3'
end
group :production do
	gem 'pg'
	gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
	gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
	gem 'rails_12factor'
end


gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

group :development, :test do
	gem 'rspec-rails', '~> 3.0.0'
	gem "factory_girl_rails", "~> 4.0" 
end

group :test do 
	gem 'capybara', '~> 2.4.0'
	gem 'capybara-email', '~> 2.4.0'
	gem 'shoulda-matchers', '~> 2.6.2'
end
