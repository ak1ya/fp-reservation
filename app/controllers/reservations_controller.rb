# ユーザーの予約を管理するコントローラー
# FP はこの画面を使えない（require_user_login で制限）
class ReservationsController < ApplicationController
  before_action :require_user_login

  def index
    # 今日以降の予約を日時昇順で取得（N+1 を避けるため fp まで includes）
    @upcoming = current_user.reservations
                            .joins(:available_slot)
                            .where("available_slots.slot_date >= ?", Date.current)
                            .includes(available_slot: :fp)
                            .order("available_slots.slot_date, available_slots.start_time")
    # 過去の予約は直近 10 件のみ表示
    @past = current_user.reservations
                        .joins(:available_slot)
                        .where("available_slots.slot_date < ?", Date.current)
                        .includes(available_slot: :fp)
                        .order("available_slots.slot_date DESC, available_slots.start_time")
                        .limit(10)
  end

  def create
    # available スコープを通すことで予約済みの枠は 404 になり二重予約を防ぐ
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
    # 当日以降の予約のみキャンセル可能とする
    if reservation.available_slot.slot_date >= Date.current
      reservation.destroy
      redirect_to reservations_path, notice: "予約をキャンセルしました"
    else
      redirect_to reservations_path, alert: "過去の予約はキャンセルできません"
    end
  end
end
