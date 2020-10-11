require 'csv'
require 'json'

csv_string = CSV.generate do |csv|
    users = JSON.parse(File.open("./_data/users.json").read)
    csv << ["telegramId", "name"]
    users["records"].each do |record|
        fields = record["fields"]
        csv << ["@" + fields["Telegram Nickname"], fields["First Name"] + " " + fields["Last Name"]]
    end
end

puts csv_string