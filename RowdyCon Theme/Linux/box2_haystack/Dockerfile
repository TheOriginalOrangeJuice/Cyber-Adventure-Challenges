FROM ubuntu:22.04

# SSH, sudo for privilege escalation tasks, cron for the timed flag drop, and e2fsprogs for chattr.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        cron \
        nano \
        e2fsprogs \
        coreutils \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd

# Player account with password and passwordless sudo (needed for chattr/ownership).
RUN useradd -ms /bin/bash linuxRCC2 \
    && echo 'linuxRCC2:RCC{how_did_you_read_this_if_it_was_hidden?}' | chpasswd

# Vault files and decoys
COPY vault/ /home/linuxRCC2/vault/
RUN chown -R linuxRCC2:linuxRCC2 /home/linuxRCC2/vault

# Cron job to reveal the flag once evidence is prepared.
COPY cron_check.sh /usr/local/bin/cron_check.sh
RUN chmod +x /usr/local/bin/cron_check.sh \
    && echo "* * * * * root /usr/local/bin/cron_check.sh" > /etc/cron.d/vault-flag \
    && chmod 600 /etc/cron.d/vault-flag

EXPOSE 22

# Start cron in the background, then keep sshd in the foreground.
CMD ["sh", "-c", "service cron start && /usr/sbin/sshd -D"]
