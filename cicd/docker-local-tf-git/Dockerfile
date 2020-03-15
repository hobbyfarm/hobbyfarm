FROM nginx:alpine

RUN apk add --no-cache \
        git \
        git-daemon \
        fcgiwrap \
        spawn-fcgi

RUN git config --system http.receivepack true \
    && git config --system http.uploadpack true \
    && mkdir -p /usr/local/share/git \
    && chown nginx:nginx /usr/local/share/git

COPY stage/ /
COPY --chown=nginx:nginx tf-module-fake /usr/local/share/tf-module-fake

USER nginx:nginx
RUN cd /usr/local/share/git \
    && mkdir tf-module-fake.git \
    && cd tf-module-fake.git \
    && git init --bare \
    && cd /usr/local/share/tf-module-fake \
    && git init \
    && git config user.email "fake-tf@hf.local" \
    && git config user.name "Fake TF" \
    && git remote add origin /usr/local/share/git/tf-module-fake.git \
    && git add --all \
    && git commit -m "initial" \
    && git push -f origin master
USER root:root

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
