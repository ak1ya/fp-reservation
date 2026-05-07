module Fp
  class AvailableSlotsController < ApplicationController
    before_action :require_fp_login

    def index
      @target_date = parse_date || Date.current
      @target_date = Date.current if @target_date < Date.current
      @target_date = @target_date.next_weekday if @target_date.wday == 0
      @weeks = generate_weeks
      @possible_slots = User.slot_times_for_date(@target_date)
      @my_slots = current_user.available_slots.where(slot_date: @target_date).index_by(&:start_time_str)
    end

    def create
      date = Date.parse(params[:slot_date])
      slot_params_list = params[:slots] || []

      existing_slots = current_user.available_slots.where(slot_date: date)
      existing_keys = existing_slots.map(&:start_time_str).to_set
      new_keys = slot_params_list.to_set

      to_add = new_keys - existing_keys
      to_remove = existing_keys - new_keys

      ActiveRecord::Base.transaction do
        to_add.each do |start_str|
          slot_times = User.slot_times_for_date(date).find { |s| s[:start_time] == start_str }
          next unless slot_times

          current_user.available_slots.create!(
            slot_date: date,
            start_time: slot_times[:start_time],
            end_time: slot_times[:end_time]
          )
        end

        existing_slots.each do |slot|
          if to_remove.include?(slot.start_time_str)
            slot.destroy! unless slot.booked?
          end
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

    def generate_weeks
      start_date = Date.current.beginning_of_week(:monday)
      (0...4).map do |week_offset|
        week_start = start_date + week_offset.weeks
        (0...6).map { |d| week_start + d.days }.reject { |d| d.wday == 0 }
      end
    end
  end
end
