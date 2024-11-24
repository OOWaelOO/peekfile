#!/bin/bash

# Purpose: Produce a concise report about fasta/fa files in a given folder and its subfolders.

# Function to count sequences (lines starting with ">")
get_sequence_count() {
    grep -c "^>" "$1"
}

# Function to determine the sequence type (Amino Acid or Nucleotide)
get_sequence_type() {
    # Check only the first 100 lines for amino acid-specific characters
    head -100 "$1" | grep -qi "[EFILPQWXZ]" && echo "Amino Acid" || echo "Nucleotide"
}

# Function to display file content based on the N value
display_file_content() {
    local file="$1"
    local n="$2"
    local total_lines
    total_lines=$(wc -l < "$file")
    if [[ $total_lines -le $((2 * $n)) ]] || [[ $n -eq 0 ]]; then
        cat "$file"
    else
        echo "Warning: File has more than $((2 * $n)) lines. Showing first and last $n lines."
        head -n $n "$file"
        echo "..."
        tail -n $n "$file"
    fi
}

# (1) Check for --help flag
if [[ $1 == "--help" ]]; then
    echo "Usage: fastascan.sh [folder] [N]"
    echo "  folder: Folder to search for fasta files (default: current folder)."
    echo "  N: Number of lines to display at the start and end of files (default: 0)."
    exit 0
fi

# (2) Validate and set the search folder
if [[ -n $1 ]] && [[ -d $1 ]]; then
    search_folder="$1"
else
    if [[ -n $1 ]]; then
        echo "### WARNING ### $1 is not a valid directory. Using the current directory instead."
    fi
    search_folder="."
fi

# (3) Validate and set the number of lines to display (N)
if [[ -n $2 ]] && [[ $2 =~ ^[0-9]+$ ]]; then
    N=$2
else
    if [[ -n $2 ]]; then
        echo "### WARNING ### Second argument (N) must be a positive integer. Using default value (0)."
    fi
    N=0
fi

# (4) Search for fasta files (with .fasta or .fa extensions)
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

# (5) Count and report unique fasta IDs across all files
echo -n "Total unique fasta IDs: "
for file in $fasta_files; do
    grep "^>" "$file" | awk '{print $1}'
done | sort | uniq | wc -l

# (6) Process each fasta file for detailed reporting
for file in $fasta_files; do
    echo "=============================="
    echo "Processing File: $file"
    echo "=============================="

    # Check if the file is empty
    if [[ ! -s "$file" ]]; then
        echo "### WARNING ### $file is empty. Skipping."
        continue
    fi

    # Check if the file is readable
    if [[ ! -r "$file" ]]; then
        echo "### ERROR ### $file is not readable. Skipping."
        continue
    fi

    # Check if the file is a symbolic link
    if [[ -h "$file" ]]; then
        if [[ -e "$file" ]]; then
            symlink_status="Yes"
        else
            echo "### ERROR ### $file is a broken symlink."
            continue
        fi
    else
        symlink_status="No"
    fi
    echo "Symlink: $symlink_status"

    # Count the number of sequences
    sequence_count=$(get_sequence_count "$file")
    echo "Sequences: $sequence_count"

    # Calculate the total sequence length (excluding headers, gaps, and spaces)
    total_sequence_length=$(grep -v "^>" "$file" | sed 's/ //g; s/-//g' | awk '{length_sum += length($0)} END {print length_sum}')
    echo "Total sequence length: $total_sequence_length"

    # Determine the type of sequences
    sequence_type=$(get_sequence_type "$file")
    echo "Sequence type: $sequence_type"

    # Display file content based on N
    display_file_content "$file" "$N"
    echo
done

