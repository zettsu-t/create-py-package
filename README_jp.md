# Pythonパッケージの雛型を作る

[Python Package Template Project](https://github.com/AlexIoannides/py-package-template)を使って、Pythonパッケージの開発環境を構築する。

## Dockerコンテナをビルドする

[jupyter/datascience-notebook](https://hub.docker.com/r/jupyter/datascience-notebook/) を基にしたコンテナを、以下のコマンドでビルドする。同じことを同梱の `bash docker_build.sh` で実行する。

```bash
docker-compose build --build-arg "$(< password_digest.txt)"
```

必要なLinuxパッケージとPythonパッケージを追加する。詳しくは[Dockerfile](my_notebook/Dockerfile)を参照すること。

Jupyter Notebook のログインパスワードをSHA1ダイジェストにしたものを、ファイル [password_digest.txt](password_digest.txt) に書く(後述)。Dockerコンテナをビルドするときに、 コンテナ内の **/home/jovyan/.jupyter/jupyter_notebook_config.py** にこのSHA1ダイジェストを埋め込む。

## Dockerコンテナを起動する

以下の通りコンテナを起動し、起動時のカレントディレクトリを **/home/jovyan/work** にマウントする。詳しくは [docker-compose.yml](docker-compose.yml) を参照。マウントするディレクトリを変えたいときは、 docker-compose.yml を編集する。ユーザ名は jupyter/datascience-notebook のデフォルト通り **jovyan** にする。

```bash
docker-compose up -d
```

## パスワードを変更する

Jupyter Notebook のログインパスワードが設定されていないので、まだJupyter Notebookにログインできない。コンテナIDを調べて、コンテナに入る。

```bash
docker ps
## CONTAINER ID   IMAGE
## 7d07786719a5   my_notebook
docker exec -it 7d07786719a5 /bin/bash
```

Python 3.9を起動する。

```bash
python3
```

Pythonで以下の通り実行するとパスワードを訊かれるので、同じ文字列を二度入力するとSHA1ダイジェストが表示される。

```bash
from notebook.auth import passwd
passwd(algorithm="sha1")
## Enter password:
## Verify password:
## 'sha1:...'
```

この sha1:...という文字列を、 [password_digest.txt](password_digest.txt) に設定する。 Dockerfile の変数 **JUPYTER_PASSWORD** として埋め込むように、以下を置き換える。

```bash
JUPYTER_PASSWORD=u'sha1:...'
```

Pythonをquit()で終了し、コンテナから **exit** で抜けてから、コンテナを終了、再ビルド、起動すると、パスワードを Jupyter Notebook に反映する。単に docker-compose build を **--build-arg** 無しで実行してもパスワードを設定できないので注意。

```bash
docker-compose down
bash docker_build.sh
docker-compose up -d
```

## Pythonパッケージの雛型を入手する

[Python Package Template Project](https://github.com/AlexIoannides/py-package-template) リポジトリの内容を、ZIPファイル **py-package-template-master.zip** としてダウンロードする。このzipファイルを、Dockerコンテナから見える作業用ディレクトリに置く。

DockerコンテナのIDを調べてコンテナに入る。

```bash
docker ps
docker exec -it 5b7c9a890b0a /bin/bash
```

この雛型パッケージをインストールする。

```bash
cd /path/to/py-package-template-master.zip
pip3 install py-package-template-master.zip
```

カレントディレクトリに雛形を作る。 "Download Python package template project to this directory" と訊かれたら y と答える。**py-package-template-master/** というディレクトリに雛形ができるので、ディレクトリ名を適宜変更する。ここでは雛形にならって、 **py_pkg/** というディレクトリ名とパッケージ名にする。

```bash
py-package-template install
mv py-package-template-master py_pkg
cd py_pkg
```

このままコマンドラインを使って、雛形パッケージをビルドしよう。この雛型には、Pythonのバージョンが3.7に固定されている記述がある。この環境に合わせて、3.9に変更しないと、この後エラーが出る。

```bash
find . -type f | xargs egrep -e "3\\.7"
```

## 雛型をビルドする

雛形にはすでにコードがあるので、 README.md に従ってテストからインストールまで一通りの処理をできることを確認する。失敗したときはパッケージが足りないので、Dockerfileを修正する。

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

### 雛形を実行する

Jupyter Notebook から、インストールしたパッケージを使う。ウェブブラウザで **localhost:8888** からログインして、新しいNotebookを作成し、以下を実行すると結果が返る。

```python
from py_pkg.curves import DemandCurve
DemandCurve([{"price": 10, "demand": 2}, {"price": 20, "demand": 1}]).quantity(15)
```
