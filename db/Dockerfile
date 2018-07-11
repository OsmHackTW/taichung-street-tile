FROM postgres:10
RUN apt-get update && \
    apt-get install -y postgis postgresql-10-postgis-2.4 postgresql-10-pgrouting python-requests python-psycopg2 python-unicodecsv && \
    rm -rf /var/lib/apt/lists/*
ADD ./postgis.sql /docker-entrypoint-initdb.d
ADD ./process.py /process.py
