#!/bin/bash

input_file="$1"
output_dir="/home/app/outputs"

# Extract the base filename without extension
base_filename=$(basename "$input_file" | cut -d. -f1)

echo "Starting video transcoding for file: $input_file"

ffmpeg -i "$input_file" \
    -filter_complex "[0:v]split=4[v360][v480][v720][v1080]; \
    [v360]scale=w=640:h=360[v360out]; \
    [v480]scale=w=854:h=480[v480out]; \
    [v720]scale=w=1280:h=720[v720out]; \
    [v1080]scale=w=1920:h=1080[v1080out]" \
    -map [v360out] -map 0:a -c:v:0 libx264 -b:v:0 800k -c:a:0 aac -b:a:0 96k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "$output_dir/${base_filename}_360p_%03d.ts" "$output_dir/${base_filename}_360p.m3u8" \
    -map [v480out] -map 0:a -c:v:1 libx264 -b:v:1 1400k -c:a:1 aac -b:a:1 128k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "$output_dir/${base_filename}_480p_%03d.ts" "$output_dir/${base_filename}_480p.m3u8" \
    -map [v720out] -map 0:a -c:v:2 libx264 -b:v:2 2800k -c:a:2 aac -b:a:2 128k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "$output_dir/${base_filename}_720p_%03d.ts" "$output_dir/${base_filename}_720p.m3u8" \
    -map [v1080out] -map 0:a -c:v:3 libx264 -b:v:3 5000k -c:a:3 aac -b:a:3 192k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "$output_dir/${base_filename}_1080p_%03d.ts" "$output_dir/${base_filename}_1080p.m3u8"

echo "Video transcoding completed: $input_file"

echo "#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=985600,RESOLUTION=640x360,CODECS=\"avc1.64001f,mp4a.40.2\"
${base_filename}_360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1400000,RESOLUTION=854x480,CODECS=\"avc1.64001f,mp4a.40.2\"
${base_filename}_480p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720,CODECS=\"avc1.64001f,mp4a.40.2\"
${base_filename}_720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080,CODECS=\"avc1.64001f,mp4a.40.2\"
${base_filename}_1080p.m3u8" > "$output_dir/master.m3u8"

echo "Master playlist generated: $output_dir/master.m3u8"