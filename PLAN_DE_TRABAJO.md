# Plan de trabajo

## Problemas

1. Cuesta encontrar a un personaje por nombre entre muchos registros, y la ficha no alcanza si solo se ve el nombre.
2. El teléfono pasa de una persona a otra. Cada quien necesita su espacio y retomar donde se quedó.
3. En la expedición se va la señal. Lo que se marcó para revisar después se pierde al cerrar la app.
4. Si la consulta falla o no hay coincidencias, no queda claro qué pasó.

## Tareas

| Prioridad | Tarea | Horas |
|---|---|---|
| Alta | Acceso con celular y código en notificación local | 2 |
| Alta | Búsqueda por nombre, paginación y ficha | 3.5 |
| Alta | Guardar la ficha en SQLite, separada por celular, y leerla sin red | 2.5 |
| Alta | Mensajes de vacío, de red y de error de la API | 1 |
| Alta | Episodios y ubicación en la ficha, también al guardar | 2 |
| Media | Lista con estado y marca de lo ya guardado | 1 |
| Media | Reanudar pestaña y última búsqueda | 1 |
| Media | README, este plan y el APK | 1.5 |

## Bitácora

Empecé por la estructura: `core` para errores, casos de uso e inyección, y cada feature con data, domain y presentation. Elegí BLoC y `get_it` porque el dominio queda separado de la pantalla y se puede explicar caso por caso.

Después armé el acceso. El número se valida a 10 dígitos, el código se genera en el teléfono y se muestra en una notificación. No quise dejar el código escrito en la pantalla: la idea es simular el SMS. En Android se vio enseguida. En iOS, con la app abierta, el aviso no aparecía. El sistema no lo presenta en primer plano si nadie responde `willPresent`. Lo resolví en el `AppDelegate` y mandando un payload, porque el plugin ignora el aviso si no lo trae. El código dura 3 minutos.

La búsqueda usa `https://rickandmortyapi.com/api/character`. Cuando el nombre no existe, la API responde 404 con "There is nothing here". Al principio eso se iba a tratar como error del servidor. Lo separé: 404 es lista vacía, timeout o sin red es otro mensaje, y el resto es fallo de la API.

Para guardar usé SQLite y no solo preferencias, porque hay que conservar varios personajes por persona, la foto y ahora los episodios. La foto se descarga al guardar. Si otro celular entra en el mismo aparato, la consulta filtra por el número de la sesión.

La ficha al inicio solo decía cuántos episodios había y el nombre del lugar. Eso se quedaba corto para preparar una salida. Ahora pido los episodios por id (`/episode/1,2,3`) y la ubicación por su URL, y los guardo en la base. Si ya están guardados, la ficha los lee de SQLite y no depende de la red. La lista muestra vivo, muerto o desconocido, y un marcador si ese personaje ya está en Guardados.

Al reabrir, si hay sesión, entra directo y recupera la última pestaña y el texto buscado.

## Pendiente

- Filtrar la búsqueda por estado.
- Buscar también dentro de Guardados.
- Subir el repositorio y generar el APK de entrega.

El filtro y el buscador de guardados no bloquean el uso. Los dejé fuera para no meter pantallas que el problema no pide.
