FROM python:3.11-slim

# Install cron, bash, and cronnext
RUN apt-get update \
    && apt-get install -y cron bash curl \
    && pip install cronnext \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables for script and schedule (with defaults)
ENV CRON_SCHEDULE="0 * * * *" \
    SCRIPT_PATH="/app/script.sh"

# Entrypoint will set up the cron job and start cron
ENTRYPOINT ["/entrypoint.sh"] 