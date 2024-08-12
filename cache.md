# cache

- [Introducción](#introduction)
- [Configuración](#configuration)
  - [Requisitos previos del controlador](#driver-prerequisites)
- [Cache Usage](#cache-usage)
  - [Obtaining A Cache Instance](#obtaining-a-cache-instance)
  - [Recuperación de elementos de la cache](#retrieving-items-from-the-cache)
  - [Almacenamiento de elementos en la cache](#storing-items-in-the-cache)
  - [Eliminación de elementos de la cache](#removing-items-from-the-cache)
  - [The Cache Helper](#the-cache-helper)
- [Cache Tags](#cache-tags)
  - [Storing Tagged Cache Items](#storing-tagged-cache-items)
  - [Accessing Tagged Cache Items](#accessing-tagged-cache-items)
  - [Removing Tagged Cache Items](#removing-tagged-cache-items)
- [Bloqueos atómicos](#atomic-locks)
  - [Requisitos previos del controlador](#lock-driver-prerequisites)
  - [Gestión de Bloqueos](#managing-locks)
  - [Gestión de bloqueos entre procesos](#managing-locks-across-processes)
- [Adding Custom Cache Drivers](#adding-custom-cache-drivers)
  - [Escribiendo el Driver](#writing-the-driver)
  - [Registro del controlador](#registering-the-driver)
- [Eventos](#events)

[]()

## Introducción

Algunas de las tareas de recuperación o procesamiento de datos realizadas por su aplicación pueden requerir un uso intensivo de la CPU o tardar varios segundos en completarse. Cuando este es el caso, es común cache los datos recuperados durante un tiempo para que puedan ser recuperados rápidamente en posteriores peticiones de los mismos datos. Los datos en caché suelen almacenarse en un almacén de datos muy rápido, como [Memcached](https://memcached.org) o [Redis](https://redis.io).

Afortunadamente, Laravel proporciona una API expresiva y unificada para varios backends de cache, permitiéndote aprovechar su rapidísima recuperación de datos y acelerar tu aplicación web.

[]()

## Configuración

El archivo de configuración de cache de tu aplicación se encuentra en `config/cache.php`. En este fichero puedes especificar qué controlador de cache quieres que se utilice por defecto en toda tu aplicación. Laravel soporta backends de caché populares como [Memcached](https://memcached.org), [Redis](https://redis.io), [DynamoDB](https://aws.amazon.com/dynamodb) y bases de datos relacionales. Además, está disponible un controlador de cache basado en archivos, mientras que los controladores de cache de `array` y "null" proporcionan backends de cache convenientes para tus tests automatizadas.

El archivo de configuración de cache también contiene otras opciones, que están documentadas en el archivo, así que asegúrese de leer estas opciones. Por defecto, Laravel está configurado para utilizar el controlador de cache `archivos`, que almacena los objetos serializados y almacenados en caché en el sistema de archivos del servidor. Para aplicaciones más grandes, se recomienda utilizar un controlador más robusto como Memcached o Redis. Puede incluso configurar múltiples cache para el mismo controlador.

[]()

### Requisitos previos del controlador

[]()

#### Base de datos

Cuando utilice el controlador de cache de base de `datos`, necesitará configurar una tabla para contener los elementos de la cache. A continuación encontrarás un ejemplo de declaración de `esquema` para la tabla:

    Schema::create('cache', function ($table) {
        $table->string('key')->unique();
        $table->text('value');
        $table->integer('expiration');
    });

> **Nota**  
> También puede utilizar el comando `php artisan cache` Artisan para generar una migración con el esquema adecuado.

[]()

#### Memcached

El uso del controlador Memcached requiere la instalación del [paquete Memcached PECL](https://pecl.php.net/package/memcached). Puedes listar todos tus servidores Memcached en el archivo de configuración `config/cache.php`. Este archivo ya contiene una entrada `memcached.` servers para empezar:

    'memcached' => [
        'servers' => [
            [
                'host' => env('MEMCACHED_HOST', '127.0.0.1'),
                'port' => env('MEMCACHED_PORT', 11211),
                'weight' => 100,
            ],
        ],
    ],

Si es necesario, puede establecer la opción `host` en una ruta de socket UNIX. Si hace esto, la opción de `puerto` debe establecerse en `0`:

    'memcached' => [
        [
            'host' => '/var/run/memcached/memcached.sock',
            'port' => 0,
            'weight' => 100
        ],
    ],

[]()

#### Redis

Antes de utilizar una cache Redis con Laravel, tendrás que instalar la extensión PHP PhpRedis a través de PECL o instalar el paquete `predis/predis` (\~1.0) a través de Composer. [Laravel Sail](/docs/{{version}}/sail) ya incluye esta extensión. Además, las plataformas de despliegue oficiales de Laravel como [Laravel Forge](https://forge.laravel.com) y [Laravel Vapor](https://vapor.laravel.com) tienen la extensión PhpRedis instalada por defecto.

Para obtener más información sobre la configuración de Redis, consulta su [página de documentación](/docs/{{version}}/redis#configuration) de Laravel.

[]()

#### DynamoDB

Antes de utilizar el controlador de cache de [DynamoDB](https://aws.amazon.com/dynamodb), debe crear una tabla de DynamoDB para almacenar todos los datos almacenados en caché. Normalmente, esta tabla debe llamarse `cache`. Sin embargo, el nombre de la tabla debe basarse en el valor de configuración `stores.dynamodb.` table del archivo de configuración de `cache` de la aplicación.

Esta tabla también debe tener una clave de partición de cadena con un nombre que se corresponda con el valor del elemento de configuración `stores.dynamodb.attributes.key` dentro del archivo de configuración de `cache` de su aplicación. Por defecto, la clave de partición debe llamarse `key`.

[]()

## Uso decache

[cache-instance">]()

### Obtención de una instancia de cache

Para obtener una instancia de un almacén cache, puede utilizar la facade de `cache`, que es lo que utilizaremos a lo largo de esta documentación. La fachada facade `cache` proporciona un acceso cómodo y conciso a las implementaciones subyacentes de los contratos de cache de Laravel:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Support\Facades\Cache;

    class UserController extends Controller
    {
        /**
         * Show a list of all users of the application.
         *
         * @return Response
         */
        public function index()
        {
            $value = Cache::get('key');

            //
        }
    }

[cache-stores">]()

#### Acceso a múltiples almacenes de cache

Utilizando la facade de `cache`, se puede acceder a varios almacenes de cache a través del método `store`. La clave que se pasa al método `store` debe corresponder a uno de los almacenes listados en el array configuración de `almacenes` del fichero de configuración de `cache`:

    $value = Cache::store('file')->get('foo');

    Cache::store('redis')->put('bar', 'baz', 600); // 10 Minutes

[]()

### Recuperación de elementos de la cache

El método `get` de facade fachada de la `cache` se utiliza para recuperar elementos de la cache. Si el elemento no existe en la cache, se devolverá `null`. Si lo desea, puede pasar un segundo argumento al método `get` especificando el valor por defecto que desea que se devuelva si el elemento no existe:

    $value = Cache::get('key');

    $value = Cache::get('key', 'default');

Incluso puede pasar un closure como valor por defecto. Se devolverá el resultado del closure si el elemento especificado no existe en la cache. Pasar un closure permite aplazar la recuperación de valores por defecto de una base de datos u otro servicio externo:

    $value = Cache::get('key', function () {
        return DB::table(/* ... */)->get();
    });

[]()

#### Comprobación de la existencia de un elemento

El método `has` puede utilizarse para determinar si un elemento existe en la cache. Este método también devolverá `false` si el elemento existe pero su valor es `nulo`:

    if (Cache::has('key')) {
        //
    }

[]()

#### Incrementar / Disminuir valores

Los métodos `increment` y `decrement` pueden utilizarse para ajustar el valor de los elementos enteros de la cache. Ambos métodos aceptan un segundo argumento opcional que indica la cantidad por la que incrementar o decrementar el valor del elemento:

    Cache::increment('key');
    Cache::increment('key', $amount);
    Cache::decrement('key');
    Cache::decrement('key', $amount);

[]()

#### Recuperar y almacenar

A veces puede que desee recuperar un elemento de la cache, pero también almacenar un valor por defecto si el elemento solicitado no existe. Por ejemplo, puede que desee recuperar todos los usuarios de la cache o, si no existen, recuperarlos de la base de datos y añadirlos a la cache. Puede hacerlo utilizando el método `cache::remember`:

    $value = Cache::remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

Si el elemento no existe en la cache, se ejecutará el closure pasado al método `remember` y su resultado se colocará en la cache.

Puedes utilizar el método `rememberForever` para recuperar un elemento de la cache o almacenarlo para siempre si no existe:

    $value = Cache::rememberForever('users', function () {
        return DB::table('users')->get();
    });

[]()

#### Recuperar y eliminar

Si necesitas recuperar un elemento de la cache y luego borrarlo, puedes utilizar el método `pull`. Al igual que el método `get`, se devolverá `null` si el elemento no existe en la cache:

    $value = Cache::pull('key');

[]()

### Almacenamiento de elementos en la cache

Puede utilizar el método `put` en la facade la `cache` para almacenar elementos en la cache:

    Cache::put('key', 'value', $seconds = 10);

Si no se pasa el tiempo de almacenamiento al método `put`, el elemento se almacenará indefinidamente:

    Cache::put('key', 'value');

En lugar de pasar el número de segundos como un entero, también puede pasar una instancia de `DateTime` que represente la hora de caducidad deseada del elemento almacenado en caché:

    Cache::put('key', 'value', now()->addMinutes(10));

[]()

#### Almacenar si no está presente

El método `add` sólo añadirá el elemento a la cache si no existe ya en el almacén de cache. El método devolverá `true` si el elemento se ha añadido a cache caché. En caso contrario, el método devolverá `false`. El método `add` es una operación atómica:

    Cache::add('key', 'value', $seconds);

[]()

#### Almacenar elementos para siempre

El método `forever` puede utilizarse para almacenar un elemento en la cache de forma permanente. Dado que estos elementos no caducan, deben ser eliminados manualmente de la cache utilizando el método `olvidar`:

    Cache::forever('key', 'value');

> **Nota**  
> Si se utiliza el controlador Memcached, los elementos almacenados "para siempre" pueden eliminarse cuando la cache alcance su límite de tamaño.

[]()

### Eliminación de elementos de la cache

Puedes eliminar elementos de la cache utilizando el método `forget`:

    Cache::forget('key');

También puede eliminar elementos indicando un número cero o negativo de segundos de caducidad:

    Cache::put('key', 'value', 0);

    Cache::put('key', 'value', -5);

Puede borrar toda la cache utilizando el método `flush`:

    Cache::flush();

> **Advertencia**  
> Vaciar la cache no respeta el "prefijo" de cache configurado y eliminará todas las entradas de la cache. Tenlo en cuenta cuando limpies una cache compartida por otras aplicaciones.

[cache-helper">]()

### El ayudante de cache

Además de utilizar la facade `cache`, también puedes utilizar la función de `cache` global para recuperar y almacenar datos a través de la cache. Cuando se llama a la función de `cache` con un único argumento de cadena, devolverá el valor de la clave dada:

    $value = cache('key');

Si proporciona una array de pares clave/valor y un tiempo de caducidad a la función, ésta almacenará los valores en la cache durante el tiempo especificado:

    cache(['key' => 'value'], $seconds);

    cache(['key' => 'value'], now()->addMinutes(10));

Cuando se llama a la función de `cache` sin ningún argumento, devuelve una instancia de la implementación `Illuminate\Contracts\cache\Factory`, permitiéndole llamar a otros métodos de caché:

    cache()->remember('users', $seconds, function () {
        return DB::table('users')->get();
    });

> **Nota**  
> Al probar la llamada a la función de `cache` global, puede utilizar el método `cache::shouldReceive` como si estuviera [probando la facade](/docs/{{version}}/mocking#mocking-facades).

[]()

## Etiquetas de lacache

> **Advertencia**  
> Las etiquetas de caché no son compatibles cuando se utilizan los controladores de cache `archivos`, `dynamodb` o `bases de datos`. Además, cuando se utilizan múltiples etiquetas con cachés que se almacenan "para siempre", el rendimiento será mejor con un controlador como `memcached`, que purga automáticamente los registros obsoletos.

[cache-items">]()

### Almacenamiento de elementos etiquetados en la cache

Las etiquetas decache caché permiten etiquetar elementos relacionados en la cache y, a continuación, vaciar todos los valores de la caché a los que se haya asignado una etiqueta determinada. Puede acceder a una cache etiquetada pasando una array ordenada de nombres de etiquetas. No se puede acceder a los elementos almacenados mediante etiquetas sin proporcionar también las etiquetas que se utilizaron para almacenar el valor. Por ejemplo, accedamos a una cache etiquetada y `pongamos` un valor en la cache:

    Cache::tags(['people', 'artists'])->put('John', $john, $seconds);

    Cache::tags(['people', 'authors'])->put('Anne', $anne, $seconds);

[cache-items">]()

### Acceso a los elementos etiquetados de la cache

Para recuperar un elemento de cache etiquetado, pase la misma lista ordenada de etiquetas al método `tags` y, a continuación, llame al método `get` con la clave que desea recuperar:

    $john = Cache::tags(['people', 'artists'])->get('John');

    $anne = Cache::tags(['people', 'authors'])->get('Anne');

[cache-items">]()

### Eliminación de elementos etiquetados de cache caché

Puede vaciar todos los elementos que tengan asignada una etiqueta o lista de etiquetas. Por ejemplo, esta sentencia eliminaría todas las cachés etiquetadas con `personas`, `autores` o ambos. Así, tanto `Ana` como `Juan` serían eliminados de cache caché:

    Cache::tags(['people', 'authors'])->flush();

Por el contrario, esta sentencia eliminaría sólo los valores de la caché etiquetados con `autores`, por lo que se eliminaría a `Ana`, pero no a `Juan`:

    Cache::tags('authors')->flush();

[]()

## Bloqueos atómicos

> **Advertencia**  
> Para utilizar esta función, tu aplicación debe utilizar `memcached`, `redis`, `dynamodb`, `base de datos`, `archivo` o controlador de cache `array` como controlador de cache predeterminado de tu aplicación. Además, todos los servidores deben comunicarse con el mismo servidor central de cache.

[]()

### Requisitos previos del controlador

[]()

#### Base de datos

Cuando utilices el controlador de caché cache base de `datos`, necesitarás configurar una tabla para contener los bloqueos de cache de tu aplicación. A continuación encontrará un ejemplo de declaración de `esquema` para la tabla:

    Schema::create('cache_locks', function ($table) {
        $table->string('key')->primary();
        $table->string('owner');
        $table->integer('expiration');
    });

[]()

### Gestión de Bloqueos

Los bloqueos atómicos permiten la manipulación de bloqueos distribuidos sin preocuparse por las condiciones de carrera. Por ejemplo, [Laravel Forge](https://forge.laravel.com) utiliza bloqueos atómicos para asegurar que sólo una tarea remota se está ejecutando en un servidor a la vez. Puedes crear y gestionar bloqueos utilizando el método `cache::lock`:

    use Illuminate\Support\Facades\Cache;

    $lock = Cache::lock('foo', 10);

    if ($lock->get()) {
        // Lock acquired for 10 seconds...

        $lock->release();
    }

El método `get` también acepta un closure. Una vez ejecutado el closure, Laravel liberará automáticamente el bloqueo:

    Cache::lock('foo')->get(function () {
        // Lock acquired indefinitely and automatically released...
    });

Si el bloqueo no está disponible en el momento en que lo solicitas, puedes indicar a Laravel que espere un número determinado de segundos. Si el bloqueo no puede ser adquirido dentro del límite de tiempo especificado, se lanzará una `Illuminate\Contracts\cache\LockTimeoutException`:

    use Illuminate\Contracts\Cache\LockTimeoutException;

    $lock = Cache::lock('foo', 10);

    try {
        $lock->block(5);

        // Lock acquired after waiting a maximum of 5 seconds...
    } catch (LockTimeoutException $e) {
        // Unable to acquire lock...
    } finally {
        optional($lock)->release();
    }

El ejemplo anterior puede simplificarse pasando un closure al método `block`. Cuando se pasa un closure a este método, Laravel intentará adquirir el bloqueo durante el número de segundos especificado y lo liberará automáticamente una vez que el closure se haya ejecutado:

    Cache::lock('foo', 10)->block(5, function () {
        // Lock acquired after waiting a maximum of 5 seconds...
    });

[]()

### Gestión de bloqueos entre procesos

A veces, es posible que desee adquirir un bloqueo en un proceso y liberarlo en otro proceso. Por ejemplo, puede adquirir un bloqueo durante una solicitud web y desea liberar el bloqueo al final de un trabajo en cola que se desencadena por esa solicitud. En este caso, deberías pasar el "owner token" del bloqueo al trabajo en cola para que el trabajo pueda re-instalar el bloqueo usando el token dado.

En el siguiente ejemplo, enviaremos un trabajo en cola si el bloqueo se adquiere con éxito. Además, pasaremos el token del propietario del bloqueo al trabajo en cola a través del método `propietario` del bloqueo:

    $podcast = Podcast::find($id);

    $lock = Cache::lock('processing', 120);

    if ($lock->get()) {
        ProcessPodcast::dispatch($podcast, $lock->owner());
    }

Dentro del trabajo `ProcessPodcast` de nuestra aplicación, podemos restaurar y liberar el bloqueo utilizando el token de propietario:

    Cache::restoreLock('processing', $this->owner)->release();

Si deseas liberar un bloqueo sin respetar su propietario actual, puedes utilizar el método `forceRelease`:

    Cache::lock('processing')->forceRelease();

[cache-drivers">]()

## Adición de controladores de cache personalizados

[]()

### Escribir el controlador

Para crear nuestro controlador de cache personalizado, primero necesitamos implementar el [contrato](/docs/{{version}}/contracts) `Illuminate\Contracts\cache\Store`. Así, una implementación de cache MongoDB podría ser algo como esto:

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

Sólo tenemos que implementar cada uno de estos métodos utilizando una conexión MongoDB. Para ver un ejemplo de cómo implementar cada uno de estos métodos, echa un vistazo a `Illuminate\cache\MemcachedStore` en el [código fuente de Laravel framework](https://github.com/laravel/framework). Una vez completada nuestra implementación, podemos finalizar el registro de nuestro controlador personalizado llamando al método `extend` de la facade `cache`:

    Cache::extend('mongo', function ($app) {
        return Cache::repository(new MongoStore);
    });

> **Nota**  
> Si te estás preguntando dónde poner tu código de controlador de cache personalizado, podrías crear un espacio de nombres `Extensions` dentro del directorio de tu `app`. Sin embargo, ten en cuenta que Laravel no tiene una estructura de aplicación rígida y eres libre de organizar tu aplicación según tus preferencias.

[]()

### Registro del controlador

Para registrar el controlador de cache personalizado en Laravel, utilizaremos el método `extend` de la facade de `cache`. Dado que otros proveedores de servicios pueden intentar leer los valores almacenados en caché dentro de su método de `arranque`, registraremos nuestro controlador personalizado dentro de un callback de `arranque`. Usando `el` callback de arranque, podemos asegurarnos de que el controlador personalizado se registra justo antes de que el método de `arranque` sea llamado en los proveedores de servicio de nuestra aplicación, pero después de que el método `register` sea llamado en todos los proveedores de servicio. Registraremos nuestro callback de `arranque` dentro del método `register` de la clase `AppProviders\AppServiceProvider` de nuestra aplicación:

    <?php

    namespace App\Providers;

    use App\Extensions\MongoStore;
    use Illuminate\Support\Facades\Cache;
    use Illuminate\Support\ServiceProvider;

    class CacheServiceProvider extends ServiceProvider
    {
        /**
         * Register any application services.
         *
         * @return void
         */
        public function register()
        {
            $this->app->booting(function () {
                 Cache::extend('mongo', function ($app) {
                     return Cache::repository(new MongoStore);
                 });
             });
        }

        /**
         * Bootstrap any application services.
         *
         * @return void
         */
        public function boot()
        {
            //
        }
    }

El primer argumento pasado al método `extend` es el nombre del driver. Esto corresponderá a la opción de `controlador` en el archivo de configuración `config/cache.php`. El segundo argumento es un closure que debe devolver una instancia `Illuminate\cache\Repository`. Al closure se le pasará una instancia `$app`, que es una instancia del [contenedor de servicios](/docs/{{version}}/container).

Una vez registrada tu extensión, actualiza la opción `driver` de tu fichero de configuración `config/cache.` php con el nombre de tu extensión.

[]()

## Eventos

Para ejecutar código en cada operación de cache, puede escuchar los [eventos](/docs/{{version}}/events) disparados por la cache. Típicamente, deberías colocar estos escuchadores de eventos dentro de la clase `App\Providers\EventServiceProvider` de tu aplicación:

    use App\Listeners\LogCacheHit;
    use App\Listeners\LogCacheMissed;
    use App\Listeners\LogKeyForgotten;
    use App\Listeners\LogKeyWritten;
    use Illuminate\Cache\Events\CacheHit;
    use Illuminate\Cache\Events\CacheMissed;
    use Illuminate\Cache\Events\KeyForgotten;
    use Illuminate\Cache\Events\KeyWritten;

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        CacheHit::class => [
            LogCacheHit::class,
        ],

        CacheMissed::class => [
            LogCacheMissed::class,
        ],

        KeyForgotten::class => [
            LogKeyForgotten::class,
        ],

        KeyWritten::class => [
            LogKeyWritten::class,
        ],
    ];
