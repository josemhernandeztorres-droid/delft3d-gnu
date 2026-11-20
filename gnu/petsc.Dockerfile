# PETSc 3.24.5 (the version Deltares builds in ci/dockerfiles/linux/third-party-libs.Dockerfile:200) from source, GNU +
# Open MPI, on top of deps.Dockerfile. Debian trixie's petsc-dev is 3.22.5, whose Fortran API the DIMRset_2026.02 tree no
# longer matches (solve_petsc.F90: reason%v, KSPGetConvergedReasonString). No Intel.
ARG BASE=dflowfm-gnu-deps:base
FROM ${BASE}
ARG PETSC_URL=https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.24.5.tar.gz
RUN set -eux; mkdir -p /usr/src/petsc && cd /usr/src/petsc && \
    wget -q -O petsc.tar.gz "$PETSC_URL" && sha256sum petsc.tar.gz | tee /usr/src/petsc/SHA256 && \
    tar xzf petsc.tar.gz --strip-components=1 && \
    ./configure --prefix=/opt/petsc-3.24.5 --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif90 \
      --with-debugging=0 --COPTFLAGS=-O3 --CXXOPTFLAGS=-O3 --FOPTFLAGS=-O3 && \
    make && make install && rm -rf /usr/src/petsc/src /usr/src/petsc/petsc.tar.gz
ENV PKG_CONFIG_PATH=/opt/petsc-3.24.5/lib/pkgconfig:/usr/local/lib/pkgconfig \
    LD_LIBRARY_PATH=/opt/petsc-3.24.5/lib
