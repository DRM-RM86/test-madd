# Exploradores

Aplicación para que un investigador busque personajes, vea su ficha y deje guardados los que va a revisar después. Los datos salen de la API pública de Rick and Morty.

## Cómo correrla

```bash
flutter pub get
flutter run
```

En un teléfono Android o iOS. El aviso del código no se ve bien en todas las simulaciones de escritorio.

## Cómo probar el acceso

1. Escribe un celular de 10 dígitos.
2. Acepta el permiso de notificaciones.
3. El código de 4 dígitos llega en una notificación del propio teléfono. No es un SMS.
4. El código vence a los 3 minutos. Si no coincide, se puede pedir otro.
5. Cerrar sesión deja entrar a otra persona en el mismo aparato. Lo guardado no se mezcla.

## Qué se puede hacer

- Buscar por nombre y cargar más resultados.
- Abrir la ficha: estado, especie, género, origen, ubicación y episodios.
- Entrar al origen o a la ubicación para ver tipo, dimensión y cuántos residentes tiene.
- Guardar la ficha. Queda la foto, los episodios y el lugar, y se abre sin red.
- Al volver a abrir la app, sigue la sesión, la última búsqueda y la pestaña.

Si el nombre no existe, la API responde 404. La app lo muestra como "no hay personajes", no como un fallo del servidor. Si no hay red, el mensaje lo dice y Guardados sigue disponible.

## Decisiones

El dominio no conoce Flutter, Dio ni la base de datos. Los casos de uso hablan con contratos. La UI usa BLoC y `get_it` arma las implementaciones.

La sesión y la última búsqueda viven en `shared_preferences`. Lo que el investigador decide conservar vive en SQLite (`sqflite`): un registro por celular y personaje, y otra tabla con los episodios. La foto se copia al almacenamiento del teléfono porque la URL de la API no abre sin señal.

El código de acceso se genera en el dispositivo y se muestra con una notificación local. En iOS, con la app abierta, el sistema no enseña el aviso si el `AppDelegate` no lo presenta. Por eso ahí se responde a `willPresent`.
