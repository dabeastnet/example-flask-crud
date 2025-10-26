FROM python:3.10-slim
# Avoid creating .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app \
    PYTHONPATH=/app

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Install system libraries required 
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Expose the port that Gunicorn will listen on
EXPOSE 80

# Run database migrations and then start Gunicorn
# If no migrations are present or the database is empty, the upgrade command will no-op.
# Note: DATABASE_URL must be provided at runtime via the ECS task definition.
# Optional: only run migrations when RUN_MIGRATIONS=true
# CMD bash -lc '[ "${RUN_MIGRATIONS:-false}" != "true" ] || flask db upgrade || true; \
#   exec gunicorn -w ${GUNICORN_WORKERS:-4} -b 0.0.0.0:80 --access-logfile=- --error-logfile=- wsgi:app'
CMD ["bash","-lc","\
if [ \"${RUN_MIGRATIONS:-false}\" = true ]; then \
  if [ -d migrations ]; then flask db upgrade; else echo 'No migrations/ folder; skipping upgrade'; fi; \
fi; \
exec gunicorn -w ${GUNICORN_WORKERS:-4} -b 0.0.0.0:80 --access-logfile=- --error-logfile=- wsgi:app"]
