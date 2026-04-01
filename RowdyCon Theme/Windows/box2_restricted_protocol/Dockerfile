FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# SSH for remote access (forced into PowerShell).
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        gcc \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# SSH daemon prep and PowerShell-only enforcement (loads hidden profile).
RUN mkdir -p /var/run/sshd \
    && sed -i 's@#PasswordAuthentication yes@PasswordAuthentication yes@' /etc/ssh/sshd_config \
    && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
    && echo 'ForceCommand /usr/bin/pwsh -NoLogo -NoProfile -NoExit -Command ". /opt/.rcc_profile/profile.ps1"' >> /etc/ssh/sshd_config \
    && echo 'AcceptEnv TERM' >> /etc/ssh/sshd_config

# Player account; password is the flag from Box 1.
RUN useradd -m -s /usr/bin/pwsh windowsRCC2 \
    && echo 'windowsRCC2:RCC{38.13.218.70_ke_yang}' | chpasswd

# Challenge assets.
COPY decrypt_comms.ps1 .how_to_powershell.txt powershell-wrapper.sh /home/windowsRCC2/
RUN mkdir -p /opt/.rcc_profile
COPY profile_restricted.ps1 /opt/.rcc_profile/profile.ps1
RUN echo 'FiYgSzIMNg1uME4gABFDOyQmDW49TjA6CkQZ' | base64 -d > /opt/.rcc_profile/.comms.dat \
    && chown root:root /opt/.rcc_profile/.comms.dat /opt/.rcc_profile/profile.ps1 \
    && chmod 640 /opt/.rcc_profile/.comms.dat \
    && chmod 644 /opt/.rcc_profile/profile.ps1 \
    && chmod 751 /opt/.rcc_profile
COPY get_payload.c /tmp/get_payload.c
RUN gcc /tmp/get_payload.c -o /usr/local/bin/get_payload \
    && chown root:root /usr/local/bin/get_payload \
    && chmod 4755 /usr/local/bin/get_payload \
    && rm /tmp/get_payload.c
RUN install -m 755 /home/windowsRCC2/powershell-wrapper.sh /usr/local/bin/powershell \
    && chown -R windowsRCC2:windowsRCC2 /home/windowsRCC2 \
    && chmod +x /home/windowsRCC2/decrypt_comms.ps1 \
    && rm /home/windowsRCC2/powershell-wrapper.sh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]


#Remove Briefing
