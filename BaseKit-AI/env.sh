export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
export PATH="$CONDA_PREFIX/go/bin:$PATH"
export GOBIN="$GOROOT/bin"

echo "--sysroot=$CONDA_BUILD_SYSROOT --gcc-toolchain=$CONDA_PREFIX --target=$HOST $CXXFLAGS" >"$CONDA_PREFIX/bin/icpx.cfg"
echo "--sysroot=$CONDA_BUILD_SYSROOT --gcc-toolchain=$CONDA_PREFIX --target=$HOST $CFLAGS" >"$CONDA_PREFIX/bin/icx.cfg"
