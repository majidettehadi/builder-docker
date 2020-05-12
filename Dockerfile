FROM majid7221/java:openjdk-8

# Useful tools 
# lftp, netcat, jq, python3-requests
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
        lftp \
        netcat \
        jq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* 

# ansible
ENV ANSIBLE_KEY 93C4A3FD7BB9C367
RUN set -ex \
    && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $ANSIBLE_KEY \
    && apt-get update \
    && apt-get install -y \
        ansible \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    && ansible --version

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
