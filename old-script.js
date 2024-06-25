const {exec} = require('child_process')
const path = require('path')
const fs = require('fs')
const {S3Client, PutObjectCommand, GetObjectCommand} = require('@aws-sdk/client-s3')
const mime = require('mime-types')

const videoTranscoderSh = 'video-transcoder.sh'
const videoThumbnailsGeneratorSh = 'video-thumbnails-generator.sh'
const videoTranslatorSh = 'video-translator.sh'

const USER_ID = process.env.USER_ID
const UPLOAD_FOLDER_NAME = process.env.UPLOAD_FOLDER_NAME
const DOWNLOAD_BUCKET_NAME = process.env.DOWNLOAD_BUCKET_NAME
const UPLOAD_BUCKET_NAME = process.env.UPLOAD_BUCKET_NAME
const DOWNLOAD_FOLDER_NAME = process.env.DOWNLOAD_FOLDER_NAME
const FILE_NAME = process.env.FILE_NAME

const RETURN_API_ENDPOINT = process.env.RETURN_API_ENDPOINT
const S3_REGION = process.env.S3_REGION
const S3_ACCESS_KEY_ID = process.env.S3_ACCESS_KEY_ID
const S3_SECRET_ACCESS_KEY = process.env.S3_SECRET_ACCESS_KEY



const s3Client  = S3Client({
    region:`'${S3_REGION}`,
    credentials: {
        accessKeyId: `${S3_ACCESS_KEY_ID}`,
        secretAccessKey: `${S3_SECRET_ACCESS_KEY}`
    }
})


async function init() {
    console.log("Executing script.js")
    const outDirPath = path.join(__dirname, 'videos')

    // 

    const s3DownloadCommand = new GetObjectCommand({
        Bucket: `${DOWNLOAD_BUCKET_NAME}`,
        Key: `${DOWNLOAD_FOLDER_NAME}/${FILE_NAME}`,
    });

    const p0 = exec(`cd ${outDirPath}`)

    const response = await s3Client.send(s3DownloadCommand);

    const fileStream = fs.createWriteStream(outDirPath);
    response.Body.pipe(fileStream);

    fileStream.on('close', () => {
        console.log('File downloaded successfully to', outDirPath);
    });

    // 

    console.log('Downloaded video file from S3')

    const p = exec(`cd ${outDirPath} && bash ${videoTranscoderSh} && bash ${videoThumbnailsGeneratorSh} && bash ${videoTranslatorSh}`)

    p.stdout.on('data', function(data){
        console.log(data.toString())
    })

    p.stdout.on('error', function(data){
        console.log('Error', data.toString())
    })

    p.on('close', async function(){
        console.log('Build complete')
        const outputsPath = path.join(__dirname, 'outputs')
        const outputsContents = fs.readdirSync(outputsPath, { recursive: true})

        for(const file of outputsContents) {
            const filepath = path.join(outputsPath, file)
            if(fs.lstatSync(filepath).isDirectory()) continue;

            console.log('Uploading', filepath)

            const s3UploadCommand = new PutObjectCommand({
                Bucket: `${UPLOAD_BUCKET_NAME}`,
                Key: `${USER_ID}/${UPLOAD_FOLDER_NAME}/${file}`,
                Body: fs.createReadStream(filepath),
                ContentType: mime.lookup(filepath)
            })

            await s3Client.send(s3UploadCommand)

            console.log('Uploaded', filepath)
        }

        // curl a post request to RETURN_API_ENDPOINT from here

        console.log('Done...')
    })
}

init()
