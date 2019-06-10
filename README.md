# serboox_microservices
serboox microservices repository

# 14.Технология контейнеризации. Введение в Docker.
1) Подключил travis и slack
2) Поигрался с docker

# 15.Docker контейнеры. Docker под капотом
1) Создал docker проект в GCP, переконфигурировал gcloud, поднял новый инстанс *docker-host* через docker-machine
2) Попробовал кое-что из лекции
3) *--pid host* позволяет запустить процесс используя PID пространства имен хостовой машины, что дает нам возможность не использовать изолированное дерево процессов, а работать в существующем и как следствие видеть все его процессы с реальными ID.
4) Собрал image *reddit:latest*
5) Запустил container *reddir* в GCP используя network namespace хостовой машины, что сделало бы доступным reddit если бы не firewall)
6) Создал firewall правило открывающее порт tcp:9292 для инстансов с network тегом *docker-machine*
7) Загрузил свой образ на DockerHub: https://hub.docker.com/r/serboox/otus-reddit

# 16.Docker образы. Микросервисы
1) Скачал, распаковал архив, создал Dockerfile в каждой папке
2*) Поигрался с названием сети, алиасами и переменными среды
3) Перенес ui на кастомный образ ubuntu:16.04, уменьшив тем самым начальный размер образа
4*) Перенес **post** и **comment** на alpine:3.9
5) Создал persistent volume, перестартанул контейнер с монго, убедился, что все работает при перезапуске

# 17. Сетевое взаимодействие Docker контейнеров. Docker Compose. Тестирование образов
1) Запустил консейнер --network none
2) Запустил 4 контейнера с --network host

> Каков результат? Что выдал docker ps? Как думаете почему?
``` bash
docker logs -f 837e3a07717a
2019/05/18 05:53:03 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```
Зпустился только первый контейнер. Команда docker ps вернула информацию только по первому контейнеру. Как видно из логов, запуск остальных контейнеров не состоялся по причине того, что 80 порт занят.

3) Работа с **net-namespaces**
Создал симолическую ссылку на хосте
``` bash
sudo ln -s /var/run/docker/netns /var/run/netns
```
ссозал контейнер --network none, получил namespace и попробовал выполнить
``` bash
sudo ip netns exec 9db845598b47 ifconfig
```
получил список интерфейсов контейнера.
При запуске контейнера --network host в списке был только default namespace.

4) Запустил проект в одной bridge сети
``` bash
docker network create reddit --driver bridge

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --rm --network=reddit --network-alias=post serboox/post:1.0
docker run -d --rm --network=reddit --network-alias=comment serboox/comment:1.0
docker run -d --rm --network=reddit -p 9292:9292 serboox/ui:1.0
```

5) Запустил проект в двух bridge сетях
``` bash
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

docker run -d --rm --network=front_net -p 9292:9292 --name ui serboox/ui:1.0
docker run -d --rm --network=back_net --name comment serboox/comment:1.0
docker run -d --rm --network=back_net --name post serboox/post:1.0
docker run -d --rm --network=back_net --name mongo_db \
 --network-alias=post_db --network-alias=comment_db mongo:latest

docker network connect front_net post
docker network connect front_net comment
```

6) Посмотрел как выглядит сетевой стек Linux
``` bash
# зашел на хостовую систему
docker-machine ssh docker-host
# установил bridge-utils
sudo apt-get update && sudo apt-get install bridge-utils
# обратил внимание на созданные итерфейсы
ifconfig | grep br
# посмотрел на информацию по интерфейсу
brctl show br-a670a45b7573
# посмотрел на правила iptables
sudo iptables -v -nL -t nat
# убедился что существует процесс docker-proxy который слушает сетевой tcp-порт 9292
ps ax | grep docker-proxy
```

7) Создал docker-compose.yml, .env и .env.example файлы в папке src. Заполнил файл docker-compose.yml. Запустил контейнеры с использованием одного бриджа.

8) Вынес версии приложений и порт в переменные. Переделал docker-compose.yml для использования двух сетей.
> Узнайте как образуется базовое имя проекта. Можно
ли его задать? Если можно то как?

В качестве базового имени "по умолчанию" используется имя директории в которой расположен  docker-compose.yml файл. Задать иное имя можно при помощи переменной *COMPOSE_PROJECT_NAME* которую, можно экспортировать или поместить в .env файл. Еще одним способом задания базового имени является использование флага **-p** при работе с docker-compose.

# 19. Устройство Gitlab CI. Построение процесса непрерывной интеграции

1) Создал виртуалкку через docker-machine
2) Поднял GitLab используя docker-compose
3) Отключил регистрацию, создал группу, создал проект
4) Залил проект serboox_microservices, создал в корне файл .gitlab-ci.yml
5) Создал и зарегистрировал runner
6) Добавил в проект приложение reddit, расширил pipeline
7) Добавил environment для review stage
8) Добавил stage и production environments
9) Добавил ограничение деплоя по тегу для stage и production
10) Добавил динамическое окружение для stage review

# 20 Введение в мониторинг. Модели и принципы работы систем мониторинга

1) Добавил правило фаервола и поднял prometheus
2) Создал новый Docker образ serboox/prometheus
3) Добавил в корневой Makefile команды для сборки/удаления и пуша Docker образов
4) Добавил в docker/docker-compose.yml данные сервис **prometheus** и **node-exporter**
Ссылки на hub.docker.com:
[serboox/ui](https://cloud.docker.com/u/serboox/repository/docker/serboox/ui)
[serboox/post](https://cloud.docker.com/u/serboox/repository/docker/serboox/post)
[serboox/comment](https://cloud.docker.com/u/serboox/repository/docker/serboox/comment)
[serboox/prometheus](https://cloud.docker.com/u/serboox/repository/docker/serboox/prometheus)
