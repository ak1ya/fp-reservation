fps_data = [
  { name: "田中 美咲", email: "tanaka.misaki@fp-example.com" },
  { name: "鈴木 健太", email: "suzuki.kenta@fp-example.com" },
  { name: "佐藤 由美", email: "sato.yumi@fp-example.com" }
]

fps = fps_data.map do |data|
  User.find_or_create_by!(email: data[:email]) do |u|
    u.name = data[:name]
    u.role = "fp"
  end
end

users_data = [
  { name: "山田 太郎", email: "yamada.taro@example.com" },
  { name: "伊藤 花子", email: "ito.hanako@example.com" },
  { name: "渡辺 次郎", email: "watanabe.jiro@example.com" }
]

users_data.each do |data|
  User.find_or_create_by!(email: data[:email]) do |u|
    u.name = data[:name]
    u.role = "user"
  end
end

today = Date.current
(1..14).each do |offset|
  date = today + offset.days
  next if date.wday == 0

  fps.first(2).each do |fp|
    slots = User.slot_times_for_date(date)
    slots.first(6).each do |slot_times|
      fp.available_slots.find_or_create_by!(
        slot_date: date,
        start_time: slot_times[:start_time]
      ) do |s|
        s.end_time = slot_times[:end_time]
      end
    end
  end
end

puts "シードデータを作成しました"
puts "FP: #{User.fps.count}名"
puts "ユーザー: #{User.regular_users.count}名"
puts "利用可能枠: #{AvailableSlot.count}枠"
