for file in $@
do
  total_lines=$(cat $file | wc -l)

  if [[ $total_lines -eq 0 ]]; then
    echo "$file file has zero lines."
  elif [[ $total_lines -eq 1 ]]; then
    echo "$file file has one line."
  else
    echo "$file file has $total_lines lines."
  fi
done
