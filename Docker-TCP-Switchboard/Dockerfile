FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir docker Twisted service_identity

COPY docker-tcp-switchboard.py /app/docker-tcp-switchboard.py

ENTRYPOINT ["python", "/app/docker-tcp-switchboard.py"]
CMD ["/config/docker-tcp-switchboard.conf"]
