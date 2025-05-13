# Base image: R with Shiny Server
FROM rocker/shiny:4.3.1

# System dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    libcurl4-openssl-dev libssl-dev libxml2-dev git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create and activate Python virtualenv
WORKDIR /opt/venv
RUN python3 -m venv . && \
    . bin/activate && \
    pip install --upgrade pip

# Install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN . bin/activate && pip install -r /tmp/requirements.txt

# Set reticulate environment variable
ENV RETICULATE_PYTHON=/opt/venv/bin/python

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'seqinr', 'caret', 'ggplot2', 'lattice', 'markdown', 'reticulate'), repos='http://cran.rstudio.com/')"

# Set working directory and copy app files
WORKDIR /srv/shiny-server/
COPY . .

# Expose Shiny default port
EXPOSE 3838

# Start Shiny server
CMD ["/usr/bin/shiny-server"]
