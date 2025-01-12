FROM golang:1.23.4-alpine AS builder
WORKDIR /tmp/builder

RUN apk add --no-cache \
	ca-certificates \
	gcc \
	musl-dev

COPY go.mod /tmp/builder/

RUN --mount=type=cache,target=/go/pkg/mod/ \
	--mount=type=bind,source=go.mod,target=go.mod \
	go mod download -x

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod/ \
	--mount=type=cache,target="/tmp/builder/.cache/go-build" \
	GOCACHE=/tmp/builder/.cache/go-build \
	CGO_ENABLED=0 GOOS=linux go build -o server  -ldflags '-s -w -extldflags "-static"' ./main.go

FROM ubuntu:oracular AS user
RUN useradd -u 10001 scratchuser

FROM scratch
WORKDIR /tmp/runner

COPY --from=builder /tmp/builder/server ./
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=user /etc/passwd /etc/passwd

USER scratchuser
STOPSIGNAL SIGINT
EXPOSE 8080

CMD ["/tmp/runner/server"]
