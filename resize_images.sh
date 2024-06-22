for sp in filtered/*; do 
  echo "Resizing Image: $sp"
  convert -resize 40% $sp smaller/$(basename $sp)
done
