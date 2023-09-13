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

# Run stage
FROM alpine:3.18
WORKDIR /app
# Copy from builder stage (main file)
COPY --from=builder /app/main .
COPY app.env .

EXPOSE 8080
CMD [ "/app/main" ]