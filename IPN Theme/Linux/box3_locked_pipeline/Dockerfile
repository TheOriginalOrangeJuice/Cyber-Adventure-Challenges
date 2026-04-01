FROM ubuntu:22.04

# SSH for access and sudo for ownership/permission tasks.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd

# Primary linuxIPN3
RUN useradd -ms /bin/bash linuxIPN3 \
    && echo 'linuxIPN3:IPN{seaching_through_files_just_got_a_lot_easier}' | chpasswd \
    && useradd -m -s /usr/sbin/nologin salim_ghee

# Locked pipeline assets
RUN mkdir -p /home/linuxIPN3/ /usr/local/lib/.hidden_pipeline /usr/local/.hidden_secret
COPY decrypt_wrapper.sh /home/linuxIPN3/decrypt.sh
COPY encoded_payload.txt /usr/local/.hidden_secret/.encoded_payload
COPY getsecret.c /tmp/getsecret.c

# Build setuid helper to gate access to the payload and require piping.
RUN gcc /tmp/getsecret.c -o /usr/local/lib/.hidden_pipeline/getsecret \
    && chown root:root /usr/local/lib/.hidden_pipeline/getsecret \
    && chmod 4755 /usr/local/lib/.hidden_pipeline/getsecret \
    && rm /tmp/getsecret.c

# Make decrypt non-executable and owned by linuxIPN3 to force chmod+chown steps.
RUN chown linuxIPN3:linuxIPN3 /home/linuxIPN3/decrypt.sh \
    && chmod 640 /home/linuxIPN3/decrypt.sh \
    && chown root:root /usr/local/.hidden_secret/.encoded_payload \
    && chmod 600 /usr/local/.hidden_secret/.encoded_payload

# Allow chmod via sudo without password to let users toggle executability.
RUN echo 'ALL ALL=(ALL) NOPASSWD:/bin/chmod' > /etc/sudoers.d/chmod \
    && chmod 440 /etc/sudoers.d/chmod
RUN echo 'ALL ALL=(ALL) NOPASSWD:/bin/chown' > /etc/sudoers.d/chown \
    && chmod 440 /etc/sudoers.d/chown

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
