# backend/gunicorn.conf.py

import os

# Basic configuration
bind = "0.0.0.0:8000"
workers = int(os.getenv("WORKERS", "3"))
worker_class = "uvicorn.workers.UvicornWorker"

# Timeout configuration to prevent worker timeout
timeout = int(os.getenv("WORKER_TIMEOUT", "300"))  # 5 minutes instead of 30s
keepalive = 10
graceful_timeout = 30

# Memory and performance
worker_connections = 1000
max_requests = 2000
max_requests_jitter = 100
preload_app = True

# Logging
accesslog = "-"
errorlog = "-"
loglevel = os.getenv("LOG_LEVEL", "info").lower()
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "dear_flutter_backend"

# Resource limits
worker_tmp_dir = "/dev/shm"  # Use tmpfs for worker files

# Restart workers after processing this many requests (prevents memory leaks)
max_requests = 1000
max_requests_jitter = 50

# Enable proper cleanup
def on_exit(server):
    """Clean up resources on exit"""
    # Add any cleanup logic here
    pass

def when_ready(server):
    """Log when server is ready"""
    server.log.info("Dear Flutter Backend server is ready. Listening on: %s", server.address)

def worker_int(worker):
    """Handle worker interruption gracefully"""
    worker.log.info("Worker received INT or QUIT signal")

def pre_fork(server, worker):
    """Before forking worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    """After forking worker"""
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def worker_abort(worker):
    """Handle worker abort"""
    worker.log.info("Worker aborted (pid: %s)", worker.pid)
