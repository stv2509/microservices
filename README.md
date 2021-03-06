[![Build Status](https://travis-ci.org/stv2509/microservices.svg?branch=master)](https://travis-ci.org/stv2509/microservices)


### [Курсы DevOps практики и инструменты](https://otus.ru/lessons/devops-praktiki-i-instrumenty/)


## ШПАРГАЛКИ:
<details><p>

## [Шпаргалка-1 с командами Docker](https://habr.com/ru/company/flant/blog/336654/)

## [Шпаргалка-2 с командами Docker](https://github.com/eon01/DockerCheatSheet)

## [Большой Docker FAQ: отвечаем на самые важные вопросы](https://xakep.ru/2015/06/04/docker-faq/)

## [Драйверы которые поддерживает docker-machine](https://docs.docker.com/machine/drivers/)

# [Grok-patterns](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns)

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

</p></details>

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

#  
# Homework 23-24. Logging and Docker. EFK Stack

- Сбор неструктурированных логов
- Визуализация логов
- Сбор структурированных логов

### В процессе сделано:
<details><p>

- [Создадим Docker хост в GCE и настроим локальное окружение на работу с ним](https://gist.github.com/stv2509/4fe8a00f834e3baf1572b8724a2a9110)
- Создадим образы микросервисов:
  ```bash
  $ cd src/*
  /src/ui      $ bash docker_build.sh
  /src/post-py $ bash docker_build.sh
  /src/comment $ bash docker_build.sh
  ```
- Создадим отдельный compose-файл для нашей системы логирования **docker/docker-compose-logging.yml**
- Создадим файл конфигурации для *Fluentd* **logging/fluentd/fluent.conf**
- Создадим образ *Fluentd* с нужной нам конфигурацией **logging/fluentd/Dockerfile**
  - **docker build -t $USER_NAME/fluentd .**
- Запустите сервисы приложения из директории **docker/:**
  - **$ docker-compose up -d**
- Просмотрим логи post-сервиса:
  - **docker/ $ docker-compose logs -f post**
  - создадим несколько постов, понаблюдаем за терминалом
- Отправка логов во *Fluentd*
  - Определим драйвер логирования для сервиса *post* в **docker/docker-compose.yaml:**
  ```bash
  ...
  post:
   ...
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
  ```
- Запустим систему логирования и перезапустим сервисы:
  ```bash
  $ docker-compose -f docker-compose-logging.yml up -d
  $ docker-compose down
  $ docker-compose up -d
  ```
- Добавим фильтр для парсинга json логов **logging/fluentd/fluent.conf:**
  ```bash
  <source>
    @type forward
    port 24224
    bind 0.0.0.0
  </source>
  
  <filter service.post>
    @type parser
    format json
    key_name log
  </filter>
  
  <match *.**>
    @type copy
    ...
  ```
- Персоберем образ и перезапустим сервисы:
  ```bash
  logging/fluentd $ docker build -t $USER_NAME/fluentd .
  docker/ $ docker-compose -f docker-compose-logging.yml up -d fluentd
  ```
- Создадим пару новых постов и поиск по ним в **Kibana**:
  - search ***event: post_create***
- Неструктурированные логи:
  - Определим для ui сервиса драйвер для логирования *fluentd* в **docker/docker-compose.yml**
  ```bash
  ui:
  ...
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
  ```
  - Перезапустим ui сервис:
  ```bash
  $ docker-compose stop ui
  $ docker-compose rm ui
  $ docker-compose up -d
  ```
  - Добавим фильтр для парсинга логов ui используем **grok**-шаблоны **logging/fluentd/fluent.conf:**
  ```bash
  <filter service.ui>
    @type parser
    format grok
    grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \|
    message='%{GREEDYDATA:message}'
    key_name message
    reserve_data true
  </filter>
  ```
  - Перезапустим сервисы:
  ```bash
  logging/fluentd $ docker build -t $USER_NAME/fluentd .
  $ docker-compose -f docker-compose-logging.yml down
  $ docker-compose -f docker-compose-logging.yml up -d
  ```
  - Проверим результат.
</p></details>

#  
# Homework 25-26. Introduction to Kubernetes

- Разобрать на практике все компоненты Kubernetes, развернуть их вручную используя The Hard Way
- Ознакомиться с описанием основных примитивов нашего приложения и его дальнейшим запуском в Kubernetes.

### В процессе сделано:
<details><p>

- Создадим первый Deployment manifest **kubernetes/reddit/post-deployment.yml:**
  ```bash
  ---
  apiVersion: apps/v1beta2
  kind: Deployment
  metadata:
    name: post-deployment
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: post
    template:
      metadata:
        name: post
        labels:
          app: post
      spec:
        containers:
        - image: USER_NAME/post
          name: post
  ```
- Пройдите [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- Проверить, что **kubectl apply -f** проходит по созданным до этого deployment-ам (ui, post, mongo, comment) и поды запускаются:
  ```bash
  $ kubectl get pods -o wide
  NAME                                  READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE
  busybox-bd8fb7cbd-mpf5k               1/1     Running   0          59m   10.200.1.2   worker-1   <none>
  comment-deployment-6df88f7fb8-7j5vt   1/1     Running   0          14m   10.200.2.3   worker-2   <none>
  mongo-deployment-57b8d4d88c-ggx7n     1/1     Running   0          13m   10.200.2.4   worker-2   <none>
  nginx-dbddb74b8-2vhxc                 1/1     Running   0          46m   10.200.1.3   worker-1   <none>
  post-deployment-55bdc66fcd-rhjjw      1/1     Running   0          21m   10.200.0.3   worker-0   <none>
  ui-deployment-795cdbb698-bn2s8        1/1     Running   0          14m   10.200.0.4   worker-0   <none>
  ```
</p></details>

#  
# Homework 27. Kubernetes, Controllers, Security

- Развернуть локальное окружение для работы с Kubernetes
- Развернуть Kubernetes в GKE
- Запустить reddit в Kubernetes

### В процессе сделано:

- **Создание локального окружения для работы с Kubernetes:**
<details><p>

- Подготовим локальное окружение:
  - Установим **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)**
  - Директории **~/.kube** - содержит служебную инфу для kubectl (конфиги, кеши, схемы API)
  - Установим **[VirtualBox](https://www.virtualbox.org/wiki/Downloads)**
  - Установим **[minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)**
- Запустим наш Minukube-кластер:
  - **$ minikube start --cpus 2 --memory 1024 --disk-size 10g**
- Проверим, что кластер развернут:
  ```bash
  $ kubectl get nodes
    NAME       STATUS    ROLES     AGE       VERSION
    minikube   Ready     master    4m        v1.14.0
  ```
- Порядок конфигурирования **kubectl**:
  - Создать cluster:
    -  $ kubectl config set-cluster ... **cluster_name**
  - Создать данные пользователя (credentials)
    - $ kubectl config set-credentials ... **user_name**
  - Создать контекст
    - $ kubectl config set-context **context_name** --cluster=**cluster_name** --user=**user_name**
  - Использовать контекст
    - $ kubectl config use-context **context_name**
  - Посмотреть текущий контекст
  ```bash
  $ kubectl config current-context
    minikube
  ```
  - Посмотреть список всех контекстов
  ```bash
  $ kubectl config get-contexts
  CURRENT       NAME                 CLUSTER                 AUTHINFO    NAMESPACE
          kubernetes-the-hard-way   kubernetes-the-hard-way   admin
    *     minikube                  minikube                  minikube
  ```
- Запустим приложение:
  ```bash  
  $ kubectl apply -f kubernetes/reddit/ui-deployment.yml
  deployment.apps/ui created
  ```
- Пробросим сетевые порты POD-ов на локальную машину
  ```bash
  $ kubectl get pods --selector component=ui
  $ kubectl port-forward <pod-name> 8080:9292  # (local-port:pod-port)
  ```
- Зайдем в браузере на **http://localhost:8080**, UI работает.
- Подключим остальные компоненты
  ```bash
  $ kubectl apply -f comment-deployment.yml
  $ kubectl apply -f post-deployment.yml
  ```
- Для связи компонент между собой и с внешним миром используется объект **Service**
  - **$ kubectl apply -f kubernetes/reddit/comment-service.yml**
  - Посмотрите по label-ам соответствующие POD-ы:
  ```bash
  $ kubectl describe service comment | grep Endpoints
  Endpoints:         172.17.0.11:9292,172.17.0.12:9292,172.17.0.13:9292
  
  $ kubectl exec -ti <pod-name> nslookup comment
  nslookup: can't resolve '(null)': Name does not resolve

  Name:      comment
  Address 1: 10.104.40.232 comment.default.svc.cluster.local
  ```
  - Сделаем Service для БД comment: **kubernetes/reddit/comment-mongodb-service.yml**
  - Сделаем Service для БД post: **kubernetes/reddit/post-mongodb-service.yml**
- Обеспечим доступ к ui-сервису снаружи **kubernetes/reddit/ui-service.yml**
  - Тип сервиса **NodePort** - на каждой ноде кластера открывает порт из диапазона **30000-32767** и переправляет трафик с этого порта на тот, который указан в **targetPort Pod** (похоже на стандартный expose в docker)
  ```bash
  ...
  spec:
   type: NodePort
   ports:
   - nodePort: 32092
     port: 9292
     protocol: TCP
     targetPort: 9292
  ...
  ```
- Minikube может перенаправлять на web-странцы с сервисами которые были помечены типом **NodePort**
  ```bash
  C:\Users\1>minikube service list
  |-------------|------------|-----------------------------|
  |  NAMESPACE  |    NAME    |             URL             |
  |-------------|------------|-----------------------------|
  | default     | comment    | No node port                |
  | default     | comment-db | No node port                |
  | default     | kubernetes | No node port                |
  | default     | post       | No node port                |
  | default     | post-db    | No node port                |
  | default     | ui         | http://192.168.99.100:32092 |
  | kube-system | kube-dns   | No node port                |
  |-------------|------------|-----------------------------|
  ```
- Получим список расширений:
  ```bash
  $ minikube addons list
  - addon-manager: enabled
  - dashboard: enabled
  - default-storageclass: enabled
  - efk: disabled
  - freshpod: disabled
  - gvisor: disabled
  - heapster: disabled
  - ingress: disabled
  - logviewer: disabled
  - metrics-server: disabled
  - nvidia-driver-installer: disabled
  - nvidia-gpu-device-plugin: disabled
  - registry: disabled
  - registry-creds: disabled
  - storage-provisioner: enabled
  - storage-provisioner-gluster: disabled
  ```
- Включим и зайдем в Dashboard:
  ```bash
  $ minikube service kubernetes-dashboard -n kube-system
  
  $ minikube dashboard --url
  -   Enabling dashboard ...
  -   Verifying dashboard health ...
  -   Launching proxy ...
  -   Verifying proxy health ...
  http://127.0.0.1:3561/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
  ```
- **Namespace:**
- Cоздадим свой Namespace **kubernetes/reddit/dev-namespace.yml**
  - **$ kubectl apply -f dev-namespace.yml**
- Запустим приложение в **dev** неймспейсе:
  - **$ kubectl apply -n dev -f ...**
  - Если возник конфликт портов у ui-service, то убираем из описания значение **NodePort**
- Смотрим результат:
  - **$ minikube service ui -n dev**
- Добавим информацию об окружении внутрь контейнера UI **kubernetes/reddit/ui-deployment.yml**:
  ```bash
  ...
  spec:
    containers:
    - image: USER_NAME/ui
      name: ui
      env:
      - name: ENV
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
  ```
- Смотрим результат:
  - **$ minikube service ui -n dev**
  - В заголовке появиться **dev:** *"Microservices Reddit in* **dev** *ui-8644b898fd-h8wkm container"*
</p></details>

#

- **Google Kubernetes Engine:**
<details><p>

- Зайдите в свою gcloud console, перейдите в *"kubernetes clusters"*
- Нажмите *"создать Cluster"*
- Жмем *"Создать"* и ждем, пока поднимется кластер
- Подключимся к GKE для запуска нашего приложения:
  - Нажмите *"Connect"* и скопируйте команду вида:
  **$ gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project docker-182508**
  - Введите в консоли скопированную команду. В результате в файл **~/.kube/config** будут добавлены **user**, **cluster** и **context** для подключения к кластеру в **GKE.**
  - Проверьте, что текущий контекст будет выставлен для подключения к этому кластеру
    - **$ kubectl config current-context**
- Запустим наше приложение в GKE:
  - Создадим dev namespace
    - **$ kubectl apply -f ./kubernetes/reddit/dev-namespace.yml**
  - Задеплоим все компоненты приложения в namespace dev
    - **$ kubectl apply -f ./kubernetes/reddit/ -n dev**
- Создайте правила firewall и откройте порты **tcp:30000-32767** kubernetes для публикации сервисов
- Посмотрим внешний IP-адрес любой ноды из кластера
  ```bash
   $ kubectl get nodes -o wide
  NAME                                                STATUS   ROLES    AGE   VERSION           EXTERNAL-IP      
  gke-standard-cluster-1-default-pool-3fc50298-2t9b   Ready    <none>   15m   v1.10.12-gke.14   35.195.212.157 
  gke-standard-cluster-1-default-pool-3fc50298-mdls   Ready    <none>   17m   v1.10.12-gke.14   35.195.109.252
  ```
- Найдите порт публикации сервиса ui
  ```bash
  $ kubectl describe service ui -n dev | grep NodePort
    Type: NodePort
    NodePort: <unset> 31474/TCP
  ```
- Идем по адресу **http://\<node-ip\>:\<NodePort\>** наш сервис работает.
- Запустим [Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) для кластера GKE
 - Kubernetes Engine -> Clusters -> EDIT -> Add-ons -> Kubernetes dashboard -> Enabled
 - **$ kubectl proxy**
 - Заходим по адресу *http://localhost:8001/ui* (Жмем "SKIP") или *http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login*
 - У dashboard не хватает прав, чтобы посмотреть на кластер, его не пускает **RBAC**
 - Назначим нашему *Service Account* роль с достаточными правами на просмотр информации о кластере
   - **$ kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard**
 - Снова зайдем по адресу *http://localhost:8001/ui* - dashboard работает
</p></details>

#  
# Homework 28. Kubernetes. Network. Storage.

- Сетевое взаимодействие в Kubernetes
- Хранение данных в Kubernetes

### В процессе сделано:
<details><p>

- **[LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)**
  - Настроим соответствующим образом Service UI **ui-service.yml**
  ```bash
  ....
  spec:
    type: LoadBalancer # Тип LoadBalancer
    ports:
    - port: 80         # Порт, который будет открыт на балансировщике
      nodePort: 32092  # на ноде будет открыт порт, но нам он не нужен и его можно даже убрать
      protocol: TCP
      targetPort: 9292 # Порт POD-а
  ...
  ```
  - **$ kubectl apply -f ./kubernetes/reddit/ui-service.yml -n dev**
  - Проверим, что получилось:
  ```bash
  $ kubectl get service -n dev --selector component=ui
  NAME   TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
  ui     LoadBalancer   10.7.242.18   <pending>     80:31372/TCP   1h
  ```
  - Немного подождем и проверим еще раз, появился **"EXTERNAL-IP"**
  ```bash
  $ kubectl get service -n dev --selector component=ui
  NAME   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
  ui     LoadBalancer   10.7.242.18   104.199.87.67   80:31372/TCP   1h
  ```
  - Наш IP-адрес для доступа **104.199.87.67:80**
  - Откроем консоль GCP и посмотрим созданное правило балансировки:
    - **GCP -> Network services -> Load balancer details**
- **[Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)**
  - Сами по себе Ingress’ы это просто правила. Для их применения нужен **Ingress Controller**
  - Ingress Controller (В отличие от остальных контроллеров k8s - он не стартует вместе с кластером.) - это скорее плагин (а значит и отдельный POD), который состоит из 2-х функциональных частей:
    - Приложение, которое отслеживает через k8s API новые объекты Ingress и обновляет конфигурацию балансировщика
    - Балансировщик (Nginx, haproxy, traefik,...), который и занимается управлением сетевым трафиком
	- Создадим Ingress **kubernetes/reddit/ui-ingress.yml** для сервиса UI
	- В **GCP -> Network services -> Load balancer details** должно появиться наше правило.
	- Посмотрим в сам кластер:
	```bash
	$ kubectl get ingress -n dev
    NAME   HOSTS   ADDRESS       PORTS   AGE
    ui     *       34.96.85.47   80      10m
	```
	- У нас 2 балансировщика для 1 сервиса, уберем один балансировщик из **kubernetes/reddit/ui-service.yml:**
	```bash
	...
	spec:
      type: NodePort
      ports:
      - port: 9292
        protocol: TCP
        targetPort: 9292
	...
	```
	- **$ kubectl apply -f kubernetes/reddit/ui-service.yml -n dev**
	- Заставим работать Ingress Controller как классический веб - **kubernetes/reddit/ui-ingress.yml:**
	```bash
	---
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: ui
    spec:
      rules:
      - http:
        paths:
        - path: /*
        backend:
          serviceName: ui
          servicePort: 9292
	```
	- **$ kubectl apply -f kubernetes/reddit/ui-ingress.yml**. Может долго запускаться. Ждите.
- **[Secret](https://kubernetes.io/docs/concepts/configuration/secret/)**
  - Защитим наш сервис с помощью TLS.
  ```bash
  $ kubectl get ingress -n dev
    NAME   HOSTS   ADDRESS       PORTS   AGE
    ui     *       34.96.85.47   80      3h
    
  $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.96.85.47"
    
  $ kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
  
  #Проверить можно командой
  $ kubectl describe secret ui-ingress -n dev
  ```
  - Настроим Ingress на прием только HTTPS траффика **kubernetes/reddit/ui-ingress.yml:**
  ```bash
  ...
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: ui
    annotations:
      kubernetes.io/ingress.allow-http: "false"  # Отключаем проброс HTTP
  spec:
    tls:
      - secretName: ui-ingress  # Подключаем наш сертификат
    backend:
      serviceName: ui
      servicePort: 9292
  ```
  - Применим конфигурацию
    - **$ kubectl apply -f ui-ingress.yml -n dev**
  - Откроем консоль GCP и посмотрим, что осталось одно созданное правило HTTPS(443) балансировки:
    - **GCP -> Network services -> Load balancer details** или
	- **$ kubectl.exe get ingress -n dev**
  - Если осталось еще правило HTTP(80), тогда нужно его вручную удалить и пересоздать:
  ```bash
  $ kubectl delete ingress ui -n dev
  $ kubectl apply -f ui-ingress.yml -n dev
  ```
  - Заходим на страницу нашего приложения по https, подтверждаем исключение безопасности (у нас сертификат самоподписанный) и видим что все работает. Правила Ingress могут долго применяться, если не получилось зайти с первой попытки - подождите и попробуйте еще раз
  - **kubectl describe ingress -n dev**
  - Запишем пункты выше в манифест **kubernetes/reddit/ui-ingress-secret.yml**
- **[Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)**  - инструмент для декларативного описания потоков трафика. Ограничим трафик, поступающий на mongodb отовсюду, кроме сервисов post и comment.
  - Включим Network Policy в GCP
  ```bash
  # Найдем имя кластера
  $ gcloud beta container clusters list
    NAME                LOCATION        MASTER_VERSION  MASTER_IP     MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
    standard-cluster-1  europe-west1-b  1.11.8-gke.6    35.233.64.87  n1-standard-1  1.11.8-gke.6  2          RUNNING

  # Включим network-policy для GKE.
  $ gcloud beta container clusters update standard-cluster-1 --zone=europe-west1-b --update-addons=NetworkPolicy=ENABLED
  Updating standard-cluster-1...
  ...........................done.
  
  $ gcloud beta container clusters update standard-cluster-1 --zone=europe-west1-b  --enable-network-policy
  Do you want to continue (Y/n)?
  Updating standard-cluster-1...
  .done.
  ```
  - Создадим манифест для mongo **kubernetes/reddit/mongo-network-policy.yml** и применим
    - **$ kubectl apply -f mongo-network-policy.yml -n dev**
  - Посмотрим на созданные правила
    - **$ kubectl describe NetworkPolicy -n dev**
- **[Хранилище для базы](https://kubernetes.io/docs/concepts/storage/volumes/)
  - Подключим volume в **kubernetes/reddit/mongo-deployment.yml**
  Тип Volume **emptyDir.** При создании пода с таким типом просто создается пустой docker volume.
  При остановке POD’a содержимое **emtpyDir** удалится навсегда.
  ```bash
  ---
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
    name: mongo
  ...
      spec:
        containers:
          - image: mongo:lates
            name: mongo
            volumeMounts:
            - name: mongo-persistent-storage
              mountPath: /data/db
      volumes:
        - name: mongo-persistent-storage
          emptyDir: {}
  ```
  - Создадим диск в Google Cloud
    - **gcloud compute disks create --size=25GB --zone=europe-west1-b reddit-mongo-disk**
  - Добавим новый Volume в **kubernetes/reddit/mongo-deployment.yml**
  ```bash
  ---
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
    name: mongo
  ...
      spec:
        containers:
          - image: mongo:lates
            name: mongo
            volumeMounts:
            - name: mongo-persistent-storage
              mountPath: /data/db
      volumes:
        - name: mongo-gce-pd-storage
          gcePersistentDisk:
            pdName: reddit-mongo-disk
            fsType: ext4  
  ```
  - **$ kubectl apply -f mongo-deployment.yml -n dev**
  - Создадим post и удалим *deployment*
    - **$ kubectl delete deploy mongo -n dev**
  - Заново подключим *deployment* и проверим, что post остался на месте.
- **[PersistentVolume ](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)**
  - Создадим описание PersistentVolume **kubernetes/reddit/mongo-volume.yml**
  ```bash
  ---
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: reddit-mongo-disk
  spec:
    capacity:
      storage: 25Gi
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    gcePersistentDisk:
      fsType: "ext4" 
      pdName: "reddit-mongo-disk"
  ```
  - Добавим PersistentVolume в кластер
   - **$ kubectl apply -f mongo-volume.yml -n dev**
  - Мы создали ресурс дискового хранилища, распространенный на весь кластер, в виде **PersistentVolume.**
- **[PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)**
  - Создадим описание PersistentVolumeClaim (PVC) **kubernetes/reddit/mongo-claim.yml**
  ```bash
  ---
  kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: mongo-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 15Gi
  ```
  - **$ kubectl apply -f mongo-claim.yml -n dev**
  - **$ kubectl describe storageclass standard -n dev**
  - Подключим PVC к нашим Pod'ам **kubernetes/reddit/mongo-deployment.yml**
  ```bash
  ---
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
  name: mongo
  ...
    spec:
    containers:
    - image: mongo:latest
      name: mongo
      volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
    volumes:
      - name: mongo-persistent-storage  # Имя PersistentVolumeClame'а
        persistentVolumeClaim:
          claimName: mongo-pvc
  ```
  - Обновим описание нашего Deployment’а
    - **$ kubectl apply -f mongo-deployment.yml -n dev**
- Создадим **StorageClass** Fast: **kubernetes/reddit/storage-fast.yml**
  - Добавим StorageClass в кластер
    - **$ kubectl apply -f storage-fast.yml -n dev**
- **PVC + StorageClass**
  - Создадим описание PersistentVolumeClaim **kubernetes/reddit/mongo-claim-dynamic.yml**
    - Добавим StorageClass в кластер
    - **$ kubectl apply -f mongo-claim-dynamic.yml -n dev**
  - Подключим PVC к нашим Pod'ам **kubernetes/reddit/mongo-deployment.yml**
  ```bash
  ---
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
  name: mongo
  ...
    spec:
    containers:
    - image: mongo:latest
      name: mongo
      volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
    volumes:
      - name: mongo-persistent-storage  # Имя PersistentVolumeClame'а
        persistentVolumeClaim:
          claimName: mongo-pvc-dynamic  # Обновим PersistentVolumeClaim
  ```
  - Обновим описание нашего Deployment’а
    - **$ kubectl apply -f mongo-deployment.yml -n dev**
- Посмотрим какие в итоге у нас получились **PersistentVolume'ы:**
  ```bash
  $ kubectl get persistentvolume -n dev
  NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                   STORAGECLASS   REASON   AGE
  pvc-05270d79-6b42-11e9-b8fc-42010a84014d   15Gi       RWO            Delete           Bound       dev/mongo-pvc           standard                36m
  pvc-976f7c75-6b46-11e9-b8fc-42010a84014d   10Gi       RWO            Delete           Bound       dev/mongo-pvc-dynamic   fast                    3m
  reddit-mongo-disk                          25Gi       RWO            Retain           Available                                                   42m
  ```
  - *STATUS* - Статус PV по отношению к Pod'ам и Claim'ам
  - *CLAIM* - К какому Claim'у привязан данный PV
  - *STORAGECLASS* - StorageClass данного PV
- На созданные Kubernetes'ом диски можно посмотреть в *GCP -> Compute Engine -> Disks*
</p></details>

#  
# Homework 29. Kubernetes: Helm, Gitlab, Ci_CD

- Работа с Helm
- Развертывание Gitlab в Kubernetes
- Запуск CI/CD конвейера в Kubernetes


### В процессе сделано:
<details><p>

- [Установим Helm](https://github.com/helm/helm/releases)
<details><p>

- Установим серверную часть Helm’а - **Tiller**
  ```bash
  $ kubectl apply -f kubernetes/tiller.yml
  
    #Теперь запустим tiller-сервер
  $ helm init --service-account tiller
  
    #Проверим
  $ kubectl get pods -n kube-system --selector app=helm
  NAME                             READY   STATUS    RESTARTS   AGE
  tiller-deploy-54fc6d9ccc-62r54   1/1     Running   0          1d
  ```
- Создайте директорию **kubernetes/Charts**
- Helm предпочитает **.yaml**
- Создадим файл-описание chart’а ui **kubernetes/Charts/ui/Chart.yaml**
- Создадим директорию **ui/templates** и перенесем в неё все манифесты, разработанные ранее для сервиса ui (ui-service, ui-deployment, ui-ingress). Уберем префикс *'ui-'*) и поменяем расширение на **.yaml**)
- Установим *Chart*
  ```bash
  $ helm install --name test-ui-1 ui/  # Где test-ui-1 - имя релиза
  
  # Посмотрим, что получилось
  $ helm ls
  NAME            REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
  test-ui-1       1               Thu May  2 14:12:04 2019        DEPLOYED        ui-1.0.0        1               default
  ```
- Сделаем шаблон из файла **ui/templates/service.yaml** для запуска нескольких экземпляров (релизов).
  ```bash
  ...
  metadata:
    name: {{ .Release.Name }}-{{ .Chart.Name }} # Уникальное имя запущенного ресурса
    ...
	release: {{ .Release.Name }} # Помечаем, что сервис из конкретного релиза
  selector:
    ...
    release: {{ .Release.Name }} # Выбираем POD-ы только из этого релиза
  ```
- Шаблонизируем подобным образом остальные манифесты
- Определим значения собственных переменных в файле **kubernetes/Charts/ui/values.yaml**
- Попробуем установить несколько релизов *ui*
  ```bash
  $ helm install kubernetes/Charts/ui/  --name ui-1
  $ helm install kubernetes/Charts/ui/  --name ui-2
  $ helm install kubernetes/Charts/ui/  --name ui-3
  
    # Должны появиться 3 ингресса
  $ kubectl get ingress
  NAME      HOSTS   ADDRESS          PORTS   AGE
  ui-1-ui   *       35.190.67.102    80      8m
  ui-2-ui   *       34.96.85.47      80      7m
  ui-3-ui   *       35.244.168.219   80      7m
  ```
- Шаблонизируем сервисы *comment* и *post*  
- Итоговая структура должна выглядеть так

  kubernetes/Charts/
  |-- comment
  |   |-- Chart.yaml
  |   |-- templates
  |   |   |-- deployment.yaml
  |   |   `-- service.yaml
  |   `-- values.yaml
  |-- post
  |   |-- Chart.yaml
  |   |-- templates
  |   |   |-- deployment.yaml
  |   |   `-- service.yaml
  |   `-- values.yaml
  |-- reddit
  `-- ui
      |-- Chart.yaml
      |-- templates
      |   |-- deployment.yaml
      |   |-- ingress.yaml
      |   `-- service.yaml
      `-- values.yaml
	  
- **Helper** - это написанная нами функция. Шаблоны этих функция распологаются в файле **_helpers.tpl**
- Пример функции **comment.fullname(kubernetes/Charts/comment/templates/_helpers.tpl), :**
  ```bash
  {{- define "comment.fullname" -}}
  {{- printf "%s-%s" .Release.Name .Chart.Name }}
  {{- end -}}
  
  # которая в результате выдаст то же, что и:
  {{ .Release.Name }}-{{ .Chart.Name }}
  ```
- Вызов функции
  ```bash
  {{ template "comment.fullname" . }}
  ```
  - *"template"* - Функция template
  - *"comment.fullname"* - Название функции для импорта
  - *"."* - область видимости всех переменных для импорта (можно передать .Chart, тогда .Values не будут доступны внутри функции).
  
- **Управление зависимостями:**
  - Создадим единый Chart *kubernetes/Charts/reddit/**, который объединит наши компоненты
  - В директории Chart’а reddit создадим файл **kubernetes/Charts/reddit/requirements.yaml**
  ```bash
  dependencies:
  - name: ui			# Имя и версия должны совпадать
    version: "1.0.0"    # с содеражанием ui/Chart.yml
    repository: "file://../ui"   # Путь относительно расположения самого requiremetns.yml
  - name: post
    version: 1.0.0
    repository: file://../post
  - name: comment
    version: 1.0.0
    repository: file://../comment
  ```
  - В директории **kubernetes/Charts/reddit/** выполним команду:
    - **$ helm dep update**
  - Chart для базы данных найдем в общедоступном helm репозитории:
  ```bash
  $ helm search mongo
  NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
  stable/mongodb                          5.16.4          4.0.9           NoSQL document-oriented database that stores JSON-like do...
  stable/mongodb-replicaset               3.9.2           3.6             NoSQL document-oriented database that stores JSON-like do...
  ```
  - Добавим его в **reddit/requirements.yaml**
  ```bash
  dependencies:
   ...
   - name: comment
     version: 1.0.0
     repository: file://../comment
   - name: mongodb
     version: 5.16.4
     repository: https://kubernetes-charts.storage.googleapis.com
  ```
    - В директории **kubernetes/Charts/reddit/** обновим зависимости:
    - **$ helm dep update**
  - Установим наше приложение:
    - **$ helm.exe install kubernetes/Charts/reddit/ --name reddit-test**
  - Добавим в **kubernetes/Charts/ui/templates/deployment.yaml** переменные окружения,
  чтобы UI-сервис знал как правильно ходить в *post* и *comment* сервисы:
  ```bash
   spec:
    containers:
    ...
      env:
        - name: POST_SERVICE_HOST
          value: {{ .Values.postHost | default (printf "%s-post" .Release.Name) }}
        - name: POST_SERVICE_PORT
          value: {{ .Values.postPort | default "5000" | quote }}
        - name: COMMENT_SERVICE_HOST
          value: {{ .Values.commentHost | default (printf "%s-comment" .Release.Name) }}
        - name: COMMENT_SERVICE_PORT
          value: {{ .Values.commentPort | default "9292" | quote }}  # 'quote' функция для добавления кавычек. Для чисел и булевых значений это важно
        - name: ENV
  ```
  - Не забудте описать созданные переменные в конфигурации Chart’а **kubernetes/Charts/ui/values.yaml**
  ```bash
  ...
  postHost:
  postPort:
  commentHost:
  commentPort:
  ```
  - Теперь можете задавать переменные для зависимостей прямо в **kubernetes/Charts/reddit/values.yaml** самого Chart’а reddit.
  ```bash
  comment: # ссылаемся на переменные чартов из зависимостей
    image:
      repository: stv2509/comment
      tag: latest
    service:
      externalPort: 9292
    post:  # ссылаемся на переменные чартов из зависимостей
      image:
        repository: stv2509/post
        tag: latest
    service:
        externalPort: 5000
  ...
  ```
  - Обновим зависимости чарта *reddit*:
    - **$ helm dep update**
  - Обновим релиз, установленный в k8s:
    - **$ helm upgrade <release-name> ./reddit**
  - Теперь сервис UI должен работать как положено.
</p></details>

#
  
- **Установим Gitlab**
<details><p>


- Добавим репозиторий Gitlab
  - **$ helm repo add gitlab https://charts.gitlab.io**
- Скачаем Chart Gitlab
  ```bash
  $ helm fetch gitlab/gitlab-omnibus --version 0.1.37 --untar
  $ cd gitlab-omnibus
  ```
- Добавим в **gitlab-omnibus/templates/gitlab/gitlab-svc.yaml** "web:80"
  ```bash
  ports:
    ...
    - name: prometheus
      port: 9090
      targetPort: prometheus
    - name: web
      port: 80
      targetPort: workhorse
  ```
- Поправим параметры в **gitlab-omnibus/templates/gitlab-config.yaml:**
  ```bash
  ---
  apiVersion: v1
  kind: ConfigMap
  ...
    data:
      external_scheme: http
      external_hostname: {{ template "fullname" . }}
  ```
- Поправим параметры в **gitlab-omnibus/templates/ingress/gitlab-ingress.yaml:**
  ```bash
  ...
    rules:
      - host: {{ template "fullname" . }}
        http:
          paths:
    ...
  ```
- Установим gitlab
  - **$ helm install --name gitlab . -f values.yaml**

- Найдите выданный IP-адрес ingress-контроллера nginx:
  ```bash
  $ kubectl get service -n nginx-ingress nginx
  NAME    TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)                                   AGE
  nginx   LoadBalancer   10.7.245.5   35.187.179.251   80:30051/TCP,443:32046/TCP,22:31475/TCP   6m
  ```
- Поместите запись в локальный файл **/etc/hosts**
  - **$ echo "35.187.179.251 gitlab-gitlab staging production” >> /etc/hosts**
- Идем по адресу [http://gitlab-gitlab](http://gitlab-gitlab), установим новый пароль.
- Создадим public group, в качестве имени введите свой Docker ID (*Mattermost: disabled*)
- В настройках группы выберите пункт CI/CD
- Добавьте 2 переменные
  - **CI_REGISTRY_USER** - логин в dockerhub
  - **CI_REGISTRY_PASSWORD** - пароль от Docker Hub
- Создайте в группе новый *public* проект с именем **"reddit-deploy"**
- Создайте еще 3 *public* проекта: post, ui, comment
- Локально у себя создайте директорию Gitlab_ci с директориями: reddit-deploy, post, ui, comment
- Перенесем исходные коды сервиса *ui* из **src/ui/** в **kubernetes/Gitlab_ci/ui/**
- В директории **Gitlab_ci/ui**:
  ```bash
  # Инициализируем локальный git-репозиторий
  $ git init
  
  #Добавим удаленный репозиторий
  $ git remote add origin http://gitlab-gitlab/stv2509/ui.git
  
  # Закоммитим и отправим в gitlab
  $ git add .
  $ git commit -m “init”
  $ git push origin master
  ```
- Для *"post"* и *"comment"* проделаем аналогичные действия.
- Перенести содержимое директории **Charts** (папки ui, post, comment, reddit) в **Gitlab_ci/reddit-deploy** и запушем в gitlab-проект reddit-deploy.
- Создадим .gitlab-ci.yml в директориях ui, post, comment и запушем его. Проверем pipelines, проследим, что сборки образов прошли успешно.
- Запустим отдельное окружение в Kubernetes по коммиту в feature-бранч:
  - Изменем в манифесте **reddit-deploy/ui/templates/ingress.yaml** ingress с "gce" на "nginx"
  - Добавим переменную "ingress" в **reddit-deploy/ui/templates/values.yaml**
  ```bash
  ---
  service:
    internalPort: 9292
    externalPort: 9292
  ...
  ingress:
    class: nginx
  ...
  ```
  - В **.gitlab-ci.yml** в директориях ui добавм стадию *review*, запускающую приложение в **k8s** по коммиту в feature-бранчи (не master).
  - Создадим новый бранч в репозитории ui
  ```bash
  $ git checkout -b feature/3
  $ git commit -am "Add review feature"
  $ git push origin feature/3
  ```
  - Проверим запущенные релизы в kubernetes
  ```bash
  $ helm ls
  NAME                            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
  gitlab                          1               Wed May  8 09:25:41 2019        DEPLOYED        gitlab-omnibus-0.1.37                   default
  review-stv2509-ui-zqgovs        1               Wed May  8 12:16:28 2019        DEPLOYED        reddit-1.0.0            1               review
  ```
- **Создадим staging и production среды для работы приложения в reddit-deploy/.gitlab-ci.yml**
  - Этот файл отличается от предыдущих тем, что:
    - Не собирает docker-образы
    - Деплоит на статичные окружения (staging и production)
    - Не удаляет окружения
- Посмотрим что получилось
  ```bash
  $ helm ls
  NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
  gitlab          1               Wed May  8 09:25:41 2019        DEPLOYED        gitlab-omnibus-0.1.37                   default
  production      2               Wed May  8 14:11:16 2019        DEPLOYED        reddit-1.0.0            1               production
  staging         1               Wed May  8 13:58:39 2019        DEPLOYED        reddit-1.0.0            1               staging
  ```
</p></details>
</p></details>


#  
# Homework 30. Kubernetes: Monitoring and logging

- Развертывание Prometheus в k8s
- Настройка Prometheus и Grafana для сбора метрик
- Настройка EFK для сбора логов


### В процессе сделано:
<details><p>

- Из Helm-чарта установим ingress-контроллер nginx
  ```bash
  $ helm install stable/nginx-ingress --name nginx**
  
  # Найдем IP-адрес, выданный nginx’у
  $ kubectl get svc
  NAME                                  TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
  kubernetes                            ClusterIP      10.63.240.1     <none>           443/TCP                      37m
  nginx-nginx-ingress-controller        LoadBalancer   10.63.246.181   35.190.196.132   80:32389/TCP,443:31456/TCP   54s
  nginx-nginx-ingress-default-backend   ClusterIP      10.63.244.227   <none>           80/TCP                       54s
  
  # Добавьте в /etc/hosts
  35.190.196.132 reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod
  ```


- Установим Prometheus
  - **$ cd kubernetes/charts && helm fetch stable/prometheus --untar**
- Создадим Chart-файл **kubernetes/Charts/prometheus/custom_values.yml**
- Запустм Prometheus в k8s из charsts/prometheus
  - **$ helm upgrade prom . -f custom_values.yml --install**
  - Перейдем на страницу **[http://reddit-prometheus/targets](http://reddit-prometheus/targets)** Видим что присутствует ряд endpoint’ов для сбора метрик.
- Запустим приложение из helm чарта reddit
  ```bash
  $ helm upgrade reddit-test ./reddit --install
  $ helm upgrade production --namespace production ./reddit --install
  $ helm upgrade staging --namespace staging ./reddit --install
  ```
- Добавим еще *label’ы* для prometheus и обновим helm-релиз.
Т.к. метки вида __meta_* не публикуются, то нужно создать свои, перенеся в них информацию
  ```bash
  - source_labels: [__meta_kubernetes_namespace]
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_service_name]
    target_label: kubernetes_name
  ```
- Установим Grafana с помощью Helm:
  ```bash
  helm upgrade --install grafana stable/grafana --set "server.adminPassword=admin" \
  --set "server.service.type=NodePort" \
  --set "server.ingress.enabled=true" \
  --set "server.ingress.hosts={reddit-grafana}"
  ```
- Добавим prometheus data-source
  ```bash
  $ kubectl get svc
  NAME                                  TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
  prom-prometheus-server                LoadBalancer   10.63.255.210   35.241.240.207   80:32384/TCP                 3h
  ```
- Добавим самый распространенный **[dashboard](https://grafana.com/dashboards/315)** для отслеживания состояния ресурсов k8s.
- Логирование
- Добавьте *label* самой мощной ноде в кластере
  - **$ kubectl label node gke-cluster-1-bigpool-5085c23d-rhb7** *elastichost=true*
- Запустите стек в нашем k8s
  - **$ kubectl apply -f kubernetes/efk/**
- Kibana поставим из helm чарта
  ```bash
  helm upgrade --install kibana stable/kibana \
  --set "ingress.enabled=true" \
  --set "ingress.hosts={reddit-kibana}" \
  --set "env.ELASTICSEARCH_URL=http://elasticsearch-logging:9200" \
  --version 0.1.1
  ```
</p></details>