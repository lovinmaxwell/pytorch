#!/bin/bash

# If you want to rebuild, run this with REBUILD=1
# If you want to build with CUDA, run this with USE_CUDA=1
# If you want to build without CUDA, run this with USE_CUDA=0

if [ ! -f setup.py ]; then
  echo "ERROR: Please run this build script from PyTorch root directory."
  exit 1
fi

COMPACT_JOB_NAME=pytorch-win-ws2016-cuda9-cudnn7-py3-build

SCRIPT_PARENT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_PARENT_DIR/common.sh"

export IMAGE_COMMIT_TAG=${BUILD_ENVIRONMENT}-${IMAGE_COMMIT_ID}
if [[ ${JOB_NAME} == *"develop"* ]]; then
  export IMAGE_COMMIT_TAG=develop-${IMAGE_COMMIT_TAG}
fi

export TMP_DIR="${PWD}/build/win_tmp"
export TMP_DIR_WIN=$(cygpath -w "${TMP_DIR}")

CI_SCRIPTS_DIR=$TMP_DIR/ci_scripts
mkdir -p $CI_SCRIPTS_DIR


SCRIPT_HELPERS_DIR=$SCRIPT_PARENT_DIR/win-test-helpers


# upload_image.py is called by build_pytorch.bat:
cp $SCRIPT_HELPERS_DIR/upload_image.py $CI_SCRIPTS_DIR

$SCRIPT_HELPERS_DIR/build_pytorch.bat

assert_git_not_dirty

if [ ! -f ${TMP_DIR}/${IMAGE_COMMIT_TAG}.7z ] && [ ! ${BUILD_ENVIRONMENT} == "" ]; then
    exit 1
fi
echo "BUILD PASSED"
