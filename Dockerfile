FROM frolvlad/alpine-oraclejdk8:8.161.12-slim
MAINTAINER Oleg Ilyenko

# generic
RUN apk --update add \
    bash \
    curl \
    jq \
    git \
    g++ \
    go \
    make \
    openssh \
    openssl \
    openssl-dev \
    gnupg \
    python \
    docker

ENV SBT_VERSION="1.1.4"
ENV SBT_FILENAME="sbt-${SBT_VERSION}.tgz"

# Sbt
RUN curl -L https://piccolo.link/${SBT_FILENAME} -o /tmp/${SBT_FILENAME} \
    && tar -zxvf /tmp/${SBT_FILENAME} -C /tmp \
    && mv /tmp/sbt /usr/lib/sbt \
    && ln -s /usr/lib/sbt/bin/sbt /bin/sbt

# GCE & Kube
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip -o google-cloud-sdk.zip \
    && unzip google-cloud-sdk.zip \
    && google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app kubectl alpha beta

ENV PATH $PATH:/google-cloud-sdk/bin

# We use old version of helm :(
ENV HELM_VERSION v2.6.1
ENV GIT_CRYPT_VERSION 0.5.0-2

ENV HELM_FILENAME="helm-${HELM_VERSION}-linux-amd64.tar.gz"

# git-crypt
RUN curl -L https://github.com/AGWA/git-crypt/archive/debian/$GIT_CRYPT_VERSION.tar.gz | tar zxv -C /var/tmp \
    && cd /var/tmp/git-crypt-debian-$GIT_CRYPT_VERSION && make && make install PREFIX=/usr/local

# Helm
RUN curl -L http://storage.googleapis.com/kubernetes-helm/${HELM_FILENAME} -o /tmp/${HELM_FILENAME} \
    && tar -zxvf /tmp/${HELM_FILENAME} -C /tmp \
    && mv /tmp/linux-amd64/helm /bin/helm

# Helpers
ADD bin bin-helpers
RUN chmod a+x bin-helpers/*
ENV PATH $PATH:/bin-helpers

# Cleanup uncessary files
RUN rm /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf google-cloud-sdk.zip

CMD ["/bin/bash"]