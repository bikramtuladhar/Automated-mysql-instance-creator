FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg netcat-traditional\
    lsb-release \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker repository
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Download and install shell2http
RUN wget https://github.com/msoap/shell2http/releases/download/v1.17.0/shell2http_1.17.0_linux_amd64.deb && \
    dpkg -i shell2http_1.17.0_linux_amd64.deb && \
    rm shell2http_1.17.0_linux_amd64.deb

expose 8081
# Default command (optional, adjust as needed)

CMD ["shell2http", "-host=0.0.0.0", "-port=8081", "-500", "-form", "/release_management", "/containers/release-db-mgmt.sh \"$v_jira_code\" \"$v_jira_number\" \"$v_delete\"", "/wait_for_it", "/containers/wait-for-it.sh \"$v_jira_code\" \"$v_jira_number\""]
