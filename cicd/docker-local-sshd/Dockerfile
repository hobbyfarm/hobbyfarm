FROM alpine:latest

RUN apk add --no-cache \
        jq \
        openssh

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
    && addgroup -g 1000 ubuntu \
    && adduser -u 1000 -G ubuntu -h /home/ubuntu -s /bin/sh -D ubuntu \
    && sed -i 's/ubuntu:!/ubuntu:/g' /etc/shadow

COPY stage/ /
COPY --chown=ubuntu:ubuntu stage-ubuntu/ /

RUN chmod 700 /home/ubuntu /home/ubuntu/.ssh \
    && chmod 600 /home/ubuntu/.ssh/authorized_keys

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
