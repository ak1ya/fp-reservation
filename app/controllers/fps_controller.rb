class FpsController < ApplicationController
  before_action :require_login, except: [:index, :show]

  def index
    @fps = User.fps.order(:name)
  end

  def show
    @fp = User.fps.find(params[:id])
    @target_date = parse_date || Date.current
    @target_date = @target_date.next_weekday if @target_date.wday == 0
    @weeks = generate_weeks
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

  def generate_weeks
    start_date = Date.current.beginning_of_week(:monday)
    (0...4).map do |week_offset|
      week_start = start_date + week_offset.weeks
      (0...6).map { |d| week_start + d.days }.reject { |d| d.wday == 0 }
    end
  end
end
