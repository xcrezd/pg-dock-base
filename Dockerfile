FROM postgres:9.6.3

RUN apt-get update
RUN apt-get install -y curl wget rsync openssh-server supervisor postgresql-plperl-9.6

#repmgr 3 install
RUN TEMP_DEB="$(mktemp)" && \
     wget -O "$TEMP_DEB" "http://atalia.postgresql.org/morgue/r/repmgr/repmgr-common_3.3.2-1.pgdg80%2b1_all.deb" && \
     dpkg -i "$TEMP_DEB" && rm -f "$TEMP_DEB" && \
     TEMP_DEB="$(mktemp)" && \
     wget -O "$TEMP_DEB" "http://atalia.postgresql.org/morgue/r/repmgr/postgresql-$PG_MAJOR-repmgr_3.3.2-1.pgdg80%2b1_amd64.deb" && \
     dpkg -i "$TEMP_DEB" && apt-get install -f && rm -f "$TEMP_DEB"

#wall-e install
RUN apt-get install -y python3-pip python3.4 lzop pv daemontools
RUN python3 -m pip install wal-e[aws]

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#daily job runner
RUN curl -L -o /usr/local/sbin/daily https://github.com/xcrezd/daily/releases/download/v0.1/daily
RUN chmod o+x /usr/local/sbin/daily

# for ssh server/client
RUN mkhomedir_helper postgres
RUN chsh postgres -s /bin/bash

ENV TERM xterm
ENV PGHOST localhost

# change postgres group & user id
RUN sed -i 's/999/5432/g' /etc/passwd
RUN sed -i 's/999/5432/g' /etc/group

# prepare folders for ssh
RUN mkdir -p /home/postgres/.ssh 
RUN touch /var/run/sshd.pid
RUN chown -R postgres:postgres /etc/ssh /home/postgres/.ssh /var/run/sshd.pid
RUN chmod g-w /home/postgres
RUN chmod 700 /home/postgres/.ssh

# dir for all configurations
WORKDIR /etc/scripts
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-pg-dock.sh
ENTRYPOINT ["docker-entrypoint-pg-dock.sh"]