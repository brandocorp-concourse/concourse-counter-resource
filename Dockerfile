FROM alpine:latest

RUN apk update  \
  && apk add bash coreutils curl jq make

ADD assets /opt/resource
RUN chmod +x /opt/resource/*
