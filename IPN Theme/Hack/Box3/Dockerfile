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
RUN useradd -ms /bin/bash hackIPN3 \
    && echo 'hackIPN3:hackIPN3' | chpasswd

# Provide the gobuster wordlist and mission readme to the user.
COPY wordlists/gobuster-500.txt /home/hackIPN3/500-files.txt

# Prepare SSH daemon and home permissions.
RUN mkdir -p /var/run/sshd /run/sshd \
    && chown -R hackIPN3:hackIPN3 /home/hackIPN3

# Add egress guard to block internet scans while allowing lab traffic.
RUN cat > /usr/local/bin/egress-guard.sh <<'EOF' && chmod +x /usr/local/bin/egress-guard.sh
#!/bin/bash
set -euo pipefail
iptables -F OUTPUT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow private/lab ranges (including hackIPN3_net)
iptables -A OUTPUT -d 172.19.0.0/27 -j ACCEPT
# Allow local DNS stub if present
iptables -A OUTPUT -d 127.0.0.53 -j ACCEPT
# Drop everything else to prevent external gobuster scans
iptables -A OUTPUT -j DROP
exec /usr/sbin/sshd -D
EOF

RUN echo "/usr/local/bin/egress-guard.sh" > /etc/ssh/sshrc

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd","-D"]
