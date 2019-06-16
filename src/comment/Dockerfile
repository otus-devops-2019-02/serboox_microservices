FROM alpine:3.9

LABEL maintainer="serboox@gmail.com" \
    version="1.0" \
    description="Homework №16"

ENV  APP_HOME /app
ENV  COMMENT_DATABASE_HOST post_db
ENV  COMMENT_DATABASE comments

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

EXPOSE 9292
CMD ["puma"]
