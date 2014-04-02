DISH
====

Шелл-скрипты для работы с контейнерами docker (Docker Image SHell)

Подготовка
----------

* Установить [docker](http://www.docker.io/gettingstarted/)
* Установить dish
```
git clone git@github.com:LeKovr/dish.git

# Далее $DISHROOT - каталог установки dish
export DISHROOT=$PWD/dish
```


Использование
-------------

### Выполнение рецептов вручную

#### Контейнер docker

    # иначе контейнер docker будет использовать DNS от Google
    export DNS=YOUR_LOCAL_DNS

    # этот каталог примонтируем в образ
    cd $DISHROOT

    # стартуем контейнер с ubuntu:12.04
    sudo docker run -t -i -rm -p 23:22 -dns $DNS192.168.4.100 -v $PWD:/home/app ubuntu:12.04 /bin/bash

    # если на родительской системе установлен apt-cacher - найти и подключить
    cat /home/app/charm/apt-cacher | bash -s -- --

    # первоначальная настройка контейнера
    cat /home/app/charm/base | bash

    # обновим пакеты
    cat /home/app/charm/update | bash

    # установим ssh (аргументы отключают upstart для ssh контейнера)
    cat /home/app/charm/ssh | bash -s -- --

    # создадим пользователя (op)
    cat /home/app/charm/user | bash

#### Сервер в облаке

```
# обновим пакеты
curl -s https://raw.githubusercontent.com/LeKovr/dish/master/charm/update | bash

# установим ssh
curl -s https://raw.githubusercontent.com/LeKovr/dish/master/charm/ssh | bash

# создадим пользователя (op)
curl -s https://raw.githubusercontent.com/LeKovr/dish/master/charm/user | bash
```

