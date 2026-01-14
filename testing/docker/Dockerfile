FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install SSH server and testing tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    tmux \
    vim \
    curl \
    python3 \
    locales \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /run/sshd

# Set up locale for UTF-8 support
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create test user with password authentication
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser:testpass" | chpasswd

# Configure SSH for password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Copy test scripts
COPY test-scripts/ /home/testuser/test-scripts/
RUN chmod +x /home/testuser/test-scripts/*.sh \
    && chown -R testuser:testuser /home/testuser/test-scripts

# Configure tmux for extended-keys (needed for Shift+Enter in tmux)
RUN echo "set -g extended-keys always" > /home/testuser/.tmux.conf \
    && chown testuser:testuser /home/testuser/.tmux.conf

# Set TERM for proper terminal support
ENV TERM=xterm-256color

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
