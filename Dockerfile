FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./

RUN go mod download

COPY Server/MuchToDo/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o muchtodo ./cmd/api/main.go

FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates wget

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/muchtodo .

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./muchtodo"]