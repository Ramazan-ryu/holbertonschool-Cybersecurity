# SECURITY.md

## Architecture Overview

This project implements a **hardened container image** designed for secure web service hosting. Key features include:

- **Base Image**: Minimal Debian Slim to reduce attack surface.  
- **Non-root Execution**: Application runs under a dedicated `appuser` with UID/GID isolation.  
- **Services**:  
  - Web server: Apache2 or Nginx configured to serve content from `/var/www/html`.  
  - SSH server: OpenSSH for administrative access (non-root login enforced).  
- **Scripts**: Initialization scripts copied into `/opt/scripts` with executable permissions.  
- **Container Interaction**:  
  - HEALTHCHECK pings the local web server and SSH port 22.  
  - Exposed ports: 80 (HTTP) and 22 (SSH) only.  
- **Labels and Metadata**: `LABEL maintainer="SecOps Team" version="1.0"` for traceability.  

## Security Controls

Implemented hardening measures include:

- **Identity & Access**:  
  - Password complexity enforced via `pam_pwquality` (minlen=12, ucredit=-1, lcredit=-1, dcredit=-1).  
  - SSH configuration: `PermitRootLogin no`, `PasswordAuthentication no`, `X11Forwarding no`.  
  - Root account locked (`usermod -L root`) and idle session timeout configured.  
  - Account lockout with `pam_faillock` (deny=5, unlock_time=900).  

- **Service Hardening**:  
  - Only web and SSH services are enabled; unused services disabled.  
  - Health checks ensure web server responds to HTTP and SSH listens on port 22.  
  - Web server runs under non-privileged user (`www-data`).  

- **Filesystem & Package Security**:  
  - Scripts and configuration files set to restrictive permissions (e.g., 0640 for config files, 0755 for scripts).  
  - Critical packages blacklisted from auto-upgrades (`apache2`, `mysql-server`).  

- **Container Runtime Options**:  
  - Non-root user with UID/GID isolation.  
  - Healthcheck configured for automated monitoring.  
  - Minimal installed packages to reduce attack surface (<500MB image).  

## Usage Instructions

1. **Build the container**:  
   ```bash
   docker build -t novatech-hardened-web:1.0 .
