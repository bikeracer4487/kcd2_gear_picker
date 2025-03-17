FROM ghcr.io/lunarmodules/busted:master

RUN apk add --no-cache entr lua-dev && \
    luarocks install luacov

WORKDIR /data

ENTRYPOINT ["busted", "--verbose", "--output=gtest", "--coverage"]