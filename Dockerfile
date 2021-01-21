FROM python:2-stretch
LABEL maintainer="luca.lianas@crs4.it"

RUN mkdir -p /home/promort

RUN groupadd promort && useradd -g promort promort

RUN apt-get update \
    && apt-get install -y curl build-essential \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g grunt

ENV HOME=/home/promort
ENV APP_HOME=/home/promort/app
RUN mkdir ${APP_HOME} \
    && chown -R promort ${HOME}
WORKDIR ${APP_HOME}

ARG PROMORT_VERSION=0.6.1

USER promort

RUN wget https://github.com/crs4/promort/archive/v${PROMORT_VERSION}.zip -P ${APP_HOME} \
    && unzip ${APP_HOME}/v${PROMORT_VERSION}.zip -d ${APP_HOME} \
    && mv ${APP_HOME}/ProMort-${PROMORT_VERSION} ${APP_HOME}/ProMort \
    && rm ${APP_HOME}/v${PROMORT_VERSION}.zip

USER root

WORKDIR ${APP_HOME}/ProMort/

RUN pip install -r requirements_pg.txt \
    && pip install gunicorn==19.9.0

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
