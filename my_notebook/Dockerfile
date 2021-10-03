FROM jupyter/datascience-notebook

USER root
RUN apt-get update && apt-get install -y make python3-sphinx

USER jovyan
ENV PATH="/opt/conda/bin:${PATH}"
RUN pip3 install flake8 mypy pipenv pytest pytest-cov py_pkg sphinx sphinx_rtd_theme types-requests

ARG JUPYTER_PASSWORD="sha1:pass-with-build-arg"
RUN sed -i.bak -e "s/^[# ]*c.NotebookApp.password *=.*/c.NotebookApp.password = ${JUPYTER_PASSWORD}/" /home/jovyan/.jupyter/jupyter_notebook_config.py
