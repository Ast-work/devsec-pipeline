FROM python:3.11.16-slim

WORKDIR /app

RUN apt-get update \
    && apt-get upgrade -y \
    && python -m pip install --upgrade \
        setuptools \
        jaraco.context \
        wheel \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash appuser

COPY app/vulnerable.py .

RUN chown -R appuser:appuser /app

USER appuser

CMD ["python", "vulnerable.py", "date"]
