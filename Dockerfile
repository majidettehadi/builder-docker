FROM majid7221/java:openjdk-8

# lftp
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
        lftp \
        netcat \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* 

# ansible
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
        ansible \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* 

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
