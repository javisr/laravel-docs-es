# Cache

- [Cache](#cache)
  - [Introducción](#introducción)
  - [Configuración](#configuración)
    - [Requisitos del controlador](#requisitos-del-controlador)
      - [Base de datos](#base-de-datos)
      - [Memcached](#memcached)
      - [Redis](#redis)
      - [DynamoDB](#dynamodb)
  - [Uso de Cache](#uso-de-cache)
    - [Obteniendo una instancia de Cache](#obteniendo-una-instancia-de-cache)
      - [Accediendo a múltiples almacenes de Cache](#accediendo-a-múltiples-almacenes-de-cache)
    - [Recuperando elementos de la Cache](#recuperando-elementos-de-la-cache)
      - [Determinando la existencia de un elemento](#determinando-la-existencia-de-un-elemento)
      - [Incrementando / Decrementando valores](#incrementando--decrementando-valores)
      - [Recuperar y almacenar](#recuperar-y-almacenar)
      - [Recuperar y eliminar](#recuperar-y-eliminar)
    - [Almacenando elementos en la Cache](#almacenando-elementos-en-la-cache)
      - [Almacenar si no está presente](#almacenar-si-no-está-presente)
      - [Almacenando elementos para siempre](#almacenando-elementos-para-siempre)
    - [Eliminando elementos de la Cache](#eliminando-elementos-de-la-cache)
    - [El Helper de Cache](#el-helper-de-cache)
  - [Bloqueos atómicos](#bloqueos-atómicos)
    - [Gestionando bloqueos](#gestionando-bloqueos)
    - [Gestionando bloqueos entre procesos](#gestionando-bloqueos-entre-procesos)
  - [Agregar Controladores de Caché Personalizados](#agregar-controladores-de-caché-personalizados)
    - [Escribiendo el Controlador](#escribiendo-el-controlador)
    - [Registrando el Controlador](#registrando-el-controlador)
  - [Eventos](#eventos)

<a name="introduction"></a>
## Introducción

Algunas de las tareas de recuperación o procesamiento de datos realizadas por tu aplicación podrían ser intensivas en CPU o tardar varios segundos en completarse. Cuando este es el caso, es común almacenar en caché los datos recuperados por un tiempo para que puedan ser recuperados rápidamente en solicitudes posteriores para los mismos datos. Los datos en caché generalmente se almacenan en un almacén de datos muy rápido como [Memcached](https://memcached.org) o [Redis](https://redis.io).

Afortunadamente, Laravel proporciona una API unificada y expresiva para varios backends de caché, lo que te permite aprovechar su rápida recuperación de datos y acelerar tu aplicación web.

<a name="configuration"></a>
## Configuración

El archivo de configuración de caché de tu aplicación se encuentra en `config/cache.php`. En este archivo, puedes especificar qué almacén de caché te gustaría que se utilizara por defecto en toda tu aplicación. Laravel admite backends de caché populares como [Memcached](https://memcached.org), [Redis](https://redis.io), [DynamoDB](https://aws.amazon.com/dynamodb) y bases de datos relacionales de forma predeterminada. Además, hay disponible un controlador de caché basado en archivos, mientras que los controladores de caché `array` y "null" proporcionan backends de caché convenientes para tus pruebas automatizadas.

El archivo de configuración de caché también contiene una variedad de otras opciones que puedes revisar. Por defecto, Laravel está configurado para usar el controlador de caché `database`, que almacena los objetos en caché serializados en la base de datos de tu aplicación.

<a name="driver-prerequisites"></a>
### Requisitos del controlador

<a name="prerequisites-database"></a>
#### Base de datos

Al usar el controlador de caché `database`, necesitarás una tabla de base de datos para contener los datos de caché. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000001_create_cache_table.php` [migración de base de datos](/docs/{{version}}/migrations); sin embargo, si tu aplicación no contiene esta migración, puedes usar el comando Artisan `make:cache-table` para crearla:

```shell
php artisan make:cache-table

php artisan migrate
```

<a name="memcached"></a>
#### Memcached

Usar el controlador Memcached requiere que el [paquete PECL de Memcached](https://pecl.php.net/package/memcached) esté instalado. Puedes listar todos tus servidores Memcached en el archivo de configuración `config/cache.php`. Este archivo ya contiene una entrada `memcached.servers` para que empieces:

    'memcached' => [
        // ...

        'servers' => [
            [
                'host' => env('MEMCACHED_HOST', '127.0.0.1'),
                'port' => env('MEMCACHED_PORT', 11211),
                'weight' => 100,
            ],
        ],
    ],

Si es necesario, puedes establecer la opción `host` en una ruta de socket UNIX. Si haces esto, la opción `port` debe establecerse en `0`:

    'memcached' => [
        // ...

        'servers' => [
            [
                'host' => '/var/run/memcached/memcached.sock',
                'port' => 0,
                'weight' => 100
            ],
        ],
    ],

<a name="redis"></a>
#### Redis

Antes de usar una caché Redis con Laravel, necesitarás instalar la extensión PHP PhpRedis a través de PECL o instalar el paquete `predis/predis` (~2.0) a través de Composer. [Laravel Sail](/docs/{{version}}/sail) ya incluye esta extensión. Además, plataformas de despliegue oficiales de Laravel como [Laravel Forge](https://forge.laravel.com) y [Laravel Vapor](https://vapor.laravel.com) tienen la extensión PhpRedis instalada por defecto.

Para más información sobre cómo configurar Redis, consulta su [página de documentación de Laravel](/docs/{{version}}/redis#configuration).

<a name="dynamodb"></a>
#### DynamoDB

Antes de usar el controlador de caché [DynamoDB](https://aws.amazon.com/dynamodb), debes crear una tabla DynamoDB para almacenar todos los datos en caché. Típicamente, esta tabla debería llamarse `cache`. Sin embargo, deberías nombrar la tabla según el valor de la configuración `stores.dynamodb.table` dentro del archivo de configuración `cache`. El nombre de la tabla también puede establecerse a través de la variable de entorno `DYNAMODB_CACHE_TABLE`.

Esta tabla también debe tener una clave de partición de tipo cadena con un nombre que corresponda al valor del elemento de configuración `stores.dynamodb.attributes.key` dentro del archivo de configuración `cache` de tu aplicación. Por defecto, la clave de partición debería llamarse `key`.

A continuación, instala el SDK de AWS para que tu aplicación Laravel pueda comunicarse con DynamoDB:

```shell
composer require aws/aws-sdk-php
```

Además, deberías asegurarte de que se proporcionen valores para las opciones de configuración del almacén de caché DynamoDB. Típicamente, estas opciones, como `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`, deberían definirse en el archivo de configuración `.env` de tu aplicación:

```php
'dynamodb' => [
    'driver' => 'dynamodb',
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    'table' => env('DYNAMODB_CACHE_TABLE', 'cache'),
    'endpoint' => env('DYNAMODB_ENDPOINT'),
],
```

<a name="cache-usage"></a>
## Uso de Cache

<a name="obtaining-a-cache-instance"></a>
### Obteniendo una instancia de Cache

Para obtener una instancia de almacén de caché, puedes usar la fachada `Cache`, que es lo que utilizaremos a lo largo de esta documentación. La fachada `Cache` proporciona acceso conveniente y conciso a las implementaciones subyacentes de los contratos de caché de Laravel:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Support\Facades\Cache;

    class UserController extends Controller
    {
        /**
         * Mostrar una lista de todos los usuarios de la aplicación.
         */
        public function index(): array
        {
            $value = Cache::get('key');

            return [
                // ...
            ];
        }
    }

<a name="accessing-multiple-cache-stores"></a>
#### Accediendo a múltiples almacenes de Cache

Usando la fachada `Cache`, puedes acceder a varios almacenes de caché a través del método `store`. La clave pasada al método `store` debe corresponder a uno de los almacenes listados en el arreglo de configuración `stores` en tu archivo de configuración `cache`:

    $value = Cache::store('file')->get('foo');

    Cache::store('redis')->put('bar', 'baz', 600); // 10 Minutos

<a name="retrieving-items-from-the-cache"></a>
### Recuperando elementos de la Cache

El método `get` de la fachada `Cache` se utiliza para recuperar elementos de la caché. Si el elemento no existe en la caché, se devolverá `null`. Si lo deseas, puedes pasar un segundo argumento al método `get` especificando el valor predeterminado que deseas que se devuelva si el elemento no existe:

    $value = Cache::get('key');

    $value = Cache::get('key', 'default');

Incluso puedes pasar una función anónima como valor predeterminado. El resultado de la función anónima se devolverá si el elemento especificado no existe en la caché. Pasar una función anónima te permite diferir la recuperación de valores predeterminados de una base de datos u otro servicio externo:

    $value = Cache::get('key', function () {
        return DB::table(/* ... */)->get();
    });

<a name="determining-item-existence"></a>
#### Determinando la existencia de un elemento

El método `has` se puede usar para determinar si un elemento existe en la caché. Este método también devolverá `false` si el elemento existe pero su valor es `null`:

    if (Cache::has('key')) {
        // ...
    }

<a name="incrementing-decrementing-values"></a>
#### Incrementando / Decrementando valores

Los métodos `increment` y `decrement` se pueden usar para ajustar el valor de elementos enteros en la caché. Ambos métodos aceptan un segundo argumento opcional que indica la cantidad por la cual incrementar o decrementar el valor del elemento:

    // Inicializa el valor si no existe...
    Cache::add('key', 0, now()->addHours(4));

    // Incrementa o decrementa el valor...
    Cache::increment('key');
    Cache::increment('key', $amount);
    Cache::decrement('key');
    Cache::decrement('key', $amount);

<a name="retrieve-store"></a>
#### Recuperar y almacenar

A veces, puedes desear recuperar un elemento de la caché, pero también almacenar un valor predeterminado si el elemento solicitado no existe. Por ejemplo, puedes desear recuperar todos los usuarios de la caché o, si no existen, recuperarlos de la base de datos y agregarlos a la caché. Puedes hacer esto usando el método `Cache::remember`:

    $value = Cache::remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

Si el elemento no existe en la caché, la función anónima pasada al método `remember` se ejecutará y su resultado se colocará en la caché.

Puedes usar el método `rememberForever` para recuperar un elemento de la caché o almacenarlo para siempre si no existe:

    $value = Cache::rememberForever('users', function () {
        return DB::table('users')->get();
    });

<a name="retrieve-delete"></a>
#### Recuperar y eliminar

Si necesitas recuperar un elemento de la caché y luego eliminar el elemento, puedes usar el método `pull`. Al igual que el método `get`, se devolverá `null` si el elemento no existe en la caché:

    $value = Cache::pull('key');

    $value = Cache::pull('key', 'default');

<a name="storing-items-in-the-cache"></a>
### Almacenando elementos en la Cache

Puedes usar el método `put` en la fachada `Cache` para almacenar elementos en la caché:

    Cache::put('key', 'value', $seconds = 10);

Si el tiempo de almacenamiento no se pasa al método `put`, el elemento se almacenará indefinidamente:

    Cache::put('key', 'value');

En lugar de pasar el número de segundos como un entero, también puedes pasar una instancia de `DateTime` que represente el tiempo de expiración deseado del elemento en caché:

    Cache::put('key', 'value', now()->addMinutes(10));

<a name="store-if-not-present"></a>
#### Almacenar si no está presente

El método `add` solo agregará el elemento a la caché si no existe ya en el almacén de caché. El método devolverá `true` si el elemento se agrega realmente a la caché. De lo contrario, el método devolverá `false`. El método `add` es una operación atómica:

    Cache::add('key', 'value', $seconds);

<a name="storing-items-forever"></a>
#### Almacenando elementos para siempre

El método `forever` se puede usar para almacenar un elemento en la caché de forma permanente. Dado que estos elementos no expirarán, deben eliminarse manualmente de la caché utilizando el método `forget`:

    Cache::forever('key', 'value');

> [!NOTE]  
> Si estás usando el controlador Memcached, los elementos que se almacenan "para siempre" pueden eliminarse cuando la caché alcanza su límite de tamaño.

<a name="removing-items-from-the-cache"></a>
### Eliminando elementos de la Cache

Puedes eliminar elementos de la caché usando el método `forget`:

    Cache::forget('key');

También puedes eliminar elementos proporcionando un número cero o negativo de segundos de expiración:

    Cache::put('key', 'value', 0);

    Cache::put('key', 'value', -5);

Puedes limpiar toda la caché usando el método `flush`:

    Cache::flush();

> [!WARNING]  
> Limpiar la caché no respeta tu "prefijo" de caché configurado y eliminará todas las entradas de la caché. Considera esto cuidadosamente al limpiar una caché que es compartida por otras aplicaciones.

<a name="the-cache-helper"></a>
### El Helper de Cache

Además de usar la fachada `Cache`, también puedes usar la función global `cache` para recuperar y almacenar datos a través de la caché. Cuando se llama a la función `cache` con un solo argumento de cadena, devolverá el valor de la clave dada:

    $value = cache('key');

Si proporcionas un arreglo de pares clave / valor y un tiempo de expiración a la función, almacenará valores en la caché por la duración especificada:

    cache(['key' => 'value'], $seconds);

    cache(['key' => 'value'], now()->addMinutes(10));

Cuando se llama a la función `cache` sin argumentos, devuelve una instancia de la implementación `Illuminate\Contracts\Cache\Factory`, lo que te permite llamar a otros métodos de caché:

    cache()->remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

> [!NOTE]  
> Al probar la llamada a la función global `cache`, puedes usar el método `Cache::shouldReceive` como si estuvieras [probando la fachada](/docs/{{version}}/mocking#mocking-facades).

<a name="atomic-locks"></a>
## Bloqueos atómicos

> [!WARNING]  
> Para utilizar esta función, tu aplicación debe estar usando el controlador de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como tu controlador de caché predeterminado. Además, todos los servidores deben comunicarse con el mismo servidor de caché central.

<a name="managing-locks"></a>
### Gestionando bloqueos

Los bloqueos atómicos permiten la manipulación de bloqueos distribuidos sin preocuparse por condiciones de carrera. Por ejemplo, [Laravel Forge](https://forge.laravel.com) utiliza bloqueos atómicos para asegurar que solo se ejecute una tarea remota en un servidor a la vez. Puedes crear y gestionar bloqueos usando el método `Cache::lock`:

    use Illuminate\Support\Facades\Cache;

    $lock = Cache::lock('foo', 10);

    if ($lock->get()) {
        // Bloqueo adquirido por 10 segundos...

        $lock->release();
    }

El método `get` también acepta una función anónima. Después de que se ejecute la función anónima, Laravel liberará automáticamente el bloqueo:

    Cache::lock('foo', 10)->get(function () {
        // Bloqueo adquirido por 10 segundos y liberado automáticamente...
    });

Si el bloqueo no está disponible en el momento en que lo solicitas, puedes instruir a Laravel para que espere un número específico de segundos. Si el bloqueo no se puede adquirir dentro del límite de tiempo especificado, se lanzará una `Illuminate\Contracts\Cache\LockTimeoutException`:

    use Illuminate\Contracts\Cache\LockTimeoutException;

    $lock = Cache::lock('foo', 10);

    try {
        $lock->block(5);

        // Bloqueo adquirido después de esperar un máximo de 5 segundos...
    } catch (LockTimeoutException $e) {
        // No se pudo adquirir el bloqueo...
    } finally {
        $lock->release();
    }

El ejemplo anterior puede simplificarse pasando una función anónima al método `block`. Cuando se pasa una función anónima a este método, Laravel intentará adquirir el bloqueo durante el número especificado de segundos y liberará automáticamente el bloqueo una vez que se haya ejecutado la función anónima:

    Cache::lock('foo', 10)->block(5, function () {
        // Bloqueo adquirido después de esperar un máximo de 5 segundos...
    });

<a name="managing-locks-across-processes"></a>
### Gestionando bloqueos entre procesos

A veces, puedes desear adquirir un bloqueo en un proceso y liberarlo en otro proceso. Por ejemplo, puedes adquirir un bloqueo durante una solicitud web y desear liberar el bloqueo al final de un trabajo en cola que se activa por esa solicitud. En este escenario, deberías pasar el "token de propietario" del bloqueo al trabajo en cola para que el trabajo pueda reinstanciar el bloqueo usando el token dado.

En el ejemplo a continuación, despacharemos un trabajo en cola si se adquiere un bloqueo con éxito. Además, pasaremos el token de propietario del bloqueo al trabajo en cola a través del método `owner` del bloqueo:

    $podcast = Podcast::find($id);

    $lock = Cache::lock('processing', 120);

    if ($lock->get()) {
        ProcessPodcast::dispatch($podcast, $lock->owner());
    }

Dentro del trabajo `ProcessPodcast` de nuestra aplicación, podemos restaurar y liberar el bloqueo utilizando el token del propietario:

    Cache::restoreLock('processing', $this->owner)->release();

Si deseas liberar un bloqueo sin respetar su propietario actual, puedes usar el método `forceRelease`:

    Cache::lock('processing')->forceRelease();

<a name="adding-custom-cache-drivers"></a>
## Agregar Controladores de Caché Personalizados

<a name="writing-the-driver"></a>
### Escribiendo el Controlador

Para crear nuestro controlador de caché personalizado, primero necesitamos implementar el contrato `Illuminate\Contracts\Cache\Store` [contrato](/docs/{{version}}/contracts). Así que, una implementación de caché de MongoDB podría verse algo así:

    <?php

    namespace App\Extensions;

    use Illuminate\Contracts\Cache\Store;

    class MongoStore implements Store
    {
        public function get($key) {}
        public function many(array $keys) {}
        public function put($key, $value, $seconds) {}
        public function putMany(array $values, $seconds) {}
        public function increment($key, $value = 1) {}
        public function decrement($key, $value = 1) {}
        public function forever($key, $value) {}
        public function forget($key) {}
        public function flush() {}
        public function getPrefix() {}
    }

Solo necesitamos implementar cada uno de estos métodos utilizando una conexión de MongoDB. Para un ejemplo de cómo implementar cada uno de estos métodos, echa un vistazo a `Illuminate\Cache\MemcachedStore` en el [código fuente del framework Laravel](https://github.com/laravel/framework). Una vez que nuestra implementación esté completa, podemos finalizar el registro de nuestro controlador personalizado llamando al método `extend` de la fachada `Cache`:

    Cache::extend('mongo', function (Application $app) {
        return Cache::repository(new MongoStore);
    });

> [!NOTE]  
> Si te preguntas dónde colocar el código de tu controlador de caché personalizado, podrías crear un espacio de nombres `Extensions` dentro de tu directorio `app`. Sin embargo, ten en cuenta que Laravel no tiene una estructura de aplicación rígida y eres libre de organizar tu aplicación según tus preferencias.

<a name="registering-the-driver"></a>
### Registrando el Controlador

Para registrar el controlador de caché personalizado con Laravel, utilizaremos el método `extend` en la fachada `Cache`. Dado que otros proveedores de servicios pueden intentar leer valores en caché dentro de su método `boot`, registraremos nuestro controlador personalizado dentro de un callback `booting`. Al usar el callback `booting`, podemos asegurarnos de que el controlador personalizado esté registrado justo antes de que se llame al método `boot` en los proveedores de servicios de nuestra aplicación, pero después de que se llame al método `register` en todos los proveedores de servicios. Registraremos nuestro callback `booting` dentro del método `register` de la clase `App\Providers\AppServiceProvider` de nuestra aplicación:

    <?php

    namespace App\Providers;

    use App\Extensions\MongoStore;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\ServiceProvider;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Registrar cualquier servicio de la aplicación.
         */
        public function register(): void
        {
            $this->app->booting(function () {
                 Cache::extend('mongo', function (Application $app) {
                     return Cache::repository(new MongoStore);
                 });
             });
        }

        /**
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            // ...
        }
    }

El primer argumento pasado al método `extend` es el nombre del controlador. Esto corresponderá a tu opción `driver` en el archivo de configuración `config/cache.php`. El segundo argumento es una función anónima que debe devolver una instancia de `Illuminate\Cache\Repository`. La función anónima recibirá una instancia de `$app`, que es una instancia del [contenedor de servicios](/docs/{{version}}/container).

Una vez que tu extensión esté registrada, actualiza la variable de entorno `CACHE_STORE` o la opción `default` dentro del archivo de configuración `config/cache.php` de tu aplicación al nombre de tu extensión.

<a name="events"></a>
## Eventos

Para ejecutar código en cada operación de caché, puedes escuchar varios [eventos](/docs/{{version}}/events) despachados por la caché:

| Nombre del Evento |
| --- |
| `Illuminate\Cache\Events\CacheHit` |
| `Illuminate\Cache\Events\CacheMissed` |
| `Illuminate\Cache\Events\KeyForgotten` |
| `Illuminate\Cache\Events\KeyWritten` |

Para aumentar el rendimiento, puedes deshabilitar los eventos de caché configurando la opción `events` en `false` para un determinado almacén de caché en el archivo de configuración `config/cache.php` de tu aplicación:

```php
'database' => [
    'driver' => 'database',
    // ...
    'events' => false,
],
```
