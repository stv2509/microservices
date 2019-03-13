# microservices

[![Build Status](https://travis-ci.org/stv2509/microservices.svg?branch=master)](https://travis-ci.org/stv2509/microservices)

* Создать образ на GCP:

```bash
docker-machine create --driver google \
--google-project docker-181710 \
--google-zone europe-west1-b \
--google-machine-type f1-micro \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
docker-host
```

<details>
  <summary>Приложение монолит docker-monolith/ :</summary>
  
* Dockerfile - текстовое описание нашего образа

* mongod.conf - преподготовленный конфиг для mongodb

* db_config - содержит переменную со ссылкой на mongodb

* start.sh - скрипт запуска приложения

* default-allow-9292.sh - скрипт для проверки firewall

</details>

#

<details>
<summary>Приложение из нескольких компонентов src/ :</summary>
  
* post-py - сервис отвечающий за написание постов
  
* comment - сервис отвечающий за написание комментариев

* ui - веб-интерфейс для других сервисов

</details>
