const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const axios = require('axios');
const mime = require('mime-types');

const videoTranscoderSh = 'video-transcoder.sh';
const videoThumbnailsGeneratorSh = 'video-thumbnails-generator.sh';
const videoTranslatorSh = 'video-translator.sh';

const USER_ID = process.env.USER_ID;
const UPLOAD_FOLDER_NAME = process.env.UPLOAD_FOLDER_NAME;
const DOWNLOAD_BUCKET_NAME = process.env.DOWNLOAD_BUCKET_NAME;
const UPLOAD_BUCKET_NAME = process.env.UPLOAD_BUCKET_NAME;
const DOWNLOAD_FOLDER_NAME = process.env.DOWNLOAD_FOLDER_NAME;
const RETURN_API_ENDPOINT = process.env.RETURN_API_ENDPOINT;
const S3_REGION = process.env.S3_REGION;
const S3_ACCESS_KEY_ID = process.env.S3_ACCESS_KEY_ID;
const S3_SECRET_ACCESS_KEY = process.env.S3_SECRET_ACCESS_KEY;
const FILE_NAME = process.env.FILE_NAME;
const VIDEO_ID = process.env.VIDEO_ID

const s3Client = new S3Client({
    region: S3_REGION,
    credentials: {
        accessKeyId: S3_ACCESS_KEY_ID,
        secretAccessKey: S3_SECRET_ACCESS_KEY
    }
});

async function downloadFileFromS3(bucket, key, destPath) {
    console.log(`Downloading file from S3: ${bucket}/${key}`);
    const command = new GetObjectCommand({ Bucket: bucket, Key: key });
    const response = await s3Client.send(command);
    const fileStream = fs.createWriteStream(destPath);
    return new Promise((resolve, reject) => {
        response.Body.pipe(fileStream);
        response.Body.on('error', reject);
        fileStream.on('finish', () => {
            console.log(`File downloaded successfully to ${destPath}`);
            resolve(destPath);
        });
    });
}

async function uploadFileToS3(bucket, key, filePath) {
    console.log(`Uploading ${filePath} to S3: ${bucket}/${key}`);
    const command = new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: fs.createReadStream(filePath),
        ContentType: mime.lookup(filePath) || 'application/octet-stream'
    });
    await s3Client.send(command);
    console.log(`Uploaded ${filePath}`);
}

async function runShellScript(script, args) {
    return new Promise((resolve, reject) => {
        const command = `bash ${script} "${args}"`;
        console.log(`Executing script: ${command}`);
        const proc = exec(command);

        proc.stdout.on('data', data => console.log(data.toString()));
        proc.stderr.on('data', data => console.error(data.toString()));
        proc.on('close', code => {
            if (code === 0) {
                console.log(`Script ${script} completed successfully`);
                resolve();
            } else {
                reject(new Error(`Script ${script} exited with code ${code}`));
            }
        });
    });
}

async function notifyEndpoint() {
    if (RETURN_API_ENDPOINT) {
        try {
            console.log(`Notifying endpoint: ${RETURN_API_ENDPOINT}`);
            await axios.post(RETURN_API_ENDPOINT, {
                message: 'Processing and uploading completed',
                userId: USER_ID,
                videoId: VIDEO_ID
            });
            console.log('Notification sent successfully.');
        } catch (error) {
            console.error('Error notifying endpoint:', error);
        }
    } else {
        console.log('No RETURN_API_ENDPOINT provided, skipping notification.');
    }
}

async function init() {
    try {
        console.log("Starting script.js");

        const videosDirPath = path.join(__dirname, 'videos');
        const outputsDirPath = path.join(__dirname, 'outputs');
        const inputFilePath = path.join(videosDirPath, FILE_NAME);

        console.log(`Creating directories at ${videosDirPath} and ${outputsDirPath}`);
        if (!fs.existsSync(videosDirPath)) {
            fs.mkdirSync(videosDirPath, { recursive: true });
        }
        if (!fs.existsSync(outputsDirPath)) {
            fs.mkdirSync(outputsDirPath, { recursive: true });
        }

        console.log(`Downloading video file from S3: ${DOWNLOAD_BUCKET_NAME}/${DOWNLOAD_FOLDER_NAME}/${FILE_NAME}`);
        await downloadFileFromS3(DOWNLOAD_BUCKET_NAME, `${DOWNLOAD_FOLDER_NAME}/${FILE_NAME}`, inputFilePath);

        console.log(`Running video transcoder script: ${videoTranscoderSh}`);
        await runShellScript(videoTranscoderSh, inputFilePath);

        console.log(`Running video thumbnails generator script: ${videoThumbnailsGeneratorSh}`);
        await runShellScript(videoThumbnailsGeneratorSh, inputFilePath);

        console.log(`Running video translator script: ${videoTranslatorSh}`);
        await runShellScript(videoTranslatorSh, inputFilePath);

        console.log(`Reading output files from directory: ${outputsDirPath}`);
        const outputFiles = fs.readdirSync(outputsDirPath);

        for (const file of outputFiles) {
            const filePath = path.join(outputsDirPath, file);
            if (fs.lstatSync(filePath).isDirectory()) continue;

            const uploadKey = `${UPLOAD_FOLDER_NAME}/${file}`;
            console.log(`Uploading file to S3: ${filePath} to ${UPLOAD_BUCKET_NAME}/${uploadKey}`);
            await uploadFileToS3(UPLOAD_BUCKET_NAME, uploadKey, filePath);
        }

        console.log('Processing and uploading completed.');

        // console.log('Notifying endpoint of completion.');
        // await notifyEndpoint();

    } catch (error) {
        console.error('Error:', error);
    }
}

init();
