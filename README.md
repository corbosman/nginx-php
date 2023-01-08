
# NGINX-PHP

![build](https://github.com/corbosman/nginx-php/workflows/Publish%20Docker%20Images/badge.svg?branch=master)

This is a docker image that combines nginx and php in a single image. This is much faster than running each image separately. It is optimised for use in laravel projects.  Right now it is only published as an alpine image. If you're interested in running this image with Laravel's scheduler, migration and Horizon, then check out my image corbosman/laravel-nginx-php. 

# Supported tags

* <code>[8.2](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>, <code>[8](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>, <code>[latest](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[8.1](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[8.0](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[7.4](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>, <code>[7](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[7.3](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[7.2](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>
* <code>[7.1](https://github.com/corbosman/nginx-php/blob/master/Dockerfile)</code>

There are also minor versions available if you want to pin a specific version. 

# Quick Reference

* **Github Repository**<br>
  https://github.com/corbosman/nginx-php

# How to use this image

This image will start up nginx with php-fpm listening on port 80.  The default site config expects the application to be mounted on /app, with the documentroot on /app/public. You can override this by using your own default.conf file. 

```
docker run -v ~/Code/myapp:/app corbosman/nginx-php:7.3 php artisan
Laravel Framework 5.8.30

Usage:
  command [options] [arguments]
...
```

## docker-compose

This image does not give you a full developer environment for your laravel application. There are other images for that. Any additional services like mysql or redis you need alongside this image can be started using docker-compose.  Refer to the docker-compose documentation for more information. 

## timezone

The default timezone is Europe/Amsterdam. To use your own timezone add a TZ environment variable.

```
docker run -v ~/Code/myapp:/app corbosman/nginx-php:7.3 date
Sun Oct 20 14:14:55 CEST 2019
```

```
docker run -e TZ=America/New_York -v ~/Code/myapp:/app corbosman/nginx-php:7.3 date
Sun Oct 20 08:14:55 EDT 2019
```

##  Note
This is work in progress,  I use this image myself on personal projectes. Feel free to comment or ask questions on the github repo. 
