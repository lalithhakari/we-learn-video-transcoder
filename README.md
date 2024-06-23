# cmd-1

    ffmpeg -i sample-video-file.mp4 \
    -filter_complex "[0:v]split=4[v360][v480][v720][v1080]; \
    [v360]scale=w=640:h=360[v360out]; \
    [v480]scale=w=854:h=480[v480out]; \
    [v720]scale=w=1280:h=720[v720out]; \
    [v1080]scale=w=1920:h=1080[v1080out]" \
    -map [v360out] -map 0:a -c:v:0 libx264 -b:v:0 800k -c:a:0 aac -b:a:0 96k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "output_360p_%03d.ts" output_360p.m3u8 \
    -map [v480out] -map 0:a -c:v:1 libx264 -b:v:1 1400k -c:a:1 aac -b:a:1 128k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "output_480p_%03d.ts" output_480p.m3u8 \
    -map [v720out] -map 0:a -c:v:2 libx264 -b:v:2 2800k -c:a:2 aac -b:a:2 128k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "output_720p_%03d.ts" output_720p.m3u8 \
    -map [v1080out] -map 0:a -c:v:3 libx264 -b:v:3 5000k -c:a:3 aac -b:a:3 192k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename "output_1080p_%03d.ts" output_1080p.m3u8

# Create the master playlist

echo '#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=985600,RESOLUTION=640x360,CODECS="avc1.64001f,mp4a.40.2"
output_360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1400000,RESOLUTION=854x480,CODECS="avc1.64001f,mp4a.40.2"
output_480p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720,CODECS="avc1.64001f,mp4a.40.2"
output_720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080,CODECS="avc1.64001f,mp4a.40.2"
output_1080p.m3u8' > master.m3u8

# subtitles

whisper sample-video-file.mp4 --language English --task translate

only .vtt output file works for videojs
we can select Model and accuracy and give suggestion prompts or words here

# thumbnails

ffmpeg -i sample-video-file.mp4 -vf "select=not(mod(n\,300)),scale=320:180" -vsync vfr -q:v 2 thumb%04d.jpg

# cmd-2

docker build -t my-test-video-transcoder .

# cmd-3

docker run -it -v "/Users/lalith/Documents/Projects/We Learn/we-learn-video-transcoder/videos:/home/videos" my-test-video-transcoder
