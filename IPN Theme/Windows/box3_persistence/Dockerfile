FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# docker run -it -p 2222:22 -v ./IPN_SUMMIT_DATA:/mnt/ipn_summit_data:ro win3:latest

# SSH for access, cron to simulate scheduled tasks.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server \
        cron \
    && rm -rf /var/lib/apt/lists/*

# SSH daemon prep and PowerShell-only enforcement (loads hidden profile).
RUN mkdir -p /var/run/sshd \
    && sed -i 's@#PasswordAuthentication yes@PasswordAuthentication yes@' /etc/ssh/sshd_config \
    && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
    && echo 'ForceCommand /usr/bin/pwsh -NoLogo -NoProfile -NoExit -Command ". /opt/.ipn_profile/profile.ps1"' >> /etc/ssh/sshd_config \
    && echo 'AcceptEnv TERM' >> /etc/ssh/sshd_config

# Player account; password is the flag from Box 2.
RUN useradd -m -s /usr/bin/pwsh windowsIPN3 \
    && echo 'windowsIPN3:IPN{execution_policy_bypassed}' | chpasswd

# Evidence setup and task state location. Evidence is expected to be mounted read-only from the host at /mnt/ipn_summit_data.
RUN mkdir -p /mnt/ipn_summit_data /home/windowsIPN3/Documents /opt/task_flags \
    && ln -s /mnt/ipn_summit_data /home/windowsIPN3/Evidence

# Simulated scheduled task scripts and profile helpers.
COPY scripts/wipe_exfil.sh /usr/local/bin/wipe_exfil.sh
COPY scripts/watch_exfil.sh /usr/local/bin/watch_exfil.sh
RUN mkdir -p /opt/.ipn_profile
COPY profile.ps1 /opt/.ipn_profile/profile.ps1
COPY mission.txt /home/windowsIPN3/mission.txt

RUN chmod +x /usr/local/bin/wipe_exfil.sh /usr/local/bin/watch_exfil.sh \
    && echo "* * * * * root /usr/local/bin/wipe_exfil.sh" > /etc/cron.d/wipe-exfil \
    && echo "* * * * * root /usr/local/bin/watch_exfil.sh" > /etc/cron.d/watch-exfil \
    && chmod 600 /etc/cron.d/wipe-exfil /etc/cron.d/watch-exfil \
    && chown -R windowsIPN3:windowsIPN3 /home/windowsIPN3 \
    && chown windowsIPN3:windowsIPN3 /opt/task_flags \
    && chmod 700 /opt/task_flags \
    && chmod 644 /opt/.ipn_profile/profile.ps1

EXPOSE 22

CMD ["sh", "-c", "service cron start && /usr/sbin/sshd -D"]
