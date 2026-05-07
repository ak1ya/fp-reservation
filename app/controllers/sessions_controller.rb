class SessionsController < ApplicationController
  def new
    @users = User.regular_users.order(:name)
    @fps = User.fps.order(:name)
  end

  def create
    user = User.find_by(id: params[:user_id])
    if user
      session[:user_id] = user.id
      if user.fp?
        redirect_to fp_available_slots_path, notice: "#{user.name}さんとしてログインしました"
      else
        redirect_to fps_path, notice: "#{user.name}さんとしてログインしました"
      end
    else
      redirect_to login_path, alert: "ユーザーを選択してください"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました"
  end
end
