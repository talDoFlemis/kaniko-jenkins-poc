FROM node:lts-slim AS base

FROM base AS deps
WORKDIR /tmp/builder

COPY package.json yarn.lock* /tmp/builder/
RUN --mount=type=cache,target=/tmp/builder/.yarn YARN_CACHE_FOLDER=/tmp/builder/.yarn yarn --frozen-lockfile


FROM base AS builder
WORKDIR /tmp/builder
COPY --from=deps /tmp/builder/node_modules /tmp/builder/node_modules
COPY . /tmp/builder

ENV NEXT_TELEMETRY_DISABLED=1

RUN yarn run build

FROM gcr.io/distroless/nodejs22-debian12:nonroot AS runner
WORKDIR /app/runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=nonroot:nonroot /tmp/builder/public /app/runner/public
COPY --from=builder --chown=nonroot:nonroot /tmp/builder/.next/standalone /app/runner/
COPY --from=builder --chown=nonroot:nonroot /tmp/builder/.next/static /app/runner/.next/static

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["server.js"]
