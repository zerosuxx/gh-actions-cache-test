FROM node:18-alpine AS base

FROM base AS build

WORKDIR /build

COPY package.json ./
COPY pnpm-lock.yaml ./

RUN npm install -g pnpm && pnpm install

COPY src src
COPY test test

RUN pnpm test
RUN pnpm prune --prod

FROM base AS packed

ENV NODE_ENV=production

WORKDIR /app

COPY --from=build --chown=node:node /build/node_modules node_modules
COPY --from=build --chown=node:node /build/src src

RUN chown node:node /app
RUN node src/index.js

USER node