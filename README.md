https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started-nodejs.html

docker build -t we-learn-video-transcoder-test-1 .

docker run -it \
-e USER_ID=2 \
-e S3_REGION=eu-north-1 \
-e S3_ACCESS_KEY_ID="AKIAZI2LIZHBTS23TUCD" \
-e S3_SECRET_ACCESS_KEY="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" \
-e VIDEO_ID=1 \
-e FILE_NAME="10- Finding Bugs Using Bisect.mp4" \
-e DOWNLOAD_FOLDER_NAME=2 \
-e DOWNLOAD_BUCKET_NAME=we-learn-dev-temp \
-e UPLOAD_FOLDER_NAME=2 \
-e UPLOAD_BUCKET_NAME=we-learn-dev-outputs \
-e RETURN_API_ENDPOINT="http://localhost/api/aws-ecs/transcode-successfull" \
we-learn-video-transcoder-test-1
