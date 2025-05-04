#!/bin/bash

# Asegura la existencia y permisos del directorio .vnc y archivos de configuración
mkdir -p /home/$USER/.vnc
echo $PASSWORD | tigervncpasswd -f > /home/$USER/.vnc/passwd
chmod 600 /home/$USER/.vnc/passwd
chown -R $USER:$USER /home/$USER/.vnc

# Crea el script xstartup para VNC si no existe
if [ ! -f "/home/$USER/.vnc/xstartup" ]; then
  echo "#!/bin/bash" > /home/$USER/.vnc/xstartup
  echo "unset SESSION_MANAGER" >> /home/$USER/.vnc/xstartup
  echo "unset DBUS_SESSION_BUS_ADDRESS" >> /home/$USER/.vnc/xstartup
  # Inicia XFCE4
  echo "startxfce4 &" >> /home/$USER/.vnc/xstartup
  # Opcional: Inicia un terminal por defecto
  # echo "terminator &" >> /home/$USER/.vnc/xstartup
  chmod +x /home/$USER/.vnc/xstartup
  chown $USER:$USER /home/$USER/.vnc/xstartup
fi

# Inicia el servidor VNC como el usuario especificado en segundo plano
# '-localhost no' permite conexiones desde fuera del contenedor
# Especificamos el display, geometría (resolución) y profundidad de color
su - $USER -c "tigervncserver $DISPLAY -localhost no -passwd /home/$USER/.vnc/passwd -geometry $VNC_RESOLUTION -depth $VNC_DEPTH -xstartup /home/$USER/.vnc/xstartup"

echo "Servidor VNC iniciado en el display $DISPLAY"
echo "Servidor SSH iniciando..."

# Inicia el servidor SSH en primer plano (-D) para mantener el contenedor corriendo
# Usamos 'exec' para que sshd se convierta en el proceso principal (PID 1)
exec /usr/sbin/sshd -D