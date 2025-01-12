FROM node:lts-slim AS base

FROM base AS deps
WORKDIR /app

COPY package.json yarn.lock /app/
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install


FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
COPY . /app

ENV NEXT_TELEMETRY_DISABLED=1

RUN yarn run build

FROM gcr.io/distroless/nodejs22-debian12:nonroot AS runner
WORKDIR /app/runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=nonroot:nonroot /app/public /app/runner/public
COPY --from=builder --chown=nonroot:nonroot /app/.next/standalone /app/runner/
COPY --from=builder --chown=nonroot:nonroot /app/.next/static /app/runner/.next/static

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["server.js"]
