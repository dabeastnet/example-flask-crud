# wsgi.py – canonical entrypoint for Gunicorn
# Allows: gunicorn wsgi:app
from app import app