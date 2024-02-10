FROM node:18-alpine AS base

FROM base AS packages

WORKDIR /build

COPY package.json ./
COPY yarn.lock ./

RUN yarn install --frozen-lockfile

FROM base AS build

WORKDIR /build

COPY --from=packages /build/node_modules node_modules
COPY src src
COPY test test

#RUN yarn test
#RUN yarn install --production --ignore-scripts --prefer-offline --frozen-lockfile

FROM base AS packed

ENV NODE_ENV=production

WORKDIR /app

COPY --from=build --chown=node:node /build/node_modules node_modules
COPY --from=build --chown=node:node /build/src src

RUN chown node:node /app

USER node