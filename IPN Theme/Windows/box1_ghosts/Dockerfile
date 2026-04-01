FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# SSH for remote access (forced into PowerShell).
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
    && rm -rf /var/lib/apt/lists/*

# SSH daemon prep and PowerShell-only enforcement (loads hidden profile).
RUN mkdir -p /var/run/sshd \
    && sed -i 's@#PasswordAuthentication yes@PasswordAuthentication yes@' /etc/ssh/sshd_config \
    && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
    && echo 'ForceCommand /usr/bin/pwsh -NoLogo -NoProfile -NoExit -Command ". /opt/.ipn_profile/profile.ps1"' >> /etc/ssh/sshd_config \
    && echo 'AcceptEnv TERM' >> /etc/ssh/sshd_config

# Player account.
RUN useradd -m -s /usr/bin/pwsh windowsIPN1 \
    && echo 'windowsIPN1:windowsIPN1' | chpasswd

# Challenge content.
COPY .vault /home/windowsIPN1/.vault
COPY notes_from_admins.txt /home/windowsIPN1/notes_from_admins.txt
RUN chown -R windowsIPN1:windowsIPN1 /home/windowsIPN1

# Hidden profile location (outside user home).
RUN mkdir -p /opt/.ipn_profile
COPY profile_restricted.ps1 /opt/.ipn_profile/profile.ps1
RUN chmod 644 /opt/.ipn_profile/profile.ps1

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
