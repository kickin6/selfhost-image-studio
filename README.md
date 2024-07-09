# SelfHost-Studio

This is the main README for the project. For instructions on setting up and using the project on Linux, please refer to the [Linux Setup Guide](docs/linux.md).

## Other Sections
- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Systems Tested](#systems-tested)

## Overview
This is the coordinating application for all the Self-Host modules.

## :warning: Large Files :warning:

The Fooocus-API image uses a CUDA base image which is about 8GB and also downloads an AI language model that is about 5GB on disk. You should have at least 20GB of storage available.

## Docker Images Used
- SelfHost-Image: https://github.com/kickin6/selfhost-image/pkgs/container/selfhost-image
- SelfHost-Nginx: https://github.com/kickin6/selfhost-nginx/pkgs/container/selfhost-nginx
- Fooocus-API: https://github.com/kickin6/Fooocus-API/pkgs/container/fooocus-api

## Requirements
- A system with Docker and Docker Compose.
  - Tests show only 1 CPU core was in use for image creation. The model used 12GB of VRAM when running in --always-gpu mode and 16GB in --always-high-vram mode.
- SSL certificate consisting of a certificate and key file.
- A public endpoint/server that terminates SSL requests.
- A GPU is required for mid to large images.
  - My tests showed 12GB of VRAM used and regularly used 90% of the resources of a Nvidia RTX 3090.
- Ability to git clone this repository.
- Abilility to docker pull from Githubs `ghcr.io` container registry.

## Installation
- Clone this repository with submodules
  - `git clone --recurse-submodules https://github.com/kickin6/selfhost-studio`
- Copy your `cert.pem` and `key.pem` to `./ssl/` directory.
- Make your images directory.
  - `mkdir ./outputs/<your-api-key>/`
    - This becomes part of your image URLs.
- Set your IMAGE_BASE_URL. This is the public URL to retrieve images.
  - `export IMAGE_BASE_URL=https://your-domain.com/image`
    - The `/image` is required.
- Run containers.
  - Run in Foregraund
    - `sudo docker-compose up`
  - Run in Background
    - `sudo docker-compose up -d`
  - If you get an error: `WARNING: The IMAGE_BASE_URL variable is not set. Defaulting to a blank string.`
    - Use a `.env` file
```
IMAGE_BASE_URL=https://your-public-domain/image
```

## Systems Tested
- Desktop
  - AMD 3950X CPU
  - 64GB RAM
  - 500GB SSD
  - Nvidia RTX 3090 24GB
  - Ubuntu 22.04 server
  - cuda_12.5.r12.5
  - Docker version 27.0.3
  - Docker Compose version v2.20.3
  - 500Mbps network
