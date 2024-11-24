#!/bin/bash

# Purpose: Produce a concise report about fasta/fa files in a given folder and its subfolders.

# (1) Check and set the search folder
if [[ -n $1 ]] && [[ -d $1 ]]; then
    # Argument provided and is a valid directory
    search_folder="$1"
else
    # Handle missing or invalid directory
    [[ -n $1 ]] && echo "### ERROR ### Directory not found. Running script for the current directory."
    search_folder="."
fi

# (2) Check and set the number of lines to display (N)
if [[ -n $2 ]] && [[ $2 -gt 0 ]]; then
    # Valid positive number provided
    N=$2
else
    # Default to 0 if not provided or invalid
    N=0
fi

# (3) Search for fasta files (with .fasta or .fa extensions)
fasta_files=$(find "$search_folder" -type f \( -name "*.fasta" -or -name "*.fa" \))

# Count the number of fasta files
number_of_fasta_files=$(echo "$fasta_files" | wc -l)

# Report the total number of fasta files found
echo "Total fasta/fa files in the given directory: $number_of_fasta_files"

# Check if no fasta files were found
if [[ -z $fasta_files ]]; then
    echo "### ERROR ### No fasta files could be found in the specified directory."
    exit 1
fi

# (4) Count and report unique fasta IDs across all files
echo -n "Total unique fasta IDs: "
for file in $fasta_files; do
    # Extract fasta headers (lines starting with ">") and keep the first word
    grep "^>" "$file" | awk '{print $1}'
done | sort | uniq | wc -l

# Process each fasta file for detailed reporting
for file in $fasta_files; do
    echo "File name: $file"

    # Check if the file is a symbolic link
    if [[ -h "$file" ]]; then
        if [[ -e "$file" ]]; then
            symlink_status="Yes"
        else
            echo "ERROR: File $file is a broken symlink."
            continue
        fi
    else
        symlink_status="No"
    fi
    echo "Symlink: $symlink_status"

    # Count the number of sequences (lines starting with ">")
    sequence_count=$(grep -c "^>" "$file")
    echo "Sequences: $sequence_count"

    # Calculate the total sequence length (excluding headers, gaps, and spaces)
    total_sequence_length=$(grep -v "^>" "$file" | sed 's/ //g; s/-//g' | awk '{length_sum += length($0)} END {print length_sum}')
    echo "Total sequence length: $total_sequence_length"

    # Determine the type of sequences (nucleotide or amino acid)
    if grep -qi "[EFILPQWXZ]" "$file"; then
        sequence_type="Amino Acid"
    else
        sequence_type="Nucleotide"
    fi
    echo "Sequence type: $sequence_type"

    # Display file content based on N
    total_lines=$(wc -l < "$file")
    if [[ $total_lines -le $((2 * $N)) ]] || [[ $N -eq 0 ]]; then
        cat "$file"
    else
        echo "Warning: File has more than $((2 * $N)) lines. Showing first and last $N lines."
        head -n $N "$file"
        echo "..."
        tail -n $N "$file"
    fi
    echo
done

