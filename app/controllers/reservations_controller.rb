class ReservationsController < ApplicationController
  before_action :require_user_login

  def index
    @upcoming = current_user.reservations
                            .joins(:available_slot)
                            .where("available_slots.slot_date >= ?", Date.current)
                            .includes(available_slot: :fp)
                            .order("available_slots.slot_date, available_slots.start_time")
    @past = current_user.reservations
                        .joins(:available_slot)
                        .where("available_slots.slot_date < ?", Date.current)
                        .includes(available_slot: :fp)
                        .order("available_slots.slot_date DESC, available_slots.start_time")
                        .limit(10)
  end

  def create
    slot = AvailableSlot.available.find(params[:available_slot_id])
    @reservation = current_user.reservations.new(available_slot: slot)

    if @reservation.save
      redirect_to reservations_path, notice: "予約が完了しました"
    else
      redirect_to fp_path(slot.fp, date: slot.slot_date.to_s), alert: @reservation.errors.full_messages.join(", ")
    end
  end

  def destroy
    reservation = current_user.reservations.find(params[:id])
    if reservation.available_slot.slot_date >= Date.current
      reservation.destroy
      redirect_to reservations_path, notice: "予約をキャンセルしました"
    else
      redirect_to reservations_path, alert: "過去の予約はキャンセルできません"
    end
  end
end
