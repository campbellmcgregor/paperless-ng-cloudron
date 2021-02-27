FROM cloudron/base:3.0.0@sha256:455c70428723e3a823198c57472785437eb6eab082e79b3ff04ea584faf46e92

EXPOSE 8000

ENV VERSION="1.2.1"

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y fonts-liberation optipng gnupg libpoppler-cpp-dev libmagic-dev unpaper ghostscript icc-profiles-free qpdf liblept5 pngquant tesseract-ocr python3-setuptools python3-wheel libxml2 zlib1g
RUN mkdir -p /app/code /app/data/media/documents/originals /app/data/media/documents/thumbnails /app/data/data /app/data/consume && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN chown -R cloudron:cloudron /app
WORKDIR /app/code
RUN wget https://github.com/jonaswinkler/paperless-ng/releases/download/ng-${VERSION}/paperless-ng-${VERSION}.tar.xz && \
    tar -xf paperless-ng-${VERSION}.tar.xz && \
    mv paperless-ng/* . && \
    rm -rf paperless-ng && \
    rm -f paperles-ng-${VERSION}.tar.xz

#fixes error for uninstall of pyyaml
#RUN pip3 uninstall pyyaml

RUN python3 -m pip install --upgrade pip
RUN pip3 install -r requirements.txt --ignore-installed pyyaml
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN python3 ./src/manage.py collectstatic --clear --no-input
COPY policy.xml /etc/ImageMagick-6
RUN rm -fr /app/code/data
RUN ln -s /app/data/media /app/code/media && ln -s /app/data/data /app/code/data && ln -s /app/data/consume /app/code/consume
COPY paperless.conf.setup /app/code/paperless.conf.setup
ADD supervisor/* /etc/supervisor/conf.d/
RUN ln -sf /run/paperless/supervisord.log /var/log/supervisor/supervisord.log && ln -sf /app/data/paperless.conf /app/code/paperless.conf
ADD start.sh /app/code/
RUN chmod +x /app/code/start.sh 

CMD [ "/app/code/start.sh" ]