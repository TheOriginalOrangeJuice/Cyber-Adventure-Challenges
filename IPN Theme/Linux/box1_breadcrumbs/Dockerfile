FROM ubuntu:22.04

# Base packages: SSH for access, sudo for privilege escalation if needed.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd

# User Account account 
RUN useradd -ms /bin/bash linuxIPN1 \
    && echo 'linuxIPN1:linuxIPN1' | chpasswd

# Challenge content: folder with space in the name and a hidden note file.
RUN mkdir -p "/home/linuxIPN1/ipn_breach_note s"
COPY [".note_to_self.txt", "/home/linuxIPN1/ipn_breach_note s/.note_to_self.txt"]
RUN chown -R linuxIPN1:linuxIPN1 "/home/linuxIPN1/ipn_breach_note s"

EXPOSE 22

# Entrypoint: keep sshd in the foreground.
CMD ["/usr/sbin/sshd", "-D"]
