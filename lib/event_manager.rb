# frozen_string_literal: true
# requred classes/libraries
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'




puts 'Event Manager Initilized!'


#
#
#This commented part down below is for testing parser for the file but we have a csv class which we used.
#
#


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


# Cleans up a given zipcode by:
#   - Setting it to '00000' if it is nil
#   - Trimming it to the first 5 characters if it is longer than 5 characters
#   - Padding it with leading zeros if it is shorter than 5 characters
#
# Parameters:
#   - zipcode: a string representing the zipcode to be cleaned
#
# Returns:
#   - a string representing the cleaned zipcode

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


# Retrieves a list of legislators based on a given zip code.

# Parameters:
# - zip (str): The zip code for which to retrieve the legislators.

# Returns:
# - str: A comma-separated string of legislator names.

# Raises:
# - Exception: If an error occurs while retrieving the legislators.

# Example:
# legislators_by_zipcode('12345')

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


# Saves a thank you letter with a specific ID and form letter.

#Parameters:
# - id: The ID of the thank you letter.
# - form_letter: The content of the thank you letter.

# Returns: None

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


# Transforms a phone number into a standardized format.
#
# Parameters:
# - phone: a string representing the phone number to be transformed
#
# Returns:
# - a string representing the transformed phone number in the format "XXX-XXX-XXXX"
#   or "000-000-0000" if the input is nil, empty, or cannot be transformed
#
# Examples:
# transform_phone_number('123-456-7890') => '123-456-7890'
# transform_phone_number('1-800-123-4567') => '800-123-4567'
# transform_phone_number('abc123') => '000-000-0000'

def transform_phone_number(phone)
  if phone.nil? || phone.empty?
    return '000-000-0000'
  end

  # Remove non-digit characters and leading '1' (if present)
  phone = phone.gsub(/[^0-9]/, '')
  if phone.length == 10
    return "#{phone[0..2]}-#{phone[3..5]}-#{phone[6..9]}"
  elsif phone.length == 11 && phone[0] == '1'
    return "#{phone[1..3]}-#{phone[4..6]}-#{phone[7..10]}"
  else
    return '000-000-0000'
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

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
  phone = row[:homephone]
  phone = transform_phone_number(phone)


  #time targetting



end


# Calculate the most common hour in a CSV file

# This function reads a CSV file containing event attendees' registration dates and times.
# It parses the time from each row, extracts the hour component, and counts the occurrences
# of each hour. Finally, it determines the hour with the maximum count and returns it as
# the most common hour.

# Parameters:
# None

# Returns:
# None


def most_common_hour
  contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)

  hours = []
  contents.each do |row|
    time = row[:regdate]
    time = DateTime.strptime(time, '%m/%d/%y %H:%M')
    hour = time.strftime("%H")
    hours << hour

  end
  # Use `tally` to count the occurrences of each hour
  hour_counts = hours.tally

  # Find the maximum count and the corresponding hour
  max_count = hour_counts.values.max
  most_common_hour = hour_counts.key(max_count)

  puts "Most common hour: #{most_common_hour}"
  puts "Occurrences: #{max_count}"


end

puts most_common_hour
