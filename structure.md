# Estructura de Directorios

- [Introducción](#introduction)
- [El Directorio Raíz](#the-root-directory)
  - [El Directorio `app`](#the-root-app-directory)
  - [El Directorio `bootstrap`](#the-bootstrap-directory)
  - [El Directorio `config`](#the-config-directory)
  - [El Directorio `database`](#the-database-directory)
  - [El Directorio `public`](#the-public-directory)
  - [El Directorio `resources`](#the-resources-directory)
  - [El Directorio `routes`](#the-routes-directory)
  - [El Directorio `storage`](#the-storage-directory)
  - [El Directorio `tests`](#the-tests-directory)
  - [El Directorio `vendor`](#the-vendor-directory)
- [El Directorio App](#the-app-directory)
  - [El Directorio `Broadcasting`](#the-broadcasting-directory)
  - [El Directorio `Console`](#the-console-directory)
  - [El Directorio `Events`](#the-events-directory)
  - [El Directorio `Exceptions`](#the-exceptions-directory)
  - [El Directorio `Http`](#the-http-directory)
  - [El Directorio `Jobs`](#the-jobs-directory)
  - [El Directorio `Listeners`](#the-listeners-directory)
  - [El Directorio `Mail`](#the-mail-directory)
  - [El Directorio `Models`](#the-models-directory)
  - [El Directorio `Notifications`](#the-notifications-directory)
  - [El Directorio `Policies`](#the-policies-directory)
  - [El Directorio `Providers`](#the-providers-directory)
  - [El Directorio `Rules`](#the-rules-directory)

<a name="introduction"></a>
## Introducción

La estructura de aplicación predeterminada de Laravel está diseñada para proporcionar un excelente punto de partida tanto para aplicaciones grandes como pequeñas. Pero puedes organizar tu aplicación como desees. Laravel impone casi ninguna restricción sobre dónde se puede ubicar una clase dada, siempre que Composer pueda autoload la clase.
> [!NOTE]
¿Nuevo en Laravel? Consulta el [Laravel Bootcamp](https://bootcamp.laravel.com) para un recorrido práctico por el framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="the-root-directory"></a>
## El Directorio Raíz


<a name="the-root-app-directory"></a>
#### El Directorio de la Aplicación

El directorio `app` contiene el código principal de tu aplicación. Exploraremos este directorio en más detalle pronto; sin embargo, casi todas las clases en tu aplicación estarán en este directorio.

<a name="the-bootstrap-directory"></a>
#### El Directorio de Bootstrap

El directorio `bootstrap` contiene el archivo `app.php` que inicializa el framework. Este directorio también alberga un directorio `cache` que contiene archivos generados por el framework para la optimización del rendimiento, como los archivos de caché de rutas y servicios.

<a name="the-config-directory"></a>
#### El Directorio de Configuración

El directorio `config`, como su nombre implica, contiene todos los archivos de configuración de tu aplicación. Es una buena idea leer todos estos archivos y familiarizarte con todas las opciones disponibles para ti.

<a name="the-database-directory"></a>
#### El Directorio de la Base de Datos

El directorio `database` contiene tus migraciones de base de datos, fábricas de modelos y semillas. Si lo deseas, también puedes usar este directorio para contener una base de datos SQLite.

<a name="the-public-directory"></a>
#### El Directorio Público

El directorio `public` contiene el archivo `index.php`, que es el punto de entrada para todas las solicitudes que ingresan a tu aplicación y configura la carga automática. Este directorio también alberga tus recursos como imágenes, JavaScript y CSS.

<a name="the-resources-directory"></a>
#### El Directorio de Recursos

El directorio `resources` contiene tus [vistas](/docs/%7B%7Bversion%7D%7D/views) así como tus activos sin compilar, como CSS o JavaScript.

<a name="the-routes-directory"></a>
#### El Directorio de Rutas

El directorio `routes` contiene todas las definiciones de rutas para tu aplicación. Por defecto, se incluyen dos archivos de rutas con Laravel: `web.php` y `console.php`.
El archivo `web.php` contiene rutas que Laravel coloca en el grupo de middleware `web`, que proporciona estado de sesión, protección CSRF y cifrado de cookies. Si tu aplicación no ofrece una API RESTful sin estado, entonces es muy probable que todas tus rutas estén definidas en el archivo `web.php`.
El archivo `console.php` es donde puedes definir todos tus comandos de consola basados en funciones anónimas. Cada función anónima está vinculada a una instancia del comando, lo que permite un enfoque simple para interactuar con los métodos de IO de cada comando. Aunque este archivo no define rutas HTTP, define puntos de entrada basados en consola (rutas) en tu aplicación. También puedes [programar](/docs/%7B%7Bversion%7D%7D/scheduling) tareas en el archivo `console.php`.
Opcionalmente, puedes instalar archivos de ruta adicionales para las rutas de API (`api.php`) y los canales de transmisión (`channels.php`), a través de los comandos Artisan `install:api` y `install:broadcasting`.
El archivo `api.php` contiene rutas que están diseñadas para ser sin estado, por lo que las solicitudes que ingresan a la aplicación a través de estas rutas están destinadas a ser autenticadas [a través de tokens](/docs/%7B%7Bversion%7D%7D/sanctum) y no tendrán acceso al estado de la sesión.
El archivo `channels.php` es donde puedes registrar todos los canales de [broadcasting de eventos](/docs/%7B%7Bversion%7D%7D/broadcasting) que tu aplicación admite.

<a name="the-storage-directory"></a>
#### El Directorio de Almacenamiento

El directorio `storage` contiene tus registros, plantillas Blade compiladas, sesiones basadas en archivos, cachés de archivos y otros archivos generados por el framework. Este directorio se divide en directorios `app`, `framework` y `logs`. El directorio `app` puede usarse para almacenar cualquier archivo generado por tu aplicación. El directorio `framework` se utiliza para almacenar archivos y cachés generados por el framework. Finalmente, el directorio `logs` contiene los archivos de registro de tu aplicación.
El directorio `storage/app/public` se puede utilizar para almacenar archivos generados por el usuario, como avatares de perfil, que deben ser de acceso público. Debes crear un enlace simbólico en `public/storage` que apunte a este directorio. Puedes crear el enlace utilizando el comando Artisan `php artisan storage:link`.

<a name="the-tests-directory"></a>
#### El Directorio de Pruebas

El directorio `tests` contiene tus pruebas automatizadas. Se proporcionan ejemplos de pruebas unitarias y pruebas de características de [Pest](https://pestphp.com) o [PHPUnit](https://phpunit.de/) desde el principio. Cada clase de prueba debe tener el sufijo `Test`. Puedes ejecutar tus pruebas utilizando los comandos `/vendor/bin/pest` o `/vendor/bin/phpunit`. O, si deseas una representación más detallada y bonita de los resultados de tus pruebas, puedes ejecutar tus pruebas utilizando el comando Artisan `php artisan test`.

<a name="the-vendor-directory"></a>
#### El Directorio de Proveedores

El directorio `vendor` contiene tus dependencias de [Composer](https://getcomposer.org).

<a name="the-app-directory"></a>
## El Directorio de la Aplicación

La mayoría de tu aplicación se encuentra en el directorio `app`. Por defecto, este directorio está en un espacio de nombres bajo `App` y se carga automáticamente con Composer utilizando el [estándar de autoloading PSR-4](https://www.php-fig.org/psr/psr-4/).
Por defecto, el directorio `app` contiene los directorios `Http`, `Models` y `Providers`. Sin embargo, con el tiempo, se generarán una variedad de otros directorios dentro del directorio app a medida que uses los comandos Artisan make para generar clases. Por ejemplo, el directorio `app/Console` no existirá hasta que ejecutes el comando Artisan `make:command` para generar una clase de comando.
Tanto los directorios `Console` como `Http` se explican más a fondo en sus respectivas secciones a continuación, pero piensa en los directorios `Console` y `Http` como proveedores de una API en el núcleo de tu aplicación. El protocolo HTTP y la CLI son ambos mecanismos para interactuar con tu aplicación, pero no contienen realmente la lógica de la aplicación. En otras palabras, son dos formas de emitir comandos a tu aplicación. El directorio `Console` contiene todos tus comandos Artisan, mientras que el directorio `Http` contiene tus controladores, middleware y solicitudes.
> [!NOTA]
Muchas de las clases en el directorio `app` pueden ser generadas por Artisan a través de comandos. Para revisar los comandos disponibles, ejecuta el comando `php artisan list make` en tu terminal.

<a name="the-broadcasting-directory"></a>
#### El Directorio de Transmisión

El directorio `Broadcasting` contiene todas las clases de canal de transmisión para tu aplicación. Estas clases se generan utilizando el comando `make:channel`. Este directorio no existe por defecto, pero se creará para ti cuando crees tu primer canal. Para aprender más sobre los canales, consulta la documentación sobre [transmisión de eventos](/docs/%7B%7Bversion%7D%7D/broadcasting).

<a name="the-console-directory"></a>
#### El Directorio de la Consola

El directorio `Console` contiene todos los comandos Artisan personalizados para tu aplicación. Estos comandos se pueden generar utilizando el comando `make:command`.

<a name="the-events-directory"></a>
#### El Directorio de Eventos

Este directorio no existe por defecto, pero será creado para ti por los comandos Artisan `event:generate` y `make:event`. El directorio `Events` alberga [clases de eventos](/docs/%7B%7Bversion%7D%7D/events). Los eventos pueden usarse para alertar a otras partes de tu aplicación que se ha producido una acción dada, proporcionando una gran flexibilidad y desacoplamiento.

<a name="the-exceptions-directory"></a>
#### El directorio de Excepciones

El directorio `Exceptions` contiene todas las excepciones personalizadas para tu aplicación. Estas excepciones se pueden generar utilizando el comando `make:exception`.

<a name="the-http-directory"></a>
#### El Directorio Http

El directorio `Http` contiene tus controladores, middleware y solicitudes de formulario. Casi toda la lógica para manejar las solicitudes que ingresan a tu aplicación se colocará en este directorio.

<a name="the-jobs-directory"></a>
#### El Directorio de Trabajos

Este directorio no existe por defecto, pero se creará para ti si ejecutas el comando Artisan `make:job`. El directorio `Jobs` alberga los [jobs encolables](/docs/%7B%7Bversion%7D%7D/queues) para tu aplicación. Los jobs pueden ser encolados por tu aplicación o ejecutarse de manera síncrona dentro del ciclo de vida de la solicitud actual. Se refiere a los jobs que se ejecutan de manera síncrona durante la solicitud actual como "comandos" ya que son una implementación del [patrón de comando](https://es.wikipedia.org/wiki/Patrón_de_comando).

<a name="the-listeners-directory"></a>
#### El Directorio de Listeners

Este directorio no existe por defecto, pero se creará para ti si ejecutas los comandos Artisan `event:generate` o `make:listener`. El directorio `Listeners` contiene las clases que manejan tus [eventos](/docs/%7B%7Bversion%7D%7D/events). Los oyentes de eventos reciben una instancia de evento y realizan lógica en respuesta a que se dispare el evento. Por ejemplo, un evento `UserRegistered` podría ser manejado por un oyente `SendWelcomeEmail`.

<a name="the-mail-directory"></a>
#### El Directorio de Correo

Este directorio no existe por defecto, pero se creará para ti si ejecutas el comando Artisan `make:mail`. El directorio `Mail` contiene todas tus [clases que representan correos electrónicos](/docs/%7B%7Bversion%7D%7D/mail) enviados por tu aplicación. Los objetos Mail te permiten encapsular toda la lógica de construcción de un correo electrónico en una sola clase simple que se puede enviar utilizando el método `Mail::send`.

<a name="the-models-directory"></a>
#### El Directorio de Modelos

El directorio `Models` contiene todas tus [clases de modelo Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). El ORM Eloquent incluido con Laravel proporciona una hermosa y simple implementación de ActiveRecord para trabajar con tu base de datos. Cada tabla de base de datos tiene un "Modelo" correspondiente que se utiliza para interactuar con esa tabla. Los modelos te permiten consultar datos en tus tablas, así como insertar nuevos registros en la tabla.

<a name="the-notifications-directory"></a>
#### El Directorio de Notificaciones

Este directorio no existe por defecto, pero se creará para ti si ejecutas el comando Artisan `make:notification`. El directorio `Notifications` contiene todas las [notificaciones]( /docs/%7B%7Bversion%7D%7D/notifications) "transaccionales" que envía tu aplicación, como notificaciones simples sobre eventos que ocurren dentro de tu aplicación. La función de notificaciones de Laravel abstrae el envío de notificaciones a través de una variedad de controladores como correo electrónico, Slack, SMS, o almacenadas en una base de datos.

<a name="the-policies-directory"></a>
#### El Directorio de Políticas

Este directorio no existe por defecto, pero se creará para ti si ejecutas el comando Artisan `make:policy`. El directorio `Policies` contiene las [clases de política de autorización](/docs/%7B%7Bversion%7D%7D/authorization) para tu aplicación. Las políticas se utilizan para determinar si un usuario puede realizar una acción dada contra un recurso.

<a name="the-providers-directory"></a>
#### El Directorio de Proveedores

El directorio `Providers` contiene todos los [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) para tu aplicación. Los proveedores de servicios inician tu aplicación vinculando servicios en el contenedor de servicios, registrando eventos o realizando cualquier otra tarea para preparar tu aplicación para las solicitudes entrantes.
En una nueva aplicación Laravel, este directorio ya contendrá el `AppServiceProvider`. Puedes añadir tus propios proveedores a este directorio según sea necesario.

<a name="the-rules-directory"></a>
#### El Directorio de Reglas

Este directorio no existe por defecto, pero se creará para ti si ejecutas el comando Artisan `make:rule`. El directorio `Rules` contiene los objetos de regla de validación personalizados para tu aplicación. Las reglas se utilizan para encapsular lógica de validación complicada en un objeto simple. Para obtener más información, consulta la [documentación de validación](/docs/%7B%7Bversion%7D%7D/validation).