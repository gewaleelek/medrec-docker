FROM node:9.9-stretch

ENV http_proxy=$HTTP_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV PAT=$PAT

RUN echo '//npm.pkg.github.com/:_authToken='$PAT >> /root/.npmrc && \
	echo 'Acquire::http::Proxy "'$http_proxy'";' >> /etc/apt/apt.conf && \
    echo 'deb http://archive.debian.org/debian stretch main non-free-firmware non-free contrib' > /etc/apt/sources.list && \
	apt-get update -q --allow-unauthenticated && \ 
	apt-get install -q -y apt-transport-https debian-archive-keyring ca-certificates --allow-unauthenticated
RUN apt-get update -q && \
	apt-get install -q -y unzip mariadb-server libxtst-dev libxss-dev libgconf2-dev libnss3-dev libasound2-dev 
	
RUN wget -q https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
	tar -xf /tmp/go.tar.gz -C /tmp && rm /tmp/go.tar.gz && \
	mv /tmp/go /usr/local
RUN git config --global http.proxy $HTTP_PROXY && \
	git config --global https.proxy $HTTP_PROXY
ENV GOPATH=/root/work
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
RUN mkdir /root/work && \
	cd /root/work && \
	wget -q https://github.com/mitmedialab/medrec/archive/refs/heads/master.zip -O /tmp/medrec.zip && \
	unzip /tmp/medrec.zip

WORKDIR /root/work/medrec-master

# Various fixes
# COPY copy/main.go main.go
RUN sed -i 's/\.\.\/common/DatabaseManager\/common/g' DatabaseManager/remoteRPC/ethereum_test.go && \
	sed -i 's/\.\.\/localRPC/DatabaseManager\/localRPC/g' DatabaseManager/remoteRPC/ethereum_test.go && \
	sed -i 's/github:ahultgren\/async-eventemitter#fa06e39e56786ba541c180061dbf2c0a5bbf951c/0.2.4/g' UserClient/package-lock.json && \
	sed -i 's/git:\/\/github\.com\/frozeman\/WebSocket-Node\.git#7004c39c42ac98875ab61126e5b4a925430f592c/1.0.35/g' UserClient/package-lock.json 
	
RUN go mod init github.com/mitmedialab/medrec && \
	go get github.com/ethereum/go-ethereum && \
	go mod tidy && \
	go build -v

# Warning! This takes a long time
RUN cd UserClient && \
	npm install --loglevel verbose && \
	npm run build --loglevel verbose

# RUN ls -la UserClient/node_modules/electron-prebuilt/ && sleep 20 

RUN cd GolangJSHelpers && \
	npm install --loglevel verbose

# RUN ls -la UserClient/node_modules/electron-prebuilt/ && sleep 20 
	
RUN cd scripts && \
	service mysql start && \
	sleep 5 && \
	mysql -u root -e "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND host = 'localhost'" && \
	mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('medrecpassword'); FLUSH PRIVILEGES;" && \
	mysql -u root < medrec-v1.sql && \
	mysql -u root < medrecWebApp.sql && \
	service mysql stop

# RUN ls -la UserClient/node_modules/electron-prebuilt/ && sleep 20 

WORKDIR /
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

#These does not work yet

# CMD ["/root/work/medrec-master/medrec","EthereumClient","&"]
# CMD ["/root/work/medrec-master/medrec","DatabaseManager","&"]
# CMD ["/root/work/medrec-master/medrec","UserClient","&"]

# intentionally hangs the build so we can inspect the container
 RUN tail -f /dev/null
