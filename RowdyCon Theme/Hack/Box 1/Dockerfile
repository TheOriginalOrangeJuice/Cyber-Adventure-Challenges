# Box 1: Network recon target with SSH entrypoint and nmap tooling
# Intended to run on the hack_rcc1_net bridge (172.18.0.0/27) alongside scout containers (--network=hack_rcc1_net)
# docker run -it -p 2222:22 --cap-add=NET_RAW --cap-add=NET_ADMIN --network=hack_rcc1_net hack1:latest

# Answer: IP_ServiceName_Port_Protocol: 172.18.0.9_rcc-backdoor_35567_tcp
FROM ubuntu:22.04

# Install SSH server, nmap, and a few common networking utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        nmap \
        sudo \
        iproute2 \
        iputils-ping \
        netcat-openbsd \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Prepare SSH server
RUN mkdir -p /var/run/sshd

# Create user account for SSH access
RUN useradd -ms /bin/bash hackRCC1 \
    && echo 'hackRCC1:hackRCC1' | chpasswd \
    && sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config


# Allow Sudo to run
RUN echo 'ALL ALL=(ALL) NOPASSWD:/bin/nmap' > /etc/sudoers.d/nmap \
    && chmod 440 /etc/sudoers.d/nmap

# Add custom service entry for the exercise
RUN printf 'rcc-backdoor\t35567/tcp\n' >> /etc/services \
        && echo 'rcc-backdoor 35567/tcp 0.00' >> /usr/share/nmap/nmap-services
#RUN printf 'rcc-backdoor  35567/tcp' >> /etc/services

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
