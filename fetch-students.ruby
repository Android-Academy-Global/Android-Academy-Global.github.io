require 'csv'
require 'json'
require 'net/http'

$airTableToken = ARGV[0]
$requestsPerSecondLimit = 4

def requestStudentsPage(offset)
    requestParams = { }
    if (offset != nil)
        requestParams["offset"] = offset
    end
    uri = URI('https://api.airtable.com/v0/appFDFb3CkxWHXrd5/Users?view=All%20participants')
    uri.query = URI.encode_www_form(requestParams)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{$airTableToken}"
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
        http.use_ssl = true
        http.request(req)
    }
    return res
end

def getStudentsPage(offset)
    response = requestStudentsPage(offset)
    return JSON.parse(response.body)
end

def writeStudentsToCsv(csv, studentsPage)
    studentsPage["records"].each do |record|
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

class LimiterPerSecond

    def initialize(limit)
        @limit = limit
        @counter = 0
    end

    def execute()
        if (@counter == @limit)
            sleep(1)
            @counter = 0
        end
        @counter = @counter + 1
        result = yield
        return result
    end
end


csv_string = CSV.generate do |csv|
    csv << ["telegramId", "name"]

    offset = nil
    requestCounter = 1
    limiter = LimiterPerSecond.new(3)
    loop do
        studentsPage = limiter.execute { getStudentsPage(offset) }
        writeStudentsToCsv(csv, studentsPage)
        offset = studentsPage['offset']
        if offset == nil
            break
        end
    end
   
end

puts csv_string