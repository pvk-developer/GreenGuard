FROM python:3.6

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

EXPOSE 8888

RUN mkdir ${HOME}/app
COPY setup.py ${HOME}/app
COPY greenguard ${HOME}/app/greenguard
COPY notebooks ${HOME}/app/notebooks
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

RUN pip install -e ${HOME}/app jupyter

WORKDIR ${HOME}/app

CMD pip install -e ${HOME}/app && /usr/local/bin/jupyter notebook --ip 0.0.0.0 --NotebookApp.token='' --allow-root
