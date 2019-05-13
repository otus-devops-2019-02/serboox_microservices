FROM python:3.6.0-alpine

LABEL maintainer="serboox@gmail.com" \
    version="1.0" \
    description="Homework №16"

ENV  POST_DATABASE_HOST post_db
ENV  POST_DATABASE posts

WORKDIR /app
COPY . /app

RUN apk add --no-cache build-base &&\
    pip install --upgrade pip &&\
    pip install -r /app/requirements.txt &&\
    apk del build-base

ENTRYPOINT ["python3", "post_app.py"]
