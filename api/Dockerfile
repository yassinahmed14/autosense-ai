FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    APP_ENV=production

WORKDIR /srv
COPY pyproject.toml README.md requirements.lock.txt ./
COPY src ./src
# The lock file pins versions as constraints; dev-only entries are simply not installed.
RUN pip install --no-cache-dir -c requirements.lock.txt .

USER 10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"
CMD ["uvicorn", "autosense_api.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
