for sp in orig/*; do 
  echo "Converting Image: $sp"
  convert -auto-gamma -auto-level -normalize $sp $(basename $sp)
done
