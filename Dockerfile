FROM python:3.6

ARG UID=1000
EXPOSE 8888

RUN mkdir /app
COPY setup.py /app
COPY greenguard /app/greenguard
COPY notebooks /app/notebooks
RUN pip install -e /app jupyter

WORKDIR /app
