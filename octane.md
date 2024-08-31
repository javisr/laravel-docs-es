# Laravel Octane

- [Introducción](#introduction)
- [Instalación](#installation)
- [Requisitos Previos del Servidor](#server-prerequisites)
  - [FrankenPHP](#frankenphp)
  - [RoadRunner](#roadrunner)
  - [Swoole](#swoole)
- [Sirviendo Tu Aplicación](#serving-your-application)
  - [Sirviendo Tu Aplicación a través de HTTPS](#serving-your-application-via-https)
  - [Sirviendo Tu Aplicación a través de Nginx](#serving-your-application-via-nginx)
  - [Observando Cambios en Archivos](#watching-for-file-changes)
  - [Especificando el Conteo de Trabajadores](#specifying-the-worker-count)
  - [Especificando el Conteo Máximo de Solicitudes](#specifying-the-max-request-count)
  - [Recargando los Trabajadores](#reloading-the-workers)
  - [Deteniendo el Servidor](#stopping-the-server)
- [Inyección de Dependencias y Octane](#dependency-injection-and-octane)
  - [Inyección de Contenedor](#container-injection)
  - [Inyección de Solicitud](#request-injection)
  - [Inyección de Repositorio de Configuración](#configuration-repository-injection)
- [Gestionando Fugas de Memoria](#managing-memory-leaks)
- [Tareas Concurrentes](#concurrent-tasks)
- [Ticks e Intervalos](#ticks-and-intervals)
- [La Caché de Octane](#the-octane-cache)
- [Tablas](#tables)

<a name="introduction"></a>
## Introducción

[Laravel Octane](https://github.com/laravel/octane) potencia el rendimiento de tu aplicación al servirla utilizando servidores de aplicaciones de alto rendimiento, incluidos [FrankenPHP](https://frankenphp.dev/), [Open Swoole](https://openswoole.com/), [Swoole](https://github.com/swoole/swoole-src) y [RoadRunner](https://roadrunner.dev). Octane inicia tu aplicación una vez, la mantiene en memoria y luego le envía solicitudes a velocidades supersónicas.

<a name="installation"></a>
## Instalación

Octane se puede instalar a través del gestor de paquetes Composer:


```shell
composer require laravel/octane

```
Después de instalar Octane, puedes ejecutar el comando Artisan `octane:install`, que instalará el archivo de configuración de Octane en tu aplicación:


```shell
php artisan octane:install

```

<a name="server-prerequisites"></a>
## Prerrequisitos del Servidor

> [!WARNING]
Laravel Octane requiere [PHP 8.1+](https://php.net/releases/).

<a name="frankenphp"></a>
### FrankenPHP

[FrankenPHP](https://frankenphp.dev) es un servidor de aplicaciones PHP, escrito en Go, que admite características web modernas como sugerencias tempranas, compresión Brotli y Zstandard. Cuando instales Octane y elijas FrankenPHP como tu servidor, Octane descargará e instalará automáticamente el binary de FrankenPHP para ti.

<a name="frankenphp-via-laravel-sail"></a>
#### FrankenPHP a través de Laravel Sail

Si planeas desarrollar tu aplicación utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), debes ejecutar los siguientes comandos para instalar Octane y FrankenPHP:


```shell
./vendor/bin/sail up

./vendor/bin/sail composer require laravel/octane

```
A continuación, deberías usar el comando Artisan `octane:install` para instalar el binario FrankenPHP:


```shell
./vendor/bin/sail artisan octane:install --server=frankenphp

```
Finalmente, añade una variable de entorno `SUPERVISOR_PHP_COMMAND` a la definición del servicio `laravel.test` en el archivo `docker-compose.yml` de tu aplicación. Esta variable de entorno contendrá el comando que Sail utilizará para servir tu aplicación utilizando Octane en lugar del servidor de desarrollo PHP:


```yaml
services:
  laravel.test:
    environment:
      SUPERVISOR_PHP_COMMAND: "/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=frankenphp --host=0.0.0.0 --admin-port=2019 --port=80" # [tl! add]
      XDG_CONFIG_HOME:  /var/www/html/config # [tl! add]
      XDG_DATA_HOME:  /var/www/html/data # [tl! add]

```
Para habilitar HTTPS, HTTP/2 y HTTP/3, aplica estas modificaciones en su lugar:


```yaml
services:
  laravel.test:
    ports:
        - '${APP_PORT:-80}:80'
        - '${VITE_PORT:-5173}:${VITE_PORT:-5173}'
        - '443:443' # [tl! add]
        - '443:443/udp' # [tl! add]
    environment:
      SUPERVISOR_PHP_COMMAND: "/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --host=localhost --port=443 --admin-port=2019 --https" # [tl! add]
      XDG_CONFIG_HOME:  /var/www/html/config # [tl! add]
      XDG_DATA_HOME:  /var/www/html/data # [tl! add]

```
Típicamente, deberías acceder a tu aplicación FrankenPHP Sail a través de `https://localhost`, ya que usar `https://127.0.0.1` requiere configuración adicional y está [desaconsejado](https://frankenphp.dev/docs/known-issues/#using-https127001-with-docker).

<a name="frankenphp-via-docker"></a>
#### FrankenPHP a través de Docker

Usar las imágenes oficiales de Docker de FrankenPHP puede ofrecer un rendimiento mejorado y el uso de extensiones adicionales no incluidas con instalaciones estáticas de FrankenPHP. Además, las imágenes oficiales de Docker proporcionan soporte para ejecutar FrankenPHP en plataformas que no admite de forma nativa, como Windows. Las imágenes oficiales de Docker de FrankenPHP son adecuadas tanto para desarrollo local como para uso en producción.
Puedes usar el siguiente Dockerfile como punto de partida para contenerizar tu aplicación Laravel impulsada por FrankenPHP:


```dockerfile
FROM dunglas/frankenphp

RUN install-php-extensions \
    pcntl
    # Add other PHP extensions here...

COPY . /app

ENTRYPOINT ["php", "artisan", "octane:frankenphp"]

```
Entonces, durante el desarrollo, puedes utilizar el siguiente archivo Docker Compose para ejecutar tu aplicación:


```yaml
# compose.yaml
services:
  frankenphp:
    build:
      context: .
    entrypoint: php artisan octane:frankenphp --workers=1 --max-requests=1
    ports:
      - "8000:8000"
    volumes:
      - .:/app

```
Puedes consultar [la documentación oficial de FrankenPHP](https://frankenphp.dev/docs/docker/) para obtener más información sobre cómo ejecutar FrankenPHP con Docker.

<a name="roadrunner"></a>
### RoadRunner

[RoadRunner](https://roadrunner.dev) está alimentado por el binario de RoadRunner, que está construido utilizando Go. La primera vez que inicies un servidor Octane basado en RoadRunner, Octane te ofrecerá descargar e instalar el binario de RoadRunner por ti.

<a name="roadrunner-via-laravel-sail"></a>
#### RoadRunner a través de Laravel Sail

Si planeas desarrollar tu aplicación utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), deberías ejecutar los siguientes comandos para instalar Octane y RoadRunner:


```shell
./vendor/bin/sail up

./vendor/bin/sail composer require laravel/octane spiral/roadrunner-cli spiral/roadrunner-http

```
A continuación, debes iniciar un shell de Sail y utilizar el ejecutable `rr` para recuperar la última compilación basada en Linux del binario RoadRunner:


```shell
./vendor/bin/sail shell

# Within the Sail shell...
./vendor/bin/rr get-binary

```
Luego, añade una variable de entorno `SUPERVISOR_PHP_COMMAND` a la definición del servicio `laravel.test` en el archivo `docker-compose.yml` de tu aplicación. Esta variable de entorno contendrá el comando que Sail utilizará para servir tu aplicación utilizando Octane en lugar del servidor de desarrollo PHP:


```yaml
services:
  laravel.test:
    environment:
      SUPERVISOR_PHP_COMMAND: "/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=roadrunner --host=0.0.0.0 --rpc-port=6001 --port=80" # [tl! add]

```
Finalmente, asegúrate de que el binario `rr` sea ejecutable y construye tus imágenes de Sail:


```shell
chmod +x ./rr

./vendor/bin/sail build --no-cache

```

<a name="swoole"></a>
### Swoole

Si planeas usar el servidor de aplicaciones Swoole para servir tu aplicación Laravel Octane, debes instalar la extensión PHP de Swoole. Típicamente, esto se puede hacer a través de PECL:


```shell
pecl install swoole

```

<a name="openswoole"></a>
#### Abrir Swoole

Si deseas utilizar el servidor de aplicaciones Open Swoole para servir tu aplicación Laravel Octane, debes instalar la extensión PHP de Open Swoole. Típicamente, esto se puede hacer a través de PECL:


```shell
pecl install openswoole

```
Usar Laravel Octane con Open Swoole otorga la misma funcionalidad que proporciona Swoole, como tareas concurrentes, ticks e intervalos.

<a name="swoole-via-laravel-sail"></a>
#### Swoole a través de Laravel Sail

> [!WARNING]
Antes de servir una aplicación de Octane a través de Sail, asegúrate de tener la última versión de Laravel Sail y ejecuta `./vendor/bin/sail build --no-cache` dentro del directorio raíz de tu aplicación.
Alternativamente, puedes desarrollar tu aplicación Octane basada en Swoole utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), el entorno de desarrollo basado en Docker oficial de Laravel. Laravel Sail incluye la extensión Swoole por defecto. Sin embargo, aún necesitarás ajustar el archivo `docker-compose.yml` utilizado por Sail.
Para comenzar, agrega una variable de entorno `SUPERVISOR_PHP_COMMAND` a la definición del servicio `laravel.test` en el archivo `docker-compose.yml` de tu aplicación. Esta variable de entorno contendrá el comando que Sail utilizará para servir tu aplicación utilizando Octane en lugar del servidor de desarrollo PHP:


```yaml
services:
  laravel.test:
    environment:
      SUPERVISOR_PHP_COMMAND: "/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan octane:start --server=swoole --host=0.0.0.0 --port=80" # [tl! add]

```
Finalmente, construye tus imágenes de Sail:


```shell
./vendor/bin/sail build --no-cache

```

<a name="swoole-configuration"></a>
#### Configuración de Swoole

Swoole admite algunas opciones de configuración adicionales que puedes añadir a tu archivo de configuración `octane` si es necesario. Dado que rara vez necesitan ser modificadas, estas opciones no se incluyen en el archivo de configuración predeterminado:


```php
'swoole' => [
    'options' => [
        'log_file' => storage_path('logs/swoole_http.log'),
        'package_max_length' => 10 * 1024 * 1024,
    ],
],

```

<a name="serving-your-application"></a>
## Sirviendo Tu Aplicación

El servidor Octane puede iniciarse a través del comando Artisan `octane:start`. Por defecto, este comando utilizará el servidor especificado por la opción de configuración `server` del archivo de configuración `octane` de tu aplicación:


```shell
php artisan octane:start

```
Por defecto, Octane iniciará el servidor en el puerto 8000, por lo que puedes acceder a tu aplicación en un navegador web a través de `http://localhost:8000`.

<a name="serving-your-application-via-https"></a>
### Sirviendo tu Aplicación a través de HTTPS

Por defecto, las aplicaciones que se ejecutan a través de Octane generan enlaces prefijados con `http://`. La variable de entorno `OCTANE_HTTPS`, utilizada dentro del archivo de configuración `config/octane.php` de tu aplicación, se puede configurar en `true` cuando sirvas tu aplicación a través de HTTPS. Cuando este valor de configuración se establece en `true`, Octane indicará a Laravel que prefije todos los enlaces generados con `https://`:


```php
'https' => env('OCTANE_HTTPS', false),

```

<a name="serving-your-application-via-nginx"></a>
### Sirviendo tu aplicación a través de Nginx

> [!NOTA]
Si aún no estás listo para gestionar tu propia configuración de servidor o no te sientes cómodo configurando todos los diversos servicios necesarios para ejecutar una robusta aplicación Laravel Octane, consulta [Laravel Forge](https://forge.laravel.com).
En entornos de producción, debes servir tu aplicación Octane detrás de un servidor web tradicional como Nginx o Apache. Hacer esto permitirá que el servidor web sirva tus activos estáticos como imágenes y hojas de estilo, así como gestionar la terminación de tu certificado SSL.
En el ejemplo de configuración de Nginx a continuación, Nginx servirá los activos estáticos del sitio y proxy will a las solicitudes al servidor Octane que se está ejecutando en el puerto 8000:


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
### Observando Cambios en Archivos

Dado que tu aplicación se carga en memoria una vez cuando se inicia el servidor Octane, cualquier cambio en los archivos de tu aplicación no se reflejará cuando actualices tu navegador. Por ejemplo, las definiciones de ruta añadidas a tu archivo `routes/web.php` no se reflejarán hasta que se reinicie el servidor. Para mayor comodidad, puedes usar el flag `--watch` para instruir a Octane a reiniciar automáticamente el servidor ante cualquier cambio en los archivos dentro de tu aplicación:


```shell
php artisan octane:start --watch

```
Antes de usar esta función, debes asegurarte de que [Node](https://nodejs.org) esté instalado en tu entorno de desarrollo local. Además, deberías instalar la biblioteca de vigilancia de archivos [Chokidar](https://github.com/paulmillr/chokidar) dentro de tu proyecto:


```shell
npm install --save-dev chokidar

```
Puedes configurar los directorios y archivos que se deben supervisar utilizando la opción de configuración `watch` dentro del archivo de configuración `config/octane.php` de tu aplicación.

<a name="specifying-the-worker-count"></a>
### Especificando el Conteo de Trabajadores

Por defecto, Octane iniciará un trabajador de solicitud de aplicación para cada núcleo de CPU proporcionado por tu máquina. Estos trabajadores se utilizarán para servir las solicitudes HTTP entrantes a medida que ingresen a tu aplicación. Puedes especificar manualmente cuántos trabajadores te gustaría iniciar utilizando la opción `--workers` al invocar el comando `octane:start`:


```shell
php artisan octane:start --workers=4

```
Si estás utilizando el servidor de aplicaciones Swoole, también puedes especificar cuántos ["trabajadores de tarea"](#concurrent-tasks) deseas iniciar:

<a name="specifying-the-max-request-count"></a>
### Especificando el Conteo Máximo de Solicitudes

Para ayudar a prevenir fugas de memoria, Octane reinicia de forma controlada cualquier trabajador una vez que ha gestionado 500 solicitudes. Para ajustar este número, puedes usar la opción `--max-requests`:


```shell
php artisan octane:start --max-requests=250

```

<a name="reloading-the-workers"></a>
### Recargando los Trabajadores (Workers)

Puedes reiniciar de manera elegante los trabajadores de la aplicación del servidor Octane utilizando el comando `octane:reload`. Típicamente, esto se debe hacer después del despliegue para que tu código recién desplegado se cargue en memoria y se utilice para atender las solicitudes posteriores:


```shell
php artisan octane:reload

```

<a name="stopping-the-server"></a>
### Deteniendo el Servidor

Puedes detener el servidor Octane utilizando el comando Artisan `octane:stop`:


```shell
php artisan octane:stop

```

<a name="checking-the-server-status"></a>
#### Comprobando el Estado del Servidor

Puedes verificar el estado actual del servidor Octane utilizando el comando Artisan `octane:status`:


```shell
php artisan octane:status

```

<a name="dependency-injection-and-octane"></a>
## Inyección de Dependencias y Octane

Dado que Octane inicia tu aplicación una vez y la mantiene en memoria mientras atiende las solicitudes, hay algunas advertencias que debes considerar al construir tu aplicación. Por ejemplo, los métodos `register` y `boot` de los proveedores de servicios de tu aplicación solo se ejecutarán una vez cuando el trabajador de solicitudes se inicie inicialmente. En solicitudes posteriores, se reutilizará la misma instancia de la aplicación.
En vista de esto, debes tener especial cuidado al inyectar el contenedor de servicios de la aplicación o la solicitud en el constructor de cualquier objeto. Al hacerlo, es posible que ese objeto tenga una versión obsoleta del contenedor o de la solicitud en solicitudes posteriores.
Octane se encargará automáticamente de restablecer cualquier estado del marco de trabajo de primera parte entre solicitudes. Sin embargo, Octane no siempre sabe cómo restablecer el estado global creado por su aplicación. Por lo tanto, debe ser consciente de cómo construir su aplicación de una manera que sea amigable con Octane. A continuación, discutiremos las situaciones más comunes que pueden causar problemas al usar Octane.

<a name="container-injection"></a>
### Inyección de Contenedor

En general, deberías evitar inyectar el contenedor de servicios de la aplicación o la instancia de la solicitud HTTP en los constructores de otros objetos. Por ejemplo, el siguiente enlace inyecta todo el contenedor de servicios de la aplicación en un objeto que está vinculado como un singleton:


```php
use App\Service;
use Illuminate\Contracts\Foundation\Application;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->app->singleton(Service::class, function (Application $app) {
        return new Service($app);
    });
}

```
En este ejemplo, si la instancia de `Service` se resuelve durante el proceso de arranque de la aplicación, el contenedor se inyectará en el servicio y ese mismo contenedor será mantenido por la instancia de `Service` en solicitudes posteriores. Esto **puede** no ser un problema para su aplicación en particular; sin embargo, puede llevar a que el contenedor falte inesperadamente en enlaces que se añadieron más tarde en el ciclo de arranque o por una solicitud posterior.
Como solución alternativa, podrías dejar de registrar la vinculación como un singleton, o podrías inyectar una `función anónima` de resolución de contenedor en el servicio que siempre resuelva la instancia actual del contenedor:


```php
use App\Service;
use Illuminate\Container\Container;
use Illuminate\Contracts\Foundation\Application;

$this->app->bind(Service::class, function (Application $app) {
    return new Service($app);
});

$this->app->singleton(Service::class, function () {
    return new Service(fn () => Container::getInstance());
});

```
El helper global `app` y el método `Container::getInstance()` siempre devolverán la última versión del contenedor de la aplicación.

<a name="request-injection"></a>
### Inyección de Solicitudes

En general, debes evitar inyectar el contenedor de servicios de la aplicación o la instancia de la solicitud HTTP en los constructores de otros objetos. Por ejemplo, el siguiente enlace inyecta toda la instancia de la solicitud en un objeto que está vinculado como un singleton:


```php
use App\Service;
use Illuminate\Contracts\Foundation\Application;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->app->singleton(Service::class, function (Application $app) {
        return new Service($app['request']);
    });
}

```
En este ejemplo, si la instancia de `Service` se resuelve durante el proceso de arranque de la aplicación, la solicitud HTTP se inyectará en el servicio y esa misma solicitud será mantenida por la instancia de `Service` en solicitudes posteriores. Por lo tanto, todos los encabezados, entradas y datos de la cadena de consulta serán incorrectos, al igual que todos los demás datos de la solicitud.
Como solución alternativa, podrías dejar de registrar el enlace como un singleton, o podrías inyectar una `función anónima` de resolución de solicitudes en el servicio que siempre resuelva la instancia de la solicitud actual. O, la opción más recomendada es simplemente pasar la información específica de la solicitud que tu objeto necesita a uno de los métodos del objeto en tiempo de ejecución:


```php
use App\Service;
use Illuminate\Contracts\Foundation\Application;

$this->app->bind(Service::class, function (Application $app) {
    return new Service($app['request']);
});

$this->app->singleton(Service::class, function (Application $app) {
    return new Service(fn () => $app['request']);
});

// Or...

$service->method($request->input('name'));

```
El helper `request` global siempre devolverá la solicitud que la aplicación está manejando actualmente y, por lo tanto, es seguro usarlo dentro de tu aplicación.
> [!WARNING]
Está bien utilizar la sugerencia de tipo de la instancia `Illuminate\Http\Request` en los métodos de tu controlador y las funciones anónimas de la ruta.

<a name="configuration-repository-injection"></a>
### Inyección del Repositorio de Configuración

En general, deberías evitar inyectar la instancia del repositorio de configuración en los constructores de otros objetos. Por ejemplo, el siguiente enlace inyecta el repositorio de configuración en un objeto que está vinculado como un singleton:


```php
use App\Service;
use Illuminate\Contracts\Foundation\Application;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->app->singleton(Service::class, function (Application $app) {
        return new Service($app->make('config'));
    });
}

```
En este ejemplo, si los valores de configuración cambian entre solicitudes, ese servicio no tendrá acceso a los nuevos valores porque depende de la instancia del repositorio original.
Como solución alternativa, podrías dejar de registrar el binding como un singleton, o podrías inyectar una función anónima de resolución del repositorio de configuración a la clase:


```php
use App\Service;
use Illuminate\Container\Container;
use Illuminate\Contracts\Foundation\Application;

$this->app->bind(Service::class, function (Application $app) {
    return new Service($app->make('config'));
});

$this->app->singleton(Service::class, function () {
    return new Service(fn () => Container::getInstance()->make('config'));
});

```
La configuración global `config` siempre devolverá la última versión del repositorio de configuración y, por lo tanto, es seguro usarla dentro de tu aplicación.

<a name="managing-memory-leaks"></a>
### Gestión de Fugas de Memoria

Recuerda que Octane mantiene tu aplicación en memoria entre solicitudes; por lo tanto, agregar datos a un array mantenido de forma estática resultará en una fuga de memoria. Por ejemplo, el siguiente controlador tiene una fuga de memoria, ya que cada solicitud a la aplicación continuará agregando datos al array estático `$data`:


```php
use App\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * Handle an incoming request.
 */
public function index(Request $request): array
{
    Service::$data[] = Str::random(10);

    return [
        // ...
    ];
}

```
Mientras construyes tu aplicación, debes tener cuidado de evitar la creación de estos tipos de fugas de memoria. Se recomienda que monitorees el uso de memoria de tu aplicación durante el desarrollo local para asegurarte de que no estás introduciendo nuevas fugas de memoria en tu aplicación.

<a name="concurrent-tasks"></a>
## Tareas Concurrentes

Al usar Swoole, puedes ejecutar operaciones de forma concurrente a través de tareas en segundo plano ligeras. Puedes lograr esto utilizando el método `concurrently` de Octane. Puedes combinar este método con la desestructuración de arrays en PHP para recuperar los resultados de cada operación:


```php
use App\Models\User;
use App\Models\Server;
use Laravel\Octane\Facades\Octane;

[$users, $servers] = Octane::concurrently([
    fn () => User::all(),
    fn () => Server::all(),
]);

```
Las tareas concurrentes procesadas por Octane utilizan los "trabajadores de tareas" de Swoole, y se ejecutan en un proceso completamente diferente al de la solicitud entrante. La cantidad de trabajadores disponibles para procesar tareas concurrentes se determina por la directiva `--task-workers` en el comando `octane:start`:


```shell
php artisan octane:start --workers=4 --task-workers=6

```
Al invocar el método `concurrently`, no debes proporcionar más de 1024 tareas debido a las limitaciones impuestas por el sistema de tareas de Swoole.

<a name="ticks-and-intervals"></a>
## Ticks e Intervalos

Al utilizar Swoole, puedes registrar operaciones de "tick" que se ejecutarán cada número especificado de segundos. Puedes registrar callbacks de "tick" a través del método `tick`. El primer argumento que se proporciona al método `tick` debe ser una cadena que represente el nombre del ticker. El segundo argumento debe ser un callable que se invocará en el intervalo especificado.
En este ejemplo, registraremos una función anónima que se invocará cada 10 segundos. Típicamente, el método `tick` debería ser llamado dentro del método `boot` de uno de los proveedores de servicios de tu aplicación:


```php
Octane::tick('simple-ticker', fn () => ray('Ticking...'))
        ->seconds(10);

```
Usando el método `immediate`, puedes instruir a Octane para que invoque inmediatamente el callback de tick cuando se inicie el servidor de Octane, y cada N segundos después:


```php
Octane::tick('simple-ticker', fn () => ray('Ticking...'))
        ->seconds(10)
        ->immediate();

```

<a name="the-octane-cache"></a>
## El Caché de Octane

Al usar Swoole, puedes aprovechar el driver de caché de Octane, que ofrece velocidades de lectura y escritura de hasta 2 millones de operaciones por segundo. Por lo tanto, este driver de caché es una excelente opción para aplicaciones que necesitan velocidades de lectura / escritura extremas desde su capa de caché.
Este driver de caché está impulsado por [tablas Swoole](https://www.swoole.co.uk/docs/modules/swoole-table). Todos los datos almacenados en la caché están disponibles para todos los workers en el servidor. Sin embargo, los datos en caché se eliminarán cuando se reinicie el servidor:


```php
Cache::store('octane')->put('framework', 'Laravel', 30);

```
> [!NOTA]
El número máximo de entradas permitidas en la caché de Octane puede definirse en el archivo de configuración `octane` de tu aplicación.

<a name="cache-intervals"></a>
### Intervalos de Caché

Además de los métodos típicos proporcionados por el sistema de caché de Laravel, el driver de caché de Octane presenta cachés basados en intervalos. Estos cachés se actualizan automáticamente en el intervalo especificado y deben registrarse dentro del método `boot` de uno de los proveedores de servicios de tu aplicación. Por ejemplo, la siguiente caché se actualizará cada cinco segundos:


```php
use Illuminate\Support\Str;

Cache::store('octane')->interval('random', function () {
    return Str::random(10);
}, seconds: 5);

```

<a name="tables"></a>
## Tablas

> [!WARNING]
Esta función requiere [Swoole](#swoole).
Al utilizar Swoole, puedes definir e interactuar con tus propias [tablas Swoole](https://www.swoole.co.uk/docs/modules/swoole-table) arbitrarias. Las tablas Swoole ofrecen un rendimiento de alta capacidad y los datos en estas tablas pueden ser accedidos por todos los trabajadores en el servidor. Sin embargo, los datos dentro de ellas se perderán cuando se reinicie el servidor.
Las tablas deben definirse dentro del array de configuración `tables` del archivo de configuración `octane` de tu aplicación. Ya se ha configurado una tabla de ejemplo que permite un máximo de 1000 filas. El tamaño máximo de las columnas de cadena se puede configurar especificando el tamaño de la columna después del tipo de columna, como se ve a continuación:


```php
'tables' => [
    'example:1000' => [
        'name' => 'string:1000',
        'votes' => 'int',
    ],
],

```
Para acceder a una tabla, puedes usar el método `Octane::table`:


```php
use Laravel\Octane\Facades\Octane;

Octane::table('example')->set('uuid', [
    'name' => 'Nuno Maduro',
    'votes' => 1000,
]);

return Octane::table('example')->get('uuid');

```
> [!WARNING]
Los tipos de columna soportados por las tablas de Swoole son: `string`, `int` y `float`.