FROM majid7221/java:openjdk-8

# Useful tools 
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
        g++ \
        gcc \
        jq \
        lftp \
        libc6-dev \
        make \
        netcat \
        pkg-config \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* 

# Ansible (latest)
ENV ANSIBLE_KEY 93C4A3FD7BB9C367
RUN set -ex \
    && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $ANSIBLE_KEY \
    && apt-get update \
    && apt-get install -y \
        ansible \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    && ansible --version

# Golang 14
ENV GOLANG_VERSION 1.14.3
ENV Sha256 1c39eac4ae95781b066c144c58e45d6859652247f7515f0d2cba7be7d57d2226
RUN set -ex \
	&& url="https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" \
	&& wget -O go.tgz "$url" \
	&& echo "${Sha256} *go.tgz" | sha256sum -c - \
	&& tar -C /usr/local -xzf go.tgz \
	&& rm go.tgz \
	&& export PATH="/usr/local/go/bin:$PATH" \
	&& go version 

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Node 10
ENV NODE_VERSION 10.20.1
RUN set -ex \
    && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Yarn 1.22
ENV YARN_VERSION 1.22.4
RUN set -ex \
    && curl -fSLO --compressed "http://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && mkdir -p /opt \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz

# OpenSSH
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
        openssh-server \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    && mkdir /var/run/sshd \
    # SSH login fix. Otherwise user is kicked off after login
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY files/authorized_keys /root/.ssh/authorized_keys
EXPOSE 22

WORKDIR /root/jenkins
VOLUME [ "/root/jenkins" ]

CMD ["/usr/sbin/sshd", "-D"]
