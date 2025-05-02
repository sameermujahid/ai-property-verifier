FROM python:3.9-slim

# Add build arguments for credentials
ARG DOCKER_USERNAME
ARG DOCKER_PASSWORD

# Set build arguments
ARG FLASK_VERSION=2.0.1
ARG WERKZEUG_VERSION=2.0.1

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    LOG_DIR=/app/logs \
    DOCKER_USERNAME=${DOCKER_USERNAME} \
    DOCKER_PASSWORD=${DOCKER_PASSWORD}

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    tesseract-ocr \
    tesseract-ocr-eng \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir flask==${FLASK_VERSION} werkzeug==${WERKZEUG_VERSION}

# Copy application code
COPY . .

# Create log directory
RUN mkdir -p /app/logs && chmod 777 /app/logs

# Expose port
EXPOSE 5000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
