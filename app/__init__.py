from flask import Flask
from app.config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from werkzeug.middleware.proxy_fix import ProxyFix
import logging, sys

app = Flask(__name__)

app.config.from_object(Config)
#update configuration to enforce HTTPS cookies:
app.config.update(
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    PREFERRED_URL_SCHEME='https'
)
# Trust a single reverse proxy (the ALB). If you add Nginx in front, set x_* accordingly.
# Why: Without this, URLs, scheme (https), and client IPs can be wrong when sitting behind a proxy / ALB.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# ensures logs go to stdout/stderr (works well with CloudWatch):
if not app.debug:
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)

from app import routes, models
