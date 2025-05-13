FROM rocker/shiny:4.3.1

# Install Python 3.9 and dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.9 \
        python3.9-dev \
        python3.9-venv \
        curl \
        git \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Python 3.9 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Create virtual environment and install Python packages
WORKDIR /opt/venv
RUN python3 -m venv . && \
    . bin/activate && \
    pip install --upgrade pip && \
    pip install wheel && \
    pip install -r /tmp/requirements.txt

# Copy requirements after env is ready (to leverage Docker cache)
COPY requirements.txt /tmp/requirements.txt

# Copy your app code
COPY . /srv/shiny-server/

# Expose default Shiny port
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
