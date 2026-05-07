# FP予約システム

ファイナンシャルプランナー（FP）との相談予約を管理するWebアプリケーションです。

## 機能概要

- **ユーザー・FP登録** — 氏名・メールアドレスとロール（ユーザー or FP）を登録
- **ログイン/ログアウト** — 登録済みのユーザー/FPをリストから選択（パスワード不要）
- **予約枠管理（FP向け）** — 日付ごとに受け付ける枠をチェックボックスで設定
- **予約（ユーザー向け）** — FPの空き枠を一覧から選んでワンクリック予約・キャンセル

### 予約枠仕様

| 曜日 | 受付時間 | 枠数 |
|------|---------|------|
| 平日（月〜金） | 10:00〜18:00（30分刻み） | 16枠/日 |
| 土曜日 | 11:00〜15:00（30分刻み） | 8枠/日 |
| 日曜日 | 休業 | − |

## 技術スタック

| 項目 | バージョン |
|------|-----------|
| Ruby | 3.3.5 |
| Rails | 8.1 |
| MySQL | 8.4 |
| Docker / Docker Compose | 28以上 / v2以上 |
| Tailwind CSS | v3（tailwindcss-rails） |
| Sass | Dart Sass（dartsass-rails） |
| フロントエンド | Hotwire（Turbo + Stimulus）+ Importmap |

---

## セットアップ・起動手順

### 前提条件

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) がインストール・起動済みであること

### 1. リポジトリをクローン

```bash
git clone https://github.com/YOUR_USERNAME/fp-reservation.git
cd fp-reservation
```

### 2. 起動

```bash
docker compose up --build
```

初回は以下が自動で実行されます。

1. Dockerイメージのビルド（Ruby / Node.js インストール）
2. Gemのインストール
3. データベースの作成・マイグレーション
4. シードデータの投入（FP 3名・ユーザー 3名・予約枠 144件）
5. Tailwind CSS / Sass のビルド
6. Railsサーバー起動（Tailwind watch・Sass watch も同時起動）

### 3. ブラウザでアクセス

```
http://localhost:3001
```

### 4. 停止

```bash
# サーバーを止めるだけ（データは保持）
docker compose down

# データも含めて完全リセット
docker compose down -v
```

---

## 初期データ

シードデータとして以下が自動登録されます。ログイン画面のリストから選択してすぐに試せます。

### FP（3名）

| 氏名 | メールアドレス |
|------|---------------|
| 田中 美咲 | tanaka.misaki@fp-example.com |
| 鈴木 健太 | suzuki.kenta@fp-example.com |
| 佐藤 由美 | sato.yumi@fp-example.com |

田中・鈴木FPは起動日から14日分（各日6枠）の予約枠を設定済みです。

### ユーザー（3名）

| 氏名 | メールアドレス |
|------|---------------|
| 山田 太郎 | yamada.taro@example.com |
| 伊藤 花子 | ito.hanako@example.com |
| 渡辺 次郎 | watanabe.jiro@example.com |

---

## 使い方

### ユーザーとして予約する

1. `http://localhost:3001/login` → 「ユーザーとしてログイン」タブからユーザーを選択
2. ナビの「FP一覧」からFPを選択
3. カレンダーで日付を選び、空き枠をクリック → 予約完了
4. 「マイ予約」ページからキャンセルも可能

### FPとして枠を設定する

1. `http://localhost:3001/login` → 「FPとしてログイン」タブからFPを選択
2. ナビの「枠管理」で日付を選択
3. 受け付けたい枠にチェックを入れて「枠を保存する」をクリック

---

## 開発者向け情報

### よく使うコマンド

```bash
# Railsコンソール
docker compose exec web bundle exec rails console

# マイグレーション
docker compose exec web bundle exec rails db:migrate RAILS_ENV=development

# ルーティング一覧
docker compose exec web bundle exec rails routes

# ログをリアルタイムで確認
docker compose logs -f web

# シードデータを再投入（既存データがあればスキップ）
docker compose exec web bundle exec rails db:seed RAILS_ENV=development
```

### 環境変数（docker-compose.yml で設定済み）

| 変数名 | 値 | 説明 |
|--------|-----|------|
| `DB_HOST` | `db` | MySQLホスト名 |
| `DB_USERNAME` | `fp_user` | DBユーザー名 |
| `DB_PASSWORD` | `fp_password` | DBパスワード |
| `RAILS_ENV` | `development` | Rails環境 |

### ポートについて

デフォルトはホスト側 **3001** → コンテナ側 3000 のマッピングです。  
ポートが競合する場合は `docker-compose.yml` の `ports` を変更してください。

```yaml
ports:
  - "任意のポート:3000"
```

### ディレクトリ構成

```
fp-reservation/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb       # 認証ヘルパー（current_user 等）
│   │   ├── home_controller.rb              # トップページ
│   │   ├── sessions_controller.rb          # ログイン・ログアウト
│   │   ├── registrations_controller.rb     # ユーザー・FP登録
│   │   ├── fps_controller.rb               # FP一覧・詳細
│   │   ├── fp/
│   │   │   └── available_slots_controller.rb  # FPの枠管理
│   │   └── reservations_controller.rb      # 予約一覧・作成・キャンセル
│   ├── models/
│   │   ├── user.rb                         # ユーザー・FP（role で区別）
│   │   ├── available_slot.rb               # FPが開放した予約枠
│   │   └── reservation.rb                  # 予約
│   ├── views/                              # 各ページのテンプレート（ERB）
│   └── assets/stylesheets/
│       ├── application.scss                # Sass カスタムスタイル（変数・ミックスイン等）
│       └── application.tailwind.css        # Tailwind CSS エントリーポイント
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── tailwind.config.js
├── db/
│   ├── migrate/                            # マイグレーションファイル
│   └── seeds.rb                            # 初期データ
├── Dockerfile
├── docker-compose.yml
└── Procfile.dev                            # foreman 用（Rails + Tailwind watch + Sass watch）
```

### データベース設計

**users**

| カラム | 型 | 説明 |
|--------|-----|------|
| id | integer | PK |
| name | string | 氏名 |
| email | string | メールアドレス（ユニーク） |
| role | string | `user` または `fp` |

**available_slots**（FPが開放した枠）

| カラム | 型 | 説明 |
|--------|-----|------|
| id | integer | PK |
| fp_id | integer | FK → users（role = fp） |
| slot_date | date | 枠の日付 |
| start_time | time | 開始時刻 |
| end_time | time | 終了時刻 |

**reservations**

| カラム | 型 | 説明 |
|--------|-----|------|
| id | integer | PK |
| user_id | integer | FK → users（role = user） |
| available_slot_id | integer | FK → available_slots（ユニーク） |
