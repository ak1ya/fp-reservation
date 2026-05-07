# 全コントローラーの基底クラス
# セッションを使った簡易認証のヘルパーをここに集約する
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  # ビューからも呼べるようにヘルパーとして公開
  helper_method :current_user, :logged_in?, :logged_in_as_fp?

  private

  # セッションに保存した user_id からログイン中のユーザーを取得する
  # 同一リクエスト内では @current_user にキャッシュして DB アクセスを 1 回に抑える
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def logged_in_as_fp?
    logged_in? && current_user.fp?
  end

  # ログインが必要なページに付与する before_action
  def require_login
    redirect_to login_path, alert: "ログインしてください" unless logged_in?
  end

  # 一般ユーザー専用ページ（FP でのログインは拒否）
  def require_user_login
    unless logged_in? && !current_user.fp?
      redirect_to login_path, alert: "ユーザーとしてログインしてください"
    end
  end

  # FP 専用ページ（一般ユーザーでのログインは拒否）
  def require_fp_login
    unless logged_in_as_fp?
      redirect_to login_path, alert: "FPとしてログインしてください"
    end
  end
end
