# builder 1.18.5-alpine3.16
FROM golang@sha256:dda10a0c69473a595ab11ed3f8305bf4d38e0436b80e1462fb22c9d8a1c1e808 as builder

WORKDIR /build
COPY . .
RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build  -o app-devops-task .

# run image
FROM scratch
COPY --from=builder /build/app-devops-task .

ENTRYPOINT [ "./app-devops-task" ]
