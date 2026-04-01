FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gobuster \
        nmap \
        openssh-server \
        iptables \
        nano \
        vim-tiny \
        less \
        curl \
        iproute2 \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Add the login user for the box and set credentials.
RUN useradd -ms /bin/bash hackRCC3 \
    && echo 'hackRCC3:hackRCC3' | chpasswd

# Provide the gobuster wordlist and mission readme to the user.
COPY wordlists/gobuster-500.txt /home/hackRCC3/500-files.txt

# Prepare SSH daemon and home permissions.
RUN mkdir -p /var/run/sshd /run/sshd \
    && chown -R hackRCC3:hackRCC3 /home/hackRCC3

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd","-D"]
