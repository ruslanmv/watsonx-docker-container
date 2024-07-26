## Creating a Docker Container for IBM Watsonx.ai, Langchain, and Jupyter Notebook with Elyra Compatible with CUDA

### Introduction

In this blog post, we will walk you through the process of creating a Docker container that is compatible with IBM Watsonx.ai, Langchain, and Jupyter Notebook with Elyra, all while ensuring CUDA compatibility for GPU acceleration. This setup is perfect for those who need a powerful environment for AI and machine learning RAG tasks and pipelines automatizations.

### Prerequisites

Before we begin, make sure you have the following installed on your system:

- Docker
- NVIDIA Docker support for GPU usage

### Dockerfile Explained

Below is the Dockerfile we will use to build our Docker image. It includes best practices, CUDA compatibility, and the installation of JupyterLab with Elyra.

```Dockerfile
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
```

### requirements.txt

Here is the `requirements.txt` file based on the packages you specified:

```
python=^3.10
ipykernel=^6.29.5
python-dotenv=^1.0.1
pandas=^2.1.4
langchain=^0.2.6
langchain-openai=^0.1.14
langchain-core=^0.2.11
langchain-ibm=^0.1.8
langchain-community=^0.2.6
ibm-watson-machine-learning=^1.0.359
azure-search-documents=^11.4.0
azure-core=^1.30.2
azure-storage-blob=^12.20.0
sentence-transformers=^3.0.1
openai=^1.32.0
chromadb=0.5.3
pydantic=^2.8.0
gradio=^4.37.2
lxml=^5.2.2
camelot-py=^0.11.0
opencv-python=^4.10.0.84
ghostscript=^0.7
pdfminer-six=^20240706
```

### Building the Docker Image

To build the Docker image, run the following command in the directory containing your Dockerfile:

```bash
docker build -t my-jupyter-image .
```

### Running the Docker Container

To run the Docker container and expose JupyterLab, use the following command:

```bash
docker run --gpus all -it --rm -p 8888:8888 my-jupyter-image
```

The `--gpus all` flag ensures that the container can leverage your GPU for CUDA processing.

### Conclusion

By following these steps, you will have a Docker container that is set up with IBM Watsonx.ai, Langchain, and Jupyter Notebook with Elyra, all compatible with CUDA for GPU acceleration. This powerful environment will enable you to perform advanced AI and machine learning tasks efficiently.

Happy coding!