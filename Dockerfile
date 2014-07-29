FROM centos

MAINTAINER erickbrower

RUN sed -i.bak '/^\[base\]/a exclude=postgresql\*' /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i.bak '/^\[updates\]/a exclude=postgresql\*' /etc/yum.repos.d/CentOS-Base.repo 
RUN rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
RUN yum install -y proj proj-devel geos geos-devel postgresql93 postgresql93-server postgres93-libs postgres93-devel postgresql93-contrib
RUN service postgresql-9.3 initdb
RUN sed -i.bak -e '53d' /etc/init.d/postgresql-9.3
RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/9.3/data/pg_hba.conf
RUN echo "host    all             docker          0.0.0.0/0               trust" >> /var/lib/pgsql/9.3/data/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /var/lib/pgsql/9.3/data/postgresql.conf
RUN echo "port = 5432" >> /var/lib/pgsql/9.3/data/postgresql.conf
RUN touch /etc/sysconfig/network
RUN service postgresql-9.3 start && runuser -l postgres -c 'createuser -d -s -r -l docker' && runuser -l postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" && service postgresql-9.3 stop
RUN echo 'HOSTNAME=database' >> /etc/sysconfig/network

EXPOSE 5432

CMD ["/bin/su", "postgres", "-c", "/usr/pgsql-9.3/bin/postgres -D /var/lib/pgsql/9.3/data -c config_file=/var/lib/pgsql/9.3/data/postgresql.conf"]
