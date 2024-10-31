total_lines=$(cat $1 | wc -l)

if [[ $total_lines -eq 0 ]]; then
  echo "The file has zero lines."
elif [[ $total_lines -eq 1 ]]; then
  echo "The file has one line."
else
  echo "The file has $total_lines lines."
fi

