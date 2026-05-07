# FP が自分の予約枠を管理するコントローラー（fp/ 名前空間）
# FP としてログインしていないと全アクションにアクセスできない
module Fp
  class AvailableSlotsController < ApplicationController
    before_action :require_fp_login

    def index
      @target_date = parse_date || Date.current
      # 過去日は本日に補正、日曜は翌月曜にスキップ
      @target_date = Date.current if @target_date < Date.current
      @target_date = @target_date.next_weekday if @target_date.wday == 0

      @weeks = generate_weeks
      # 選択日に設定できる全スロット（曜日によって平日・土曜が切り替わる）
      @possible_slots = User.slot_times_for_date(@target_date)
      # 既に登録済みの枠を start_time 文字列でインデックスしてビューで O(1) 参照できるようにする
      @my_slots = current_user.available_slots.where(slot_date: @target_date).index_by(&:start_time_str)
    end

    def create
      date = Date.parse(params[:slot_date])
      # フォームのチェックボックスから送られた開始時刻の配列
      slot_params_list = params[:slots] || []

      existing_slots = current_user.available_slots.where(slot_date: date)
      existing_keys  = existing_slots.map(&:start_time_str).to_set
      new_keys       = slot_params_list.to_set

      # 差分計算: 追加すべき枠・削除すべき枠をそれぞれ算出する
      to_add    = new_keys - existing_keys
      to_remove = existing_keys - new_keys

      # 追加・削除を 1 トランザクションで行い、途中エラーで中途半端な状態にならないようにする
      ActiveRecord::Base.transaction do
        to_add.each do |start_str|
          slot_times = User.slot_times_for_date(date).find { |s| s[:start_time] == start_str }
          next unless slot_times

          current_user.available_slots.create!(
            slot_date:  date,
            start_time: slot_times[:start_time],
            end_time:   slot_times[:end_time]
          )
        end

        existing_slots.each do |slot|
          # 予約済みの枠は削除しない（ユーザーへの影響を避けるため）
          slot.destroy! if to_remove.include?(slot.start_time_str) && !slot.booked?
        end
      end

      redirect_to fp_available_slots_path(date: date.to_s), notice: "予約枠を更新しました"
    rescue => e
      redirect_to fp_available_slots_path(date: params[:slot_date]), alert: "更新に失敗しました: #{e.message}"
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
end
