#!/bin/bash

# Check if bc is installed
if ! command -v bc &> /dev/null
then
    echo "bc could not be found, please install bc to proceed."
    exit
fi

# Input video file
input_file="sample-video-file.mp4"

# Output directory for thumbnails
output_dir="./thumbnails"
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

# Generate the thumbnails sprite with correct rows and columns
ffmpeg -y -i "$input_file" -vf "fps=1/$thumb_interval,scale=$thumb_width:$thumb_height,tile=${cols}x${rows}" -q:v 2 "$sprite_file"

# Write VTT header
echo "WEBVTT" > "$vtt_file"

# Write VTT body
for ((i=0; i<$num_thumbs; i++)); do
    start_time=$(echo "$i * $thumb_interval" | bc -l)
    end_time=$(echo "($i + 1) * $thumb_interval" | bc -l)
    x_offset=$(echo "($i % $cols) * $thumb_width" | bc -l)
    y_offset=$(echo "($i / $cols) * $thumb_height" | bc -l)
    printf "\n%02d:%02d:%02d.%03d --> %02d:%02d:%02d.%03d\n" $((start_time/3600)) $(((start_time/60)%60)) $((start_time%60)) $((start_time*1000%1000)) $((end_time/3600)) $(((end_time/60)%60)) $((end_time%60)) $((end_time*1000%1000)) >> "$vtt_file"
    echo "$sprite_file#xywh=$x_offset,$y_offset,$thumb_width,$thumb_height" >> "$vtt_file"
done