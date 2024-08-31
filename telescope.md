# Laravel Telescope

- [Introducción](#introduction)
- [Instalación](#installation)
  - [Instalación Solo Local](#local-only-installation)
  - [Configuración](#configuration)
  - [Poda de Datos](#data-pruning)
  - [Autorización de Tablero](#dashboard-authorization)
- [Actualizando Telescope](#upgrading-telescope)
- [Filtrado](#filtering)
  - [Entradas](#filtering-entries)
  - [Lotes](#filtering-batches)
- [Etiquetado](#tagging)
- [Monitores Disponibles](#available-watchers)
  - [Monitor de Lotes](#batch-watcher)
  - [Monitor de Caché](#cache-watcher)
  - [Monitor de Comando](#command-watcher)
  - [Monitor de Volcado](#dump-watcher)
  - [Monitor de Evento](#event-watcher)
  - [Monitor de Excepción](#exception-watcher)
  - [Monitor de Puerta](#gate-watcher)
  - [Monitor de Cliente HTTP](#http-client-watcher)
  - [Monitor de Trabajo](#job-watcher)
  - [Monitor de Registro](#log-watcher)
  - [Monitor de Correo](#mail-watcher)
  - [Monitor de Modelo](#model-watcher)
  - [Monitor de Notificación](#notification-watcher)
  - [Monitor de Consulta](#query-watcher)
  - [Monitor de Redis](#redis-watcher)
  - [Monitor de Solicitud](#request-watcher)
  - [Monitor de Programa](#schedule-watcher)
  - [Monitor de Vista](#view-watcher)
- [Mostrando Avatares de Usuario](#displaying-user-avatars)

<a name="introduction"></a>
## Introducción

[Laravel Telescope](https://github.com/laravel/telescope) es un compañero maravilloso para tu entorno de desarrollo local de Laravel. Telescope proporciona información sobre las solicitudes que llegan a tu aplicación, excepciones, entradas de registro, consultas a la base de datos, trabajos en cola, correo, notificaciones, operaciones de caché, tareas programadas, volcado de variables y más.
<img src="https://laravel.com/img/docs/telescope-example.png">

<a name="installation"></a>
## Instalación

Puedes usar el gestor de paquetes Composer para instalar Telescope en tu proyecto Laravel:


```shell
composer require laravel/telescope

```
Después de instalar Telescope, publica sus activos y migraciones utilizando el comando Artisan `telescope:install`. Después de instalar Telescope, también debes ejecutar el comando `migrate` para crear las tablas necesarias para almacenar los datos de Telescope:


```shell
php artisan telescope:install

php artisan migrate

```
Finalmente, puedes acceder al panel de control de Telescope a través de la ruta `/telescope`.

<a name="local-only-installation"></a>
### Instalación Solo Local

Si planeas usar Telescope solo para ayudar en tu desarrollo local, puedes instalar Telescope utilizando el flag `--dev`:


```shell
composer require laravel/telescope --dev

php artisan telescope:install

php artisan migrate

```
Después de ejecutar `telescope:install`, deberías eliminar el registro del proveedor de servicios `TelescopeServiceProvider` del archivo de configuración `bootstrap/providers.php` de tu aplicación. En su lugar, registra manualmente los proveedores de servicios de Telescope en el método `register` de tu clase `App\Providers\AppServiceProvider`. Nos aseguraremos de que el entorno actual sea `local` antes de registrar los proveedores:


```php
/**
 * Register any application services.
 */
public function register(): void
{
    if ($this->app->environment('local')) {
        $this->app->register(\Laravel\Telescope\TelescopeServiceProvider::class);
        $this->app->register(TelescopeServiceProvider::class);
    }
}
```
Finalmente, también deberías evitar que el paquete Telescope sea [auto-descubierto](/docs/%7B%7Bversion%7D%7D/packages#package-discovery) añadiendo lo siguiente a tu archivo `composer.json`:


```json
"extra": {
    "laravel": {
        "dont-discover": [
            "laravel/telescope"
        ]
    }
},

```

<a name="configuration"></a>
### Configuración

Después de publicar los activos de Telescope, su archivo de configuración principal se ubicará en `config/telescope.php`. Este archivo de configuración te permite configurar tus [opciones de vigilancia](#available-watchers). Cada opción de configuración incluye una descripción de su propósito, así que asegúrate de explorar este archivo a fondo.
Si lo deseas, puedes deshabilitar completamente la recopilación de datos de Telescope utilizando la opción de configuración `enabled`:


```php
'enabled' => env('TELESCOPE_ENABLED', true),
```

<a name="data-pruning"></a>
### Eliminación de Datos

Sin eliminar, la tabla `telescope_entries` puede acumular registros muy rápidamente. Para mitigar esto, debes [programar](/docs/%7B%7Bversion%7D%7D/scheduling) el comando Artisan `telescope:prune` para que se ejecute a diario:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('telescope:prune')->daily();
```
Por defecto, se eliminarán todas las entradas que tengan más de 24 horas. Puedes usar la opción `hours` al llamar al comando para determinar cuánto tiempo retener los datos de Telescope. Por ejemplo, el siguiente comando eliminará todos los registros creados hace más de 48 horas:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('telescope:prune --hours=48')->daily();
```

<a name="dashboard-authorization"></a>
### Autorización del panel de control

El panel de control de Telescope se puede acceder a través de la ruta `/telescope`. Por defecto, solo podrás acceder a este panel en el entorno `local`. Dentro de tu archivo `app/Providers/TelescopeServiceProvider.php`, hay una definición de [puerta de autorización](/docs/%7B%7Bversion%7D%7D/authorization#gates). Esta puerta de autorización controla el acceso a Telescope en entornos **no locales**. Puedes modificar esta puerta según sea necesario para restringir el acceso a tu instalación de Telescope:


```php
use App\Models\User;

/**
 * Register the Telescope gate.
 *
 * This gate determines who can access Telescope in non-local environments.
 */
protected function gate(): void
{
    Gate::define('viewTelescope', function (User $user) {
        return in_array($user->email, [
            'taylor@laravel.com',
        ]);
    });
}
```
> [!WARNING]
Debes asegurarte de cambiar la variable de entorno `APP_ENV` a `production` en tu entorno de producción. De lo contrario, tu instalación de Telescope estará disponible públicamente.

<a name="upgrading-telescope"></a>
## Actualizando Telescope

Al actualizar a una nueva versión principal de Telescope, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/telescope/blob/master/UPGRADE.md).
Además, al actualizar a cualquier nueva versión de Telescope, debes volver a publicar los activos de Telescope:


```shell
php artisan telescope:publish

```
Para mantener los recursos actualizados y evitar problemas en futuras actualizaciones, puedes agregar el comando `vendor:publish --tag=laravel-assets` a los scripts `post-update-cmd` en el archivo `composer.json` de tu aplicación:


```json
{
    "scripts": {
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ]
    }
}

```

<a name="filtering"></a>
## Filtrado


<a name="filtering-entries"></a>
### Entradas

Puedes filtrar los datos que se registran por Telescope a través de la función anónima `filter` que se define en tu clase `App\Providers\TelescopeServiceProvider`. Por defecto, esta función anónima registra todos los datos en el entorno `local` y excepciones, trabajos fallidos, tareas programadas y datos con etiquetas monitoreadas en todos los demás entornos:


```php
use Laravel\Telescope\IncomingEntry;
use Laravel\Telescope\Telescope;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->hideSensitiveRequestDetails();

    Telescope::filter(function (IncomingEntry $entry) {
        if ($this->app->environment('local')) {
            return true;
        }

        return $entry->isReportableException() ||
            $entry->isFailedJob() ||
            $entry->isScheduledTask() ||
            $entry->isSlowQuery() ||
            $entry->hasMonitoredTag();
    });
}
```

<a name="filtering-batches"></a>
### Lotes

Mientras que la función anónima `filter` filtra datos para entradas individuales, puedes usar el método `filterBatch` para registrar una función anónima que filtre todos los datos para una solicitud dada o un comando de consola. Si la función anónima devuelve `true`, todas las entradas son registradas por Telescope:


```php
use Illuminate\Support\Collection;
use Laravel\Telescope\IncomingEntry;
use Laravel\Telescope\Telescope;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->hideSensitiveRequestDetails();

    Telescope::filterBatch(function (Collection $entries) {
        if ($this->app->environment('local')) {
            return true;
        }

        return $entries->contains(function (IncomingEntry $entry) {
            return $entry->isReportableException() ||
                $entry->isFailedJob() ||
                $entry->isScheduledTask() ||
                $entry->isSlowQuery() ||
                $entry->hasMonitoredTag();
            });
    });
}
```

<a name="tagging"></a>
## Etiquetado

Telescope te permite buscar entradas por "etiqueta". A menudo, las etiquetas son nombres de clase de modelo Eloquent o identificadores de usuario autenticados que Telescope añade automáticamente a las entradas. Ocasionalmente, es posible que desees adjuntar tus propias etiquetas personalizadas a las entradas. Para lograr esto, puedes usar el método `Telescope::tag`. El método `tag` acepta una función anónima que debe devolver un array de etiquetas. Las etiquetas devueltas por la función anónima se fusionarán con las etiquetas que Telescope añadiría automáticamente a la entrada. Típicamente, deberías llamar al método `tag` dentro del método `register` de tu clase `App\Providers\TelescopeServiceProvider`:


```php
use Laravel\Telescope\IncomingEntry;
use Laravel\Telescope\Telescope;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->hideSensitiveRequestDetails();

    Telescope::tag(function (IncomingEntry $entry) {
        return $entry->type === 'request'
                    ? ['status:'.$entry->content['response_status']]
                    : [];
    });
 }
```

<a name="available-watchers"></a>
## Observadores Disponibles

Los "observadores" de Telescope recopilan datos de la aplicación cuando se ejecuta una solicitud o un comando de consola. Puedes personalizar la lista de observadores que te gustaría habilitar dentro de tu archivo de configuración `config/telescope.php`:


```php
'watchers' => [
    Watchers\CacheWatcher::class => true,
    Watchers\CommandWatcher::class => true,
    ...
],
```
Algunos observadores también te permiten proporcionar opciones de personalización adicionales:


```php
'watchers' => [
    Watchers\QueryWatcher::class => [
        'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
        'slow' => 100,
    ],
    ...
],
```

<a name="batch-watcher"></a>
### Observador por Lotes

El vigilante de lotes registra información sobre los [lotes](/docs/%7B%7Bversion%7D%7D/queues#job-batching) en la cola, incluida la información del trabajo y de la conexión.

<a name="cache-watcher"></a>
### Vigilante de Caché

El monitor de caché registra datos cuando se accede, pierde, actualiza y olvida una clave de caché.

<a name="command-watcher"></a>
### Observador de Comandos

El vigilante de comandos registra los argumentos, opciones, código de salida y salida cada vez que se ejecuta un comando Artisan. Si deseas excluir ciertos comandos de ser registrados por el vigilante, puedes especificar el comando en la opción `ignore` dentro de tu archivo `config/telescope.php`:


```php
'watchers' => [
    Watchers\CommandWatcher::class => [
        'enabled' => env('TELESCOPE_COMMAND_WATCHER', true),
        'ignore' => ['key:generate'],
    ],
    ...
],
```

<a name="dump-watcher"></a>
### Dump Watcher

El observador de volcados registra y muestra tus volcados de variables en Telescope. Al usar Laravel, las variables pueden volcarse utilizando la función global `dump`. La pestaña del observador de volcados debe estar abierta en un navegador para que se registre el volcado; de lo contrario, los volcadors serán ignorados por el observador.

<a name="event-watcher"></a>
### Observador de Eventos

El observador de eventos registra la carga útil, los oyentes y los datos de difusión para cualquier [evento](/docs/%7B%7Bversion%7D%7D/events) despachado por tu aplicación. Los eventos internos del framework Laravel son ignorados por el observador de eventos.

<a name="exception-watcher"></a>
### Observador de Excepciones

El observador de excepciones registra los datos y la traza de la pila para cualquier excepción reportable que sea lanzada por tu aplicación.

<a name="gate-watcher"></a>
### Vigilante de Puertas

El observador de puertas registra los datos y el resultado de las verificaciones de [puerta y política](/docs/%7B%7Bversion%7D%7D/authorization) por su aplicación. Si desea excluir ciertas habilidades de ser registradas por el observador, puede especificarlas en la opción `ignore_abilities` en su archivo `config/telescope.php`:


```php
'watchers' => [
    Watchers\GateWatcher::class => [
        'enabled' => env('TELESCOPE_GATE_WATCHER', true),
        'ignore_abilities' => ['viewNova'],
    ],
    ...
],
```

<a name="http-client-watcher"></a>
### Observador de Cliente HTTP

El vigilante del cliente HTTP registra las [solicitudes del cliente HTTP](/docs/%7B%7Bversion%7D%7D/http-client) salientes realizadas por tu aplicación.

<a name="job-watcher"></a>
### Observador de Trabajo

El observador de trabajos registra los datos y el estado de cualquier [trabajo](/docs/%7B%7Bversion%7D%7D/queues) despachado por tu aplicación.

<a name="log-watcher"></a>
### Observador de Registros

El observador de registros registra los [datos de registro](/docs/%7B%7Bversion%7D%7D/logging) para cualquier registro escrito por tu aplicación.
Por defecto, Telescope solo registrará logs en el nivel `error` y superiores. Sin embargo, puedes modificar la opción `level` en el archivo de configuración `config/telescope.php` de tu aplicación para modificar este comportamiento:


```php
'watchers' => [
    Watchers\LogWatcher::class => [
        'enabled' => env('TELESCOPE_LOG_WATCHER', true),
        'level' => 'debug',
    ],

    // ...
],
```

<a name="mail-watcher"></a>
### Observador de Correo

El visor de correo te permite ver una vista previa en el navegador de los [correos electrónicos](/docs/%7B%7Bversion%7D%7D/mail) enviados por tu aplicación junto con sus datos asociados. También puedes descargar el correo electrónico como un archivo `.eml`.

<a name="model-watcher"></a>
### Observador de Modelos

El vigilante de modelos registra los cambios de modelo siempre que se despache un [evento de modelo](/docs/%7B%7Bversion%7D%7D/eloquent#events) de Eloquent. Puedes especificar qué eventos de modelo deben ser registrados a través de la opción `events` del vigilante:


```php
'watchers' => [
    Watchers\ModelWatcher::class => [
        'enabled' => env('TELESCOPE_MODEL_WATCHER', true),
        'events' => ['eloquent.created*', 'eloquent.updated*'],
    ],
    ...
],
```
Si deseas registrar el número de modelos hidratados durante una solicitud dada, habilita la opción `hydrations`:


```php
'watchers' => [
    Watchers\ModelWatcher::class => [
        'enabled' => env('TELESCOPE_MODEL_WATCHER', true),
        'events' => ['eloquent.created*', 'eloquent.updated*'],
        'hydrations' => true,
    ],
    ...
],
```

<a name="notification-watcher"></a>
### Observador de Notificaciones

El observador de notificaciones registra todas las [notificaciones](/docs/%7B%7Bversion%7D%7D/notifications) enviadas por tu aplicación. Si la notificación activa un correo electrónico y tienes habilitado el observador de correo, el correo electrónico también estará disponible para vista previa en la pantalla del observador de correo.

<a name="query-watcher"></a>
### Observador de Consultas

El reloj de consulta registra el SQL en bruto, los enlaces y el tiempo de ejecución para todas las consultas que son ejecutadas por tu aplicación. El reloj también etiqueta cualquier consulta más lenta que 100 milisegundos como `slow`. Puedes personalizar el umbral de consulta lenta utilizando la opción `slow` del reloj:


```php
'watchers' => [
    Watchers\QueryWatcher::class => [
        'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
        'slow' => 50,
    ],
    ...
],
```

<a name="redis-watcher"></a>
### Observador de Redis

El watcher de Redis registra todos los comandos [Redis](/docs/%7B%7Bversion%7D%7D/redis) ejecutados por su aplicación. Si está utilizando Redis para almacenamiento en caché, los comandos de caché también serán registrados por el watcher de Redis.

<a name="request-watcher"></a>
### Observador de Solicitudes

El visor de solicitudes registra la solicitud, encabezados, sesión y datos de respuesta asociados con cualquier solicitud manejada por la aplicación. Puedes limitar los datos de respuesta grabados a través de la opción `size_limit` (en kilobytes):


```php
'watchers' => [
    Watchers\RequestWatcher::class => [
        'enabled' => env('TELESCOPE_REQUEST_WATCHER', true),
        'size_limit' => env('TELESCOPE_RESPONSE_SIZE_LIMIT', 64),
    ],
    ...
],
```

<a name="schedule-watcher"></a>
### Vigilante de Programación

El vigilante de programación registra el comando y la salida de cualquier [tarea programada](/docs/%7B%7Bversion%7D%7D/scheduling) ejecutada por tu aplicación.

<a name="view-watcher"></a>
### Observador de Vista

El observador de vistas registra el nombre, la ruta, los datos y los "compositores" utilizados al renderizar vistas.

<a name="displaying-user-avatars"></a>
## Mostrando Avatares de Usuario

El panel de Telescope muestra el avatar del usuario para el usuario que fue autenticado cuando se guardó una entrada dada. Por defecto, Telescope recuperará los avatares utilizando el servicio web Gravatar. Sin embargo, puedes personalizar la URL del avatar registrando un callback en tu clase `App\Providers\TelescopeServiceProvider`. El callback recibirá la ID y la dirección de correo electrónico del usuario y debe devolver la URL de la imagen del avatar del usuario:


```php
use App\Models\User;
use Laravel\Telescope\Telescope;

/**
 * Register any application services.
 */
public function register(): void
{
    // ...

    Telescope::avatar(function (string $id, string $email) {
        return '/avatars/'.User::find($id)->avatar_path;
    });
}
```