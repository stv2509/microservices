FROM python:alpine
RUN apk --update add gcc make g++ zlib-dev
RUN pip install --upgrade pip && pip install --upgrade setuptools flask pymongo prometheus_client structlog py-zipkin requests 
WORKDIR /app
ADD . /app
ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts
ENTRYPOINT ["python3", "post_app.py"]
