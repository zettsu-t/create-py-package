# Creating a Python package template

This is an introduction to use [Python Package Template Project](https://github.com/AlexIoannides/py-package-template) and make a Python package template.

## Building a Docker container

We build a Docker container based on [jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/) using docker-compose. `bash docker_build.sh` in this repository does the same thing below.

```bash
docker-compose build --build-arg "$(< password_digest.txt)"
```

This will install Linux packages and Python packages which we use later. See [Dockerfile](my_notebook/Dockerfile) for more details.

We have to describe a SHA1 digest of a login password for Jupyter Notebook in [password_digest.txt](password_digest.txt) as described later. The command above embeds the SHA1 digest to **/home/jovyan/.jupyter/jupyter_notebook_config.py** in the Docker container.

## Running the Docker container

We run the Docker container as below and it mounts the current directory of the host OS to **/home/jovyan/work** in the container. It is described in [docker-compose.yml](docker-compose.yml) and you can change it as you like. The default user is **jovyan** same as jupyter/datascience-notebook.

```bash
docker-compose up -d
```

## Changing our password for Jupyter Notebook

Jupyter Notebook in the container has no valid password yet and we cannot log in to it. To set a password to it, we show the ID of the container and open a shell inside the container.

```bash
docker ps
## CONTAINER ID   IMAGE
## 7d07786719a5   my_notebook
docker exec -it 7d07786719a5 /bin/bash
```

We launch Python 3.9.

```bash
python3
```

We run scripts below on Python 3.9, enter a password twice, and it shows a SHA1 digest of the password.

```python
from notebook.auth import passwd
passwd(algorithm="sha1")
## Enter password:
## Verify password:
## 'sha1:...'
```

We copy the sha1:... digest string to [password_digest.txt](password_digest.txt) to overwrite the **JUPYTER_PASSWORD** variable in Dockerfiles.

```
JUPYTER_PASSWORD=u'sha1:...'
```

To get out of the container, we run quit() to exit Python and execute **exit** to quit the shell. We stop, build, and start the container to reflect the password in Jupyter Notebook in the container. Note that bare `docker-compose build` without **--build-arg** does not reflect the password.

```bash
docker-compose down
bash docker_build.sh
docker-compose up -d
```

## Downloading a Python package template

We download the repository of [Python Package Template Project](https://github.com/AlexIoannides/py-package-template) as a ZIP file **py-package-template-master.zip** and put it into a directory which the Docker container can read.

We open a shell inside the container

```bash
docker ps
docker exec -it 5b7c9a890b0a /bin/bash
```

and install the ZIP file.

```bash
cd /path/to/py-package-template-master.zip
pip3 install py-package-template-master.zip
```

py-package-template creates a Python package template on the current directory of the shell. We reply "y" when it asks you "Download Python package template project to this directory", and it creates a **py-package-template-master/** directory. We rename it to **py_pkg/** same as the template's name.

```bash
py-package-template install
mv py-package-template-master py_pkg
cd py_pkg
```

Let's stay in the container and execute commands to build the template. Files in the template in **py_pkg/** fix versions of Python to 3.7. It causes errors and we change 3.7 to 3.9 in all text files of the template as the default version of Python in the container.

```bash
find . -type f | xargs egrep -e "3\\.7"
```

## Building the package template

The package template contains an executable sample as a Python package and we can do workflows from testing to installing the package as below. If some commands fail due to missing packages, we modify the Dockerfile to install them.

```bash
pipenv run pytest
pipenv run flake8 py_pkg
pipenv run mypy py_pkg/*.py
pipenv run sphinx-quickstart
pipenv run sphinx-build -b html docs/source docs/build_html
make html
pipenv run python setup.py bdist_wheel
pipenv install ./dist/py_package_template-0.2.0-py3-none-any.whl
```

## Running the package in Jupyter Notebook

Now we can run the package in Jupyter Notebook. We log in to the Jupyter Notebook via **localhost:8888** via a Web browser, create a Python notebook, and execute the Python script below in a code chunk.

```python
from py_pkg.curves import DemandCurve
DemandCurve([{"price": 10, "demand": 2}, {"price": 20, "demand": 1}]).quantity(15)
```

We get a result when we succeeded in installing the package template.
