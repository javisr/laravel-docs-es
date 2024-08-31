# Cache

- [Introducción](#introduction)
- [Configuración](#configuration)
  - [Requisitos Previos del Driver](#driver-prerequisites)
- [Uso de Caché](#cache-usage)
  - [Obtener una Instancia de Caché](#obtaining-a-cache-instance)
  - [Recuperar Elementos de la Caché](#retrieving-items-from-the-cache)
  - [Almacenar Elementos en la Caché](#storing-items-in-the-cache)
  - [Eliminar Elementos de la Caché](#removing-items-from-the-cache)
  - [El Helper de Caché](#the-cache-helper)
- [Bloqueos Atómicos](#atomic-locks)
  - [Gestionar Bloqueos](#managing-locks)
  - [Gestionar Bloqueos Entre Procesos](#managing-locks-across-processes)
- [Agregar Controladores de Caché Personalizados](#adding-custom-cache-drivers)
  - [Escribir el Driver](#writing-the-driver)
  - [Registrar el Driver](#registering-the-driver)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Algunas de las tareas de recuperación o procesamiento de datos realizadas por su aplicación pueden ser intensivas en CPU o tardar varios segundos en completarse. Cuando este es el caso, es común almacenar en caché los datos recuperados durante un tiempo para que se puedan recuperar rápidamente en solicitudes posteriores para los mismos datos. Los datos en caché suelen almacenarse en un almacén de datos muy rápido como [Memcached](https://memcached.org) o [Redis](https://redis.io).
Afortunadamente, Laravel ofrece una API unificada y expresiva para varios backends de caché, lo que te permite aprovechar su rápida recuperación de datos y acelerar tu aplicación web.

<a name="configuration"></a>
## Configuración

El archivo de configuración de caché de tu aplicación se encuentra en `config/cache.php`. En este archivo, puedes especificar qué almacén de caché te gustaría usar de manera predeterminada en toda tu aplicación. Laravel admite backend de caché populares como [Memcached](https://memcached.org), [Redis](https://redis.io), [DynamoDB](https://aws.amazon.com/dynamodb) y bases de datos relacionales de manera predeterminada. Además, hay disponible un driver de caché basado en archivos, mientras que los controladores de caché `array` y "null" ofrecen backend de caché convenientes para tus pruebas automatizadas.
El archivo de configuración de caché también contiene una variedad de otras opciones que puedes revisar. Por defecto, Laravel está configurado para usar el driver de caché `database`, que almacena los objetos en caché serializados en la base de datos de tu aplicación.

<a name="driver-prerequisites"></a>
### Prerrequisitos del driver


<a name="prerequisites-database"></a>
#### Base de datos

Al utilizar el driver de caché `database`, necesitarás una tabla de base de datos para contener los datos de caché. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000001_create_cache_table.php` [migración de base de datos](/docs/%7B%7Bversion%7D%7D/migrations); sin embargo, si tu aplicación no contiene esta migración, puedes usar el comando Artisan `make:cache-table` para crearla:


```shell
php artisan make:cache-table

php artisan migrate

```

<a name="memcached"></a>
#### Memcached

Usar el driver de Memcached requiere que el [paquete PECL de Memcached](https://pecl.php.net/package/memcached) esté instalado. Puedes listar todos tus servidores de Memcached en el archivo de configuración `config/cache.php`. Este archivo ya contiene una entrada `memcached.servers` para que comiences:


```php
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
```
Si es necesario, puedes establecer la opción `host` en una ruta de socket UNIX. Si haces esto, la opción `port` debe configurarse en `0`:


```php
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
```

<a name="redis"></a>
#### Redis

Antes de usar un caché Redis con Laravel, necesitarás instalar la extensión PHP PhpRedis a través de PECL o instalar el paquete `predis/predis` (~2.0) a través de Composer. [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail) ya incluye esta extensión. Además, plataformas de despliegue oficiales de Laravel como [Laravel Forge](https://forge.laravel.com) y [Laravel Vapor](https://vapor.laravel.com) tienen la extensión PhpRedis instalada por defecto.
Para obtener más información sobre la configuración de Redis, consulta su [página de documentación de Laravel](/docs/%7B%7Bversion%7D%7D/redis#configuration).

<a name="dynamodb"></a>
#### DynamoDB

Antes de utilizar el driver de caché [DynamoDB](https://aws.amazon.com/dynamodb), debes crear una tabla DynamoDB para almacenar todos los datos en caché. Típicamente, esta tabla debería llamarse `cache`. Sin embargo, debes nombrar la tabla en función del valor de la configuración `stores.dynamodb.table` dentro del archivo de configuración `cache`. El nombre de la tabla también puede configurarse a través de la variable de entorno `DYNAMODB_CACHE_TABLE`.
Esta tabla también debe tener una clave de partición de cadena con un nombre que corresponda al valor del ítem de configuración `stores.dynamodb.attributes.key` dentro del archivo de configuración `cache` de tu aplicación. Por defecto, la clave de partición debe llamarse `key`.
A continuación, instala el SDK de AWS para que tu aplicación Laravel pueda comunicarse con DynamoDB:


```shell
composer require aws/aws-sdk-php

```
Además, debes asegurarte de que se proporcionen valores para las opciones de configuración del almacén de caché de DynamoDB. Típicamente, estas opciones, como `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`, deben definirse en el archivo de configuración `.env` de tu aplicación:


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
## Uso de Caché


<a name="obtaining-a-cache-instance"></a>
### Obtención de una Instancia de Caché

Para obtener una instancia de almacenamiento en caché, puedes usar la facade `Cache`, que es lo que utilizaremos a lo largo de esta documentación. La facade `Cache` proporciona un acceso conveniente y conciso a las implementaciones subyacentes de los contratos de caché de Laravel:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Cache;

class UserController extends Controller
{
    /**
     * Show a list of all users of the application.
     */
    public function index(): array
    {
        $value = Cache::get('key');

        return [
            // ...
        ];
    }
}
```

<a name="accessing-multiple-cache-stores"></a>
#### Accediendo a Múltiples Almacenes de Caché

Usando la facade `Cache`, puedes acceder a varias tiendas de caché a través del método `store`. La clave pasada al método `store` debe corresponder a una de las tiendas listadas en el array de configuración `stores` en tu archivo de configuración `cache`:


```php
$value = Cache::store('file')->get('foo');

Cache::store('redis')->put('bar', 'baz', 600); // 10 Minutes
```

<a name="retrieving-items-from-the-cache"></a>
### Recuperando Elementos de la Caché

El método `get` de la fachada `Cache` se utiliza para recuperar elementos de la caché. Si el elemento no existe en la caché, se devolverá `null`. Si lo desea, puede pasar un segundo argumento al método `get` especificando el valor predeterminado que desea que se devuelva si el elemento no existe:


```php
$value = Cache::get('key');

$value = Cache::get('key', 'default');
```
Puedes incluso pasar una `función anónima` como el valor predeterminado. El resultado de la `función anónima` se devolverá si el ítem especificado no existe en la caché. Pasar una `función anónima` te permite aplazar la recuperación de valores predeterminados de una base de datos u otro servicio externo:


```php
$value = Cache::get('key', function () {
    return DB::table(/* ... */)->get();
});
```

<a name="determining-item-existence"></a>
#### Determinando la Existencia de un Elemento

El método `has` puede utilizarse para determinar si un elemento existe en la caché. Este método también devolverá `false` si el elemento existe pero su valor es `null`:


```php
if (Cache::has('key')) {
    // ...
}
```

<a name="incrementing-decrementing-values"></a>
#### Incrementando / Decrementando Valores

Los métodos `increment` y `decrement` se pueden utilizar para ajustar el valor de elementos enteros en la caché. Ambos métodos aceptan un segundo argumento opcional que indica la cantidad por la cual aumentar o disminuir el valor del elemento:


```php
// Initialize the value if it does not exist...
Cache::add('key', 0, now()->addHours(4));

// Increment or decrement the value...
Cache::increment('key');
Cache::increment('key', $amount);
Cache::decrement('key');
Cache::decrement('key', $amount);
```

<a name="retrieve-store"></a>
#### Recuperar y Almacenar

A veces es posible que desees recuperar un elemento de la caché, pero también almacenar un valor predeterminado si el elemento solicitado no existe. Por ejemplo, es posible que desees recuperar todos los usuarios de la caché o, si no existen, recuperarlos de la base de datos y agregarlos a la caché. Puedes hacer esto utilizando el método `Cache::remember`:


```php
$value = Cache::remember('users', $seconds, function () {
    return DB::table('users')->get();
});
```
Si el elemento no existe en la caché, la función anónima pasada al método `remember` se ejecutará y su resultado se colocará en la caché.
Puedes usar el método `rememberForever` para recuperar un elemento de la caché o almacenarlo de forma indefinida si no existe:


```php
$value = Cache::rememberForever('users', function () {
    return DB::table('users')->get();
});
```

<a name="retrieve-delete"></a>
#### Recuperar y Eliminar

Si necesitas recuperar un elemento de la caché y luego eliminar el elemento, puedes usar el método `pull`. Al igual que el método `get`, se devolverá `null` si el elemento no existe en la caché:


```php
$value = Cache::pull('key');

$value = Cache::pull('key', 'default');
```

<a name="storing-items-in-the-cache"></a>
### Almacenando Elementos en la Caché

Puedes usar el método `put` en la fachada `Cache` para almacenar elementos en la caché:


```php
Cache::put('key', 'value', $seconds = 10);
```
Si el tiempo de almacenamiento no se pasa al método `put`, el elemento se almacenará indefinidamente:


```php
Cache::put('key', 'value');
```
En lugar de pasar el número de segundos como un entero, también puedes pasar una instancia de `DateTime` que represente el tiempo de expiración deseado del elemento en caché:


```php
Cache::put('key', 'value', now()->addMinutes(10));
```

<a name="store-if-not-present"></a>
#### Almacenar si no está presente

El método `add` solo añadirá el elemento a la caché si no existe ya en el almacén de caché. El método devolverá `true` si el elemento es realmente añadido a la caché. De lo contrario, el método devolverá `false`. El método `add` es una operación atómica:


```php
Cache::add('key', 'value', $seconds);
```

<a name="storing-items-forever"></a>
#### Almacenando Elementos para Siempre

El método `forever` se puede utilizar para almacenar un elemento en la caché de manera permanente. Dado que estos elementos no expirarán, deben ser eliminados manualmente de la caché utilizando el método `forget`:


```php
Cache::forever('key', 'value');
```
> [!NOTA]
Si estás utilizando el driver de Memcached, los elementos que se almacenan "para siempre" pueden ser eliminados cuando el caché alcanza su límite de tamaño.

<a name="removing-items-from-the-cache"></a>
### Eliminando Elementos de la Caché

Puedes eliminar elementos de la caché utilizando el método `forget`:


```php
Cache::forget('key');
```
También puedes eliminar elementos proporcionando un número de segundos de expiración cero o negativo:


```php
Cache::put('key', 'value', 0);

Cache::put('key', 'value', -5);
```
Puedes limpiar toda la caché usando el método `flush`:


```php
Cache::flush();
```
> [!WARNING]
Flushing the cache no respeta tu "prefijo" de caché configurado y eliminará todas las entradas de la caché. Considera esto cuidadosamente al borrar una caché que es compartida por otras aplicaciones.

<a name="the-cache-helper"></a>
### El Helper de Cache

Además de utilizar la facade `Cache`, también puedes usar la función global `cache` para recuperar y almacenar datos a través de la caché. Cuando se llama a la función `cache` con un solo argumento de cadena, devolverá el valor de la clave dada:


```php
$value = cache('key');
```
Si proporcionas un array de pares clave / valor y un tiempo de expiración a la función, almacenará los valores en la caché por la duración especificada:


```php
cache(['key' => 'value'], $seconds);

cache(['key' => 'value'], now()->addMinutes(10));
```
Cuando se llama a la función `cache` sin argumentos, devuelve una instancia de la implementación `Illuminate\Contracts\Cache\Factory`, lo que te permite llamar a otros métodos de almacenamiento en caché:


```php
cache()->remember('users', $seconds, function () {
    return DB::table('users')->get();
});
```
> [!NOTA]
Al probar la llamada a la función global `cache`, puedes usar el método `Cache::shouldReceive` como si estuvieras [probando la facade](/docs/%7B%7Bversion%7D%7D/mocking#mocking-facades).

<a name="atomic-locks"></a>
## Bloqueos Atómicos

> [!WARNING]
Para utilizar esta función, tu aplicación debe estar utilizando el driver de caché `memcached`, `redis`, `dynamodb`, `database`, `file` o `array` como el driver de caché predeterminado de tu aplicación. Además, todos los servidores deben estar comunicándose con el mismo servidor de caché central.

<a name="managing-locks"></a>
### Gestión de Bloqueos

Los bloqueos atómicos permiten la manipulación de bloqueos distribuidos sin preocuparse por condiciones de carrera. Por ejemplo, [Laravel Forge](https://forge.laravel.com) utiliza bloqueos atómicos para asegurar que solo una tarea remota se esté ejecutando en un servidor a la vez. Puedes crear y gestionar bloqueos utilizando el método `Cache::lock`:


```php
use Illuminate\Support\Facades\Cache;

$lock = Cache::lock('foo', 10);

if ($lock->get()) {
    // Lock acquired for 10 seconds...

    $lock->release();
}
```
El método `get` también acepta una función anónima. Después de que se ejecute la función anónima, Laravel liberará automáticamente el bloqueo:


```php
Cache::lock('foo', 10)->get(function () {
    // Lock acquired for 10 seconds and automatically released...
});
```
Si el bloqueo no está disponible en el momento en que lo solicitas, puedes instruir a Laravel para que espere un número específico de segundos. Si el bloqueo no puede ser adquirido dentro del límite de tiempo especificado, se lanzará una `Illuminate\Contracts\Cache\LockTimeoutException`:


```php
use Illuminate\Contracts\Cache\LockTimeoutException;

$lock = Cache::lock('foo', 10);

try {
    $lock->block(5);

    // Lock acquired after waiting a maximum of 5 seconds...
} catch (LockTimeoutException $e) {
    // Unable to acquire lock...
} finally {
    $lock->release();
}
```
El ejemplo anterior puede simplificarse pasando una función anónima al método `block`. Cuando se pasa una función anónima a este método, Laravel intentará adquirir el bloqueo durante el número especificado de segundos y liberará automáticamente el bloqueo una vez que se haya ejecutado la función anónima:


```php
Cache::lock('foo', 10)->block(5, function () {
    // Lock acquired after waiting a maximum of 5 seconds...
});
```

<a name="managing-locks-across-processes"></a>
### Administrando Bloqueos Entre Procesos

A veces, es posible que desees adquirir un bloqueo en un proceso y liberarlo en otro proceso. Por ejemplo, puedes adquirir un bloqueo durante una solicitud web y desear liberar el bloqueo al final de un trabajo en cola que es activado por esa solicitud. En este escenario, debes pasar el "token de propietario" con alcance del bloqueo al trabajo en cola para que el trabajo pueda reinstanciar el bloqueo utilizando el token dado.
En el ejemplo a continuación, despacharemos un trabajo en cola si se adquiere un bloqueo con éxito. Además, pasaremos el token del propietario del bloqueo al trabajo en cola a través del método `owner` del bloqueo:


```php
$podcast = Podcast::find($id);

$lock = Cache::lock('processing', 120);

if ($lock->get()) {
    ProcessPodcast::dispatch($podcast, $lock->owner());
}
```
Dentro del trabajo `ProcessPodcast` de nuestra aplicación, podemos restaurar y liberar el bloqueo utilizando el token del propietario:


```php
Cache::restoreLock('processing', $this->owner)->release();
```
Si deseas liberar un bloqueo sin respetar su propietario actual, puedes usar el método `forceRelease`:


```php
Cache::lock('processing')->forceRelease();
```

<a name="adding-custom-cache-drivers"></a>
## Agregar Controladores de Caché Personalizados


<a name="writing-the-driver"></a>
### Escribiendo el Driver

Para crear nuestro driver de caché personalizado, primero necesitamos implementar el contrato `Illuminate\Contracts\Cache\Store` [contract](/docs/%7B%7Bversion%7D%7D/contracts). Así que, una implementación de caché de MongoDB podría verse algo así:


```php
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
```
Solo necesitamos implementar cada uno de estos métodos utilizando una conexión a MongoDB. Para un ejemplo de cómo implementar cada uno de estos métodos, echa un vistazo a la `Illuminate\Cache\MemcachedStore` en el [código fuente del framework Laravel](https://github.com/laravel/framework). Una vez que nuestra implementación esté completa, podemos finalizar nuestro registro de driver personalizado llamando al método `extend` de la fachada `Cache`:


```php
Cache::extend('mongo', function (Application $app) {
    return Cache::repository(new MongoStore);
});
```
> [!NOTA]
Si te preguntas dónde colocar tu código del driver de caché personalizado, podrías crear un espacio de nombres `Extensions` dentro de tu directorio `app`. Sin embargo, ten en cuenta que Laravel no tiene una estructura de aplicación rígida y eres libre de organizar tu aplicación según tus preferencias.

<a name="registering-the-driver"></a>
### Registrando el Driver

Para registrar el driver de caché personalizado con Laravel, utilizaremos el método `extend` en la fachada `Cache`. Dado que otros proveedores de servicios pueden intentar leer los valores en caché dentro de su método `boot`, registraremos nuestro driver personalizado en un callback `booting`. Al usar el callback `booting`, podemos asegurarnos de que el driver personalizado se registre justo antes de que se llame al método `boot` en los proveedores de servicios de nuestra aplicación, pero después de que se llame al método `register` en todos los proveedores de servicios. Registraremos nuestro callback `booting` dentro del método `register` de la clase `App\Providers\AppServiceProvider` de nuestra aplicación:


```php
<?php

namespace App\Providers;

use App\Extensions\MongoStore;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
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
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // ...
    }
}
```
El primer argumento pasado al método `extend` es el nombre del driver. Esto corresponderá a tu opción `driver` en el archivo de configuración `config/cache.php`. El segundo argumento es una función anónima que debe devolver una instancia de `Illuminate\Cache\Repository`. La función anónima recibirá una instancia de `$app`, que es una instancia del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container).
Una vez que tu extensión esté registrada, actualiza la variable de entorno `CACHE_STORE` o la opción `default` dentro del archivo de configuración `config/cache.php` de tu aplicación al nombre de tu extensión.

<a name="events"></a>
## Eventos

Para ejecutar código en cada operación de caché, puedes escuchar varios [eventos](/docs/%7B%7Bversion%7D%7D/events) despachados por la caché:
<div class="overflow-auto">

| Nombre del Evento |
| --- |
| `Illuminate\Cache\Events\CacheHit` |
| `Illuminate\Cache\Events\CacheMissed` |
| `Illuminate\Cache\Events\KeyForgotten` |
| `Illuminate\Cache\Events\KeyWritten` |
</div>
Para aumentar el rendimiento, puedes deshabilitar los eventos de caché configurando la opción de configuración `events` a `false` para un almacén de caché dado en el archivo de configuración `config/cache.php` de tu aplicación:


```php
'database' => [
    'driver' => 'database',
    // ...
    'events' => false,
],

```