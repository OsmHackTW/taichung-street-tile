FROM postgres:9.6
RUN sed -i 's/httpredir/ftp.tw/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y postgis postgresql-9.6-postgis-2.3 postgresql-9.6-pgrouting python-requests python-psycopg2 python-unicodecsv && \
    rm -rf /var/lib/apt/lists/*
ADD ./postgis.sql /docker-entrypoint-initdb.d
ADD ./process.py /process.py
