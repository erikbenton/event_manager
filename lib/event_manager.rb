puts "EventManager Initialized!"

if File.exist? "../event_attendees.csv"
	File.readlines("../event_attendees.csv").each_with_index do |line, idx|
		next if idx == 0
		columns = line.split(",");
		name = columns[2]
		puts name
	end
end