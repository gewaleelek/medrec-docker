FROM node:9.9-stretch
ENV DEBIAN_FRONTEND=noninteractive
ENV http_proxy=$HTTP_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
RUN echo 'Acquire::http::Proxy "$HTTP_PROXY";'
RUN echo "deb http://archive.debian.org/debian stretch main non-free-firmware non-free contrib" > /etc/apt/sources.list && \
    apt-get update -q --allow-unauthenticated && \ 
    apt-get install -q -y apt-transport-https debian-archive-keyring ca-certificates --allow-unauthenticated
RUN apt-get update -q && \
    apt-get install -q -y unzip mariadb-server
RUN wget -q https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -xf /tmp/go.tar.gz -C /tmp && rm /tmp/go.tar.gz && \
    mv /tmp/go /usr/local
RUN git config --global http.proxy $http_proxy
ENV GOPATH=/root/work
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
RUN wget -q https://github.com/mitmedialab/medrec/archive/refs/heads/master.zip -O /tmp/medrec.zip && \ 
    mkdir /root/work && \ 
    unzip -q /tmp/medrec.zip -d /root/work/
RUN cd /root/work/medrec-master && \
    sed -i 's/\.\.\/common/DatabaseManager\/common/g' /root/work/medrec-master/DatabaseManager/remoteRPC/ethereum_test.go && \
    sed -i 's/\.\.\/localRPC/DatabaseManager\/localRPC/g' /root/work/medrec-master/DatabaseManager/remoteRPC/ethereum_test.go && \
    go mod init github.com/mitmedialab/medrec && \
    go get github.com/ethereum/go-ethereum && \
    go mod tidy
RUN cd /root/work/medrec-master && \
    go build -v
RUN cd /root/work/medrec-master/UserClient && \
    sed -i 's/git:\/\/github\.com\/frozeman\/WebSocket-Node\.git#7004c39c42ac98875ab61126e5b4a925430f592c/1.0.35/g' package-lock.json && \
    cd /root/work/medrec-master/UserClient && \
    npm -v install && \
    npm -v run build
RUN cd /root/work/medrec-master/GolangJSHelpers && \
    npm install && sleep 10
RUN cd /root/work/medrec-master && \
    service mysql start && \
    sleep 5 && \
    mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('medrecpassword'); FLUSH PRIVILEGES;" && \
    mysql -u root < scripts/medrec-v1.sql && \
    mysql -u root < scripts/medrecWebApp.sql && \
    service mysql stop
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

#These does not work yet

CMD ["/root/work/medrec-master/medrec","EthereumClient","&"]
CMD ["/root/work/medrec-master/medrec","DatabaseManager","&"]
CMD ["/root/work/medrec-master/medrec","UserClient","&"]
