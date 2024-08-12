# Estructura del Directorio

- [Introducción](#introduction)
- [El directorio raíz](#the-root-directory)
  - [El directorio `app`](#the-root-app-directory)
  - [El directorio `bootstrap`](#the-bootstrap-directory)
  - [El directorio `config`](#the-config-directory)
  - [El directorio `database`](#the-database-directory)
  - [El directorio `lang`](#the-lang-directory)
  - [El directorio `public`](#the-public-directory)
  - [El directorio `resources`](#the-resources-directory)
  - [El directorio `routes`](#the-routes-directory)
  - [El directorio `storage`](#the-storage-directory)
  - [El directorio `tests`](#the-tests-directory)
  - [El directorio `vendor`](#the-vendor-directory)
- [El directorio App](#the-app-directory)
  - [El directorio `Broadcasting`](#the-broadcasting-directory)
  - [El directorio `Console`](#the-console-directory)
  - [El directorio `Events`](#the-events-directory)
  - [El directorio `Exceptions`](#the-exceptions-directory)
  - [El directorio `Http`](#the-http-directory)
  - [El directorio `Jobs`](#the-jobs-directory)
  - [El directorio `Listeners`](#the-listeners-directory)
  - [El directorio `Mail`](#the-mail-directory)
  - [El directorio `Models`](#the-models-directory)
  - [El directorio `Notifications`](#the-notifications-directory)
  - [El directorio `Policies`](#the-policies-directory))
  - [El directorio `Providers`](#the-providers-directory)
  - [El directorio `Rules`](#the-rules-directory)

<a name="introduction"></a>
## Introducción

La estructura de aplicaciones por defecto de Laravel está pensada para proporcionar un buen punto de partida tanto para aplicaciones grandes como pequeñas. No obstante, usted es libre de organizar su aplicación como quiera. Laravel casi no impone restricciones sobre la ubicación de cualquier clase - siempre y cuando Composer pueda cargar automáticamente la clase.

> **Nota**
> ¿Es nuevo en Laravel? Echa un vistazo al [Laravel Bootcamp](https://bootcamp.laravel.com) para un tour práctico del framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="the-root-directory"></a>
## El directorio raíz

<a name="the-root-app-directory"></a>
#### El directorio `app`

El directorio `app` contiene el código central de tu aplicación. Exploraremos este directorio en más detalle pronto; sin embargo, casi todas las clases de tu aplicación estarán en este directorio.

<a name="the-bootstrap-directory"></a>
#### El directorio `bootstrap`

El directorio `bootstrap` contiene el archivo `app.php` que arranca el framework. Este directorio también contiene un directorio de `cache` que contiene archivos generados por el framework para optimizar el rendimiento, como los archivos de cache rutas y servicios. Normalmente no debería ser necesario modificar ningún archivo de este directorio.

<a name="the-config-directory"></a>
#### El directorio `config`

El directorio `config`, como su nombre indica, contiene todos los archivos de configuración de tu aplicación. Es una buena idea leer todos estos archivos y familiarizarse con todas las opciones disponibles.

<a name="the-database-directory"></a>
#### El directorio `database`

El directorio `database` contiene las migraciones de la base de datos, las factorías de modelos y las semillas. Si lo deseas, también puedes utilizar este directorio para alojar una base de datos SQLite.

<a name="the-lang-directory"></a>
#### El directorio `lang`

El directorio `lang` contiene todos los archivos de idioma de su aplicación.

<a name="the-public-directory"></a>
#### El directorio `public`

El directorio `public` contiene el archivo `index.php`, que es el punto de entrada para todas las peticiones que entran en su aplicación y configura la carga automática. Este directorio también aloja archivos como tus imágenes, JavaScript y CSS.

<a name="the-resources-directory"></a>
#### El directorio `resources`

El directorio `resources` contiene tus [vistas](/docs/{{version}}/views) así como tus "assets" sin compilar como CSS o JavaScript.

<a name="the-routes-directory"></a>
#### El directorio `routes`

El directorio de `routes` contiene todas las definiciones de rutas para su aplicación. Por defecto, varios archivos de ruta se incluyen con Laravel: `web.php`, `api.php`, `console.php`, y `channels.php`.

El archivo `web.php` contiene rutas que el `RouteServiceProvider` coloca en el grupo de middleware `web`, que proporciona estado de sesión, protección CSRF y cifrado de cookies. Si su aplicación no ofrece una API RESTful sin estado, lo más probable es que todas sus rutas estén definidas en el archivo `web.php`.

El archivo `api.php` contiene rutas que el `RouteServiceProvider` coloca en el grupo `api` middleware. Estas rutas están diseñadas para que no tengan estado, por lo que las solicitudes que entran en la aplicación a través de estas rutas están diseñadas para ser autenticadas [a través de tokens](/docs/{{version}}/sanctum) y no tendrán acceso al estado de la sesión.

El archivo `console.php`  es donde puede definir todos sus comandos de consola basados en closure. Cada closure está vinculado a una instancia de comando permitiendo un enfoque simple para interactuar con los métodos IO de cada comando. Aunque este archivo no define rutas HTTP, define puntos de entrada basados en consola (rutas) en su aplicación.

El archivo `channels.php` es donde puedes registrar todos los canales de [transmisión de eventos](/docs/{{version}}/broadcasting) que tu aplicación soporta.

<a name="the-storage-directory"></a>
#### El directorio `storage`

El directorio de `storage` contiene tus logs, plantillas Blade compiladas, sesiones basadas en ficheros, cachés de ficheros, y otros ficheros generados por el framework. Este directorio está segregado en los directorios `app`, `framework` y `logs`. El directorio `app` se puede utilizar para almacenar cualquier archivo generado por su aplicación. El directorio `framework` se utiliza para almacenar los archivos y cachés generados por el framework. Por último, el directorio `logs` contiene los archivos de registro de tu aplicación.

El directorio `storage/app/public` puede utilizarse para almacenar archivos generados por el usuario, como avatares de perfil, que deben ser accesibles públicamente. Debes crear un enlace simbólico en `public/storage` que apunte a este directorio. Puedes crear el enlace usando el comando `php artisan storage:link` Artisan.

<a name="the-tests-directory"></a>
#### El directorio `tests`

El directorio `tests` contiene los tests automatizados. Ejemplos de tests unitarias [PHPUnit](https://phpunit.de/) y tests de "features" se proporcionan con cada instalación nueva de Laravel. Cada clase de test debe tener como sufijo la palabra `Test`. Puede ejecutar sus tests usando los comandos `phpunit` o `php vendor/bin/phpunit`. O, si desea una representación más detallada y hermosa de los resultados de sus test, puede ejecutar sus tests utilizando el comando php `artisan test` Artisan.

<a name="the-vendor-directory"></a>
#### El directorio `vendor`

El directorio `vendor` contiene tus dependencias de [Composer](https://getcomposer.org).

<a name="the-app-directory"></a>
## El directorio App

La mayor parte de su aplicación se encuentra en el directorio `app`. Por defecto, este directorio se encuentra bajo el namespace `App` y es autocargado por Composer utilizando el [estándar de autocarga PSR-4](https://www.php-fig.org/psr/psr-4/).

El directorio `app` contiene una variedad de directorios adicionales como `Console`, `Http`, y `Providers`. Piense en los directorios `Console` y `Http` como una API dentro del núcleo de su aplicación. Tanto el protocolo HTTP como la CLI son mecanismos para interactuar con tu aplicación, pero en realidad no contienen lógica de aplicación. En otras palabras, son dos formas de emitir comandos a tu aplicación. El directorio `Console` contiene todos sus comandos Artisan, mientras que el directorio `Http` contiene sus controladores, middleware y peticiones.

Otros directorios serán generados dentro del directorio `app` cuando utilices los comandos `make` Artisan para generar clases. Así, por ejemplo, el directorio `app/Jobs` no existirá hasta que ejecutes el comando `make:job` Artisan para generar una clase job.

> **Nota**  
> Muchas de las clases en el directorio `app` pueden ser generadas por Artisan a través de comandos. Para revisar los comandos disponibles, ejecute el comando `php artisan list make` en su terminal.

<a name="the-broadcasting-directory"></a>
#### El directorio `Broadcasting`

El directorio `Broadcasting` contiene todas las clases de canales de emisión de la aplicación. Estas clases se generan utilizando el comando `make:channel`. Este directorio no existe por defecto, pero se creará para usted cuando cree su primer canal. Para saber más sobre canales, consulta la documentación sobre [difusión de eventos](/docs/{{version}}/broadcasting).

<a name="the-console-directory"></a>
#### El directorio `Console`

El directorio `Console` contiene todos los comandos personalizados de Artisan para su aplicación. Estos comandos pueden ser generados utilizando el comando `make:command`. Este directorio también contiene el kernel de tu consola, que es donde tus comandos personalizados de Artisan son registrados y tus [tareas programadas](/docs/{{version}}/scheduling) son definidas.

<a name="the-events-directory"></a>
#### El directorio `Events`

Este directorio no existe por defecto, pero será creado para ti por los comandos `event:generate` y `make:event` de Artisan. El directorio `Events` contiene [clases de eventos](/docs/{{version}}/events). Los eventos pueden ser utilizados para alertar a otras partes de tu aplicación de que una determinada acción ha ocurrido, proporcionando una gran flexibilidad y desacoplamiento.

<a name="the-exceptions-directory"></a>
#### El directorio `Exceptions`

El directorio `Exceptions` contiene el manejador de excepciones de su aplicación y es también un buen lugar para colocar cualquier excepción lanzada por su aplicación. Si desea personalizar la forma en que sus excepciones se registran o renderizan, debe modificar la clase `Handler` en este directorio.

<a name="the-http-directory"></a>
#### El directorio `Http`

El directorio `Http` contiene sus controladores, middleware y solicitudes de formularios. Casi toda la lógica para manejar las peticiones que entran en su aplicación se colocará en este directorio.

<a name="the-jobs-directory"></a>
#### El directorio `Jobs`

Este directorio no existe por defecto, pero será creado por usted si ejecuta el comando `make:job` de  Artisan. El directorio `Jobs` alberga los [trabajos en cola](/docs/{{version}}/queues) para su aplicación. Los trabajos pueden ser puestos en cola por su aplicación o ejecutados sincrónicamente dentro del ciclo de vida de la solicitud actual. Los trabajos que se ejecutan de forma sincrónica durante la solicitud actual se denominan a veces "comandos", ya que son una implementación del [patrón de comandos](https://en.wikipedia.org/wiki/Command_pattern).

<a name="the-listeners-directory"></a>
#### El directorio `Listeners`

Este directorio no existe por defecto, pero será creado si ejecutas los comandos `event:generate` o `make:listener` de Artisan. El directorio `Listeners` contiene las clases que manejan tus [eventos](/docs/{{version}}/events). Los escuchadores de eventos reciben una instancia de evento y ejecutan la lógica en respuesta al evento disparado. Por ejemplo, un evento `UserRegistered` puede ser manejado por un listener `SendWelcomeEmail`.

<a name="the-mail-directory"></a>
#### El directorio `Mail`

Este directorio no existe por defecto, pero será creado por ti si ejecutas el comando `make:mail` de Artisan. El directorio `Mail` contiene todas las [clases que representan correos electrónicos](/docs/{{version}}/mail) enviados por su aplicación. Los objetos Mail le permiten encapsular toda la lógica de construcción de un correo electrónico en una única y simple clase que puede ser enviada utilizando el método `Mail::send`.

<a name="the-models-directory"></a>
#### El directorio `Models`

El directorio `Models` contiene todas las [clases modelo de Eloquent](/docs/{{version}}/eloquent). El ORM Eloquent incluido con Laravel proporciona una hermosa y simple implementación de ActiveRecord para trabajar con tu base de datos. Cada tabla de la base de datos tiene su correspondiente "Modelo" que se utiliza para interactuar con esa tabla. Los modelos te permiten consultar los datos de tus tablas, así como insertar nuevos registros en la tabla.

<a name="the-notifications-directory"></a>
#### El directorio `Notifications`

Este directorio no existe por defecto, pero será creado si ejecutas el comando `make:notification` de Artisan. El directorio `Notifications` contiene todas las [notificaciones](/docs/{{version}}/notifications) "transaccionales" que son enviadas por tu aplicación, tales como notificaciones simples sobre eventos que ocurren dentro de tu aplicación. La característica de notificaciones de Laravel abstrae el envío de notificaciones a través de una variedad de drivers como correo electrónico, Slack, SMS, o almacenadas en una base de datos.

<a name="the-policies-directory"></a>
#### El directorio `Policies`

Este directorio no existe por defecto, pero será creado para ti si ejecutas el comando `make:policy` de Artisan. El directorio `policies` contiene las [clases de autorización policy ](/docs/{{version}}/authorization) para tu aplicación. La policies se utilizan para determinar si un usuario puede realizar una acción determinada contra un recurso.

<a name="the-providers-directory"></a>
#### El directorio `Providers`

El directorio `Providers` contiene todos los [proveedores de servicios](/docs/{{version}}/providers) para tu aplicación. Los proveedores de servicios arrancan tu aplicación vinculando servicios en el contenedor de servicios, registrando eventos o realizando cualquier otra tarea para preparar tu aplicación para las peticiones entrantes.

En una aplicación Laravel nueva, este directorio ya contendrá varios proveedores. Eres libre de añadir tus propios proveedores a este directorio según sea necesario.

<a name="the-rules-directory"></a>
#### El directorio `Rules`

Este directorio no existe por defecto, pero será creado por ti si ejecutas el comando `make:rule` Artisan. El directorio `Rules` contiene los objetos de reglas de validación personalizados para su aplicación. Las reglas se utilizan para encapsular lógica de validación complicada en un objeto simple. Para mayor información, revise la [documentación](/docs/{{version}}/validation) de validación.
