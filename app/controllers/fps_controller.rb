# FP の一覧・詳細を表示するコントローラー
# 詳細画面ではカレンダーと当日の空き枠を合わせて表示する
class FpsController < ApplicationController
  # 一覧・詳細はログイン不要で閲覧可能にする
  before_action :require_login, except: [:index, :show]

  def index
    @fps = User.fps.order(:name)
  end

  def show
    @fp = User.fps.find(params[:id])

    # クエリパラメータ ?date=YYYY-MM-DD で日付を切り替える（不正値は当日にフォールバック）
    @target_date = parse_date || Date.current
    # 日曜日が選択された場合は翌月曜日にスキップ
    @target_date = @target_date.next_weekday if @target_date.wday == 0

    @weeks = generate_weeks
    # 選択日のうち予約が入っていない枠のみ表示する
    @slots = @fp.available_slots
                .where(slot_date: @target_date)
                .available
                .order(:start_time)
  end

  private

  def parse_date
    Date.parse(params[:date]) if params[:date].present?
  rescue Date::Error
    nil
  end

  # カレンダー用に今週から 4 週分の日付配列を生成する（日曜除外）
  def generate_weeks
    start_date = Date.current.beginning_of_week(:monday)
    (0...4).map do |week_offset|
      week_start = start_date + week_offset.weeks
      (0...6).map { |d| week_start + d.days }.reject { |d| d.wday == 0 }
    end
  end
end
