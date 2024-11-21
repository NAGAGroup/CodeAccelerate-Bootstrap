#!/bin/bash

set -e

export BUILD_TYPE=sycl_f16
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@1958fcbe2ca8bd93af633f11e97d44e567e945af

if [ ! -d "LocalAI" ]; then
  git clone https://github.com/go-skynet/LocalAI
fi
cd LocalAI
make BUILD_TYPE="$BUILD_TYPE" build
