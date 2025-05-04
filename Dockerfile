# Usa la imagen oficial de Ubuntu 24.04 como base
FROM ubuntu:24.04

# Evitar preguntas
ENV DEBIAN_FRONTEND=noninteractive

# Variables config
ENV USER=david
ENV PASSWORD=itb
ENV VNC_RESOLUTION=1280x800
ENV VNC_DEPTH=24
ENV DISPLAY=:1

# Installs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    wget \
    gnupg \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    dbus-x11 \
    xfce4 \
    xfce4-goodies \
    terminator \
    tigervnc-standalone-server \
    tigervnc-common \
    python3 \
    python3-pip \
    openssh-server && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
    apt-get update && \
    apt-get install -y code && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Crea usuario no root
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    adduser $USER sudo

# Configura SSH
RUN mkdir /var/run/sshd && \
    # Permite la autenticación por contraseña para el usuario creado
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configura VNC para el usuario
# Se hará en el script de entrada para asegurar permisos correctos al iniciar

# Copia el script que iniciará los servicios VNC y SSH
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expone los puertos para VNC (5901 porque usamos DISPLAY=:1) y SSH (22)
EXPOSE 5901 22

# Define el punto de entrada que ejecutará el script al iniciar el contenedor
ENTRYPOINT ["/entrypoint.sh"]

# Establece el directorio de trabajo por defecto para el usuario
WORKDIR /home/$USER