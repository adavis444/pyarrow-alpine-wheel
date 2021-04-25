FROM python:3.9.6-alpine3.14 AS numpy-buider
RUN apk --update add --no-cache \
        cmake \
        g++ \
        git \
        make
RUN pip wheel --no-cache-dir -w wheels \
        Cython==0.29.23 \
        numpy==1.19.4


FROM numpy-builder AS pyarrow-builder
ARG ARROW_VERSION=3.0.0
ENV ARROW_HOME=/usr/local/lib/python3.9/site-packages/pyarrow
RUN pip install --no-cache-dir --no-index -f wheels Cython numpy
RUN git clone https://github.com/apache/arrow.git \
        --branch apache-arrow-${ARROW_VERSION} \
        --depth 1 \
    && mkdir /arrow/cpp/build \
    && cd /arrow/cpp/build \
    && cmake -D CMAKE_INSTALL_PREFIX=$ARROW_HOME -D ARROW_PYTHON=ON .. \
    && make -j $(nproc) \
    && make install \
    && cd /arrow/python \
    && python setup.py build_ext \
    && python setup.py install
RUN pip wheel --no-cache-dir -w wheels -f wheels \
        pyarrow==$ARROW_VERSION
