source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails',        '5.1.6'

gem 'bcrypt',         '3.1.12'

gem 'faker',          '1.7.3'

gem 'carrierwave',             '1.2.2'
# 投稿した画像を扱ったり、その画像をMicropostモデルと関連付けするために、CarrierWaveという画像アップローダーを使用
# CarrierWaveを導入すると、Railsのジェネレーターで画像アップローダーが生成できるようになる
# $ rails generate uploader Picture で生成

gem 'mini_magick',             '4.7.0'
# 画像をリサイズしたり、本番環境で画像をアップロードするために使用。

gem 'will_paginate',           '3.1.6'
# ページネーション (pagination) というもので、この場合は、例えば1つのページに一度に30人だけユーザーを表示する設定をする。
gem 'bootstrap-will_paginate', '1.0.0'
# 最もシンプルかつ堅牢なwill_paginateメソッドを使うため、Gemfileにwill_paginate gem とbootstrap-will_paginate gemを両方含め、Bootstrapのページネーションスタイルを使ってwill_paginateを構成

gem 'bootstrap-sass', '3.3.7'
# Use mysql as the database for Active Record
gem 'puma',         '4.3.8'
# Use SCSS for stylesheets
gem 'sass-rails',   '5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier',     '3.2.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'jquery-rails', '4.3.1'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '4.2.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks',   '5.0.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder',     '2.7.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'mysql2', '>= 0.3.18', '< 0.6.0'
  # Use Puma as the app server
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug',  '9.0.6', platform: :mri
  # Adds support for Capybara system testing and selenium driver
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest',                 '5.10.3'
  gem 'minitest-reporters',       '1.1.14'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
end

# group :production do
#   gem 'pg',  '0.20.0'
#   gem 'fog', '1.42'
# end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
