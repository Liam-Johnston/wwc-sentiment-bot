FROM node:16-alpine3.11
WORKDIR /app

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV

COPY package.json ./
RUN apk add --update --no-cache zip
RUN npm install

COPY . /app/
CMD [ "./bin/run" ]
