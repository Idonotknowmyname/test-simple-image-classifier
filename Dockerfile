FROM python:3.10.11-slim-buster as server

RUN useradd -m noroot
RUN mkdir /app
WORKDIR /app

# Copy and install requirements
ADD api/requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir

# Copy and install files
ADD api/setup.py .
ADD api/backend ./backend
RUN pip install .

# Build static sources
FROM node:18.16.0-buster-slim as build

RUN mkdir /app
WORKDIR /app

ENV PATH=/app/node_modules/.bin:$PATH
COPY app/package.json ./
COPY app/package-lock.json ./
RUN npm ci --silent
RUN npm install react-scripts@3.4.1 -g --silent
COPY app ./

# Get URL of backend host for frontend axios requests
ARG HOST_URL
ENV REACT_APP_HOST_URL="${HOST_URL}"
RUN npm run build

# Serving environment
FROM server
COPY --from=build /app/build /app/static

USER noroot

ENTRYPOINT ["/bin/bash", "-c", "gunicorn backend.app:app --workers ${NWORKERS:-2} --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:${PORT:-8080}"]
