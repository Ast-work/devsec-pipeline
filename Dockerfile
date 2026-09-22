FROM python:3.11-slim

WORKDIR /app

COPY app/vulnerable.py .

CMD ["python", "vulnerable.py", "date"]
