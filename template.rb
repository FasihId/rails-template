############ MAINTAINER ############
### ervinismu | ervinismu.com
###

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

# Setup model for Auth
generate(:model, 'user username:string email:string password_digest:string recovery_password_digest:string')
insert_into_file 'app/models/user.rb', after: "class User < ApplicationRecord\n" do <<-EOF
  # https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  has_secure_password
  has_secure_password :recovery_password, validations: false

  # validations
  validates :email, uniqueness: true
EOF
end

# setup gem
gem 'figaro' # environemnts
gem 'jwt' # authentication
gem 'bcrypt', '~> 3.1.7' # # Use Active Model has_secure_password

# add config file
file 'config/application.yml', <<-CODE
AUTH_SECRET: 'yoursecrethere'
CODE

# remove and copy controllers
run 'rm -rf app/controllers'
directory 'app/controllers', 'app/controllers'

# copy lib
directory 'lib', 'lib'

# configure routing
insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-EOF
  scope :api do
    scope :core do
      scope :users do
        post '/sign-in', to: 'users#sign_in'
        post '/sign-up', to: 'users#sign_up'
        get '/all', to: 'users#index'
        get '/me', to: 'users#profile'
      end
    end
  end
EOF
end

# load lib
insert_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do <<-EOF
  # load libs
  config.autoload_paths << Rails.root.join('lib')
EOF
end

# stimulus js
if yes?('Would you like to setup StimulusJs? (y/n)')
  run 'yarn add stimulus'
  directory 'app/javascript/controllers', 'app/javascript/controllers'
  inject_into_file 'app/javascript/packs/application.js' do <<-'EOF'
  import 'controllers'
  EOF
  end
end

# tailwind css
if yes?('Would you like to setup TailwinsCSS? (y/n)')
  run 'yarn add tailwindcss@npm:@tailwindcss/postcss7-compat postcss@7 autoprefixer@9'
  directory 'app/javascript/stylesheets', 'app/javascript/stylesheets'
  inject_into_file 'app/javascript/packs/application.js' do <<-'EOF'
  import '../stylesheets/application.scss'
  EOF
  end

  # NOTE :
  # still error in this section, current solutions is set manually on postcss.config.js

  # inject_into_file 'postcss.config.js', after: "plugins: [\n"do <<-'EOF'
  # require('tailwindcss'),
  # require('autoprefixer'),
  # EOF
  # end
end
