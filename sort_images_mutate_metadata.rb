require 'multi_exiftool'

# https://exiftool.org/forum/index.php?topic=13154.0
# bundle exec ruby sort_images_mutate_metadata.rb "/Users/davidlakata/Pictures/latest/*.JPG"

FILE_GLOB = ARGV[0]
puts FILE_GLOB
dir = Dir[FILE_GLOB]

# Actually updates the files to have appropriate timestamps so that Google Photos sorts them correctly
# The time when the two cameras took a picture of the same moment
KNOWN_TIME = Time.new(2024, 6, 8, 20, 30)
CAM1_KNOWN_PIC = "218_cam1_0152.JPG"
CAM2_KNOWN_PIC = "217_cam2_0067.JPG"

reader = MultiExiftool::Reader.new
reader.filenames = dir
results = reader.read
unless reader.errors.empty?
  $stderr.puts reader.errors
end

puts "num files"
puts results.length

original_times = results.map do |values|
  [values.file_name, values.date_time_original]
end.to_h

def get_corrected_time(original_times, filename)
    cam1_offset = KNOWN_TIME - original_times[CAM1_KNOWN_PIC]
    cam2_offset = KNOWN_TIME - original_times[CAM2_KNOWN_PIC]
    date_time_original = original_times[filename]
    new_time = if filename.include?("cam1")
        date_time_original + cam1_offset
    elsif filename.include?("cam2")
        date_time_original + cam2_offset
    else
        raise "unexpected filename"
    end
    new_time
end

new_times = original_times.map do |filename, original_time|
    correct_time = get_corrected_time(original_times, filename)
    puts "#{filename}\t#{original_time}\t#{correct_time}"
    [filename, correct_time]
end.to_h.sort_by {|filename, time| time}.to_h

puts "Mutating..."
batch = MultiExiftool::Batch.new
dir.each do |filename|
    basename = File.basename(filename)
    original_time = original_times[basename]
    if original_time >= Time.new(2024)
        puts "Time is already recent: #{filename}\t#{original_time}"
        next
    end
    new_time = new_times[basename]
    values = {"DateTimeOriginal": new_time, "ModifyDate": new_time, "CreateDate": new_time}
    puts "Updating: #{filename}: old: #{original_time}\t#{values}"
    batch.write filename, values
end

if batch.execute
    puts 'ok'
else
    puts "errors!"
    puts batch.errors
end