#!/bin/bash

# Creamos la imagen
docker build -t xfce-vnc-dmp-img .

# Ejecutamos el contenedor
docker run -d --name xfce-vnc-dmp \
  -p 5901:5901 \
  -p 2222:22 \
  --shm-size="1gb" \
  xfce-vnc-dmp-img