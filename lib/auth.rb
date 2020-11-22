require 'jwt'

# based onhttps://www.thegreatcodeadventure.com/jwt-auth-in-rails-from-scratch/
class Auth
  ALGORITHM = 'HS256'

  def self.issue(payload)
    exp = {
      exp: (Time.now + expired_in.days).to_i
    }
    JWT.encode(
      payload.merge!(exp),
      auth_secret,
      ALGORITHM
    )
  end

  def self.decode(token)
    JWT.decode(
      token,
      auth_secret,
      true,
      { algorithm: ALGORITHM }
    ).first
  rescue JWT::ExpiredSignature
    false
  end

  def self.expired_in
    ENV['AUTH_EXP_DAY'].to_i
  end

  def self.auth_secret
    ENV['AUTH_SECRET']
  end
end
