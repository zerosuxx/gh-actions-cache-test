FROM node:18-alpine AS base

FROM base AS build

WORKDIR /build

COPY .npmrc package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY src src
COPY test test

RUN yarn test
RUN yarn install --production --ignore-scripts --prefer-offline --frozen-lockfile

FROM base AS packed

ENV NODE_ENV=production

WORKDIR /app

COPY --from=build --chown=node:node /build/node_modules node_modules
COPY --from=build --chown=node:node /build/src src

RUN chown node:node /app

USER node