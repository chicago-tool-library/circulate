FROM gliderlabs/herokuish

COPY . /tmp/app
RUN /build
