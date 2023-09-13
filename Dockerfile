# Because our docker image size is large, we can convert it into multistage build
# Build stage

# Specifies the golang docker image version to build with
FROM golang:1.21-alpine3.18 AS builder 
# Specifies the work directory to put all our folders
WORKDIR /app
# Copy everything from the corresponding folder (root of our code folder) to the destination(app folder)
COPY . .
# Build into a single executable binary file
RUN go build -o main main.go
RUN apk add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.18
WORKDIR /app
# Copy from builder stage (main file)
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh" ]