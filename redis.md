# Redis

- [Introducción](#introduction)
- [Configuración](#configuration)
  - [Clústeres](#clusters)
  - [Predis](#predis)
  - [PhpRedis](#phpredis)
- [Interacción Con Redis](#interacting-with-redis)
  - [Transacciones](#transactions)
  - [Pipelining de Comandos](#pipelining-commands)
- [Pub / Sub](#pubsub)

<a name="introduction"></a>
## Introducción

[Redis](https://redis.io) es un almacén de clave-valor avanzado y de código abierto. A menudo se le llama servidor de estructuras de datos, ya que las claves pueden contener [cadenas](https://redis.io/docs/data-types/strings/), [hashes](https://redis.io/docs/data-types/hashes/), [listas](https://redis.io/docs/data-types/lists/), [conjuntos](https://redis.io/docs/data-types/sets/) y [conjuntos ordenados](https://redis.io/docs/data-types/sorted-sets/).
Antes de usar Redis con Laravel, te recomendamos que instalas y uses la extensión PHP [PhpRedis](https://github.com/phpredis/phpredis) a través de PECL. La extensión es más compleja de instalar en comparación con los paquetes PHP "user-land", pero puede ofrecer un mejor rendimiento para aplicaciones que hacen un uso intensivo de Redis. Si estás utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail), esta extensión ya está instalada en el contenedor Docker de tu aplicación.
Si no puedes instalar la extensión PhpRedis, puedes instalar el paquete `predis/predis` a través de Composer. Predis es un cliente Redis escrito completamente en PHP y no requiere extensiones adicionales:


```shell
composer require predis/predis:^2.0

```

<a name="configuration"></a>
## Configuración

Puedes configurar la configuración de Redis de tu aplicación a través del archivo de configuración `config/database.php`. Dentro de este archivo, verás un array `redis` que contiene los servidores Redis utilizados por tu aplicación:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
    ],

    'default' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'username' => env('REDIS_USERNAME'),
        'password' => env('REDIS_PASSWORD'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_DB', '0'),
    ],

    'cache' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'username' => env('REDIS_USERNAME'),
        'password' => env('REDIS_PASSWORD'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_CACHE_DB', '1'),
    ],

],
```
Cada servidor Redis definido en tu archivo de configuración debe tener un nombre, host y un puerto, a menos que definas una sola URL para representar la conexión Redis:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
    ],

    'default' => [
        'url' => 'tcp://127.0.0.1:6379?database=0',
    ],

    'cache' => [
        'url' => 'tls://user:password@127.0.0.1:6380?database=1',
    ],

],
```

<a name="configuring-the-connection-scheme"></a>
#### Configurando el Esquema de Conexión

Por defecto, los clientes de Redis utilizarán el esquema `tcp` al conectarse a tus servidores Redis; sin embargo, puedes usar cifrado TLS / SSL especificando una opción de configuración `scheme` en el array de configuración de tu servidor Redis:


```php
'default' => [
    'scheme' => 'tls',
    'url' => env('REDIS_URL'),
    'host' => env('REDIS_HOST', '127.0.0.1'),
    'username' => env('REDIS_USERNAME'),
    'password' => env('REDIS_PASSWORD'),
    'port' => env('REDIS_PORT', '6379'),
    'database' => env('REDIS_DB', '0'),
],
```

<a name="clusters"></a>
### Clústeres

Si tu aplicación está utilizando un clúster de servidores Redis, debes definir estos clústeres dentro de una clave `clusters` de tu configuración de Redis. Esta clave de configuración no existe por defecto, así que necesitarás crearla dentro del archivo de configuración `config/database.php` de tu aplicación:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
    ],

    'clusters' => [
        'default' => [
            [
                'url' => env('REDIS_URL'),
                'host' => env('REDIS_HOST', '127.0.0.1'),
                'username' => env('REDIS_USERNAME'),
                'password' => env('REDIS_PASSWORD'),
                'port' => env('REDIS_PORT', '6379'),
                'database' => env('REDIS_DB', '0'),
            ],
        ],
    ],

    // ...
],
```
Por defecto, Laravel utilizará el clustering nativo de Redis ya que el valor de configuración `options.cluster` está configurado en `redis`. El clustering de Redis es una excelente opción predeterminada, ya que maneja la conmutación por error de manera eficiente.
Laravel también admite sharding del lado del cliente. Sin embargo, el sharding del lado del cliente no maneja la conmutación por error; por lo tanto, se adapta principalmente a datos en caché transitorios que están disponibles desde otro almacén de datos primario.
Si deseas utilizar sharding del lado del cliente en lugar del clustering nativo de Redis, puedes eliminar el valor de configuración `options.cluster` dentro del archivo de configuración `config/database.php` de tu aplicación:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    'clusters' => [
        // ...
    ],

    // ...
],
```

<a name="predis"></a>
### Predis

Si deseas que tu aplicación interactúe con Redis a través del paquete Predis, debes asegurarte de que el valor de la variable de entorno `REDIS_CLIENT` sea `predis`:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'predis'),

    // ...
],
```
Además de las opciones de configuración predeterminadas, Predis admite parámetros de [conexión adicionales](https://github.com/nrk/predis/wiki/Connection-Parameters) que pueden definirse para cada uno de tus servidores Redis. Para utilizar estas opciones de configuración adicionales, agrégalas a la configuración de tu servidor Redis en el archivo de configuración `config/database.php` de tu aplicación:


```php
'default' => [
    'url' => env('REDIS_URL'),
    'host' => env('REDIS_HOST', '127.0.0.1'),
    'username' => env('REDIS_USERNAME'),
    'password' => env('REDIS_PASSWORD'),
    'port' => env('REDIS_PORT', '6379'),
    'database' => env('REDIS_DB', '0'),
    'read_write_timeout' => 60,
],
```

<a name="phpredis"></a>
### PhpRedis

Por defecto, Laravel utilizará la extensión PhpRedis para comunicarse con Redis. El cliente que Laravel utilizará para comunicarse con Redis está dictado por el valor de la opción de configuración `redis.client`, que típicamente refleja el valor de la variable de entorno `REDIS_CLIENT`:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    // ...
],
```
Además de las opciones de configuración predeterminadas, PhpRedis admite los siguientes parámetros de conexión adicionales: `name`, `persistent`, `persistent_id`, `prefix`, `read_timeout`, `retry_interval`, `timeout` y `context`. Puedes añadir cualquiera de estas opciones a la configuración de tu servidor Redis en el archivo de configuración `config/database.php`:


```php
'default' => [
    'url' => env('REDIS_URL'),
    'host' => env('REDIS_HOST', '127.0.0.1'),
    'username' => env('REDIS_USERNAME'),
    'password' => env('REDIS_PASSWORD'),
    'port' => env('REDIS_PORT', '6379'),
    'database' => env('REDIS_DB', '0'),
    'read_timeout' => 60,
    'context' => [
        // 'auth' => ['username', 'secret'],
        // 'stream' => ['verify_peer' => false],
    ],
],
```

<a name="phpredis-serialization"></a>
#### Serialización y Comprensión de PhpRedis

La extensión PhpRedis también se puede configurar para usar una variedad de serializadores y algoritmos de compresión. Estos algoritmos se pueden configurar a través del array `options` de tu configuración de Redis:


```php
'redis' => [

    'client' => env('REDIS_CLIENT', 'phpredis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
        'serializer' => Redis::SERIALIZER_MSGPACK,
        'compression' => Redis::COMPRESSION_LZ4,
    ],

    // ...
],
```
Los serializers actualmente soportados incluyen: `Redis::SERIALIZER_NONE` (por defecto), `Redis::SERIALIZER_PHP`, `Redis::SERIALIZER_JSON`, `Redis::SERIALIZER_IGBINARY` y `Redis::SERIALIZER_MSGPACK`.
Los algoritmos de compresión compatibles incluyen: `Redis::COMPRESSION_NONE` (predeterminado), `Redis::COMPRESSION_LZF`, `Redis::COMPRESSION_ZSTD` y `Redis::COMPRESSION_LZ4`.

<a name="interacting-with-redis"></a>
## Interactuando Con Redis

Puedes interactuar con Redis llamando a varios métodos en la `facade` de `Redis` [facade](/docs/%7B%7Bversion%7D%7D/facades). La `facade` de `Redis` admite métodos dinámicos, lo que significa que puedes llamar a cualquier [comando de Redis](https://redis.io/commands) en la `facade` y el comando será pasado directamente a Redis. En este ejemplo, llamaremos al comando `GET` de Redis llamando al método `get` en la `facade` de `Redis`:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Redis;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show the profile for the given user.
     */
    public function show(string $id): View
    {
        return view('user.profile', [
            'user' => Redis::get('user:profile:'.$id)
        ]);
    }
}
```
Como se mencionó anteriormente, puedes llamar a cualquiera de los comandos de Redis en la fachada `Redis`. Laravel utiliza métodos mágicos para pasar los comandos al servidor Redis. Si un comando de Redis espera argumentos, debes pasarlos al método correspondiente de la fachada:


```php
use Illuminate\Support\Facades\Redis;

Redis::set('name', 'Taylor');

$values = Redis::lrange('names', 5, 10);
```
Alternativamente, puedes enviar comandos al servidor utilizando el método `command` de la fachada `Redis`, que acepta el nombre del comando como su primer argumento y un array de valores como su segundo argumento:


```php
$values = Redis::command('lrange', ['name', 5, 10]);
```

<a name="using-multiple-redis-connections"></a>
#### Usando Múltiples Conexiones Redis

El archivo de configuración `config/database.php` de tu aplicación te permite definir múltiples conexiones / servidores Redis. Puedes obtener una conexión a una conexión Redis específica utilizando el método `connection` de la fachada `Redis`:


```php
$redis = Redis::connection('connection-name');
```
Para obtener una instancia de la conexión Redis predeterminada, puedes llamar al método `connection` sin argumentos adicionales:


```php
$redis = Redis::connection();
```

<a name="transactions"></a>
### Transacciones

El método `transaction` de la fachada `Redis` proporciona un envoltorio conveniente alrededor de los comandos nativos `MULTI` y `EXEC` de Redis. El método `transaction` acepta una función anónima como su único argumento. Esta función anónima recibirá una instancia de conexión a Redis y puede emitir cualquier comando que desee a esta instancia. Todos los comandos de Redis emitidos dentro de la función anónima se ejecutarán en una sola transacción atómica:


```php
use Redis;
use Illuminate\Support\Facades;

Facades\Redis::transaction(function (Redis $redis) {
    $redis->incr('user_visits', 1);
    $redis->incr('total_visits', 1);
});
```
> [!WARNING]
Al definir una transacción de Redis, no puedes recuperar ningún valor de la conexión Redis. Recuerda que tu transacción se ejecuta como una sola operación atómica y que esa operación no se ejecuta hasta que tu `función anónima` haya terminado de ejecutar sus comandos.
#### Scripts de Lua

El método `eval` proporciona otro método para ejecutar múltiples comandos Redis en una sola operación atómica. Sin embargo, el método `eval` tiene la ventaja de poder interactuar con e inspeccionar los valores clave de Redis durante esa operación. Los scripts de Redis están escritos en el [lenguaje de programación Lua](https://www.lua.org).
El método `eval` puede dar un poco de miedo al principio, pero exploraremos un ejemplo básico para romper el hielo. El método `eval` espera varios argumentos. Primero, debes pasar el script Lua (como una cadena) al método. En segundo lugar, debes pasar el número de claves (como un entero) con las que interactúa el script. En tercer lugar, debes pasar los nombres de esas claves. Finalmente, puedes pasar cualquier otro argumento adicional que necesites acceder dentro de tu script.
En este ejemplo, incrementaremos un contador, inspeccionaremos su nuevo valor e incrementaremos un segundo contador si el valor del primer contador es mayor que cinco. Finalmente, devolveremos el valor del primer contador:


```php
$value = Redis::eval(<<<'LUA'
    local counter = redis.call("incr", KEYS[1])

    if counter > 5 then
        redis.call("incr", KEYS[2])
    end

    return counter
LUA, 2, 'first-counter', 'second-counter');
```
> [!WARNING]
Por favor, consulta la [documentación de Redis](https://redis.io/commands/eval) para obtener más información sobre la programación de scripts en Redis.

<a name="pipelining-commands"></a>
### Comando de Pipelining

A veces es posible que necesites ejecutar docenas de comandos de Redis. En lugar de hacer un viaje de red a tu servidor Redis por cada comando, puedes usar el método `pipeline`. El método `pipeline` acepta un argumento: una función anónima que recibe una instancia de Redis. Puedes emitir todos tus comandos a esta instancia de Redis y se enviarán todos al servidor Redis al mismo tiempo para reducir los viajes de red al servidor. Los comandos aún se ejecutarán en el orden en que fueron emitidos:


```php
use Redis;
use Illuminate\Support\Facades;

Facades\Redis::pipeline(function (Redis $pipe) {
    for ($i = 0; $i < 1000; $i++) {
        $pipe->set("key:$i", $i);
    }
});
```

<a name="pubsub"></a>
## Pub / Sub

Laravel proporciona una interfaz conveniente para los comandos `publish` y `subscribe` de Redis. Estos comandos de Redis te permiten escuchar mensajes en un "canal" dado. Puedes publicar mensajes en el canal desde otra aplicación, o incluso utilizando otro lenguaje de programación, lo que permite una fácil comunicación entre aplicaciones y procesos.
Primero, configuremos un listener de canal utilizando el método `subscribe`. Colocaremos esta llamada al método dentro de un [comando Artisan](/docs/%7B%7Bversion%7D%7D/artisan) ya que llamar al método `subscribe` inicia un proceso de larga duración:


```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Redis;

class RedisSubscribe extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'redis:subscribe';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Subscribe to a Redis channel';

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        Redis::subscribe(['test-channel'], function (string $message) {
            echo $message;
        });
    }
}
```
Ahora podemos publicar mensajes en el canal utilizando el método `publish`:


```php
use Illuminate\Support\Facades\Redis;

Route::get('/publish', function () {
    // ...

    Redis::publish('test-channel', json_encode([
        'name' => 'Adam Wathan'
    ]));
});
```

<a name="wildcard-subscriptions"></a>
#### Suscripciones con Wildcard

Usando el método `psubscribe`, puedes suscribirte a un canal con un wildcard, lo que puede ser útil para capturar todos los mensajes en todos los canales. El nombre del canal se pasará como segundo argumento a la `función anónima` proporcionada:


```php
Redis::psubscribe(['*'], function (string $message, string $channel) {
    echo $message;
});

Redis::psubscribe(['users.*'], function (string $message, string $channel) {
    echo $message;
});
```