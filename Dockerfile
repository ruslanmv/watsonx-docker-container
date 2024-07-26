# Base Image
FROM nvidia/cuda:12.0-devel-ubuntu22.04

# Environment Variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV POETRY_VERSION=1.5.1
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

# System Updates and Essential Packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    build-essential \
    python3-pip \
    python3.10 \
    python3.10-venv \
    python3-dev \
    nodejs \
    npm \
    libgl1-mesa-glx \
    libglib2.0-0 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment 
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Poetry (Using pip in the virtual environment)
RUN pip install poetry==${POETRY_VERSION}

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml poetry.lock ./

# Install Project Dependencies (Avoid creating a separate virtualenv)
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi 

# Copy Project Files
COPY . .

# Install JupyterLab and Elyra
RUN pip install --no-cache-dir jupyterlab elyra

# Install additional Python packages using requirements.txt
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Expose JupyterLab Port
EXPOSE 8888

# Start JupyterLab with Elyra on container launch
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root"]