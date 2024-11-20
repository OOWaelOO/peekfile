#!/bin/bash

if [[ -n $1 ]] && [[ -d $1 ]]; then
	search_folder=$1
else
	[[ -n $1 ]] && echo "ERROR: DIrectory not found, running script for currecnt directory"
	search_folder="."
fi

if [[ -n $2 ]] && [[ $2 -gt 0 ]]; then
	N=$2
else
	N=0
fi

fasta_files=$(find "$search_folder" -type f -name "*.fasta" -or -type f -name "*.fa") #use "" for search_folder in case directory has spaces in it

number_of_fasta_files=$(find "$search_folder" -type f -name "*.fasta" -or -type f -name "*.fa" | wc -l) #use "" for search_folder in case directory has spaces in it

echo "Total fasta/fa files in given directory: $number_of_fasta_files"

echo "Total unique fasta IDs: "
for file in $fasta_files; do
	grep "^>" "$file" | awk '{print $1}' #this ensures to only take lines that start with ">". using ">*" in grep would also take "words" that start with >
done | sort | uniq | wc -l
