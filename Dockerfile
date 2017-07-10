FROM postgres:9.6.3

RUN apt-get update
RUN apt-get install -y curl repmgr rsync openssh-server supervisor postgresql-plperl-9.6
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# for ssh server/client
RUN mkhomedir_helper postgres
RUN chsh postgres -s /bin/bash

ENV TERM xterm

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