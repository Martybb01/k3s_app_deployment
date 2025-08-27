FROM python:3.10-slim

RUN pip install --no-cache-dir flask

WORKDIR /app

COPY app.py .

EXPOSE 5000

CMD ["python3", "app.py"]