# ログイン・ログアウトを管理するコントローラー
# パスワード認証は行わず、リストから選択するだけで任意のユーザーとしてログインできる
class SessionsController < ApplicationController
  def new
    # ログイン画面でユーザー一覧・FP 一覧をそれぞれ表示する
    @users = User.regular_users.order(:name)
    @fps   = User.fps.order(:name)
  end

  def create
    user = User.find_by(id: params[:user_id])
    if user
      # セッションにユーザー ID を保存してログイン状態にする
      session[:user_id] = user.id
      # ロールに応じてリダイレクト先を切り替える
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
    # セッションから user_id を削除することでログアウト
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました"
  end
end
