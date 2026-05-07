class HomeController < ApplicationController
  def index
    @fps = User.fps.includes(:available_slots).order(:name)
    @upcoming_slots_count = AvailableSlot.available.upcoming.count
  end
end
