[![Build Status](https://travis-ci.org/stv2509/microservices.svg?branch=master)](https://travis-ci.org/stv2509/microservices)


## [Шпаргалка-1 с командами Docker](https://habr.com/ru/company/flant/blog/336654/)

## [Шпаргалка-2 с командами Docker](https://github.com/eon01/DockerCheatSheet)

## [Большой Docker FAQ: отвечаем на самые важные вопросы](https://xakep.ru/2015/06/04/docker-faq/)

## [Драйверы которые поддерживает docker-machine](https://docs.docker.com/machine/drivers/)

#
# GOOGLE_APPLICATION_CREDENTIALS

<details><p>

```bash
API APIs & services -> Credentials. Create Credentials -> Service account key

New service account
Service account name любое
Role: owner
Key type: JSON
Create
export GOOGLE_APPLICATION_CREDENTIALS="[PATH]"
```
</p></details>

#
#
# Homework 14. Containerization technology. Introduction to Docker

 - Знакомство с Docker. Основные команды

### В процессе сделано:

 - [Устанавливаем Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
 - Запустим первый контейнер:
   - ***docker run hello-world***


# Homework 15. Docker containers

- Создание docker host
- Создание своего образа
- Работа с Docker Hub
 
### В процессе сделано:
<details>

- [Установим Docker machine](https://docs.docker.com/machine/install-machine/). docker-machine - встроенный в докер инструмент для создания хостов и установки на них docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP и др.)
- Создадим образ на GCP:
```bash
$ export GOOGLE_APPLICATION_CREDENTIALS=$HOME/gce-credentials.json
$ export GOOGLE_PROJECT=_ваш-проект_ (docker-234216)
$ docker-machine create --driver google \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
docker-host
```
- <details><p>
  <summary>Создадим приложение монолит docker-monolith/ :</summary>
  
  - **docker-monolith/Dockerfile** - текстовое описание нашего образа

  - **docker-monolith/mongod.conf** - преподготовленный конфиг для mongodb

  - **docker-monolith/db_config** - содержит переменную со ссылкой на mongodb

  - **docker-monolith/start.sh** - скрипт запуска приложения

  - **docker-monolith/default-allow-9292.sh** - скрипт для проверки firewall

  </p></details>

- Выполним команду, чтобы собрать свой образ:
  - ***$ docker build -t reddit:latest .*** (Точка в конце обязательна, она указывает на путь до Docker-контекста, флаг -t задает тег для собранного образа)
- Запустить наш контейнер и проверим результат:
  - ***$ docker run --name reddit -d --network=host reddit:latest***
  - ***$ docker-machine ls***
- Разрешим входящий TCP-трафик на порт 9292, выполним:
  - ***docker-monolith/default-allow-9292.sh***
- **Docker Hub** - это облачный registry сервис от компании Docker. В него можно выгружать и загружать из него докер образы.
- Аутентифицируемся на docker hub и загрузим наш образ для использования в будущем:
  - ***$ docker login***
  - ***$ docker tag reddit:latest <your-login>/otus-reddit:1.0***
  - ***$ docker push <your-login>/otus-reddit:1.0***
</p></details>

#  
# Homework 16. Docker microservices

- Научились описывать и собирать Docker-образы для сервисного приложения
- Научитлись оптимизировать работу с Docker-образами
- Запуск и работа приложения на основе Docker-образов
- Разбъем наше приложение на несколько компонентов
- Запустим наше микросервисное приложение

### В процессе сделано:

<details><p>
<summary>Команды docker для компонентов :</summary>

#
- Соберем образы с нашими сервисами:
```
docker pull mongo:latest 
docker build -t stv2509/post:2.0 ./post-py 
docker build -t stv2509/comment:2.0 ./comment 
docker build -t stv2509/ui:2.0 ./ui
```
- Создадим специальную bridge-сеть **"reddit** для контейнеров, так как сетевые алиасы не работают в сети по умолчанию:
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post stv2509/post:2.0
docker run -d --network=reddit --network-alias=comment stv2509/comment:2.0
docker run -d --network=reddit -p 9292:9292 stv2509/ui:2.0
```
- Запустим наши контейнеры:
```
docker volume create reddit_db

docker run -d --network=reddit -v reddit_db:/data/db --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post stv2509/post:2.0
docker run -d --network=reddit --network-alias=comment stv2509/comment:2.0
docker run -d --network=reddit -p 9292:9292 stv2509/ui:2.0
```
</p></details>

#  
# Homework 17. Docker: network, docker-compose

- Работа с сетями в Docker
- Использование docker-compose:
  - Установим docker-compose на локальную машину
  - Соберем образы приложения reddit с помощью docker-compose
  - Запустим приложение reddit с помощью docker-compose

### В процессе сделано:

<details><p>

- None network driver:
  - ***docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig***
- Host network driver:
  - ***docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig***
  - ***docker-machine ssh docker-host ifconfig***
- Остановите все запущенные контейнеры:
  - ***docker kill $(docker ps -q)***
- Docker networks:
  - ***sudo ln -s /var/run/docker/netns /var/run/netns***
  - ***sudo ip netns***
- Bridge network driver:
  - Создадим bridge-сеть в docker:
    - ***docker network create reddit --driver bridge***
  - Запустим наш проект reddit с использованием bridge-сети и присвоим контейнерам имена
    - ***--name <name> (можно задать только 1 имя)***
    - ***--network-alias <alias-name> (можно задать множество алиасов)***
  ```bash
  > docker run -d --network=reddit --network-alias=post_db --networkalias=comment_db mongo:latest
  > docker run -d --network=reddit --network-alias=post <your-login>/post:1.0
  > docker run -d --network=reddit --network-alias=comment <your-login>/comment:1.0
  > docker run -d --network=reddit -p 9292:9292 <your-login>/ui:1.0
  ```
  - Запустим наш проект в 2-х bridge сетях:
    - Создадим docker-сети
	```bash
	> docker network create back_net --subnet=10.0.2.0/24
	> docker network create front_net --subnet=10.0.1.0/24
	```
	- Запустим контейнеры:
	```bash
	> docker run -d --network=front_net -p 9292:9292 --name ui <your-login>/ui:1.0
    > docker run -d --network=back_net --name comment <your-login>/comment:1.0
    > docker run -d --network=back_net --name post <your-login>/post:1.0
    > docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
	```
	- Docker при инициализации контейнера может подключить к нему только 1 сеть. Поэтому нужно поместить контейнеры post и comment в обе сети.
	```bash
	> docker network connect <network> <container>
	> docker network connect front_net post
	> docker network connect front_net comment
	```
- Docker-compose
  - [Установка dockercompose](https://docs.docker.com/compose/install/#install-compose)
  - запустим приложение из директории **src/:**
    - ***docker-compose up -d -p new_project_name***
	- ***docker-compose ps***
  - Параметризованные параметры хранятся в отдельном файл c расширением **src/.env**