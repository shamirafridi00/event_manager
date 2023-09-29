# frozen_string_literal: true
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'




puts 'Event Manager Initilized!'

# contents = File.read('event_attendees.csv')
# puts contents


# if File.exist?('event_attendees.csv')
#   puts 'File exists'
# else
#   puts 'File does not exist'
# end


# contents = File.readlines('event_attendees.csv')
# contents.each_with_index do |line,index|
#   next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   p name
# end

def clean_zipcode(zipcode)
  if zipcode.nil?
    zipcode = '00000'
  elsif zipcode.length > 5
    zipcode = zipcode[0..4]
  elsif zipcode.length < 5
    zipcode = zipcode.rjust(5, '0')
  else
    zipcode
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end


def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


template_letter = File.read('../form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end
