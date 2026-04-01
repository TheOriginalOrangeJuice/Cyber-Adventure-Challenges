#We need to make sure to install opencl intel-oneapi-runtime-opencl

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        john \
        john-data \
        hashcat \
        ocl-icd-libopencl1 \
        pocl-opencl-icd \
        python3 \
        nano \
        vim-tiny \
        less \
        openssh-server \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Add the non-sudo login user used to access the box (not part of cracking).
RUN useradd -ms /bin/bash hackRCC2 \
    && echo 'hackRCC2:hackRCC2' | chpasswd

# Copy prebuilt wordlists from the build context into the container and set permissions.
COPY wordlists/ /home/hackRCC2/wordlists/
RUN chown -R hackRCC2:hackRCC2 /home/hackRCC2/wordlists && chmod -R a+r /home/hackRCC2/wordlists

# Copy hashcat rules into the login user's home for convenience.
RUN cp -r /usr/share/hashcat/rules/ /home/hackRCC2/ \
    && chown -R hackRCC2:hackRCC2 /home/hackRCC2/rules

# Add user accounts with 4-3-2-1 distribution across hash types ($1$, $2b$, $5$, and $6$). Make /etc/shadowers world-readable.
RUN set -eux; \
    cat > /tmp/user_hashes <<'EOF'
maanasa_baskar $1$so6X2x/n$yfHE9pftv7EcbPV/EI2fO1
elisha_szeto $1$E2WKf9Wq$95TI2tW52x0kGV6MOByEd.
joaquin $1$krzCIcwv$RijkWeuMIQP5PHr2r3rpR/
joshua_silva $1$tyVhunr4$yB0FpulbPhoxkz1NkucYL0
vian_chen $2b$12$Lh3DY1.xJ383OzvZrw5pseqOTpwReo6a8NO2f8a3cLGHM1abjeQnS
curran_hill $2b$12$RzA3MYlsW5ivxRPbeuzGcei2HFUu1GWPtZCwj5MhpEX/sKqBcWcAy
blessy $2b$12$3NGNmWfVbTgEtnA1hY34MeXZfqNtV01LToVwhzs/RLGddaRmk/WYW
daniel_ruiz $5$14QDpzc52pKWV6J6$6rmEU26.VDSgnxDXMACEHuzvApzm5UxWJ2yQKHP5d./
josie_sauceda $5$ILlXhzmNuUQPx85Q$hn/c7.LqXB6VL8pfMgjnz2mHMsCNVuwtm5SjE.pJPn3
judith_infante $6$x7wtVXHHmQOOu4.c$7slNcxl75SkQlpUQFMm4uZWQiDyrBrvAKPw9vun1lUJAdvBI/v8qfapVMXr2EHnYDG8enHttjjyWPFJ80sPVB.
EOF

RUN set -eux; \
    while read -r user hash; do \
        useradd -m -s /bin/bash -p "$hash" "$user"; \
    done < /tmp/user_hashes; \
    chmod 644 /etc/shadow; \
    rm /tmp/user_hashes; \
    mkdir -p /run/sshd


EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd","-D"]
