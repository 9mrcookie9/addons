ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache libc6-compat curl

RUN curl -sL -O https://github.com/cloudflare/cloudflared/releases/download/2022.12.1/cloudflared-linux-amd64 && mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
RUN chmod a+x /usr/local/bin/cloudflared

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
