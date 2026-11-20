#!/bin/bash
# Configure D-Flow FM (CONFIGURATION_TYPE=dflowfm) with GNU compilers and Open MPI; no Intel component.
# SRC: a writable copy of this repository. B: build directory.
set -euo pipefail
SRC=${SRC:-/build/src}
# dflowfm_configuration_basic.cmake installs $ENV{ONEAPI_ROOT}/mkl/latest/lib/intel64/: point it to an EMPTY directory.
export ONEAPI_ROOT=/opt/no-intel
mkdir -p "$ONEAPI_ROOT/mkl/latest/lib/intel64"
cmake -S "$SRC/src/cmake" -B "${B:-/build/dflowfm}" -G Ninja \
  -D CONFIGURATION_TYPE=dflowfm -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_PREFIX=/opt/delft3d -D COMMIT_VERSION=5a46498 \
  -D openmp_flag=-fopenmp \
  -D "real_size_64_flag=-fdefault-real-8;-fdefault-double-8" \
  -D qauto_threaded_flags=-frecursive \
  -D CMAKE_C_FLAGS="-Wno-error=incompatible-pointer-types" \
  -D CMAKE_Fortran_FLAGS_RELEASE="${FREL:--O2 -g} -ffree-line-length-none -D__linux__"
# Flags that compiler_options/gnu.cmake does not define and intel.cmake does (supplied as cache variables, no file edit):
#   openmp_flag            dflowfm_kernel/CMakeLists.txt sets COMPILE_FLAGS ${openmp_flag}; fails if empty.
#   real_size_64_flag      third_party_open/polypack (Intel -r8); called with real(dp) arrays.
#   qauto_threaded_flags   solveSAPHE (Intel -auto -reentrancy threaded); gfortran equivalent -frecursive.
#   CMAKE_C_FLAGS          GCC 14 makes -Wincompatible-pointer-types an error (bmi_shared_lib_fortran_api.c, typedef only).
# CMAKE_Fortran_FLAGS_RELEASE:
#   -O2                    Deltares' Intel Linux release flag (intel.cmake); CMake's GNU default would be -O3.
#   -ffree-line-length-none gnu.cmake caps free-form lines at 512; several kernel `use ..., only:` lines are longer.
#   -D__linux__            gfortran's cpp does not define it (ifx does); without it system_utils.F90 silently takes its
#                          Windows branch (FILESEP "\"): "Cannot create output directory output\".
#   -g                     line numbers in backtraces only.
# Checked build (how patches 0033-0050 were found): B=/build/dflowfm-chk FREL='-O0 -g -fcheck=all -fbacktrace'.
