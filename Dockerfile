#--Environment
ARG ALPINE_VERSION=3.22.1
FROM alpine:${ALPINE_VERSION}
ARG IAMLIVE_VERSION=1.1.26
ARG JQ_VERSION=1.8.0-r0
ARG OPENSSL_VERSION=3.5.2-r0
ARG BASH_VERSION=5.2.37-r0

#--Install packages
RUN apk add --update --no-cache \
    jq==${JQ_VERSION} \
    bash==${BASH_VERSION} \
    openssl==${OPENSSL_VERSION}
RUN wget -q "https://github.com/iann0036/iamlive/releases/download/v${IAMLIVE_VERSION}/iamlive-v${IAMLIVE_VERSION}-linux-amd64.tar.gz" -O /tmp/iamlive.tar.gz
RUN tar -xf /tmp/iamlive.tar.gz -C /usr/local/bin
RUN rm /tmp/iamlive.tar.gz

#--Harden
WORKDIR /app
RUN addgroup -S "iamlive"
RUN adduser -S "iamlive" -G "iamlive"
RUN chown -R "iamlive:iamlive" .
USER "iamlive"

#--Expose
EXPOSE 10080 10081
COPY run.sh ./
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "./run.sh" ]
