# Iniciamos servicios necesarios
dbus-daemon --system --fork && service ssh start

# Iniciamos el servidor VNC -> Sin seguridad por razones de testeo
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE