# Use an official Ubuntu base image from the Docker Hub
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies in a single RUN command to reduce image layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy necessary files
COPY . /app

# Use a more meaningful entry point or command
CMD ["echo", "Main Docker container running."]
