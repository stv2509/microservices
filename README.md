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
</p></details>
  
#  
# Homework 18-19. Gitlab-ci-1

- Подготовим инсталляцию Gitlab CI
- Подготовим репозиторий с кодом приложения
- Опишем для приложения этапы непрерывной интеграции

### В процессе сделано:

<details><p>

- Создадим instance при помощи terraform
  ```bash
  cd gitlab-ci/terraform/stage
  terraform apply
  TERRAFORM_STAGE="/vagrant_data/microservices/gitlab-ci/terraform/stage"
  export TERRAFORM_STAGE
  ```
- При помощи ansible установим docker и gitlab-ci
  - для установки docker используем готовую роль **"geerlingguy.docker"**
  - ansible запустит скрипт docker-compose.sh, кторый сгенерит файл docker-compose.yml, подставив ip-address из terraform
  - установим gitlab-ci, при помощи shell-модуля, т.к. ansible не работает с версией "docker-compose > 0.19"
  ```bash
  cd gitlab-ci/ansible
  ansible-playbook playbooks/gitlab-docker.yml
  ```
- Создадим группу "homework" и проект "example" в gitlab-ci, добавим в него новую ветку "gitlab-ci-1"
```bash
> git checkout -b gitlab-ci-1
> git remote add gitlab http://\<your-vm-ip\>/homework/example.git
> git push gitlab gitlab-ci-1
```
- Добавим в репозиторий файл ".gitlab-ci.yml"
- Запустим Runner и зарегистрируем его в интерактивном режиме
  - *http://\<your-vm-ip\>/ -> Settings -> CI/CD -> Runners settings*
  - *$ /srv/gitlab/start-runner.sh*

</p></details>
  
#  
# Homework 20. Gitlab CI for continuous delivery

- Расширим существующий пайплайн в Gitlab CI
- Определим окружения
- Создадим новый проект на gitlab "example2"

### В процессе сделано:

<details><p>

- В связи с нехваткой времени задачи с \*\* были временно пропущены

</p></details>

#  
# Homework 21. Prometheus - Monitoring system & time series database

- Prometheus: запуск, конфигурация, знакомство с Web UI
- Мониторинг состояния микросервисов
- Сбор метрик хоста с использованием экспортера


### В процессе сделано:
<details><p>

- Создадим правило фаервола для Prometheus и Puma:
  ```bash
  $ gcloud compute firewall-rules create prometheus-default --allow tcp:9090
  $ gcloud compute firewall-rules create puma-default --allow tcp:9292
  ```
