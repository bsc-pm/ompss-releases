# Dockerfile
FROM debian:jessie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        libtool \
        pkg-config \
        libltdl-dev \
        build-essential \
        git \
        gfortran \
        bison \
        flex \
        gperf \
        libsqlite3-dev \
        python \
        curl \
        ca-certificates \
        libxml2-dev \
        binutils-dev \
        libiberty-dev \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /usr/src/extrae && \
    curl -SL https://github.com/bsc-performance-tools/extrae/archive/2.5.tar.gz \
    | tar -xzC /usr/src/extrae --strip-components=2 extrae-2.5/2.5.2 && \
    cd /usr/src/extrae && \
    ./bootstrap && \
    ./configure \
        --without-mpi \
        --without-unwind \
        --without-dyninst \
        --without-papi \
        --disable-openmp \
        --disable-pthread \
        --disable-smpss && \
    make && \
    make install && \
    make distclean

COPY nanox /usr/src/nanox
RUN cd /usr/src/nanox && \
    autoreconf -fiv && \
    ./configure \
        --disable-allocator \
        --disable-memtracker \
        --with-extrae=/usr/local && \
    make && \
    make install && \
    make distclean

COPY mcxx /usr/src/mcxx
RUN cd /usr/src/mcxx && \
    autoreconf -fiv && \
    ./configure \
        --enable-ompss \
        --with-nanox=/usr/local && \
    make && \
    make install && \
    make distclean

CMD ["bash"]
