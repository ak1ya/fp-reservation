class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      if @user.fp?
        redirect_to fp_available_slots_path, notice: "#{@user.name}さんとして登録・ログインしました"
      else
        redirect_to fps_path, notice: "#{@user.name}さんとして登録・ログインしました"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [:name, :email, :role])
  end
end
