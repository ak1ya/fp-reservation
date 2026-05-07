# ユーザー・FP の新規登録コントローラー
# 登録と同時にセッションを発行してログイン状態にする
class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      # ロールに応じて初期表示ページを変える
      if @user.fp?
        redirect_to fp_available_slots_path, notice: "#{@user.name}さんとして登録・ログインしました"
      else
        redirect_to fps_path, notice: "#{@user.name}さんとして登録・ログインしました"
      end
    else
      # バリデーションエラー時はフォームを再表示（422 Unprocessable Entity）
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters でフォームから受け取るカラムを制限する
  def user_params
    params.expect(user: [:name, :email, :role])
  end
end
