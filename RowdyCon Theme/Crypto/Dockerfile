FROM debian:bookworm-slim

# Install sshd and bash, then clean up apt cache to keep the image lean.
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssh-server bash \
  && rm -rf /var/lib/apt/lists/*

# Copy the challenge shells into place.
WORKDIR /opt/crypt
COPY crypt1.sh crypt2.sh crypt3.sh crypt4.sh ./
RUN chmod 755 /opt/crypt/crypt*.sh

# Allow these scripts to be used as login shells.
RUN printf '/opt/crypt/crypt1.sh\n/opt/crypt/crypt2.sh\n/opt/crypt/crypt3.sh\n/opt/crypt/crypt4.sh\n' >> /etc/shells

# Create users mapped to their respective shells with the requested passwords.
RUN useradd -m -s /opt/crypt/crypt1.sh cryptRCC1 \
  && useradd -m -s /opt/crypt/crypt2.sh cryptRCC2 \
  && useradd -m -s /opt/crypt/crypt3.sh cryptRCC3 \
  && useradd -m -s /opt/crypt/crypt4.sh cryptRCC4 \
  && echo 'cryptRCC1:cryptRCC1' | chpasswd \
  && echo 'cryptRCC2:RCC{The_foundations_are_the_most_important!}' | chpasswd \
  && echo 'cryptRCC3:RCC{Cyber_is_so_based}' | chpasswd \
  && echo 'cryptRCC4:RCC{Go_secure_your_web_apps_or_hack_them!}' | chpasswd

# Setup SSH daemon.
RUN mkdir -p /var/run/sshd

EXPOSE 22

# Start sshd in the foreground.
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
