#!/usr/bin/env bash

python setup.py build_ext --inplace

OUTPUT_DIR="modules"

# Create the build output directory, -p flag means only if folder doesn't already exist
mkdir -p $OUTPUT_DIR

# Compile the C files into a shared library that can be loaded by the engine
gcc -shared -o $OUTPUT_DIR/fiasco.dylib src/*.c $(python3-config --cflags --ldflags) -lpython3.12