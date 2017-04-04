FROM python:2.7
RUN apt-get update && \
    apt-get install -y libgeos-dev libpq-dev && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /
RUN git clone --recursive https://github.com/hotosm/osm-tasking-manager2.git osmtm
WORKDIR /osmtm
RUN pip install uwsgi
RUN pip install -r requirements.txt
RUN python setup.py compile_catalog
ADD local.ini /osmtm
ADD uwsgi.ini /
EXPOSE 80
CMD ["uwsgi", "/uwsgi.ini"]
