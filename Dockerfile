FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y fonts-liberation optipng gnupg libpoppler-cpp-dev libmagic-dev unpaper ghostscript icc-profiles-free qpdf liblept5 pngquant tesseract-ocr python3-setuptools python3-wheel
RUN mkdir -p /app/code /app/data/media /app/data/data /app/data/consume
RUN chown -R cloudron:cloudron /app
WORKDIR /app/code
RUN wget https://github.com/jonaswinkler/paperless-ng/releases/download/ng-0.9.11/paperless-ng-0.9.11.tar.xz && \
    tar -xf paperless-ng-0.9.11.tar.xz && \
    mv paperless-ng/* . && \
    rm -rf paperless-ng paperles-ng-0.9.11.tar.xz
RUN python3 -m pip install --upgrade pip
RUN pip3 install pybind11 && \
    pip3 install -r requirements.txt
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN python3 ./src/manage.py collectstatic --clear --no-input
COPY policy.xml /etc/ImageMagick-6
RUN ln -s /app/data/media /app/code/media && ln -s /app/data/data /app/code/data && ln -s /app/data/consume /app/code/consume
COPY paperless.conf /app/code/paperless.conf

EXPOSE 8000
