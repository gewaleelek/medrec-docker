# MedRec Docker
A futile attempt to hopefully get [MedRec](https://github.com/mitmedialab/medrec) and its billion dependencies to work.

## Status
It does not work yet!
* Need to configure mysql next

## Requirements
* Docker

## Instructions
1. Download this repo as a zip and extract it somewhere
2. Open your terminal and go into the extracted directory
3. `docker build .`, or `docker build --build-arg HTTP_PROXY=$HTTP_PROXY .` if you're behind a proxy (run `export HTTP_PROXY=http://user:pass@proxy.tld:port` first)

## Notes
1. This requires a considerable amount of disk space because there's just a lot of dependencies to install
2. I've tested this on
    1. Debian Bookworm with Docker version 20.10.24+dfsg1, build 297e128 (installed using `sudo apt install docker.io`)
    2. Windows 10 with 20.10.24+dfsg1 in Debian WSL 1.20.0.0
