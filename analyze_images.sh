#
#  usage:  analyze_images.sh > analysis.csv
#  Sort by exposure clipping:
#  sort -t$'\t' -k2 -nr analysis.csv
#  Sort by blur factor:
#  sort -t$'\t' -k3 -nr analysis.csv
#  Copy the original photos of non-clipped images into a new filtered directory
#  awk -F"\t" '$2<1000' analysis.csv | cut -f1 | xargs basename | xargs -I% cp orig/% filtered/%


#  Extract gps locations from phone photos into csv:
#  exiftool -n -createdate -gpslatitude -gpslongitude -csv . > ../gps_locations.csv
#  Sort phone gps csv by created date, only keeping files that have GPS coordinates, selecting the GPS coordinates, and then reordering the columns
#  awk -F, '$3' gps_locations.csv | sort -t, -k2 -n | cut -d, -f3,4 | awk -F, '{ print $2","$1 }'


# Wrap file names in html tags
# ls | xargs -I{} echo "<figure><img data-src="{}"></figure>"

for sp in new/*; do 
  # https://imagemagick.org/discourse-server/viewtopic.php?t=19805
  luminosity_mean=$( convert "$sp" -channel RGB -threshold 99% -separate -append -format "%[mean]" info:)
  # https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=34482
  # blur_factor=$( magick "$sp" -statistic StandardDeviation 15x15 -format "%[fx:maxima]" info:)

  # to consider: https://www.igoroseledko.com/detecting-blurry-photos-with-imagemagick/
  # echo "$sp\t$luminosity_mean\t$blur_factor"
  echo "$sp\t$luminosity_mean"
done
