Rails.application.routes.draw do
  root "home#index"

  # ヘルスチェック用エンドポイント（ロードバランサー等から利用）
  get "up" => "rails/health#show", as: :rails_health_check

  # セッション（ログイン・ログアウト）
  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # ユーザー・FP の新規登録
  get  "register", to: "registrations#new",    as: :register
  post "register", to: "registrations#create"

  # FP 一覧・詳細（ユーザーが空き枠を確認・予約するページ）
  resources :fps, only: [:index, :show]

  # fp/ 名前空間: FP が自分の枠を管理するページ
  namespace :fp do
    get  "slots", to: "available_slots#index", as: :available_slots
    post "slots", to: "available_slots#create"
  end

  # ユーザーの予約一覧・作成・キャンセル
  resources :reservations, only: [:index, :create, :destroy]
end
