FROM ubuntu:latest

# Install necessary packages and clean up APT when done
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs ffmpeg python3 python3-pip python3-venv && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment, then install Python packages
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install -U openai-whisper setuptools-rust

# Ensure the virtual environment is used
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /home/app

ENTRYPOINT ["bash"]