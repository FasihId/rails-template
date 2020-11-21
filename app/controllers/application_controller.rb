class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def logged_in?
    !!current_user
  end

  def current_user
    return false unless auth_present?

    user = User.find_by(id: auth['user'])
    @current_user ||= user if user
    @current_user ||= false
  end

  def authenticate
    render json: { error: 'unauthorized' }, status: 401 unless logged_in?
  end

  private

  def token
    request.env['HTTP_AUTHORIZATION'].scan(/Bearer (.*)$/).flatten.last
  end

  def auth
    Auth.decode(token)
  end

  def auth_present?
    !!request.env.fetch('HTTP_AUTHORIZATION', '').scan(/Bearer/).flatten.first
  end
end
