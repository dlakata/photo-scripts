require 'csv'
require 'date'

# Created with something like `exiftool -n -createdate -gpslatitude -gpslongitude -csv . > camera_times.csv`
camera_times = CSV.read("camera_times.csv", headers: true)
gps_locations = CSV.read("gps_locations.csv", headers: true)

camera_time_to_file = {}
camera_times.each do |camera_row|
    time = (DateTime.strptime(camera_row['CreateDate'], '%Y:%m:%d %H:%M:%S') + 8.0/24)
    camera_time_to_file[time] = camera_row['SourceFile']
end

gps_time_to_location = {}
gps_locations.each do |location_row|
    next unless location_row['CreateDate'] && location_row['GPSLatitude'] && location_row['GPSLongitude']
    time = DateTime.strptime(location_row['CreateDate'], '%Y:%m:%d %H:%M:%S')
    gps_time_to_location[time] = {
        lat: location_row['GPSLatitude'].to_f.round(6),
        long: location_row['GPSLongitude'].to_f.round(6),
        file: location_row['SourceFile'],
    }
end

formatted_camera_time_to_file = camera_time_to_file.map {|k, v| "#{k.strftime('%m/%d/%Y %H:%M:%S')}\tcam\t#{v}"}
formatted_gps_time_to_location = gps_time_to_location.map {|k, v| "#{k.strftime('%m/%d/%Y %H:%M:%S')}\tgps\t#{v[:file]}\t#{v[:lat]}, #{v[:long]}"}
puts (formatted_camera_time_to_file + formatted_gps_time_to_location).sort

camera_time_to_file_array = camera_time_to_file.to_a.sort
gps_time_to_location_array = gps_time_to_location.to_a.sort

puts "\n\nCandidate photos\n\n"

camera_time_to_file_array.each do |camera_record|
    camera_time = camera_record[0]
    camera_file = camera_record[1]
    closest_gps_time = gps_time_to_location_array.min_by {|x| (x[0] - camera_time).to_f.abs}
    candidate_photo = if (closest_gps_time[0] - camera_time).to_f.abs < 10 * 1.0/24/60
        {
            file: closest_gps_time[1][:file],
            location: "#{closest_gps_time[1][:lat]}, #{closest_gps_time[1][:long]}",
            time: closest_gps_time[0].strftime('%m/%d/%Y %H:%M:%S'),
        }
    else
        {file: 'unknown', location: 'unknown', time: 'unknown'}
    end
    puts "#{camera_time.strftime('%m/%d/%Y %H:%M:%S')} - #{camera_file}\t#{candidate_photo[:file]}\t#{candidate_photo[:location]}\t#{candidate_photo[:time]}"
end