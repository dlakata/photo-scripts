#!/usr/bin/env ruby

require 'csv'
require 'date'

# Used when two cameras have two different timestamps, but were used to photograph the same event

# Procedure for merging and sorting two sources of images:
# 1. For each folder of images, rename the images with a prefix to avoid collisions:
# $ for f in *JPG; do mv "$f" "$(echo $f | sed 's/SUNP/cam1/g')";done
# 2. Move all the images into one directory
# 3. Create CSV with times something like `exiftool -n -createdate -csv *JPG > camera_times.csv`
# 4. ./sort_images.rb camera_times.csv /Users/davidlakata/Pictures/project/

# The time when the two cameras took a picture of the same moment
KNOWN_TIME = DateTime.new(2024, 6, 8, 20, 30)
CAM1_KNOWN_PIC = "cam1_0152.JPG"
CAM2_KNOWN_PIC = "cam2_0067.JPG"

def get_camera_time_to_file(filename)
    list_of_times = CSV.read(filename, headers: true)
    list_of_times.map do |camera_row|
        time = DateTime.strptime(camera_row['CreateDate'], '%Y:%m:%d %H:%M:%S') + 8.0/24
        [camera_row['SourceFile'], time]
    end.to_h
end

CSV_LOCATION = ARGV[0]
FILE_DIRECTORY = ARGV[1]

raw_camera_time_to_file = get_camera_time_to_file(CSV_LOCATION)
cam1_offset = KNOWN_TIME - raw_camera_time_to_file[CAM1_KNOWN_PIC]
cam2_offset = KNOWN_TIME - raw_camera_time_to_file[CAM2_KNOWN_PIC]

corrected_times = raw_camera_time_to_file.map do |filename, time|
    new_time = if filename.include?("cam1")
        time + cam1_offset
    elsif filename.include?("cam2")
        time + cam2_offset
    else
        raise "unexpected filename"
    end
    [filename, new_time]
end.to_h.sort_by {|filename, time| time}
files_sorted_by_time = corrected_times.map {|f, t| f}

files_sorted_by_time.each_with_index do |filename, index|
    new_filename = "#{index}_#{filename}"
    puts new_filename
    File.rename(FILE_DIRECTORY + filename, FILE_DIRECTORY + new_filename)
end