FROM node:10-stretch

RUN echo "deb http://ftp.tw.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y libmapnik3.0 mapnik-utils \
    fonts-noto-cjk libgeos-dev libgdal-dev libproj12 \
    python-pip python-imaging python-yaml python-shapely \
    uwsgi uwsgi-plugin-python && \
    rm -rf /var/lib/apt/lists/*
RUN pip install MapProxy==1.11.0
RUN npm install -g carto
ADD project.mml /
ADD mapproxy.yaml /
ADD style.mss /
ADD wsgi.py /
ADD uwsgi.ini /
RUN carto /project.mml > /mapnik.xml
CMD uwsgi /uwsgi.ini
