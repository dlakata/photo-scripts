#!/bin/sh
#
#  usage:  clipping_detector.sh threshold *.JPG > clippers.csv
#

function detect_clipping() {
  ImageFile="$1"

  LuminosityMean=$( convert "$ImageFile" -channel RGB -threshold 99% -separate -append -format "%[mean]" info:)
  ImageFileName=$( basename "$ImageFile" )

  echo "$ImageFile\t\t\t$LuminosityMean"
}

for i in "$@"; do
   detect_clipping "$i"
done
