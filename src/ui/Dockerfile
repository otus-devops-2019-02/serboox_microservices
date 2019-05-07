FROM alpine:3.9

LABEL maintainer="serboox@gmail.com" \
    version="1.0" \
    description="Homework №16"

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1

USER root

ADD . $APP_HOME
WORKDIR $APP_HOME

RUN mv ./root/gemrc /root/.gemrc && \
    apk update && \
    apk add ruby ruby-bigdecimal ruby-bundler ruby-io-console ruby-irb ruby-json  \
    \
    ca-certificates libressl less make gcc bash libc-dev && \
    \
    apk add --virtual build-dependencies build-base ruby-dev libressl-dev && \
    \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config git.allow_insecure true && \
    bundle install \
    && \
    gem cleanup && \
    apk del build-dependencies && \
    rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/* /tmp/* /var/tmp/*

CMD ["puma"]
