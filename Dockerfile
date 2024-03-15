FROM node:21-alpine3.18

RUN apk add --no-cache bash

ENV HOME=/home/node/app
WORKDIR $HOME

COPY package*.json ./

RUN npm install

RUN chown -R root:root $HOME/*

COPY . .

EXPOSE 3333

CMD [ "npm", "start" ]
