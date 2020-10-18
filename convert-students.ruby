require 'csv'
require 'json'

csv_string = CSV.generate do |csv|
    users = JSON.parse(File.open("./_data/users.json").read)
    csv << ["telegramId", "name"]
    users["records"].each do |record|
        fields = record["fields"]
        if (fields != nil)
            telegramId = fields["Telegram Nickname"]
            firstName = fields["First Name"]
            lastName = fields["Last Name"]
            if (telegramId != nil && firstName != nil && lastName != nil)
                csv << ["@" + telegramId, firstName + " " + lastName]
            end
        end
    end
end

puts csv_string