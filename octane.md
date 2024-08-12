# Laravel Octane

- [Introducción](#introduction)
- [Instalación](#installation)
- [Requisitos previos del servidor](#server-prerequisites)
  - [RoadRunner](#roadrunner)
  - [Swoole](#swoole)
- [Servir su aplicación](#serving-your-application)
  - [Servir su aplicación a través de HTTPS](#serving-your-application-via-https)
  - [Servir su aplicación a través de Nginx](#serving-your-application-via-nginx)
  - [Vigilancia de cambios en archivos](#watching-for-file-changes)
  - [Especificación del número de trabajadores](#specifying-the-worker-count)
  - [Especificación del número máximo de peticiones](#specifying-the-max-request-count)
  - [Recarga de trabajadores](#reloading-the-workers)
  - [Detención del servidor](#stopping-the-server)
- [Inyección de dependencia y Octane](#dependency-injection-and-octane)
  - [Inyección de contenedores](#container-injection)
  - [Inyección de peticiones](#request-injection)
  - [Inyección de repositorios de configuración](#configuration-repository-injection)
- [Gestión de fugas de memoria](#managing-memory-leaks)
- [Tareas Concurrentes](#concurrent-tasks)
- [Ticks e intervalos](#ticks-and-intervals)
- [La cache de Octane](#the-octane-cache)
- [Tablas](#tables)

<a name="introduction"></a>
## Introducción

[Laravel Octane](https://github.com/laravel/octane) aumenta drástricamente el rendimiento de tu aplicación sirviéndola mediante servidores de aplicaciones de alta potencia, como [Open Swoole](https://swoole.co.uk) y [Swoole](https://github.com/swoole/swoole-src) y [RoadRunner](https://roadrunner.dev). Octane arranca tu aplicación una vez, la mantiene en memoria, y luego la alimenta de peticiones a velocidades supersónicas.

<a name="installation"></a>
## Instalación

Octane puede instalarse a través del gestor de paquetes Composer:

```shell
composer require laravel/octane
```

Después de instalar Octane, puede ejecutar el comando `octane:install` de Artisan, que instalará el archivo de configuración de Octane en su aplicación:

```shell
php artisan octane:install
```

<a name="server-prerequisites"></a>
## Requisitos previos del servidor

> **Advertencia**  
> Laravel Octane requiere [PHP 8.0+](https://php.net/releases/).

<a name="roadrunner"></a>
### RoadRunner

[RoadRunner](https://roadrunner.dev) funciona sobre el binario RoadRunner, que se construye usando Go. La primera vez que inicie un servidor Octane basado en RoadRunner, Octane le ofrecerá descargar e instalar el binario RoadRunner por usted.

<a name="roadrunner-via-laravel-sail"></a>
#### RoadRunner Vía Laravel Sail

Si usted planea desarrollar su aplicación utilizando [Laravel Sail](/docs/{{version}}/sail), debe ejecutar los siguientes comandos para instalar Octane y RoadRunner:

```shell
./vendor/bin/sail up

./vendor/bin/sail composer require laravel/octane spiral/roadrunner
```

A continuación, debes iniciar un shell Sail y utilizar el ejecutable `rr` para recuperar la última compilación basada en Linux del binario RoadRunner:

```shell
./vendor/bin/sail shell

# Within the Sail shell...
./vendor/bin/rr get-binary
```

Después de instalar el binario RoadRunner, puede salir de su sesión Sail shell. Ahora tendrá que ajustar el archivo `supervisor.conf` utilizado por Sail para mantener su aplicación en ejecución. Para empezar, ejecuta el comando `sail:publish` Artisan:

```shell
./vendor/bin/sail artisan sail:publish
```

A continuación, actualiza la directiva `command` del archivo `docker/supervisord.conf` de tu aplicación para que Sail sirva tu aplicación utilizando Octane en lugar del servidor de desarrollo PHP:

```ini
command=/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=roadrunner --host=0.0.0.0 --rpc-port=6001 --port=80
```

Por último, asegúrese de que el binario `rr` es ejecutable y construya sus imágenes Sail:

```shell
chmod +x ./rr

./vendor/bin/sail build --no-cache
```

<a name="swoole"></a>
### Swoole

Si va a utilizar el servidor de aplicaciones Swoole para servir a su aplicación Laravel Octane, debe instalar la extensión PHP Swoole. Normalmente, esto se puede hacer a través de PECL:

```shell
pecl install swoole
```

<a name="swoole-via-laravel-sail"></a>
#### Swoole Via Laravel Sail

> **Advertencia**  
> Antes de servir una aplicación Octane a través de Sail, asegúrese de que tiene la última versión de Laravel Sail y ejecute `./vendor/bin/sail build --no-cache` dentro del directorio raíz de su aplicación.

De manera alternativa, puede desarrollar su aplicación Octane basada en Swoole utilizando [Laravel](/docs/{{version}}/sail) Sail, el entorno de desarrollo oficial basado en Docker para Laravel. Laravel Sail incluye la extensión Swoole por defecto. Sin embargo, usted todavía tendrá que ajustar el archivo `supervisor.conf` utilizado por Sail para mantener su aplicación en ejecución. Para empezar, ejecuta el comando `sail:publish` Artisan:

```shell
./vendor/bin/sail artisan sail:publish
```

A continuación, actualiza la directiva `command` del archivo `docker/supervisord.conf` de tu aplicación para que Sail sirva tu aplicación utilizando Octane en lugar del servidor de desarrollo PHP:

```ini
command=/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=swoole --host=0.0.0.0 --port=80
```

Por último, construya sus imágenes Sail:

```shell
./vendor/bin/sail build --no-cache
```

<a name="swoole-configuration"></a>
#### Configuración de Swoole

Swoole soporta algunas opciones de configuración adicionales que puede añadir a su archivo de configuración `octane` si es necesario. Debido a que raramente necesitan ser modificadas, estas opciones no están incluidas en el archivo de configuración por defecto:

```php
'swoole' => [
    'options' => [
        'log_file' => storage_path('logs/swoole_http.log'),
        'package_max_length' => 10 * 1024 * 1024,
    ],
],
```

<a name="serving-your-application"></a>
## Servir su aplicación

El servidor Octane puede iniciarse mediante el comando Artisan `octane:start`. De manera predeterminada, este comando utilizará el servidor especificado por la opción de configuración `server` del archivo de configuración de `octane` de su aplicación:

```shell
php artisan octane:start
```

De manera predeterminada, Octane iniciará el servidor en el puerto 8000, por lo que podrá acceder a su aplicación en un navegador web a través de `http://localhost:8000.`

<a name="serving-your-application-via-https"></a>
### Servir su aplicación a través de HTTPS

Por defecto, las aplicaciones que se ejecutan a través de Octane generan enlaces con el prefijo `http://.` La variable de entorno `OCTANE_HTTPS`, que se utiliza dentro del archivo de configuración `config/octane.php` de su aplicación, se puede establecer en `true` cuando se sirve su aplicación a través de HTTPS. Cuando este valor de configuración se establece en `true`, Octane le indicará a Laravel que anteponga `https://` a todos los enlaces generados:

```php
'https' => env('OCTANE_HTTPS', false),
```

<a name="serving-your-application-via-nginx"></a>
### Servir su aplicación a través de Nginx

> **Nota**  
> Si no estás preparado para gestionar tu propia configuración de servidor o no te sientes cómodo configurando todos los servicios necesarios para ejecutar una aplicación Laravel Octane robusta, echa un vistazo a [Laravel Forge](https://forge.laravel.com).

En entornos de producción, debe servir su aplicación Octane detrás de un servidor web tradicional como Nginx o Apache. De este modo, el servidor web podrá servir sus activos estáticos, como imágenes y hojas de estilo, así como gestionar la terminación de su certificado SSL.

En el ejemplo de configuración de Nginx que se muestra a continuación, Nginx servirá los activos estáticos del sitio y enviará las solicitudes al servidor Octane que se ejecuta en el puerto 8000:

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    listen [::]:80;
    server_name domain.com;
    server_tokens off;
    root /home/forge/domain.com/public;

    index index.php;

    charset utf-8;

    location /index.php {
        try_files /not_exists @octane;
    }

    location / {
        try_files $uri $uri/ @octane;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/domain.com-error.log error;

    error_page 404 /index.php;

    location @octane {
        set $suffix "";

        if ($uri = /index.php) {
            set $suffix ?$query_string;
        }

        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header Scheme $scheme;
        proxy_set_header SERVER_PORT $server_port;
        proxy_set_header REMOTE_ADDR $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        proxy_pass http://127.0.0.1:8000$suffix;
    }
}
```

<a name="watching-for-file-changes"></a>
### Vigilancia de cambios en archivos

Dado que su aplicación se carga en memoria una vez cuando se inicia el servidor Octane, cualquier cambio en los archivos de su aplicación no se reflejará cuando actualice su navegador. Por ejemplo, las definiciones de ruta añadidas a su archivo `routes/web.php` no se reflejarán hasta que se reinicie el servidor. Para mayor comodidad, puede utilizar el indicador `--watch` para indicar a Octane que reinicie automáticamente el servidor cuando se produzcan cambios en los archivos de su aplicación:

```shell
php artisan octane:start --watch
```

Antes de utilizar esta función, debe asegurarse de que [Node](https://nodejs.org) está instalado en su entorno de desarrollo local. Además, debe instalar la biblioteca [Chokidar](https://github.com/paulmillr/chokidar) dentro de su proyecto:

```shell
npm install --save-dev chokidar
```

Puede configurar los directorios y archivos que se deben vigilar mediante la opción de configuración `watch` dentro del archivo de configuración `config/octane.php` de su aplicación.

<a name="specifying-the-worker-count"></a>
### Especificación del número de trabajadores(workers)

De forma predeterminada, Octane iniciará un trabajador de solicitud de aplicación para cada núcleo de CPU proporcionado por su máquina. Estos trabajadores se utilizarán para atender las solicitudes HTTP entrantes a medida que ingresan a su aplicación. Puede especificar manualmente cuántos trabajadores desea iniciar utilizando la opción `--workers` al invocar el comando `octane:start`:

```shell
php artisan octane:start --workers=4
```

Si está utilizando el servidor de aplicaciones Swoole, también puede especificar cuántos ["task workers"](#concurrent-tasks) desea iniciar:

```shell
php artisan octane:start --workers=4 --task-workers=6
```

<a name="specifying-the-max-request-count"></a>
### Especificación del número máximo de peticiones

Para ayudar a evitar fugas de memoria, Octane reinicia cualquier trabajador una vez que ha gestionado 500 solicitudes. Para ajustar este número, puede utilizar la opción `--max-requests`:

```shell
php artisan octane:start --max-requests=250
```

<a name="reloading-the-workers"></a>
### Recarga de trabajadores

Puede reiniciar correctamente los trabajadores de aplicaciones del servidor Octane mediante el comando `octane:reload`. Por lo general, esto se debe hacer después de la implementación para que el código recién implementado se cargue en la memoria y se utilice para atender las solicitudes posteriores:

```shell
php artisan octane:reload
```

<a name="stopping-the-server"></a>
### Detención del servidor

Puede detener el servidor Octane utilizando el comando  `:stop` Artisan:

```shell
php artisan octane:stop
```

<a name="checking-the-server-status"></a>
#### Comprobación del estado del servidor

Puede comprobar el estado actual del servidor Octane utilizando el comando `octane:status` Artisan:

```shell
php artisan octane:status
```

<a name="dependency-injection-and-octane"></a>
## Inyección de dependencia y Octane

Dado que Octane arranca su aplicación una vez y la mantiene en memoria mientras atiende las solicitudes, hay algunas advertencias que debe tener en cuenta al construir su aplicación. Por ejemplo, los métodos de `register` y `boot` de los proveedores de servicios de su aplicación sólo se ejecutarán una vez cuando el trabajador de solicitudes arranque inicialmente. En peticiones posteriores, se reutilizará la misma instancia de la aplicación.

A la luz de esto, debes tener especial cuidado cuando inyectes el contenedor de servicios de la aplicación o la petición en el constructor de cualquier objeto. Al hacerlo, ese objeto puede tener una versión obsoleta del contenedor o request en solicitudes posteriores.

Octane se encargará automáticamente de restablecer el estado de framework entre solicitudes. Sin embargo, Octane no siempre sabe cómo restablecer el estado global creado por su aplicación. Por lo tanto, debe prestar atención en crear su aplicación de manera que sea compatible con Octane. A continuación, analizaremos las situaciones más comunes que pueden causar problemas al utilizar Octane.

<a name="container-injection"></a>
### Inyección de contenedores

En general, debe evitar inyectar el contenedor de servicios de la aplicación o la instancia de solicitud HTTP en los constructores de otros objetos. Por ejemplo, la siguiente vinculación inyecta todo el contenedor del servicio de aplicaciones en un objeto que está vinculado como singleton:

```php
use App\Service;

/**
 * Register any application services.
 *
 * @return void
 */
public function register()
{
    $this->app->singleton(Service::class, function ($app) {
        return new Service($app);
    });
}
```

En este ejemplo, si la instancia `Service` se resuelve durante el proceso de arranque de la aplicación, el contenedor se inyectará en el servicio y ese mismo contenedor será mantenido por la instancia `Service` en peticiones posteriores. Esto **puede** no ser un problema para tu aplicación en particular; sin embargo, puede llevar a que el contenedor inesperadamente pierda bindings que fueron añadidos más tarde en el ciclo de arranque o por una petición posterior.

Como solución, puede dejar de registrar el enlace como un singleton, o puede inyectar un closure de resolución de contenedor en el servicio que siempre resuelva la instancia de contenedor actual:

```php
use App\Service;
use Illuminate\Container\Container;

$this->app->bind(Service::class, function ($app) {
    return new Service($app);
});

$this->app->singleton(Service::class, function () {
    return new Service(fn () => Container::getInstance());
});
```

El helper global `app` y el método `Container::getInstance()` siempre devolverán la última versión del contenedor de la aplicación.

<a name="request-injection"></a>
### Inyección de peticiones

En general, debes evitar inyectar el contenedor del servicio de aplicación o la instancia de petición HTTP en los constructores de otros objetos. Por ejemplo, la siguiente vinculación inyecta toda la instancia de solicitud en un objeto que está vinculado como singleton:

```php
use App\Service;

/**
 * Register any application services.
 *
 * @return void
 */
public function register()
{
    $this->app->singleton(Service::class, function ($app) {
        return new Service($app['request']);
    });
}
```

En este ejemplo, si la instancia `Service` es resuelta durante el proceso de arranque de la aplicación, la petición HTTP será inyectada en el servicio y esa misma petición será mantenida por la instancia `Service` en peticiones posteriores. Por lo tanto, todas las cabeceras, entradas y cadenas de consulta serán incorrectas, así como el resto de datos de la petición.

Como solución, puede dejar de registrar la vinculación como un singleton, o puede inyectar un closure de resolución de solicitud en el servicio que siempre resuelva la instancia de solicitud actual. O bien, el enfoque más recomendado es simplemente pasar la información específica de la solicitud que su objeto necesita a uno de los métodos del objeto en tiempo de ejecución:

```php
use App\Service;

$this->app->bind(Service::class, function ($app) {
    return new Service($app['request']);
});

$this->app->singleton(Service::class, function ($app) {
    return new Service(fn () => $app['request']);
});

// Or...

$service->method($request->input('name'));
```

El helper global `request` siempre devolverá la petición que la aplicación está gestionando en ese momento y, por lo tanto, es seguro utilizarlo dentro de tu aplicación.

> **Advertencia**  
> Es aceptable injectar una instancia `Illuminate\Http\Request` a través de lo métodos del controlador y closures de ruta.

<a name="configuration-repository-injection"></a>
### Inyección de repositorios de configuración

En general, debes evitar inyectar la instancia del repositorio de configuración en los constructores de otros objetos. Por ejemplo, la siguiente vinculación inyecta el repositorio de configuración en un objeto que está vinculado como un singleton:

```php
use App\Service;

/**
 * Register any application services.
 *
 * @return void
 */
public function register()
{
    $this->app->singleton(Service::class, function ($app) {
        return new Service($app->make('config'));
    });
}
```

En este ejemplo, si los valores de configuración cambian entre peticiones, ese servicio no tendrá acceso a los nuevos valores porque depende de la instancia original del repositorio.

Como solución, puede dejar de registrar el enlace como un singleton, o puede inyectar un closure resolución de repositorio de configuración a la clase:

```php
use App\Service;
use Illuminate\Container\Container;

$this->app->bind(Service::class, function ($app) {
    return new Service($app->make('config'));
});

$this->app->singleton(Service::class, function () {
    return new Service(fn () => Container::getInstance()->make('config'));
});
```

El helper global `config` siempre devolverá la última versión del repositorio de configuración y por lo tanto es seguro de usar dentro de su aplicación.

<a name="managing-memory-leaks"></a>
### Gestión de fugas de memoria

Recuerde, Octane mantiene su aplicación en memoria entre peticiones; por lo tanto, añadir datos a un array mantenido estáticamente resultará en una fuga de memoria. Por ejemplo, el siguiente controlador tiene una fuga de memoria ya que cada solicitud a la aplicación continuará agregando datos a la array estática `$data`:

```php
use App\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * Handle an incoming request.
 *
 * @param  \Illuminate\Http\Request  $request
 * @return void
 */
public function index(Request $request)
{
    Service::$data[] = Str::random(10);

    // ...
}
```

Mientras construyes tu aplicación, debes tener especial cuidado para evitar crear este tipo de fugas de memoria. Se recomienda que monitorice el uso de memoria de su aplicación durante el desarrollo local para asegurarse de que no está introduciendo nuevas fugas de memoria en su aplicación.

<a name="concurrent-tasks"></a>
## Tareas Concurrentes

> **Advertencia**  
> Esta función requiere [Swoole](#swoole).

Cuando utilice Swoole, puede ejecutar operaciones de forma concurrente a través de tareas ligeras que corran en background. Puede lograr esto usando el método `concurrently` de Octane. Puede combinar este método con la funcionalidad `array destructuring` de PHP para recuperar los resultados de cada operación:

```php
use App\User;
use App\Server;
use Laravel\Octane\Facades\Octane;

[$users, $servers] = Octane::concurrently([
    fn () => User::all(),
    fn () => Server::all(),
]);
```

Las tareas concurrentes procesadas por Octane utilizan los "task workers" de Swoole, y se ejecutan dentro de un proceso completamente diferente al de la solicitud entrante. La cantidad de trabajadores disponibles para procesar tareas concurrentes está determinada por la directiva `--task-workers` en el comando `octane:start`:

```shell
php artisan octane:start --workers=4 --task-workers=6
```

Cuando invoque el método `concurrently`, no debe proporcionar más de 1024 tareas debido a las limitaciones impuestas por el sistema de tareas de Swoole.

<a name="ticks-and-intervals"></a>
## Ticks e intervalos

> **Advertencia**  
> Esta función requiere [Swoole](#swoole).

Al utilizar Swoole, puede registrar operaciones "tick" que se ejecutarán cada número especificado de segundos. Puede registrar llamadas de retorno "tick" a través del método `tick`. El primer argumento proporcionado al método `tick` debe ser una cadena que represente el nombre del ticker. El segundo argumento debe ser un callable que será invocado en el intervalo especificado.

En este ejemplo, registraremos un closure para ser invocado cada 10 segundos. Típicamente, el método `tick` debe ser llamado dentro del método `boot` de uno de los proveedores de servicio de su aplicación:

```php
Octane::tick('simple-ticker', fn () => ray('Ticking...'))
        ->seconds(10);
```

Mediante el método `immediate`, puede indicarle a Octane que invoque inmediatamente la llamada de retorno de tick cuando el servidor Octane arranca inicialmente y, a partir de ese momento, cada N segundos:

```php
Octane::tick('simple-ticker', fn () => ray('Ticking...'))
        ->seconds(10)
        ->immediate();
```

<a name="the-octane-cache"></a>
## La cache de Octane

> **Advertencia**  
> Esta función requiere [Swoole](#swoole).

Al utilizar Swoole, puede aprovechar el controlador de cache de Octane, que proporciona velocidades de lectura y escritura de hasta 2 millones de operaciones por segundo. Por lo tanto, este controlador de cache es una excelente opción para aplicaciones que necesitan velocidades extremas de lectura / escritura de su capa de caché.

Este controlador de cache funciona sobre [tablas Swoole](https://www.swoole.co.uk/docs/modules/swoole-table). Todos los datos almacenados en la cache están disponibles para todos los trabajadores del servidor. Sin embargo, los datos almacenados en la caché se vaciarán cuando se reinicie el servidor:

```php
Cache::store('octane')->put('framework', 'Laravel', 30);
```

> **Nota**  
> El número máximo de entradas permitidas en la cache de `Octane` puede definirse en el archivo de configuración de `octane` de su aplicación.

<a name="cache-intervals"></a>
### Intervalos de cache

Además de los métodos típicos proporcionados por el sistema de cache de Laravel, el controlador de cache de Octane cuenta con cachés basadas en intervalos. Estas cachés se actualizan automáticamente en el intervalo especificado y deben registrarse dentro del método de `boot` de uno de los proveedores de servicios de su aplicación. Por ejemplo, la siguiente cache se actualizará cada cinco segundos:

```php
use Illuminate\Support\Str;

Cache::store('octane')->interval('random', function () {
    return Str::random(10);
}, seconds: 5);
```

<a name="tables"></a>
## Tablas

> **Advertencia**  
> Esta función requiere [Swoole](#swoole).

Cuando utilice Swoole, podrá definir e interactuar con sus propias [tablas Swoole](https://www.swoole.co.uk/docs/modules/swoole-table) arbitrarias. Las tablas Swoole proporcionan un rendimiento extremo y todos los trabajadores del servidor pueden acceder a los datos de estas tablas. Sin embargo, los datos que contienen se perderán cuando se reinicie el servidor.

Las tablas deben definirse dentro de la array configuración `tables` del archivo de configuración de `octane` de su aplicación. Una tabla de ejemplo que permite un máximo de 1000 filas ya está configurada para usted. El tamaño máximo de las columnas de cadena puede configurarse especificando el tamaño de la columna después del tipo de columna, como se ve a continuación:

```php
'tables' => [
    'example:1000' => [
        'name' => 'string:1000',
        'votes' => 'int',
    ],
],
```

Para acceder a una tabla, puede utilizar el método `Octane::table`:

```php
use Laravel\Octane\Facades\Octane;

Octane::table('example')->set('uuid', [
    'name' => 'Nuno Maduro',
    'votes' => 1000,
]);

return Octane::table('example')->get('uuid');
```

> **Aviso**  
> Los tipos de columna soportados por las tablas Swoole son: `string`, `int` y `float`.
