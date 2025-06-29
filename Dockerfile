# Build stage
FROM golang:1.23-alpine AS builder

# Install git and ca-certificates (needed for go mod download)
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s -X main.Version=$(git describe --tags --always --dirty) -X main.BuildTime=$(date -u '+%Y-%m-%d_%H:%M:%S')" \
    -a -installsuffix cgo \
    -o main ./cmd/main.go

# Final stage
FROM scratch

# Import from builder
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /app/main /app/main

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["/app/main"] 