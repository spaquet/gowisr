# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def profile
    @user = current_user
  end

  def settings
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :profile, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
