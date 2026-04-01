FROM ubuntu:22.04

# Base packages: SSH for access, sudo for privilege escalation if needed.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd

# User account
RUN useradd -ms /bin/bash linuxRCC1 \
    && echo 'linuxRCC1:linuxRCC1' | chpasswd

# Challenge content: folder with space in the name and a hidden note file.
RUN mkdir -p "/home/linuxRCC1/rcc_breach_note s"
COPY [".note_to_self.txt", "/home/linuxRCC1/rcc_breach_note s/.note_to_self.txt"]
RUN chown -R linuxRCC1:linuxRCC1 "/home/linuxRCC1/rcc_breach_note s"

EXPOSE 22

# Entrypoint: keep sshd in the foreground.
CMD ["/usr/sbin/sshd", "-D"]
