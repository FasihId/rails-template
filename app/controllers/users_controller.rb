class UsersController < ApplicationController
  # skip_before_action :authenticate, only: [:sign_in, :sign_up]
  before_action :authenticate, except: [:sign_in, :sign_up]

  def index
    users = User.all
    render json: users, status: :ok
  end

  def sign_up
    user = User.new(email: user_params[:email], password: user_params[:password])
    return render json: { message: 'Invalid data!' }, status: :unauthorized unless user.save

    token = Auth.issue({ user: user.id })
    render json: { token: token }, status: :ok
  end

  def sign_in
    user = User.find_by(email: user_params[:email])
    unless user && user.authenticate(user_params[:password])
      render json: { message: 'Invalid authentication!' }, status: :unauthorized
      return
    end

    token = Auth.issue({ user: user.id })
    render json: { token: token }, status: :ok
  end

  def profile
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
