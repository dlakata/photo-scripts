for sp in phone/*.HEIC; do 
  echo "Resizing Image: $sp"
  convert $sp phone_jpg/$(basename $sp .HEIC).jpg
done
