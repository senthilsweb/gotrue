#
# First stage: 
# Building the gotrue binary.
#

FROM golang:1.16-alpine AS build


RUN apk add --no-cache make git

WORKDIR /go/src/github.com/netlify/gotrue

# Copy and download dependencies.
COPY go.mod go.sum ./
RUN go mod download

# Copy a source code to the container.
COPY . .

# Set necessary environmet variables needed for the image and build the server.
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

# Run go build (with ldflags to reduce binary size).
RUN go build -ldflags="-s -w" -o gotrue .

#
# Second stage: 
# Creating and running a new scratch container with the build binary.
#

FROM alpine:3.7
RUN adduser -D -u 1000 netlify

RUN apk add --no-cache ca-certificates
COPY --from=build /go/src/github.com/netlify/gotrue/.env /usr/local/bin/.env
COPY --from=build /go/src/github.com/netlify/gotrue/gotrue /usr/local/bin/gotrue


WORKDIR /usr/local/bin/

# Command to run when starting the container.

#USER netlify
ENV HOST 0.0.0.0
EXPOSE 3000

CMD ["gotrue"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]