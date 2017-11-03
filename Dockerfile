FROM node:6-alpine

ARG KRESUS_VERSION=master
ENV UID=991 GID=991 \
    KRESUS_DIR=/kresus/data \
    HOST=0.0.0.0

COPY rootfs /

RUN apk -U upgrade \
    && apk add -t build-dependencies \
       git \
       build-base \
       g++ \
       gcc \
       python-dev \
       libffi-dev \
       libxml2-dev \
       libxslt-dev \
       yaml-dev \
       tiff-dev \
       jpeg-dev \
       zlib-dev \
    && apk add python \
       libffi \
       libxml2 \
       libxslt \
       yaml \
       tiff \
       jpeg \
       zlib \
       wget \
       su-exec \
       bash \
       gnupg \
    && cd /tmp \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python ./get-pip.py \
    && pip install -U setuptools \
    && pip install html2text simplejson BeautifulSoup PyExecJS \
    && git clone https://git.weboob.org/weboob/devel /tmp/weboob \
    && cd /tmp/weboob \
    && python ./setup.py install \
    && mkdir -p /kresus/data \
    && mkdir -p /kresus/app \
    && cd /tmp \
    && git clone https://framagit.org/bnjbvr/kresus.git kresus/ \
    && cd /tmp/kresus \
    && git checkout $KRESUS_VERSION \
    && cp -rf /kresus-scripts/* ./ \
    && chmod +x /tmp/kresus/scripts/release.sh \
    && make release \
    && cp -r /tmp/kresus/build/ /kresus/app \
    && cp -r /tmp/kresus/bin /kresus/app \
    && cp -r /tmp/kresus/package.json /kresus/ \
    && cd /kresus \
    && mkdir .cache \
    && npm install --production \
    && chmod +x /usr/local/bin/startup \
    && ln -s /kresus/ /home/kresus \
    && apk del build-dependencies \
    && rm -rf /kresus-scripts /var/cache/apk/* /tmp/* /root/.gnupg /root/.cache/ 

VOLUME /kresus/data

EXPOSE 9876
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["node", "/kresus/app/bin/kresus.js"]
