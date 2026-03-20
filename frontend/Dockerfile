# syntax = docker/dockerfile:1

ARG NODE_VERSION=22.11.0
FROM node:${NODE_VERSION}-slim AS base

WORKDIR /app

ENV NODE_ENV="production"
RUN corepack enable


# Throw-away build stage to reduce size of final image
FROM base AS build

ARG NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL

ARG NEXT_PUBLIC_CLOUDFRONT_BASE_URL
ENV NEXT_PUBLIC_CLOUDFRONT_BASE_URL=$NEXT_PUBLIC_CLOUDFRONT_BASE_URL

ARG NEXT_PUBLIC_S3_HOSTNAME
ENV NEXT_PUBLIC_S3_HOSTNAME=$NEXT_PUBLIC_S3_HOSTNAME

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

COPY . .

RUN npx next build && \
    yarn cache clean


# Final stage for app image
FROM base

COPY --from=build /app /app

ENTRYPOINT [ "/app/docker-entrypoint.js" ]

EXPOSE 3000
CMD [ "yarn", "start" ]