- [Создадим Docker хост в GCE и запустим Prometheus](https://gist.githubusercontent.com/stv2509/b0894c38002903781bd3e6147f064bda/raw/cd10974d96f2d0c81a3cc7b171f52d78f411dec3/docker-machine-prometeus)
- Проверим работу Prometheus:
  - ***http://\<your-vm-ip\>:9090***
- Определим простой конфигурационный файл для сбора метрик с наших микросервисов:
  - **monitoring/prometheus/prometheus.yml**
- Создадим свой Docker образ prometheus:
  ```bash
  $ cd monitoring/prometheus/
  $ export USER_NAME=username
  $ docker build -t $USER_NAME/prometheus .
  ```
- Создадим образы микросервисов:
  ```bash
  $ cd src/*
  /src/ui $ bash docker_build.sh
  /src/post-py $ bash docker_build.sh
  /src/comment $ bash docker_build.sh
  ```
- Запустим наш Prometheus совместно с микросервисами:
  - **cd docker/**
  - **docker-compose up -d**
- Посмотрим список endpoint-ов, с которых собирает информацию Prometheus:
  - ***http://\<your-vm-ip\>:9090/targets***
- Состояние сервиса UI
  - В веб интерфейсе Prometheus выполните поиск по названию метрики *ui_health*
  - Остановим post сервис
    - **$ docker-compose stop post**
  - Посмотрим, не случилось ли чего плохого с сервисами, от которых зависит UI сервис. Наберем в строке выражений *ui_health_* и Prometheus нам предложит дополнить названия метрик.
    - *ui_health_comment_availability* - с сервисом все впорядке
    - *ui_health_post_availability* - с post сервисом все плох
  - Проблему мы обнаружили. Поднимем post сервис:
    - **docker-compose start post**
- **Exporters** - Программа, которая делает метрики доступными для сбора Prometheus
- Воспользуемся **Node Exporters** для сбора информации о работе Docker хоста
- Чтобы сказать Prometheus следить за еще одним сервисом, нам нужно добавить информацию о нем в конфиг **monitoring/prometheus/prometheus.yml:**
  ```bash
  scrape_configs:
  ...
  - job_name: 'node'
    static_configs:
      - targets:
        - 'node-exporter:9100'
  ```
- Соберем новый Docker для Prometheus:
  - **monitoring/prometheus $ docker build -t $USER_NAME/prometheus .**
- Пересоздадим наши сервисы
  ```bash
  $ docker-compose down
  $ docker-compose up -d
  ```
- Отправим собранные вами образы на DockerHub:
  ```bash
  $ docker login
  Login Succeeded
  $ docker push $USER_NAME/ui
  $ docker push $USER_NAME/comment
  $ docker push $USER_NAME/post
  $ docker push $USER_NAME/prometheus
  ```
</p></details>

#  
# Homework 22. Prometheus. cAdvisor. Grafana. AlertManager

- Мониторинг Docker контейнеров
- Визуализация метрик
- Сбор метрик работы приложения и бизнес метрик
- Настройка и проверка алертинга


### В процессе сделано:
<details><p>

- Добавлен cAdvisor
  - Добавим информацию о сервисе cAdvisor в конфигурацию Prometheus, чтобы он начал собирать метрики.
  - Не забываем открывать порты для новых сервисов
  - Пересоберем образ Prometheus с обновленной конфигурацией.
  - Запустим сервисы:
    ```bash
    $ docker-compose up -d
    $ docker-compose -f docker-compose-monitoring.yml up -d
    ```
  - Проверим работу cAdvisor:
    - ***http://\<your-vm-ip\>:8080***
  - Визуализация метрик. Grafana
  - Добавим сервис Grafana в docker-compose-monitoring.yml
    - **docker-compose -f docker-compose-monitoring.yml up -d grafana**
    - ***http://\<your-vm-ip\>:3000***
	- добавим источник данных **"Add data source":**
	```
	Name:    Prometheus Server
	Default: yes
	Type:    Prometheus
	URL:     http://prometeus:9090
	Access:  proxy
	```
  - Перейдем на сайт [Grafana](https://grafana.com/dashboards) и выберем в качестве источника данных нашу систему мониторинга Prometheus dashboard *"Docker and system monitoring"* (cAdvisor/Prometheus)
  - Нажмем загрузить *"json"* и сохраним его под именем **monitoring/grafana/dashboards/DockerMonitoring.json**
  - Откроем вновь веб интерфейс Grafana и выберем импортировать шаблон. Должен появиться набор графиков с информацией о состоянии хостовой системы и работе контейнеров.
- Сбор метрик приложения
  - Добавим информацию о *"post"* сервисе в конфигурацию Prometheus (prometheus.yml)
    ```bash
	scrape_configs:
    ...
     - job_name: 'post'
       static_configs:
         - targets:
           'post:5000'
    ```
  - Пересоздадим нашу Docker инфраструктуру мониторинга:
  ```bash
  $ docker-compose -f docker-compose-monitoring.yml down
  $ docker-compose -f docker-compose-monitoring.yml up -d
  ```
- Сохраним изменения дашборда и эспортируем его в JSON файл, который загрузим на нашу локальную машину
- "*Share dashboard*" -> "*Export*" -> "*Save to file*" -> **monitoring/grafana/dashboards/UI_Service_Monitoring.json**
- **Alertmanager** - дополнительный компонент для системы мониторинга **Prometheus**
  -  Соберем образ alertmanager:
    - ***monitoring/alertmanager $ docker build -t $USER_NAME/alertmanager .***
  - Добавим новый сервис в компоуз файл мониторинга
  ```bash
  services:
  ...
  alertmanager:
    image: ${USER_NAME}/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - 9093:9093
  ```
  - Создадим файл ***monitoring/prometheus/alerts.yml*** определим условия при которых должен срабатывать алерт и посылаться *Alertmanager-у*
  - Добавим операцию копирования данного файла в ***monitoring/prometheus/Dockerfile:***
    - **ADD alerts.yml /etc/prometheus/**
  - Добавим информацию о правилах, в конфиг ***microservices/monitoring/prometheus/prometheus.yml***
    ```bash
	global:
       scrape_interval: '5s'
    ...
    rule_files:
      - 'alerts.yml'
    alerting:
      alertmanagers:
        - scheme: http
    static_configs:
      - targets:
        - 'alertmanager:9093'
    ```
  - Пересоберем образ Prometheus (cd monitoring/prometheus):
    - **$ docker build -t $USER_NAME/prometheus .**
  - Пересоздадим нашу Docker инфраструктуру мониторинга:
  ```bash
  $ docker-compose -f docker-compose-monitoring.yml down
  $ docker-compose -f docker-compose-monitoring.yml up -d
  ```
  - Алерты можно посмотреть в веб интерфейсе Prometheus ***Alerts***
  - Остановим один из сервисов и подождем одну минуту
    - ***$ docker-compose stop post***
  - В **slack** канал должно придти сообщение
	```bash
	AlertManager APP [1:35 PM]
       [FIRING:1] InstanceDown (post:5000 post page)
	```
- Отправим собранные нами образы на DockerHub:
  ```bash
  $ docker login
  Login Succeeded
  $ docker push $USER_NAME/ui
  $ docker push $USER_NAME/comment
  $ docker push $USER_NAME/post
  $ docker push $USER_NAME/prometheus
  ```
</p></details>