FROM python:3.9-buster
LABEL maintainer="luca.lianas@crs4.it"

RUN mkdir -p /home/promort

RUN groupadd promort && useradd -g promort promort

RUN apt-get update \
    && apt-get install -y curl build-essential git \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g grunt

ENV HOME=/home/promort
ENV APP_HOME=/home/promort/app
RUN mkdir ${APP_HOME} \
    && chown -R promort ${HOME}
WORKDIR ${APP_HOME}

ARG PROMORT_TAG=airc-0.1.0

USER promort

RUN git clone https://github.com/crs4/ProMort.git

WORKDIR ${APP_HOME}/ProMort/

RUN git checkout ${PROMORT_TAG}

USER root

RUN pip install --upgrade pip \
    && pip install -r requirements_pg.txt \
    && pip install gunicorn==20.1.0

USER promort

RUN npm install \
    && grunt

USER root

COPY resources/entrypoint.sh \
     resources/wait-for-it.sh \
     /usr/local/bin/

COPY resources/80-apply-migrations.sh \
     resources/99-run.sh \
     /startup/

USER promort

WORKDIR ${APP_HOME}/ProMort/promort/

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoinyt.sh"]
