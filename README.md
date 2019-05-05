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
