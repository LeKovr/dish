DISH. Docker image shell scripting
==================================

Build and run [docker](http://docker.io) images with simple bash plugins.

This is a way to replace Dockerfile with the bunch of simple install scripts (charms).

Charm contains:
* shell commands to install some software
* dish directive to register ports and startup commands (optional)

Image build use definition file (def) which contains list of needed charm names.

Image run use registered startup commands to run them after container starts

Additionally, current host directory will be mounted into predefined container path

Requirements
============

This code is intended to run on linux system with [docker](http://docker.io) installed.
There are no other requirements.

Installation
============

1. Install [docker](http://www.docker.io/gettingstarted/)
1. Get the dish
```
git clone git@github.com:LeKovr/dish.git
```

Quick start
===========

```
host$ cd /home/dish
host$ ./di.sh build demo
#.. dish builds your docker image
host$ cd /home/app
host$ ../dish/di.sh run demo
#.. you're inside running docker image container
# if file named boot.sh exists in current dir, it will be called at container startup
demo$
```

Configuration
=============

## Personal and host-wide settings

See config.dish.default

Simple setup:

```
cp config.dish.default config.dish
echo 'MAINTAINER="YOU <your@email.com>"' >> config.dish
echo 'TAGPREFIX=YOURNICK' >> config.dish
```

## Charms

See charm/ subdir for examples.

Charm is the simple bash script with commands to install some software into docker image.

### Dish directives

These dish directives are available inside charm:

* require <charm>

Given <charm> must be included in def before current. If no - include it now.

* add_port <port>

Expose this port 

* add_boot <cmd>

Run command <cmd> on container's boot

* set_cmd <cmd>

Set <cmd> as last called on container's boot, instead of $CONT_CMD from config.dish

### Arguments

Carm will be called with arguments if they are given in def file. Argument list ended with "--".
These arguments might be accessed in charm like so:
```
L=$1
[[ "$L" != "--" ]] || L=ru
```

### Example:

```
# nginx

apt-get -y install nginx-extras

add_port 80
add_boot /etc/init.d/nginx start

```

## Defs

See def/ subdir for examples.

Def is the docker image definition file. 
It contains a list of charm names with arguments in sequence they will be called by dish for docker image building.
Full line (started with #) and end line comments are allowed.

### Example:

```
# dish def file
# Setup debelopment environment

# use apt-cache-ng from host system
apt-cacher

# This will be called by update if skip
base

# update apt package list and ubuntu packages
update

# setup utf8 locale
language ru

# we will connect to container via ssh
ssh

# we will use midnight commander 
mc # boot

# create user "op" inside container
user op

# install nginx
nginx

# install postgresql (default - v9.1)
postgres # 9.2

# install PGWS deps
pgws

```

Recommended usage
=================

1. Use ubuntu
2. Install and run [Apt-Cacher NG](http://www.unix-ag.uni-kl.de/~bloch/acng/)
3. add a line "apt-cacher IP" as first line in your image defs


Notes
=====

This project was born when my Dockerfile creation process gave me bug described here -
[Can't stack more than 42 aufs layers](https://github.com/dotcloud/docker/issues/1171)
which was opened about 3 months at time when I've met it.

Also I wanted to escape from Dockerfile's static in favor of includes, variables and cross-package requirements handling.

All of this I've got with a dish, 2 bash scripts in 200 lines).

Use it at your pleasure and risk.

License
=======

See LICENSE

Copyright
=========

2013, Alexey Kovrizhkin <lekovr@gmail.com>

