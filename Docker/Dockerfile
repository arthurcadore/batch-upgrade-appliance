# Use the official alpine image as a base:
FROM alpine:3.19.1

# Download and install TFTP server:
RUN apk add --no-cache tftp-hpa supervisor

# Create a directory to store the files:
RUN mkdir -p /tftpshare

RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d
COPY ./Docker/supervisord-TFTP.conf /etc/supervisord.conf

COPY ./Docker/startup-TFTP.sh /etc/startup.sh
RUN chmod +x /etc/startup.sh


# Start the TFTP server and keep it running:
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
