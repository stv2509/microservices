# microservices

[![Build Status](https://travis-ci.org/stv2509/microservices.svg?branch=master)](https://travis-ci.org/stv2509/microservices)

<details>
  <summary>Создать образ на GCP: </summary>

```bash
docker-machine create --driver google \
--google-project docker-181710 \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
docker-host
```
</details>

##

<details>
  <summary>Приложение монолит docker-monolith/ :</summary>
  
* Dockerfile - текстовое описание нашего образа

* mongod.conf - преподготовленный конфиг для mongodb

* db_config - содержит переменную со ссылкой на mongodb

* start.sh - скрипт запуска приложения

* default-allow-9292.sh - скрипт для проверки firewall

</details>

##

<details>
<summary>Приложение из нескольких компонентов src/ :</summary>
  
* post-py - сервис отвечающий за написание постов
  
* comment - сервис отвечающий за написание комментариев

* ui - веб-интерфейс для других сервисов

</details>

##

<details>
<summary>Команды docker для компонентов :</summary>

#
* Создание контейнеров:
```
docker pull mongo:latest 
docker build -t stv2509/post:2.0 ./post-py 
docker build -t stv2509/comment:2.0 ./comment 
docker build -t stv2509/ui:2.0 ./ui
```
* Создание сети
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post stv2509/post:2.0
docker run -d --network=reddit --network-alias=comment stv2509/comment:2.0
docker run -d --network=reddit -p 9292:9292 stv2509/ui:2.0
```
* Запуск контейнеров
```
docker volume create reddit_db

docker run -d --network=reddit -v reddit_db:/data/db --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post stv2509/post:2.0
docker run -d --network=reddit --network-alias=comment stv2509/comment:2.0
docker run -d --network=reddit -p 9292:9292 stv2509/ui:2.0
```
</details>
