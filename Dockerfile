# Base R image with Shiny Server
FROM rocker/shiny:4.3.1

# System dependencies for Python, pip, and build tools
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install required R packages (add more if needed)
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'caret', 'seqinr', 'ggplot2', 'lattice', 'reticulate'))"

# Set working directory inside the container
WORKDIR /srv/shiny-server/app

# Copy your entire app into the container
COPY . .

# Set up Python virtual environment
RUN python3 -m venv venv
ENV PATH="/srv/shiny-server/app/venv/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Ensure Shiny Server serves your app
EXPOSE 3838
CMD ["/usr/bin/shiny-server"]

