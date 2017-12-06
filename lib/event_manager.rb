require 'erb'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'date'

def clean_zipcode(zipcode)
	
	zipcode = zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone_number)
	phone_number = phone_number.to_s.split(/\(|\)|-|\.|\s/).join("")
		if phone_number.length < 10 || phone_number.length > 11
			phone_number = "BAD"
		elsif phone_number.length == 11
			if phone_number[0].to_s == "1"
				phone_number = phone_number[1..10]
			else
				phone_number = "BAD"
			end
		end
		phone_number
end

def legislators_by_zipcode(zipcode)
	civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
	civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

	begin
		civic_info.representative_info_by_address(
			address: zipcode,
			levels: "country",
			roles: ["legislatorUpperBody", "legislatorLowerBody"]).officials
	rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("../output") unless Dir.exist? "../output"

	filename = "../output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

def registration_date_time(reg_date)

	DateTime.strptime(reg_date.to_s, '%m/%d/%Y %H:%M')
end

def registration_weekday(reg_wday)

	%w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday][reg_wday]
end

puts "EventManager Initialized!"

template_letter = File.read("../form_letter.erb")
erb_template = ERB.new(template_letter)

if File.exist? "../event_attendees.csv"
	contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol
	contents.each do |row|
		id = row[0]
		name = row[:first_name]
		phone_number = clean_phone_number(row[:homephone])
		reg_date_time = registration_date_time(row[:regdate])
		reg_hour = reg_date_time.hour
		reg_wday = registration_weekday(reg_date_time.wday)
		zipcode = clean_zipcode(row[:zipcode])
		legislators = legislators_by_zipcode(zipcode)
		form_letter = erb_template.result(binding)
		save_thank_you_letters(id, form_letter)
	end
end

