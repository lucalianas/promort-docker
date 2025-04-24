FROM python:3.8-bullseye
LABEL maintainer="luca.lianas@crs4.it"

RUN mkdir -p /home/promort

RUN groupadd promort && useradd -g promort promort

RUN apt-get update \
    && apt-get install -y curl build-essential \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g grunt

ENV HOME=/home/promort
ENV APP_HOME=/home/promort/app
RUN mkdir ${APP_HOME} \
    && chown -R promort ${HOME}
WORKDIR ${APP_HOME}

ARG PROMORT_VERSION=0.11.0-beta.2

USER promort

RUN wget https://github.com/crs4/promort/archive/v${PROMORT_VERSION}.zip -P ${APP_HOME} \
    && unzip ${APP_HOME}/v${PROMORT_VERSION}.zip -d ${APP_HOME} \
    && mv ${APP_HOME}/DigitalPathologyPlatform-${PROMORT_VERSION} ${APP_HOME}/DigitalPathologyPlatform \
    && rm ${APP_HOME}/v${PROMORT_VERSION}.zip

USER root

WORKDIR ${APP_HOME}/DigitalPathologyPlatform/

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

WORKDIR ${APP_HOME}/DigitalPathologyPlatform/promort/

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
