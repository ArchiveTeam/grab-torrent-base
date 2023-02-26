FROM python:3.9-slim
ARG LIBTORRENT_VERSION=2.0.8
ENV LC_ALL=C
RUN apt-get update \
 && apt-get -y --no-install-recommends install cmake ninja-build build-essential libboost-tools-dev libboost-dev libboost-system-dev libboost-thread-dev libboost-python-dev libssl-dev gnutls-dev libgcrypt-dev curl \
 && rm -rf /var/lib/apt/lists/*
RUN curl -L https://github.com/arvidn/libtorrent/releases/download/v${LIBTORRENT_VERSION}/libtorrent-rasterbar-${LIBTORRENT_VERSION}.tar.gz | tar zx \
 && cd libtorrent-rasterbar-${LIBTORRENT_VERSION} \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -Dpython-bindings=ON -Dpython-egg-info=ON -Dpython-install-system-dir=ON -DCMAKE_CXX_STANDARD=14 -G Ninja .. \
 && ninja
RUN echo "import site; site.addsitedir('/libtorrent-rasterbar-${LIBTORRENT_VERSION}/build/bindings/python')" > /usr/local/lib/python3.9/site-packages/sitecustomize.py
RUN pip install --no-cache-dir requests seesaw 
WORKDIR /grab
ONBUILD COPY . /grab
STOPSIGNAL SIGINT
ENTRYPOINT ["run-pipeline3", "--disable-web-server", "pipeline.py"]

