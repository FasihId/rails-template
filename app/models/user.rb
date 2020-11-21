class User < ApplicationRecord
  # https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  has_secure_password
  has_secure_password :recovery_password, validations: false

  # validations
  validates :email, uniqueness: true
end
