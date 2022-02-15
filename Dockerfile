FROM alpine:latest

RUN apk add ttf-liberation poppler-utils curl perl
ADD src /app

WORKDIR /app
CMD ["sh", "/app/execute"]
