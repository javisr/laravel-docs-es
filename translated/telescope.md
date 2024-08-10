# Laravel Telescope

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Instalación Solo Local](#local-only-installation)
    - [Configuración](#configuration)
    - [Poda de Datos](#data-pruning)
    - [Autorización del Dashboard](#dashboard-authorization)
- [Actualizando Telescope](#upgrading-telescope)
- [Filtrado](#filtering)
    - [Entradas](#filtering-entries)
    - [Lotes](#filtering-batches)
- [Etiquetado](#tagging)
- [Observadores Disponibles](#available-watchers)
    - [Observador de Lotes](#batch-watcher)
    - [Observador de Caché](#cache-watcher)
    - [Observador de Comandos](#command-watcher)
    - [Observador de Volcado](#dump-watcher)
    - [Observador de Eventos](#event-watcher)
    - [Observador de Excepciones](#exception-watcher)
    - [Observador de Puertas](#gate-watcher)
    - [Observador de Cliente HTTP](#http-client-watcher)
    - [Observador de Trabajos](#job-watcher)
    - [Observador de Registros](#log-watcher)
    - [Observador de Correo](#mail-watcher)
    - [Observador de Modelos](#model-watcher)
    - [Observador de Notificaciones](#notification-watcher)
    - [Observador de Consultas](#query-watcher)
    - [Observador de Redis](#redis-watcher)
    - [Observador de Solicitudes](#request-watcher)
    - [Observador de Programación](#schedule-watcher)
    - [Observador de Vistas](#view-watcher)
- [Mostrando Avatares de Usuario](#displaying-user-avatars)

<a name="introduction"></a>
## Introducción

[Laravel Telescope](https://github.com/laravel/telescope) es un compañero maravilloso para tu entorno de desarrollo local de Laravel. Telescope proporciona información sobre las solicitudes que llegan a tu aplicación, excepciones, entradas de registro, consultas a la base de datos, trabajos en cola, correo, notificaciones, operaciones de caché, tareas programadas, volcado de variables y más.

<img src="https://laravel.com/img/docs/telescope-example.png">

<a name="installation"></a>
## Instalación

Puedes usar el gestor de paquetes Composer para instalar Telescope en tu proyecto de Laravel:

```shell
composer require laravel/telescope
```

Después de instalar Telescope, publica sus activos y migraciones usando el comando Artisan `telescope:install`. Después de instalar Telescope, también deberías ejecutar el comando `migrate` para crear las tablas necesarias para almacenar los datos de Telescope:

```shell
php artisan telescope:install

php artisan migrate
```

Finalmente, puedes acceder al dashboard de Telescope a través de la ruta `/telescope`.

<a name="local-only-installation"></a>
### Instalación Solo Local

Si planeas usar Telescope solo para ayudar en tu desarrollo local, puedes instalar Telescope usando la bandera `--dev`:

```shell
composer require laravel/telescope --dev

php artisan telescope:install

php artisan migrate
```

Después de ejecutar `telescope:install`, deberías eliminar el registro del proveedor de servicios `TelescopeServiceProvider` del archivo de configuración `bootstrap/providers.php` de tu aplicación. En su lugar, registra manualmente los proveedores de servicios de Telescope en el método `register` de tu clase `App\Providers\AppServiceProvider`. Aseguraremos que el entorno actual sea `local` antes de registrar los proveedores:

    /**
     * Registrar cualquier servicio de la aplicación.
     */
    public function register(): void
    {
        if ($this->app->environment('local')) {
            $this->app->register(\Laravel\Telescope\TelescopeServiceProvider::class);
            $this->app->register(TelescopeServiceProvider::class);
        }
    }

Finalmente, también deberías evitar que el paquete Telescope sea [auto-descubierto](/docs/{{version}}/packages#package-discovery) agregando lo siguiente a tu archivo `composer.json`:

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

Después de publicar los activos de Telescope, su archivo de configuración principal estará ubicado en `config/telescope.php`. Este archivo de configuración te permite configurar tus [opciones de observador](#available-watchers). Cada opción de configuración incluye una descripción de su propósito, así que asegúrate de explorar este archivo a fondo.

Si lo deseas, puedes deshabilitar completamente la recopilación de datos de Telescope usando la opción de configuración `enabled`:

    'enabled' => env('TELESCOPE_ENABLED', true),

<a name="data-pruning"></a>
### Poda de Datos

Sin poda, la tabla `telescope_entries` puede acumular registros muy rápidamente. Para mitigar esto, deberías [programar](/docs/{{version}}/scheduling) el comando Artisan `telescope:prune` para que se ejecute diariamente:

    use Illuminate\Support\Facades\Schedule;

    Schedule::command('telescope:prune')->daily();

Por defecto, todas las entradas más antiguas de 24 horas serán podadas. Puedes usar la opción `hours` al llamar al comando para determinar cuánto tiempo retener los datos de Telescope. Por ejemplo, el siguiente comando eliminará todos los registros creados hace más de 48 horas:

    use Illuminate\Support\Facades\Schedule;

    Schedule::command('telescope:prune --hours=48')->daily();

<a name="dashboard-authorization"></a>
### Autorización del Dashboard

El dashboard de Telescope puede ser accedido a través de la ruta `/telescope`. Por defecto, solo podrás acceder a este dashboard en el entorno `local`. Dentro de tu archivo `app/Providers/TelescopeServiceProvider.php`, hay una definición de [puerta de autorización](/docs/{{version}}/authorization#gates). Esta puerta de autorización controla el acceso a Telescope en entornos **no locales**. Eres libre de modificar esta puerta según sea necesario para restringir el acceso a tu instalación de Telescope:

    use App\Models\User;

    /**
     * Registrar la puerta de Telescope.
     *
     * Esta puerta determina quién puede acceder a Telescope en entornos no locales.
     */
    protected function gate(): void
    {
        Gate::define('viewTelescope', function (User $user) {
            return in_array($user->email, [
                'taylor@laravel.com',
            ]);
        });
    }

> [!WARNING]  
> Debes asegurarte de cambiar tu variable de entorno `APP_ENV` a `production` en tu entorno de producción. De lo contrario, tu instalación de Telescope estará disponible públicamente.

<a name="upgrading-telescope"></a>
## Actualizando Telescope

Al actualizar a una nueva versión principal de Telescope, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/telescope/blob/master/UPGRADE.md).

Además, al actualizar a cualquier nueva versión de Telescope, deberías volver a publicar los activos de Telescope:

```shell
php artisan telescope:publish
```

Para mantener los activos actualizados y evitar problemas en futuras actualizaciones, puedes agregar el comando `vendor:publish --tag=laravel-assets` a los scripts `post-update-cmd` en tu archivo `composer.json` de tu aplicación:

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

Puedes filtrar los datos que se registran por Telescope a través de la `filter` función anónima que se define en tu clase `App\Providers\TelescopeServiceProvider`. Por defecto, esta función anónima registra todos los datos en el entorno `local` y excepciones, trabajos fallidos, tareas programadas y datos con etiquetas monitoreadas en todos los demás entornos:

    use Laravel\Telescope\IncomingEntry;
    use Laravel\Telescope\Telescope;

    /**
     * Registrar cualquier servicio de la aplicación.
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

<a name="filtering-batches"></a>
### Lotes

Mientras que la `filter` función anónima filtra datos para entradas individuales, puedes usar el método `filterBatch` para registrar una función anónima que filtra todos los datos para una solicitud o comando de consola dado. Si la función anónima devuelve `true`, todas las entradas son registradas por Telescope:

    use Illuminate\Support\Collection;
    use Laravel\Telescope\IncomingEntry;
    use Laravel\Telescope\Telescope;

    /**
     * Registrar cualquier servicio de la aplicación.
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

<a name="tagging"></a>
## Etiquetado

Telescope te permite buscar entradas por "etiqueta". A menudo, las etiquetas son nombres de clases de modelo Eloquent o IDs de usuario autenticados que Telescope agrega automáticamente a las entradas. Ocasionalmente, puede que desees adjuntar tus propias etiquetas personalizadas a las entradas. Para lograr esto, puedes usar el método `Telescope::tag`. El método `tag` acepta una función anónima que debe devolver un array de etiquetas. Las etiquetas devueltas por la función anónima se fusionarán con cualquier etiqueta que Telescope adjuntaría automáticamente a la entrada. Típicamente, deberías llamar al método `tag` dentro del método `register` de tu clase `App\Providers\TelescopeServiceProvider`:

    use Laravel\Telescope\IncomingEntry;
    use Laravel\Telescope\Telescope;

    /**
     * Registrar cualquier servicio de la aplicación.
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

<a name="available-watchers"></a>
## Observadores Disponibles

Los "observadores" de Telescope recopilan datos de la aplicación cuando se ejecuta una solicitud o un comando de consola. Puedes personalizar la lista de observadores que te gustaría habilitar dentro de tu archivo de configuración `config/telescope.php`:

    'watchers' => [
        Watchers\CacheWatcher::class => true,
        Watchers\CommandWatcher::class => true,
        ...
    ],

Algunos observadores también te permiten proporcionar opciones de personalización adicionales:

    'watchers' => [
        Watchers\QueryWatcher::class => [
            'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
            'slow' => 100,
        ],
        ...
    ],

<a name="batch-watcher"></a>
### Observador de Lotes

El observador de lotes registra información sobre [lotes](/docs/{{version}}/queues#job-batching) en cola, incluyendo la información del trabajo y la conexión.

<a name="cache-watcher"></a>
### Observador de Caché

El observador de caché registra datos cuando se accede, se pierde, se actualiza y se olvida una clave de caché.

<a name="command-watcher"></a>
### Observador de Comandos

El observador de comandos registra los argumentos, opciones, código de salida y salida cada vez que se ejecuta un comando Artisan. Si deseas excluir ciertos comandos de ser registrados por el observador, puedes especificar el comando en la opción `ignore` dentro de tu archivo `config/telescope.php`:

    'watchers' => [
        Watchers\CommandWatcher::class => [
            'enabled' => env('TELESCOPE_COMMAND_WATCHER', true),
            'ignore' => ['key:generate'],
        ],
        ...
    ],

<a name="dump-watcher"></a>
### Observador de Volcado

El observador de volcado registra y muestra tus volcaduras de variables en Telescope. Al usar Laravel, las variables pueden ser volcadas usando la función global `dump`. La pestaña de volcado debe estar abierta en un navegador para que el volcado sea registrado, de lo contrario, los volcaduras serán ignorados por el observador.

<a name="event-watcher"></a>
### Observador de Eventos

El observador de eventos registra la carga útil, los oyentes y los datos de difusión para cualquier [evento](/docs/{{version}}/events) despachado por tu aplicación. Los eventos internos del marco de Laravel son ignorados por el observador de eventos.

<a name="exception-watcher"></a>
### Observador de Excepciones

El observador de excepciones registra los datos y la traza de pila para cualquier excepción reportable que sea lanzada por tu aplicación.

<a name="gate-watcher"></a>
### Observador de Puertas

El observador de puertas registra los datos y el resultado de las verificaciones de [puerta y política](/docs/{{version}}/authorization) por tu aplicación. Si deseas excluir ciertas habilidades de ser registradas por el observador, puedes especificarlas en la opción `ignore_abilities` en tu archivo `config/telescope.php`:

    'watchers' => [
        Watchers\GateWatcher::class => [
            'enabled' => env('TELESCOPE_GATE_WATCHER', true),
            'ignore_abilities' => ['viewNova'],
        ],
        ...
    ],

<a name="http-client-watcher"></a>
### Observador de Cliente HTTP

El observador de cliente HTTP registra las [solicitudes de cliente HTTP](/docs/{{version}}/http-client) salientes realizadas por tu aplicación.

<a name="job-watcher"></a>
### Observador de Trabajos

El observador de trabajos registra los datos y el estado de cualquier [trabajo](/docs/{{version}}/queues) despachado por tu aplicación.

<a name="log-watcher"></a>
### Observador de Registros

El observador de registros registra los [datos de registro](/docs/{{version}}/logging) para cualquier registro escrito por tu aplicación.

Por defecto, Telescope solo registrará registros en el nivel `error` y superior. Sin embargo, puedes modificar la opción `level` en el archivo de configuración `config/telescope.php` de tu aplicación para modificar este comportamiento:

    'watchers' => [
        Watchers\LogWatcher::class => [
            'enabled' => env('TELESCOPE_LOG_WATCHER', true),
            'level' => 'debug',
        ],

        // ...
    ],

<a name="mail-watcher"></a>
### Observador de Correo

El observador de correo te permite ver una vista previa en el navegador de [correos](/docs/{{version}}/mail) enviados por tu aplicación junto con sus datos asociados. También puedes descargar el correo como un archivo `.eml`.

<a name="model-watcher"></a>
### Observador de Modelos

El observador de modelos registra cambios en los modelos cada vez que se despacha un [evento de modelo](/docs/{{version}}/eloquent#events) Eloquent. Puedes especificar qué eventos de modelo deben ser registrados a través de la opción `events` del observador:

    'watchers' => [
        Watchers\ModelWatcher::class => [
            'enabled' => env('TELESCOPE_MODEL_WATCHER', true),
            'events' => ['eloquent.created*', 'eloquent.updated*'],
        ],
        ...
    ],

Si deseas registrar el número de modelos hidratados durante una solicitud dada, habilita la opción `hydrations`:

    'watchers' => [
        Watchers\ModelWatcher::class => [
            'enabled' => env('TELESCOPE_MODEL_WATCHER', true),
            'events' => ['eloquent.created*', 'eloquent.updated*'],
            'hydrations' => true,
        ],
        ...
    ],

<a name="notification-watcher"></a>
### Observador de Notificaciones

El observador de notificaciones registra todas las [notificaciones](/docs/{{version}}/notifications) enviadas por tu aplicación. Si la notificación desencadena un correo y tienes habilitado el observador de correo, el correo también estará disponible para vista previa en la pantalla del observador de correo.

<a name="query-watcher"></a>
### Observador de Consultas

El observador de consultas registra el SQL en bruto, los enlaces y el tiempo de ejecución para todas las consultas que son ejecutadas por tu aplicación. El observador también etiqueta cualquier consulta más lenta de 100 milisegundos como `slow`. Puedes personalizar el umbral de consulta lenta usando la opción `slow` del observador:

    'watchers' => [
        Watchers\QueryWatcher::class => [
            'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
            'slow' => 50,
        ],
        ...
    ],

<a name="redis-watcher"></a>
### Observador de Redis

El observador de Redis registra todos los [Redis](/docs/{{version}}/redis) comandos ejecutados por tu aplicación. Si estás utilizando Redis para almacenamiento en caché, los comandos de caché también serán registrados por el observador de Redis.

<a name="request-watcher"></a>
### Observador de Solicitudes

El observador de solicitudes registra la solicitud, encabezados, sesión y datos de respuesta asociados con cualquier solicitud manejada por la aplicación. Puedes limitar los datos de respuesta registrados a través de la opción `size_limit` (en kilobytes):

    'watchers' => [
        Watchers\RequestWatcher::class => [
            'enabled' => env('TELESCOPE_REQUEST_WATCHER', true),
            'size_limit' => env('TELESCOPE_RESPONSE_SIZE_LIMIT', 64),
        ],
        ...
    ],

<a name="schedule-watcher"></a>
### Observador de Programación

El observador de programación registra el comando y la salida de cualquier [tarea programada](/docs/{{version}}/scheduling) ejecutada por tu aplicación.

<a name="view-watcher"></a>
### Observador de Vistas

El observador de vistas registra el [view](/docs/{{version}}/views) nombre, ruta, datos y "composers" utilizados al renderizar vistas.

<a name="displaying-user-avatars"></a>
## Mostrando Avatares de Usuario

El panel de control de Telescope muestra el avatar del usuario que fue autenticado cuando se guardó una entrada dada. Por defecto, Telescope recuperará avatares utilizando el servicio web Gravatar. Sin embargo, puedes personalizar la URL del avatar registrando una función anónima en tu clase `App\Providers\TelescopeServiceProvider`. La función anónima recibirá el ID y la dirección de correo electrónico del usuario y debe devolver la URL de la imagen del avatar del usuario:

    use App\Models\User;
    use Laravel\Telescope\Telescope;

    /**
     * Registrar cualquier servicio de aplicación.
     */
    public function register(): void
    {
        // ...

        Telescope::avatar(function (string $id, string $email) {
            return '/avatars/'.User::find($id)->avatar_path;
        });
    }
