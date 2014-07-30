FROM centos

MAINTAINER rogerfretwell

RUN sed -i.bak '/^\[base\]/a exclude=postgresql\*' /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i.bak '/^\[updates\]/a exclude=postgresql\*' /etc/yum.repos.d/CentOS-Base.repo 
RUN rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
RUN yum install -y proj proj-devel geos geos-devel postgresql93 postgresql93-server postgres93-libs postgres93-devel postgresql93-contrib
#RUN yum install -y initscripts
RUN /usr/pgsql-9.3/bin/postgresql93-setup initdb

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

#VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql/data"]
#RUN /usr/pgsql-9.3/bin/initdb -D /var/lib/postgresql/data
RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/9.3/data/pg_hba.conf
RUN echo "host    all             docker          0.0.0.0/0               trust" >> /var/lib/pgsql/9.3/data/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /var/lib/pgsql/9.3/data/postgresql.conf
RUN echo "port = 5432" >> /var/lib/pgsql/9.3/data/postgresql.conf

USER root
RUN /usr/pgsql-9.3/bin/pg_ctl start -D /var/lib/pgsql/9.3/data &&\
  runuser -l postgres -c 'createuser -d -s -r -l docker' &&\
  runuser -l postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" &&\
  runuser -l postgres -c "psql postgres -c \"CREATE extension postgis; create extension postgis_topology;\"" &&\
  /usr/pgsql-9.3/bin/pg_ctl stop

EXPOSE 5432
CMD ["/bin/su", "postgres", "-c", "/usr/pgsql-9.3/bin/postgres -D /var/lib/pgsql/9.3/data -c config_file=/var/lib/pgsql/9.3/data/postgresql.conf"]
