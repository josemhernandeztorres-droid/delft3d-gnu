# syntax=docker/dockerfile:1.7
# D-Flow FM GNU toolchain: build dependencies only (no Intel component).
FROM debian:trixie AS deps
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential gfortran g++ cmake ninja-build pkg-config git wget ca-certificates \
      python3 patchelf m4 file procps \
      openmpi-bin libopenmpi-dev \
      libnetcdf-dev libnetcdff-dev netcdf-bin \
      petsc-dev \
      libproj-dev libgdal-dev libsqlite3-dev libtiff-dev uuid-dev libexpat1-dev libxerces-c-dev \
      libboost-log-dev libboost-program-options-dev libboost-thread-dev libboost-system-dev \
      libboost-filesystem-dev libeigen3-dev libxml2-dev libgtest-dev \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends libboost-test-dev libboost-iostreams-dev && rm -rf /var/lib/apt/lists/*

# preCICE 3.3.1 (same version as Deltares CI); not packaged in Debian trixie.
RUN wget -q -O- https://github.com/precice/precice/archive/v3.3.1.tar.gz | tar xz -C /opt \
 && cmake -S /opt/precice-3.3.1 -B /opt/precice-build -G Ninja \
      -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D CMAKE_INSTALL_LIBDIR=lib \
      -D PRECICE_HIDE_SYMBOLS=OFF -D PRECICE_FEATURE_PETSC_MAPPING=OFF \
      -D PRECICE_FEATURE_GINKGO_MAPPING=OFF -D PRECICE_FEATURE_PYTHON_ACTIONS=OFF \
      -D BUILD_SHARED_LIBS=ON -D BUILD_TESTING=OFF \
 && cmake --build /opt/precice-build --parallel 6 && cmake --install /opt/precice-build \
 && rm -rf /opt/precice-3.3.1 /opt/precice-build && ldconfig

ENV FC=mpifort CC=mpicc CXX=mpicxx \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/petsc/lib/pkgconfig \
    OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
