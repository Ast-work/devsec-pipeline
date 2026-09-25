FROM python:3.11.16-slim

WORKDIR /app

RUN apt-get update \
    && apt-get upgrade -y \
    && python -m pip install --upgrade \
	setuptools \
        jaraco.context \
        wheel \
    && rm -rf /var/lib/apt/lists/*

COPY app/vulnerable.py .

CMD ["python", "vulnerable.py", "date"]
