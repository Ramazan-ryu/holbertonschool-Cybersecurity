# =========================================
# Hardened NovaTech Container Image
# =========================================
FROM debian:12-slim

# --------------------------
# Metadata
# --------------------------
LABEL maintainer="NovaTech Security Team <security@novatech.com>"
LABEL version="1.0"
LABEL description="Hardened container with Apache, SSH, and remediation scripts"

# --------------------------
# Environment
# --------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    APP_USER=novatech \
    APP_HOME=/home/novatech

# --------------------------
# System Preparation
# --------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# --------------------------
# Create non-root user
# --------------------------
RUN useradd -m -d $APP_HOME -s /bin/bash $APP_USER \
    && mkdir -p /var/run/sshd \
    && chown -R $APP_USER:$APP_USER $APP_HOME

# --------------------------
# Copy scripts and make executable
# --------------------------
COPY scripts /opt/scripts
RUN chmod -R a+x /opt/scripts

# --------------------------
# Configure SSH securely
# --------------------------
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && mkdir -p $APP_HOME/.ssh && chown -R $APP_USER:$APP_USER $APP_HOME/.ssh

# --------------------------
# Configure Apache
# --------------------------
RUN mkdir -p /var/www/html && chown -R $APP_USER:$APP_USER /var/www/html

# --------------------------
# Expose ports
# --------------------------
EXPOSE 80 22

# --------------------------
# Healthcheck
# --------------------------
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# --------------------------
# Entrypoint
# --------------------------
USER $APP_USER
WORKDIR $APP_HOME
CMD ["bash"]
