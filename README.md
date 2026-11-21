# ProgMovil-Proyecto
Nombre: LostPaws

Problema:
Cuando una mascota se pierde, los dueños suelen recurrir a publicaciones dispersas en redes sociales (grupos de Facebook, WhatsApp, volantes físicos) que no llegan a las personas correctas ni permiten ubicar de forma precisa dónde fue vista la mascota por última vez. HuellaCerca centraliza estos reportes en un solo lugar, permitiendo geolocalizar avistamientos y facilitar el reencuentro entre mascotas perdidas y sus dueños.

Público objetivo:
Dueños de mascotas y miembros de la comunidad (barrio, distrito o campus universitario) interesados en ayudar a reunir mascotas perdidas con sus familias.

Descripción general:
HuellaCerca es una aplicación móvil que permite a los usuarios publicar reportes de mascotas perdidas o encontradas, incluyendo una fotografía y la ubicación geográfica del suceso. Otros usuarios pueden explorar estos reportes en un mapa interactivo, filtrar por tipo de mascota y contactar al publicador en caso de tener información relevante.

Funcionalidades

- Registro e inicio de sesión: autenticación de usuarios para poder publicar y gestionar reportes.
- Publicación de reportes: creación de reportes de mascota perdida o encontrada, con foto tomada desde la cámara del dispositivo y ubicación capturada automáticamente vía GPS.
- Mapa de reportes: visualización de todos los reportes activos en un mapa, con marcadores según el tipo (perdida/encontrada).
- Detalle de reporte: información completa del reporte (foto, descripción, ubicación, datos de contacto).
- Perfil de usuario: gestión de los reportes publicados por el usuario y su información de contacto.

Pantallas

1. Login / Registro

- Funcionalidad: autenticación de usuario mediante correo y contraseña (Firebase Auth).
- Flujo: si el usuario no tiene cuenta, puede registrarse; si ya inició sesión antes, accede directo al feed principal.

2. Mapa de reportes

- Funcionalidad: muestra un mapa con la ubicación actual del usuario y los marcadores de mascotas perdidas/encontradas cercanas. Permite filtrar por tipo de mascota.
- Flujo: pantalla principal tras iniciar sesión; al tocar un marcador se navega al detalle del reporte.

 3. Crear publicación

- Funcionalidad: formulario para publicar un nuevo reporte, incluyendo captura de foto desde la cámara y obtención automática de la ubicación GPS.
- Flujo: accesible desde un botón flotante en el mapa; al guardar, redirige al mapa mostrando el nuevo marcador.

4. Detalle de la publicación 

- Funcionalidad: muestra la foto, descripción, tipo de mascota, ubicación y datos de contacto del publicador.
- Flujo: se accede desde el mapa o desde el perfil; permite volver al mapa o contactar al publicador.

5. Perfil
- Funcionalidad: lista de reportes publicados por el usuario, con opción de editar o marcar como resuelto.
- Flujo: accesible desde el menú/tab inferior; permite navegar al detalle de cada reporte propio.

 Tecnologías utilizadas

- Flutter: framework principal de desarrollo móvil.
- Google Maps API / geolocator (paquete Flutter): geolocalización y visualización del mapa.
- image_picker (paquete Flutter): acceso a la cámara del dispositivo.
