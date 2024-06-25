#!/bin/bash

input_file="$1"
output_dir="/home/app/outputs"

echo "Starting video translation for file: $input_file"

whisper "$input_file" --language English --task translate --output_dir "$output_dir"

echo "Video translation completed: $input_file"
echo "Translation outputs saved to: $output_dir"
