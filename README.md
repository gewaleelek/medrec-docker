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
3. Run `export PAT=<your github token here>`. This is used to speed up the installation process. See [GitHub's documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) for how to get one. Only `read:packages` permission is needed.
4. Run `export HTTP_PROXY=<your proxy address>` if you're behind a proxy. The URL format is `http://user:pass@domain.tld:port`. If your password includes special characters [listed here](https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding), you'll need to percent-encode those characters. For example, `p@ssw0rd` becomes `p%40ssw0rd`.
5. Run `docker build . --build-arg PAT=$PAT`, or `docker build --build-arg HTTP_PROXY=$HTTP_PROXY --build-arg PAT=$PAT .` if you're behind a proxy.

## Notes
1. This requires a considerable amount of disk space because there's just a lot of dependencies to install
2. I've tested this on
    1. Debian Bookworm with Docker version 20.10.24+dfsg1, build 297e128 (installed using `sudo apt install docker.io`)
    2. Windows 10 with 20.10.24+dfsg1 in Debian WSL 1.20.0.0
