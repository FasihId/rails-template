class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:sign_in, :sign_up]

  def index
    users = User.all
    render json: users, status: :ok
  end

  def sign_up
    user = User.new(email: user_params[:email], password: user_params[:password])
    if user.save
      jwt = Auth.issue({ user: user.id })
      render json: { jwt: jwt }
    else
      render json: { message: 'Your data invalid!' }
    end
  end

  def sign_in
    user = User.find_by(email: user_params[:email])
    return render json: { msg: 'user not found' } unless user

    if user.authenticate(user_params[:password])
      jwt = Auth.issue({ user: user.id })
      render json: { jwt: jwt }
    else
      render json: { msg: 'Invalid authentication!' }
    end
  end

  def profile
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
