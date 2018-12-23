# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.py"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
# Build Binaries
#----------------------------------------------------------------
FROM python:3.6-alpine3.8 as build

ARG NUMPY_VERSION=1.15.4
ARG SCIPY_VERSION=1.2.0
ARG PANDAS_VERSION=0.23.4
ARG SCIKIT_LEARN_VERSION=0.20.2

# folder to save binaries
ENV BINARY /tmp/cache/wheel

# install build dependencies
RUN apk --no-cache --update-cache  add \
        build-base \
        gcc \
        gfortran \
        openblas-dev

# simlink the required lib for numpy
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# build and install numpy and scipy before building scikit learn
# scikit learn requires dependencies installed when building from source
# https://github.com/scikit-learn/scikit-learn/issues/4164
RUN pip wheel --wheel-dir=$BINARY numpy==${NUMPY_VERSION} \
      && pip install $BINARY/numpy*.whl

RUN pip wheel --wheel-dir=$BINARY scipy==${SCIPY_VERSION} \
      && pip install $BINARY/scipy*.whl

# build scikit learn
RUN pip wheel --wheel-dir=$BINARY scikit-learn==${SCIKIT_LEARN_VERSION}

# build pandas
RUN pip wheel --wheel-dir=$BINARY pandas==${PANDAS_VERSION}

# Install Binaries
#----------------------------------------------------------------
FROM python:3.6-alpine3.8

# copy binaries from build stage
COPY --from=build /tmp/cache/wheel /tmp/cache/wheel

# install and remove binaries
RUN apk --no-cache --update-cache add openblas \
      libstdc++ \
      && pip install --no-cache-dir /tmp/cache/wheel/* \
      && rm -rf /tmp/cache/wheel

CMD ["python3"]