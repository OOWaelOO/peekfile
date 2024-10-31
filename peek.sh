if [[ -z $2 ]]; then
  lines=3  
else
  lines=$2 
fi

total_lines=$(cat $1 | wc -l)

if [[ $total_lines -le $((2 * $lines)) ]]; then
  cat "$1"
else
  echo "Warning: File has more than $((2 * $lines)) lines. Showing first and last $lines lines."
head -n $lines $1
echo "..."
tail -n $lines $1 
fi
