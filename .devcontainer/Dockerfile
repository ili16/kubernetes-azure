# Dockerfile
FROM mcr.microsoft.com/devcontainers/universal:2

# Install Ansible via pipx (if necessary)
RUN apt-get update && \
    apt-get install -y python3-pip python3-venv && \
    pip3 install pipx && \
    pipx install ansible && \
    pipx install ansible-lint
