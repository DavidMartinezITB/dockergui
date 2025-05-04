FROM ubuntu:24.04

LABEL maintainer="david.martinez.parra.7e7@itb.cat"
LABEL description="M09 - UF2 - Practica 2"

# Instalamos paquetes
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-session \
    tigervnc-standalone-server \
    dbus-x11 \
    gnome-keyring \
    policykit-1 \
    light-locker \
    openssh-server \
    wget \
    python3 \
    python3-pip \
    sudo \
    dbus-x11 \
    x11-utils \
    xdg-utils \
    libglib2.0-bin \
    && rm -rf /var/lib/apt/lists/*

# Creamos el directorio de VNC
RUN mkdir -p /root/.vnc

# Establecemos una password para vnc
RUN printf "passworditb123\npassworditb123\n" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd

# xstartup -> Necesario para iniciar entorno grafico
RUN echo '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export XDG_SESSION_TYPE=x11\n\
export GNOME_KEYRING_CONTROL=\n\
export SSH_AUTH_SOCK=\n\
exec startxfce4' > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

# VSCODE
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code

# SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "root:itb" | chpasswd

# SSH + VNC
EXPOSE 22 5901

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]