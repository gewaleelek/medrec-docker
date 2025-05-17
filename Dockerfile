FROM node:9.9-stretch
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://archive.debian.org/debian stretch main non-free-firmware non-free contrib" > /etc/apt/sources.list && \
    apt-get update -q && \ 
    apt-get install unzip mariadb-server -y -q
RUN wget -q https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -xf /tmp/go.tar.gz -C /tmp && rm /tmp/go.tar.gz && \
    mv /tmp/go /usr/local
ENV GOPATH=/root/work
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
RUN wget -q https://github.com/mitmedialab/medrec/archive/refs/heads/master.zip -O /tmp/medrec.zip && \ 
    mkdir /root/work && \ 
    unzip -q /tmp/medrec.zip -d /root/work/
RUN cd /root/work/medrec-master && \
    go mod init github.com/mitmedialab/medrec && \
    go build
RUN cd /root/work/medrec-master/UserClient && \
    sed -i 's/git:\/\/github\.com\/frozeman\/WebSocket-Node\.git#7004c39c42ac98875ab61126e5b4a925430f592c/1.0.35/g' package-lock.json && \
    npm install && \
    npm run build
RUN cd /root/work/medrec-master/GolangJSHelpers && \
    npm install
RUN cd /root/work/medrec-master/scripts && \
    /etc/init.d/mysql start

RUN tail -f /dev/null

