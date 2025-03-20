https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started-nodejs.html

docker build -t we-learn-video-transcoder-test-1 .

docker run -it \
-e USER_ID=2 \
-e S3_REGION=eu-north-1 \
-e S3_ACCESS_KEY_ID="*****" \
-e S3_SECRET_ACCESS_KEY="******" \
-e VIDEO_ID=1 \
-e FILE_NAME="10- Finding Bugs Using Bisect.mp4" \
-e DOWNLOAD_FOLDER_NAME=2 \
-e DOWNLOAD_BUCKET_NAME=we-learn-dev-temp \
-e UPLOAD_FOLDER_NAME=2 \
-e UPLOAD_BUCKET_NAME=we-learn-dev-outputs \
-e RETURN_API_ENDPOINT="http://localhost/api/aws-ecs/transcode-successfull" \
we-learn-video-transcoder-test-1

1. Set up a License Server: Implement a license server that interacts with your content decryption module (CDM). You can either set up your own or use a third-party service. 2. Encrypt your content: Use Shaka Packager to encrypt your video content. This involves generating encryption keys and using them to package your media files. 3. Generate presigned URLs: Use AWS SDK in your Laravel controller to generate presigned URLs for master.m3u8 and other necessary files. Ensure these URLs have limited expiry times. 4. Configure CORS: Ensure your S3 bucket has appropriate CORS configuration to allow playback but restrict direct downloads. 5. Test the setup: Make sure to thoroughly test your setup to ensure the DRM protection works correctly and the playback is smooth on different devices and browsers.
