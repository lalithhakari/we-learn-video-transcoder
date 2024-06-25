#!/bin/bash

input_file="$1"
output_dir="/home/app/outputs"

echo "Starting thumbnail generation for file: $input_file"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Sprite file name
sprite_file="$output_dir/sprite.jpg"
vtt_file="$output_dir/sprite.vtt"

# Thumbnail settings
thumb_width=160
thumb_height=90
thumb_interval=10

# Get video duration
duration=$(ffprobe -i "$input_file" -show_entries format=duration -v quiet -of csv="p=0")
num_thumbs=$(echo "$duration / $thumb_interval" | bc)
cols=5 # Change this to a different value to see if it improves the distribution
rows=$(echo "($num_thumbs + $cols - 1) / $cols" | bc)

echo "Generating thumbnails sprite with $num_thumbs thumbnails, $cols columns, $rows rows"

# Generate the thumbnails sprite with correct rows and columns
ffmpeg -y -i "$input_file" -vf "fps=1/$thumb_interval,scale=$thumb_width:$thumb_height,tile=${cols}x${rows}" -q:v 2 "$sprite_file"

echo "Thumbnails sprite generated: $sprite_file"

# Write VTT header
echo "WEBVTT" > "$vtt_file"

# Write VTT body
for ((I=0; I<$num_thumbs; I++)); do
    start_time=$(echo "$I * $thumb_interval" | bc -l)
    end_time=$(echo "($I + 1) * $thumb_interval" | bc -l)
    x_offset=$(echo "($I % $cols) * $thumb_width" | bc -l)
    y_offset=$(echo "($I / $cols) * $thumb_height" | bc -l)
    printf "\n%02d:%02d:%02d.%03d --> %02d:%02d:%02d.%03d\n" $((start_time/3600)) $(((start_time/60)%60)) $((start_time%60)) $((start_time*1000%1000)) $((end_time/3600)) $(((end_time/60)%60)) $((end_time%60)) $((end_time*1000%1000)) >> "$vtt_file"
    echo "$sprite_file#xywh=$x_offset,$y_offset,$thumb_width,$thumb_height" >> "$vtt_file"
done

echo "VTT file generated: $vtt_file"
