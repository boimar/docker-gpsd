FROM python:3.9-bookworm AS build

RUN apt -y update
RUN /usr/local/bin/pip install scons
RUN mkdir /build && \
    cd /build && \
    git clone https://gitlab.com/gpsd/gpsd.git && \
    cd gpsd && \
    git checkout release-3.25 && \
    /usr/local/bin/scons -c && \
    /usr/local/bin/scons && \
    /usr/local/bin/scons install
RUN mkdir /build/x86_64-linux-gnu && \
    mv /lib/x86_64-linux-gnu/libbluetooth.so* /build/x86_64-linux-gnu/

FROM debian:bookworm-slim
COPY --link --from=build /build/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --link --from=build /usr/share/doc/libbluetooth3/copyright /usr/share/doc/libbluetooth3/copyright
COPY --link --from=build /usr/local/sbin/gpsd /sbin/gpsd
COPY --link --from=build /usr/local/share/gpsd/doc/COPYING /usr/share/gpsd/doc/COPYING

ENTRYPOINT ["/sbin/gpsd"]
