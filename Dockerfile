FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS builder

COPY Makefile /app/

RUN apt update -yq \
    && apt install -yq bzip2 cmake g++ make wget python3-pip \
    && pip wheel -w /app/ dlib \
    && make -C /app/ download-models

FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

COPY --from=builder /app/dlib*.whl /tmp/
COPY --from=builder /app/vendor/ /app/vendor/

RUN apt update -yq \
    && apt install -yq python3-pip

RUN python3 -m pip config set global.break-system-packages true
RUN pip install flask numpy \
    && pip install --no-index -f /tmp/ dlib \
    && rm /tmp/dlib*.whl

COPY facerecognition-external-model.py /app/
WORKDIR /app/

EXPOSE 5000

ENV FLASK_APP=facerecognition-external-model.py

CMD flask run -h 0.0.0.0
