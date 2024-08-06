FROM python:3.6.4 AS build

RUN /usr/local/bin/pip install scons
RUN mkdir /build && \
    cd /build && \
    git clone https://gitlab.com/gpsd/gpsd.git && \
    cd gpsd && \
    git checkout release-3.25 && \
    /usr/local/bin/scons -c && \
    /usr/local/bin/scons && \
    /usr/local/bin/scons install

FROM debian:bookworm-slim
COPY --link --from=build /usr/local/sbin/gpsd /sbin/gpsd
COPY --link --from=build /usr/local/share/gpsd/doc/COPYING /usr/share/gpsd/doc/COPYING

ENTRYPOINT ["/sbin/gpsd"]
