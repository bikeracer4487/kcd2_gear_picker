FROM node:22-alpine

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./

ENTRYPOINT ["./docker/nodejs_entrypoint.sh"]