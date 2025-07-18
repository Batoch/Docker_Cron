# Docker Cron Runner

This setup allows you to run any script on a configurable schedule using Docker and cron.

## Usage

1. **Place your script** (e.g., `script.sh`) in the project directory.
   - Make sure it is executable: `chmod +x script.sh`

2. **Build and run with Docker Compose:**

```sh
docker-compose up --build
```

3. **Configuration:**
   - By default, the script runs every hour.
   - To change the schedule or script path, edit the `environment` section in `docker-compose.yml`:
     - `CRON_SCHEDULE`: Cron expression (e.g., `*/10 * * * *` for every 10 minutes)
     - `SCRIPT_PATH`: Path inside the container (default `/app/script.sh`)

4. **Logs:**
   - Output from your script will appear in the container logs and in `/var/log/cron.log` inside the container.

## Example `docker-compose.yml` override

```yaml
services:
  cronjob:
    environment:
      - CRON_SCHEDULE=*/5 * * * *
      - SCRIPT_PATH=/app/myscript.sh
    volumes:
      - ./myscript.sh:/app/myscript.sh:ro
``` 