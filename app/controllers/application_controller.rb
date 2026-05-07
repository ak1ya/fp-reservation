class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :logged_in_as_fp?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def logged_in_as_fp?
    logged_in? && current_user.fp?
  end

  def require_login
    redirect_to login_path, alert: "ログインしてください" unless logged_in?
  end

  def require_user_login
    unless logged_in? && !current_user.fp?
      redirect_to login_path, alert: "ユーザーとしてログインしてください"
    end
  end

  def require_fp_login
    unless logged_in_as_fp?
      redirect_to login_path, alert: "FPとしてログインしてください"
    end
  end
end
