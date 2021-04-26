# User Story: VOXMAPP

La empresa VOXMAPP quiere mejorar la recolección, análisis y presentación de datos mediante la automatización de estos procesos. Esta mejora tiene el objetivo de acortar el
"time-to-decision". El trabajo se puede dividir en tres partes principales:

1) Captura de información y proceso hacia la base de datos
    - Incluye limpieza y redacción de una entrevista de recolección de datos
    - Creación de una base de datos que reciba lo obtenido en la entrevista
2) Limpieza de los datos
    - Insertar los datos en la BD corrigiendo "errores de escritura" o evitándolos: malos formatos de teléfonos, espacios en blanco, entre otros
3) Análisis y presentación de los datos
    - Crear la BD de manera que podamos obtener las vistas desde su tablas

Sabemos que la empresa tiene un registro con los hospitales a los que entrevista. Para un hospital se registra: ID único, datos geográficos (latitud, longitud, altitud), 
teléfonos (pueden ser múltiples), nombre, distrito, provincia, tipo de hospital (estatal, distrito, ...), fecha de creación.

Un hospital va a tener múltiples entrevistas, ya que busca dar un monitoreo por mes de cada uno. Cada una de esas entrevistas tiene asociado un usuario encargado de hacer
la baseline y un contacto que contestó la entrevista. Ambos pueden ser distintos cada mes.
