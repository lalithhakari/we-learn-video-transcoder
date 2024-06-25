FROM ubuntu:latest

# Install necessary packages and clean up APT when done
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs ffmpeg python3 python3-pip python3-venv build-essential bc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment, then install Python packages
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install -U openai-whisper setuptools-rust

# Ensure the virtual environment is used
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /home/app

COPY main.sh main.sh
COPY script.js script.js
COPY video-transcoder.sh video-transcoder.sh
COPY video-thumbnails-generator.sh video-thumbnails-generator.sh
COPY video-translator.sh video-translator.sh
COPY package*.json .

RUN npm install

RUN chmod +x main.sh
RUN chmod +x script.js
RUN chmod +x video-transcoder.sh
RUN chmod +x video-thumbnails-generator.sh
RUN chmod +x video-translator.sh

ENTRYPOINT ["/home/app/main.sh"]