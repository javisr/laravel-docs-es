# Colas

- [Introducción](#introduction)
  - [Conexiones vs. Colas](#connections-vs-queues)
  - [Notas del Driver y Prerequisitos](#driver-prerequisites)
- [Creando Trabajos](#creating-jobs)
  - [Generando Clases de Trabajo](#generating-job-classes)
  - [Estructura de Clase](#class-structure)
  - [Trabajos Únicos](#unique-jobs)
  - [Trabajos Encriptados](#encrypted-jobs)
- [Middleware de Trabajo](#job-middleware)
  - [Limitación de Tasa](#rate-limiting)
  - [Previniendo Superposiciones de Trabajos](#preventing-job-overlaps)
  - [Excepciones de Throttling](#throttling-exceptions)
- [Despachando Trabajos](#dispatching-jobs)
  - [Despacho Retrasado](#delayed-dispatching)
  - [Despacho Síncrono](#synchronous-dispatching)
  - [Trabajos y Transacciones de Base de Datos](#jobs-and-database-transactions)
  - [Encadenamiento de Trabajos](#job-chaining)
  - [Personalizando la Cola y la Conexión](#customizing-the-queue-and-connection)
  - [Especificar Máximos Intentos de Trabajo / Valores de Tiempo de Espera](#max-job-attempts-and-timeout)
  - [Manejo de Errores](#error-handling)
- [Agrupamiento de Trabajos](#job-batching)
  - [Definir Trabajos Agrupables](#defining-batchable-jobs)
  - [Despachar Lotes](#dispatching-batches)
  - [Cadenas y Lotes](#chains-and-batches)
  - [Agregar Trabajos a Lotes](#adding-jobs-to-batches)
  - [Inspeccionar Lotes](#inspecting-batches)
  - [Cancelar Lotes](#cancelling-batches)
  - [Fallos de Lote](#batch-failures)
  - [Purgar Lotes](#pruning-batches)
  - [Almacenar Lotes en DynamoDB](#storing-batches-in-dynamodb)
- [Colocando Funciones Anónimas en Cola](#queueing-closures)
- [Ejecutando el Worker de Cola](#running-the-queue-worker)
  - [El Comando `queue:work`](#the-queue-work-command)
  - [Prioridades de Cola](#queue-priorities)
  - [Workers de Cola y Despliegue](#queue-workers-and-deployment)
  - [Expiraciones y Tiempos de Espera de Trabajos](#job-expirations-and-timeouts)
- [Configuración del Supervisor](#supervisor-configuration)
- [Tratando con Trabajos Fallidos](#dealing-with-failed-jobs)
  - [Limpiar Después de Trabajos Fallidos](#cleaning-up-after-failed-jobs)
  - [Reintentar Trabajos Fallidos](#retrying-failed-jobs)
  - [Ignorar Modelos Faltantes](#ignoring-missing-models)
  - [Purgar Trabajos Fallidos](#pruning-failed-jobs)
  - [Almacenar Trabajos Fallidos en DynamoDB](#storing-failed-jobs-in-dynamodb)
  - [Deshabilitar Almacenamiento de Trabajos Fallidos](#disabling-failed-job-storage)
  - [Eventos de Trabajos Fallidos](#failed-job-events)
- [Limpiar Trabajos de Colas](#clearing-jobs-from-queues)
- [Monitorear tus Colas](#monitoring-your-queues)
- [Pruebas](#testing)
  - [Simular un Subconjunto de Trabajos](#faking-a-subset-of-jobs)
  - [Probar Cadenas de Trabajos](#testing-job-chains)
  - [Probar Lotes de Trabajos](#testing-job-batches)
  - [Probar Interacciones de Trabajo / Cola](#testing-job-queue-interactions)
- [Eventos de Trabajo](#job-events)

<a name="introduction"></a>
## Introducción

Mientras construyes tu aplicación web, es posible que tengas algunas tareas, como analizar y almacenar un archivo CSV cargado, que tarden demasiado en realizarse durante una solicitud web típica. Afortunadamente, Laravel te permite crear fácilmente trabajos en cola que pueden procesarse en segundo plano. Al mover tareas que consumen mucho tiempo a una cola, tu aplicación puede responder a solicitudes web a gran velocidad y proporcionar una mejor experiencia de usuario a tus clientes.
Las colas de Laravel proporcionan una API de colas unificada a través de una variedad de backends de colas diferentes, como [Amazon SQS](https://aws.amazon.com/sqs/), [Redis](https://redis.io) o incluso una base de datos relacional.
Las opciones de configuración de la cola de Laravel se almacenan en el archivo de configuración `config/queue.php` de tu aplicación. En este archivo, encontrarás configuraciones de conexión para cada uno de los drivers de cola que se incluyen con el framework, incluyendo los drivers de base de datos, [Amazon SQS](https://aws.amazon.com/sqs/), [Redis](https://redis.io) y [Beanstalkd](https://beanstalkd.github.io/), así como un driver sincrónico que ejecutará trabajos inmediatamente (para usar durante el desarrollo local). También se incluye un driver de cola `null` que descarta los trabajos en cola.
> [!NOTE]
Laravel ahora ofrece Horizon, un hermoso sistema de panel y configuración para tus colas alimentadas por Redis. Revisa la [documentación completa de Horizon](/docs/%7B%7Bversion%7D%7D/horizon) para obtener más información.

<a name="connections-vs-queues"></a>
### Conexiones vs. Colas

Antes de comenzar con las colas de Laravel, es importante entender la distinción entre "conexiones" y "colas". En tu archivo de configuración `config/queue.php`, hay un array de configuración `connections`. Esta opción define las conexiones a servicios de cola backend como Amazon SQS, Beanstalk o Redis. Sin embargo, cualquier conexión de cola dada puede tener múltiples "colas", que pueden considerarse como diferentes pilas o montones de trabajos en cola.
Ten en cuenta que cada ejemplo de configuración de conexión en el archivo de configuración `queue` contiene un atributo `queue`. Esta es la cola predeterminada a la que se enviarán los trabajos cuando se envíen a una conexión dada. En otras palabras, si despachas un trabajo sin definir explícitamente a qué cola debe ser despachado, el trabajo se colocará en la cola que está definida en el atributo `queue` de la configuración de conexión:


```php
use App\Jobs\ProcessPodcast;

// This job is sent to the default connection's default queue...
ProcessPodcast::dispatch();

// This job is sent to the default connection's "emails" queue...
ProcessPodcast::dispatch()->onQueue('emails');
```
Algunas aplicaciones pueden no necesitar nunca enviar trabajos a múltiples colas, prefiriendo en su lugar tener una cola simple. Sin embargo, enviar trabajos a múltiples colas puede ser especialmente útil para aplicaciones que desean priorizar o segmentar cómo se procesan los trabajos, ya que el trabajador de colas de Laravel te permite especificar qué colas debe procesar por prioridad. Por ejemplo, si envías trabajos a una cola `high`, puedes ejecutar un trabajador que les dé mayor prioridad de procesamiento:


```shell
php artisan queue:work --queue=high,default

```

<a name="driver-prerequisites"></a>
### Notas y Prerrequisitos del Driver


<a name="database"></a>
#### Base de datos

Para utilizar el driver de cola `database`, necesitarás una tabla de base de datos para mantener los trabajos. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000002_create_jobs_table.php` [migración de base de datos](/docs/%7B%7Bversion%7D%7D/migrations); sin embargo, si tu aplicación no contiene esta migración, puedes usar el comando Artisan `make:queue-table` para crearla:


```shell
php artisan make:queue-table

php artisan migrate

```

<a name="redis"></a>
#### Redis

Para usar el driver de cola `redis`, debes configurar una conexión a una base de datos Redis en tu archivo de configuración `config/database.php`.
> [!WARNING]
Las opciones `serializer` y `compression` de Redis no son compatibles con el driver de cola `redis`.
**Cluster de Redis**
Si tu conexión de cola Redis utiliza un clúster de Redis, los nombres de tus colas deben contener un [etiqueta de hash de clave](https://redis.io/docs/reference/cluster-spec/#hash-tags). Esto es necesario para garantizar que todas las claves de Redis para una cola dada se coloquen en el mismo slot hash:


```php
'redis' => [
    'driver' => 'redis',
    'connection' => env('REDIS_QUEUE_CONNECTION', 'default'),
    'queue' => env('REDIS_QUEUE', '{default}'),
    'retry_after' => env('REDIS_QUEUE_RETRY_AFTER', 90),
    'block_for' => null,
    'after_commit' => false,
],
```
**Bloqueo**
Al usar la cola de Redis, puedes utilizar la opción de configuración `block_for` para especificar cuánto tiempo debe esperar el driver a que un trabajo esté disponible antes de iterar a través del bucle del trabajador y volver a realizar la consulta a la base de datos Redis.
Ajustar este valor en función de la carga de tu cola puede ser más eficiente que sondear continuamente la base de datos Redis en busca de nuevos trabajos. Por ejemplo, puedes establecer el valor en `5` para indicar que el driver debe bloquearse durante cinco segundos mientras espera a que un trabajo esté disponible:


```php
'redis' => [
    'driver' => 'redis',
    'connection' => env('REDIS_QUEUE_CONNECTION', 'default'),
    'queue' => env('REDIS_QUEUE', 'default'),
    'retry_after' => env('REDIS_QUEUE_RETRY_AFTER', 90),
    'block_for' => 5,
    'after_commit' => false,
],
```
> [!WARNING]
Configurar `block_for` en `0` hará que los trabajadores de la cola se bloqueen indefinidamente hasta que un trabajo esté disponible. Esto también evitará que se manejen señales como `SIGTERM` hasta que se haya procesado el siguiente trabajo.

<a name="other-driver-prerequisites"></a>
#### Otros requisitos previos del driver

Las siguientes dependencias son necesarias para los drivers de cola listados. Estas dependencias pueden instalarse a través del gestor de paquetes Composer:
<div class="content-list" markdown="1">

- Amazon SQS: `aws/aws-sdk-php ~3.0`
- Beanstalkd: `pda/pheanstalk ~5.0`
- Redis: `predis/predis ~2.0` or phpredis PHP extension
</div>

<a name="creating-jobs"></a>
## Creando Trabajos


<a name="generating-job-classes"></a>
### Generando Clases de Trabajo

Por defecto, todos los trabajos en cola de tu aplicación se almacenan en el directorio `app/Jobs`. Si el directorio `app/Jobs` no existe, se creará cuando ejecutes el comando Artisan `make:job`:


```shell
php artisan make:job ProcessPodcast

```
La clase generada implementará la interfaz `Illuminate\Contracts\Queue\ShouldQueue`, indicando a Laravel que el trabajo debe ser colocado en la cola para ejecutarse de forma asincrónica.
> [!NOTA]
Los stubs de trabajos pueden ser personalizados utilizando [la publicación de stubs](/docs/%7B%7Bversion%7D%7D/artisan#stub-customization).

<a name="class-structure"></a>
### Estructura de Clase

Las clases de trabajo son muy simples, normalmente contienen solo un método `handle` que se invoca cuando el trabajo es procesado por la cola. Para comenzar, echemos un vistazo a un ejemplo de clase de trabajo. En este ejemplo, fingiremos que gestionamos un servicio de publicación de pódcast y necesitamos procesar los archivos de pódcast subidos antes de que sean publicados:


```php
<?php

namespace App\Jobs;

use App\Models\Podcast;
use App\Services\AudioProcessor;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public Podcast $podcast,
    ) {}

    /**
     * Execute the job.
     */
    public function handle(AudioProcessor $processor): void
    {
        // Process uploaded podcast...
    }
}
```
En este ejemplo, ten en cuenta que pudimos pasar un [modelo Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) directamente al constructor del trabajo en cola. Debido al trait `Queueable` que está utilizando el trabajo, los modelos Eloquent y sus relaciones cargadas se serializarán y deserializarán de manera fluida cuando el trabajo esté en procesamiento.
Si tu trabajo en cola acepta un modelo Eloquent en su constructor, solo se serializará el identificador del modelo en la cola. Cuando el trabajo sea realmente manejado, el sistema de cola volverá a recuperar automáticamente la instancia completa del modelo y sus relaciones cargadas desde la base de datos. Este enfoque para la serialización de modelos permite que se envíen cargas de trabajo mucho más pequeñas a tu driver de cola.

<a name="handle-method-dependency-injection"></a>
#### Inyección de Dependencias del Método `handle`

El método `handle` se invoca cuando el trabajo es procesado por la cola. Ten en cuenta que podemos indicar explícitamente las dependencias en el método `handle` del trabajo. El [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel inyecta automáticamente estas dependencias.
Si deseas tener control total sobre cómo el contenedor inyecta dependencias en el método `handle`, puedes usar el método `bindMethod` del contenedor. El método `bindMethod` acepta un callback que recibe el trabajo y el contenedor. Dentro del callback, puedes invocar el método `handle` como desees. Típicamente, debes llamar a este método desde el método `boot` de tu `App\Providers\AppServiceProvider` [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers):


```php
use App\Jobs\ProcessPodcast;
use App\Services\AudioProcessor;
use Illuminate\Contracts\Foundation\Application;

$this->app->bindMethod([ProcessPodcast::class, 'handle'], function (ProcessPodcast $job, Application $app) {
    return $job->handle($app->make(AudioProcessor::class));
});
```
> [!WARNING]
Los datos binarios, como el contenido de imágenes en bruto, deben pasarse a través de la función `base64_encode` antes de ser enviados a un trabajo en cola. De lo contrario, el trabajo puede no serializarse correctamente a JSON al ser colocado en la cola.

<a name="handling-relationships"></a>
#### Relaciones en Cola

Debido a que todas las relaciones de modelo Eloquent cargadas también se serializan cuando se pone un trabajo en cola, la cadena del trabajo serializado a veces puede volverse bastante grande. Además, cuando se deserializa un trabajo y se vuelven a recuperar las relaciones del modelo desde la base de datos, se recuperarán en su totalidad. Cualquier restricción de relación previa que se aplicó antes de que el modelo se serializara durante el proceso de encolamiento del trabajo no se aplicará cuando se deserialice el trabajo. Por lo tanto, si deseas trabajar con un subconjunto de una relación dada, debes restringir nuevamente esa relación dentro de tu trabajo en cola.
O, para evitar que las relaciones sean serializadas, puedes llamar al método `withoutRelations` en el modelo al establecer un valor de propiedad. Este método devolverá una instancia del modelo sin sus relaciones cargadas:


```php
/**
 * Create a new job instance.
 */
public function __construct(Podcast $podcast)
{
    $this->podcast = $podcast->withoutRelations();
}
```
Si estás utilizando la promoción de propiedades en el constructor de PHP y deseas indicar que un modelo Eloquent no debe tener sus relaciones serializadas, puedes usar el atributo `WithoutRelations`:


```php
use Illuminate\Queue\Attributes\WithoutRelations;

/**
 * Create a new job instance.
 */
public function __construct(
    #[WithoutRelations]
    public Podcast $podcast
) {
}
```
Si un trabajo recibe una colección o array de modelos Eloquent en lugar de un solo modelo, los modelos dentro de esa colección no tendrán sus relaciones restauradas cuando el trabajo sea deserializado y ejecutado. Esto es para evitar un uso excesivo de recursos en trabajos que manejan grandes cantidades de modelos.

<a name="unique-jobs"></a>
### Trabajos Únicos

> [!WARNING]
Los trabajos únicos requieren un driver de caché que soporte [bloqueos](/docs/%7B%7Bversion%7D%7D/cache#atomic-locks). Actualmente, los drivers de caché `memcached`, `redis`, `dynamodb`, `database`, `file` y `array` soportan bloqueos atómicos. Además, las restricciones de trabajo único no se aplican a trabajos dentro de lotes.
A veces, es posible que desees asegurarte de que solo una instancia de un trabajo específico esté en la cola en cualquier momento. Puedes hacer esto implementando la interfaz `ShouldBeUnique` en tu clase de trabajo. Esta interfaz no requiere que definas ningún método adicional en tu clase:


```
<?php

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldBeUnique;

class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
{
    ...
}
```
En el ejemplo anterior, el trabajo `UpdateSearchIndex` es único. Así que el trabajo no se despachará si otra instancia del trabajo ya está en la cola y no ha terminado de procesarse.
En ciertos casos, es posible que desees definir una "clave" específica que haga que el trabajo sea único o que desees especificar un tiempo de espera más allá del cual el trabajo ya no se considera único. Para lograr esto, puedes definir las propiedades o métodos `uniqueId` y `uniqueFor` en tu clase de trabajo:


```php
<?php

use App\Models\Product;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldBeUnique;

class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
{
    /**
     * The product instance.
     *
     * @var \App\Product
     */
    public $product;

    /**
     * The number of seconds after which the job's unique lock will be released.
     *
     * @var int
     */
    public $uniqueFor = 3600;

    /**
     * Get the unique ID for the job.
     */
    public function uniqueId(): string
    {
        return $this->product->id;
    }
}
```
En el ejemplo anterior, el trabajo `UpdateSearchIndex` es único por un ID de producto. Así que, cualquier nuevo despacho del trabajo con el mismo ID de producto será ignorado hasta que el trabajo existente haya completado su procesamiento. Además, si el trabajo existente no se procesa dentro de una hora, el bloqueo único será liberado y otro trabajo con la misma clave única puede ser despachado a la cola.
> [!WARNING]
Si tu aplicación despacha trabajos desde múltiples servidores web o contenedores, debes asegurarte de que todos tus servidores estén comunicándose con el mismo servidor de caché central para que Laravel pueda determinar con precisión si un trabajo es único.

<a name="keeping-jobs-unique-until-processing-begins"></a>
#### Manteniendo los Trabajos Únicos Hasta Que Comience el Procesamiento

Por defecto, los trabajos únicos se "desbloquean" después de que un trabajo completa su procesamiento o falla en todos sus intentos de reintento. Sin embargo, puede haber situaciones en las que desees que tu trabajo se desbloquee inmediatamente antes de ser procesado. Para lograr esto, tu trabajo debe implementar el contrato `ShouldBeUniqueUntilProcessing` en lugar del contrato `ShouldBeUnique`:


```php
<?php

use App\Models\Product;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Contracts\Queue\ShouldBeUniqueUntilProcessing;

class UpdateSearchIndex implements ShouldQueue, ShouldBeUniqueUntilProcessing
{
    // ...
}
```

<a name="unique-job-locks"></a>
#### Bloqueos de Trabajo Únicos

Detrás de escena, cuando se despacha un trabajo `ShouldBeUnique`, Laravel intenta adquirir un [lock](/docs/%7B%7Bversion%7D%7D/cache#atomic-locks) con la clave `uniqueId`. Si no se adquiere el lock, el trabajo no se despacha. Este lock se libera cuando el trabajo completa el procesamiento o falla en todos sus intentos de reintento. Por defecto, Laravel utilizará el driver de caché predeterminado para obtener este lock. Sin embargo, si deseas usar otro driver para adquirir el lock, puedes definir un método `uniqueVia` que devuelva el driver de caché que se debe usar:


```php
use Illuminate\Contracts\Cache\Repository;
use Illuminate\Support\Facades\Cache;

class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
{
    ...

    /**
     * Get the cache driver for the unique job lock.
     */
    public function uniqueVia(): Repository
    {
        return Cache::driver('redis');
    }
}
```
> [!NOTE]
Si solo necesitas limitar el procesamiento concurrente de un trabajo, utiliza el middleware de trabajo [`WithoutOverlapping`](/docs/%7B%7Bversion%7D%7D/queues#preventing-job-overlaps) en su lugar.

<a name="encrypted-jobs"></a>
### Trabajos Encriptados

Laravel te permite asegurar la privacidad e integridad de los datos de un trabajo a través de [encriptación](/docs/%7B%7Bversion%7D%7D/encryption). Para comenzar, simplemente añade la interfaz `ShouldBeEncrypted` a la clase del trabajo. Una vez que esta interfaz haya sido añadida a la clase, Laravel encriptará automáticamente tu trabajo antes de enviarlo a una cola:


```php
<?php

use Illuminate\Contracts\Queue\ShouldBeEncrypted;
use Illuminate\Contracts\Queue\ShouldQueue;

class UpdateSearchIndex implements ShouldQueue, ShouldBeEncrypted
{
    // ...
}
```

<a name="job-middleware"></a>
## Middleware de Trabajo

El middleware de trabajos te permite envolver lógica personalizada alrededor de la ejecución de trabajos en cola, reduciendo el código repetitivo en los propios trabajos. Por ejemplo, considera el siguiente método `handle` que aprovecha las características de limitación de tasa de Redis de Laravel para permitir que solo un trabajo se procese cada cinco segundos:


```php
use Illuminate\Support\Facades\Redis;

/**
 * Execute the job.
 */
public function handle(): void
{
    Redis::throttle('key')->block(0)->allow(1)->every(5)->then(function () {
        info('Lock obtained...');

        // Handle job...
    }, function () {
        // Could not obtain lock...

        return $this->release(5);
    });
}
```
Aunque este código es válido, la implementación del método `handle` se vuelve ruidosa ya que está cluttered con la lógica de limitación de tasa de Redis. Además, esta lógica de limitación de tasa debe ser duplicada para cualquier otro trabajo que queramos limitar.
En lugar de limitar la tasa en el método handle, podríamos definir un middleware de trabajo que maneje la limitación de tasa. Laravel no tiene una ubicación predeterminada para el middleware de trabajo, así que puedes colocar el middleware de trabajo en cualquier parte de tu aplicación. En este ejemplo, colocaremos el middleware en un directorio `app/Jobs/Middleware`:


```php
<?php

namespace App\Jobs\Middleware;

use Closure;
use Illuminate\Support\Facades\Redis;

class RateLimited
{
    /**
     * Process the queued job.
     *
     * @param  \Closure(object): void  $next
     */
    public function handle(object $job, Closure $next): void
    {
        Redis::throttle('key')
                ->block(0)->allow(1)->every(5)
                ->then(function () use ($job, $next) {
                    // Lock obtained...

                    $next($job);
                }, function () use ($job) {
                    // Could not obtain lock...

                    $job->release(5);
                });
    }
}
```
Como puedes ver, al igual que el [middleware de ruta](/docs/%7B%7Bversion%7D%7D/middleware), el middleware de trabajo recibe el trabajo que se está procesando y un callback que debe invocarse para continuar con el procesamiento del trabajo.
Después de crear el middleware de trabajos, pueden ser adjuntos a un trabajo devolviéndolos desde el método `middleware` del trabajo. Este método no existe en trabajos generados por el comando Artisan `make:job`, así que necesitarás añadirlo manualmente a tu clase de trabajo:


```php
use App\Jobs\Middleware\RateLimited;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [new RateLimited];
}
```
> [!NOTA]
El middleware de trabajo también se puede asignar a oyentes de eventos encolables, mailables y notificaciones.

<a name="rate-limiting"></a>
### Limitación de tasa

Aunque acabamos de demostrar cómo escribir tu propio middleware de trabajos de limitación de tasa, Laravel incluye en realidad un middleware de limitación de tasa que puedes utilizar para limitar la tasa de trabajos. Al igual que los [limitadores de tasa de ruta](/docs/%7B%7Bversion%7D%7D/routing#defining-rate-limiters), los limitadores de tasa de trabajos se definen utilizando el método `for` de la facade `RateLimiter`.
Por ejemplo, es posible que desees permitir que los usuarios respalden sus datos una vez por hora, mientras que no impongas tal límite a los clientes premium. Para lograr esto, puedes definir un `RateLimiter` en el método `boot` de tu `AppServiceProvider`:


```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    RateLimiter::for('backups', function (object $job) {
        return $job->user->vipCustomer()
                    ? Limit::none()
                    : Limit::perHour(1)->by($job->user->id);
    });
}
```
En el ejemplo anterior, definimos un límite de tasa por hora; sin embargo, puedes definir fácilmente un límite de tasa basado en minutos utilizando el método `perMinute`. Además, puedes pasar cualquier valor que desees al método `by` del límite de tasa; sin embargo, este valor se utiliza con mayor frecuencia para segmentar los límites de tasa por cliente:


```php
return Limit::perMinute(50)->by($job->user->id);
```
Una vez que hayas definido tu límite de tasa, puedes adjuntar el limitador de tasa a tu trabajo utilizando el middleware `Illuminate\Queue\Middleware\RateLimited`. Cada vez que el trabajo exceda el límite de tasa, este middleware volverá a liberar el trabajo en la cola con un retraso adecuado según la duración del límite de tasa.


```php
use Illuminate\Queue\Middleware\RateLimited;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [new RateLimited('backups')];
}
```
Reiniciar un trabajo con limitación de tasa en la cola aún incrementará el número total de `intentos` del trabajo. Puede que desees ajustar tus propiedades `tries` y `maxExceptions` en tu clase de trabajo en consecuencia. O, puede que desees usar el método [`retryUntil`](#time-based-attempts) para definir la cantidad de tiempo hasta que el trabajo no deba intentarse más.
Si no deseas que un trabajo se reintente cuando está limitado por la tasa, puedes usar el método `dontRelease`:


```php
/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new RateLimited('backups'))->dontRelease()];
}
```
> [!NOTA]
Si estás utilizando Redis, puedes usar el middleware `Illuminate\Queue\Middleware\RateLimitedWithRedis`, que está optimizado para Redis y es más eficiente que el middleware básico de limitación de tasa.

<a name="preventing-job-overlaps"></a>
### Previniendo la Superposición de Trabajos

Laravel incluye un middleware `Illuminate\Queue\Middleware\WithoutOverlapping` que te permite prevenir superposiciones de trabajos basados en una clave arbitraria. Esto puede ser útil cuando un trabajo en cola está modificando un recurso que solo debe ser modificado por un trabajo a la vez.
Por ejemplo, imaginemos que tienes un trabajo en cola que actualiza el puntaje de crédito de un usuario y deseas prevenir la superposición de trabajos de actualización de puntaje de crédito para el mismo ID de usuario. Para lograr esto, puedes devolver el middleware `WithoutOverlapping` desde el método `middleware` de tu trabajo:


```php
use Illuminate\Queue\Middleware\WithoutOverlapping;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [new WithoutOverlapping($this->user->id)];
}
```
Cualquier trabajo superpuesto del mismo tipo será liberado de nuevo a la cola. También puedes especificar la cantidad de segundos que deben transcurrir antes de que se intente el trabajo liberado nuevamente:


```php
/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new WithoutOverlapping($this->order->id))->releaseAfter(60)];
}
```
Si deseas eliminar inmediatamente cualquier trabajo superpuesto para que no se reintenten, puedes usar el método `dontRelease`:


```php
/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new WithoutOverlapping($this->order->id))->dontRelease()];
}
```
El middleware `WithoutOverlapping` está impulsado por la función de bloqueo atómico de Laravel. A veces, tu trabajo puede fallar inesperadamente o agotar el tiempo de manera que el bloqueo no se libere. Por lo tanto, puedes definir explícitamente un tiempo de expiración de bloqueo utilizando el método `expireAfter`. Por ejemplo, el ejemplo a continuación indicará a Laravel que libere el bloqueo `WithoutOverlapping` tres minutos después de que haya comenzado el procesamiento del trabajo:


```php
/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new WithoutOverlapping($this->order->id))->expireAfter(180)];
}
```
> [!WARNING]
El middleware `WithoutOverlapping` requiere un driver de caché que soporte [bloqueos](/docs/%7B%7Bversion%7D%7D/cache#atomic-locks). Actualmente, los drivers de caché `memcached`, `redis`, `dynamodb`, `database`, `file` y `array` soportan bloqueos atómicos.

<a name="sharing-lock-keys"></a>
#### Compartiendo Claves de Bloqueo entre Clases de Trabajo

Por defecto, el middleware `WithoutOverlapping` solo evitará trabajos superpuestos de la misma clase. Así que, aunque dos clases de trabajo diferentes puedan usar la misma clave de bloqueo, no se les impedirá superponerse. Sin embargo, puedes instruir a Laravel para que aplique la clave entre las clases de trabajo utilizando el método `shared`:


```php
use Illuminate\Queue\Middleware\WithoutOverlapping;

class ProviderIsDown
{
    // ...

    public function middleware(): array
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}

class ProviderIsUp
{
    // ...

    public function middleware(): array
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}

```

<a name="throttling-exceptions"></a>
### Excepciones de Limitación

Laravel incluye un middleware `Illuminate\Queue\Middleware\ThrottlesExceptions` que te permite limitar las excepciones. Una vez que el trabajo lanza un número dado de excepciones, todos los intentos posteriores de ejecutar el trabajo se retrasan hasta que transcurra un intervalo de tiempo específico. Este middleware es particularmente útil para trabajos que interactúan con servicios de terceros que son inestables.
Por ejemplo, imaginemos un trabajo en cola que interactúa con una API de terceros que comienza a lanzar excepciones. Para limitar las excepciones, puedes devolver el middleware `ThrottlesExceptions` desde el método `middleware` de tu trabajo. Típicamente, este middleware debe combinarse con un trabajo que implemente [intentos basados en el tiempo](#time-based-attempts):


```php
use DateTime;
use Illuminate\Queue\Middleware\ThrottlesExceptions;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [new ThrottlesExceptions(10, 5)];
}

/**
 * Determine the time at which the job should timeout.
 */
public function retryUntil(): DateTime
{
    return now()->addMinutes(5);
}
```
El primer argumento del constructor aceptado por el middleware es el número de excepciones que el trabajo puede lanzar antes de ser limitado, mientras que el segundo argumento del constructor es el número de minutos que deben transcurrir antes de que se intente el trabajo nuevamente una vez que ha sido limitado. En el ejemplo de código anterior, si el trabajo lanza 10 excepciones en 5 minutos, esperaremos 5 minutos antes de intentar el trabajo nuevamente.
Cuando un trabajo lanza una excepción pero el umbral de excepción no se ha alcanzado, el trabajo típicamente se reintentará de inmediato. Sin embargo, puedes especificar cuántos minutos debe retrasarse un job llamando al método `backoff` al adjuntar el middleware al trabajo:


```php
use Illuminate\Queue\Middleware\ThrottlesExceptions;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new ThrottlesExceptions(10, 5))->backoff(5)];
}
```
Internamente, este middleware utiliza el sistema de caché de Laravel para implementar el limitador de tasa, y el nombre de la clase del trabajo se utiliza como la "clave" de caché. Puedes sobrescribir esta clave llamando al método `by` al adjuntar el middleware a tu trabajo. Esto puede ser útil si tienes múltiples trabajos interactuando con el mismo servicio de terceros y te gustaría que compartan un "bucket" de limitación común:


```php
use Illuminate\Queue\Middleware\ThrottlesExceptions;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new ThrottlesExceptions(10, 10))->by('key')];
}
```
Por defecto, este middleware limitará cada excepción. Puedes modificar este comportamiento invocando el método `when` al adjuntar el middleware a tu trabajo. La excepción solo se limitará si la función anónima proporcionada al método `when` devuelve `true`:


```php
use Illuminate\Http\Client\HttpClientException;
use Illuminate\Queue\Middleware\ThrottlesExceptions;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new ThrottlesExceptions(10, 10))->when(
        fn (Throwable $throwable) => $throwable instanceof HttpClientException
    )];
}
```
Si deseas que las excepciones limitadas se informen al manejador de excepciones de tu aplicación, puedes hacerlo invocando el método `report` al adjuntar el middleware a tu trabajo. Opcionalmente, puedes proporcionar una función anónima al método `report` y la excepción solo se informará si la función anónima dada devuelve `true`:


```php
use Illuminate\Http\Client\HttpClientException;
use Illuminate\Queue\Middleware\ThrottlesExceptions;

/**
 * Get the middleware the job should pass through.
 *
 * @return array<int, object>
 */
public function middleware(): array
{
    return [(new ThrottlesExceptions(10, 10))->report(
        fn (Throwable $throwable) => $throwable instanceof HttpClientException
    )];
}
```
> [!NOTA]
Si estás utilizando Redis, puedes usar el middleware `Illuminate\Queue\Middleware\ThrottlesExceptionsWithRedis`, que está afinado para Redis y es más eficiente que el middleware básico de limitación de excepciones.

<a name="dispatching-jobs"></a>
## Despachando Trabajos

Una vez que hayas escrito tu clase de trabajo, puedes despacharla utilizando el método `dispatch` en el propio trabajo. Los argumentos pasados al método `dispatch` se darán al constructor del trabajo:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessPodcast;
use App\Models\Podcast;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PodcastController extends Controller
{
    /**
     * Store a new podcast.
     */
    public function store(Request $request): RedirectResponse
    {
        $podcast = Podcast::create(/* ... */);

        // ...

        ProcessPodcast::dispatch($podcast);

        return redirect('/podcasts');
    }
}
```
Si deseas despachar un trabajo de manera condicional, puedes usar los métodos `dispatchIf` y `dispatchUnless`:


```php
ProcessPodcast::dispatchIf($accountActive, $podcast);

ProcessPodcast::dispatchUnless($accountSuspended, $podcast);
```
En las nuevas aplicaciones Laravel, el driver `sync` es el driver de cola predeterminado. Este driver ejecuta trabajos de forma sincrónica en el primer plano de la solicitud actual, lo que a menudo es conveniente durante el desarrollo local. Si deseas comenzar a poner trabajos en cola para el procesamiento en segundo plano, puedes especificar un driver de cola diferente en el archivo de configuración `config/queue.php` de tu aplicación.

<a name="delayed-dispatching"></a>
### Despacho Retardado

Si deseas especificar que un trabajo no debe estar disponible de inmediato para su procesamiento por un trabajador de cola, puedes usar el método `delay` al despachar el trabajo. Por ejemplo, especifiquemos que un trabajo no debe estar disponible para su procesamiento hasta 10 minutos después de haber sido despachado:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessPodcast;
use App\Models\Podcast;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PodcastController extends Controller
{
    /**
     * Store a new podcast.
     */
    public function store(Request $request): RedirectResponse
    {
        $podcast = Podcast::create(/* ... */);

        // ...

        ProcessPodcast::dispatch($podcast)
                    ->delay(now()->addMinutes(10));

        return redirect('/podcasts');
    }
}
```
> [!WARNING]
El servicio de cola Amazon SQS tiene un tiempo de demora máximo de 15 minutos.

<a name="dispatching-after-the-response-is-sent-to-browser"></a>
#### Despachando Después de que la Respuesta se Envía al Navegador

Alternativamente, el método `dispatchAfterResponse` retrasa el despacho de un trabajo hasta después de que se envíe la respuesta HTTP al navegador del usuario si su servidor web está utilizando FastCGI. Esto permitirá que el usuario comience a usar la aplicación, aunque un trabajo en cola aún esté en ejecución. Esto generalmente solo debe usarse para trabajos que tardan alrededor de un segundo, como el envío de un correo electrónico. Dado que se procesan dentro de la solicitud HTTP actual, los trabajos despachados de esta manera no requieren que un trabajador de cola esté en ejecución para que se procesen:


```php
use App\Jobs\SendNotification;

SendNotification::dispatchAfterResponse();
```
También puedes `despachar` una `función anónima` y encadenar el método `afterResponse` al helper `dispatch` para ejecutar una `función anónima` después de que se haya enviado la respuesta HTTP al navegador:


```php
use App\Mail\WelcomeMessage;
use Illuminate\Support\Facades\Mail;

dispatch(function () {
    Mail::to('taylor@example.com')->send(new WelcomeMessage);
})->afterResponse();
```

<a name="synchronous-dispatching"></a>
### Despacho Sincrónico

Si deseas despachar un trabajo de inmediato (de forma sincrónica), puedes usar el método `dispatchSync`. Al utilizar este método, el trabajo no se pondrá en cola y se ejecutará de inmediato dentro del proceso actual:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessPodcast;
use App\Models\Podcast;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PodcastController extends Controller
{
    /**
     * Store a new podcast.
     */
    public function store(Request $request): RedirectResponse
    {
        $podcast = Podcast::create(/* ... */);

        // Create podcast...

        ProcessPodcast::dispatchSync($podcast);

        return redirect('/podcasts');
    }
}
```

<a name="jobs-and-database-transactions"></a>
### Trabajos y Transacciones de Base de datos

Si bien está perfectamente bien despachar trabajos dentro de transacciones de base de datos, debes tener especial cuidado para asegurarte de que tu trabajo podrá ejecutarse con éxito. Al despachar un trabajo dentro de una transacción, es posible que el trabajo sea procesado por un trabajador antes de que la transacción principal se haya comprometido. Cuando esto ocurre, cualquier actualización que hayas realizado en modelos o registros de base de datos durante la(s) transacción(es) de base de datos puede que aún no esté reflejada en la base de datos. Además, cualquier modelo o registro de base de datos creado dentro de la(s) transacción(es) puede que no exista en la base de datos.
Afortunadamente, Laravel ofrece varios métodos para abordar este problema. Primero, puedes establecer la opción de conexión `after_commit` en el array de configuración de tu conexión de cola:


```php
'redis' => [
    'driver' => 'redis',
    // ...
    'after_commit' => true,
],
```
Cuando la opción `after_commit` es `true`, puedes despachar trabajos dentro de transacciones de base de datos; sin embargo, Laravel esperará hasta que se hayan confirmado las transacciones de base de datos padres abiertas antes de despachar realmente el trabajo. Por supuesto, si no hay transacciones de base de datos actualmente abiertas, el trabajo se despachará de inmediato.
Si una transacción se deshace debido a una excepción que ocurre durante la transacción, los trabajos que se despacharon durante esa transacción serán descartados.
> [!NOTE]
Configurar la opción de configuración `after_commit` en `true` también hará que cualquier listener de eventos en cola, mailables, notificaciones y eventos de transmisión se despachen después de que se hayan confirmado todas las transacciones de base de datos abiertas.

<a name="specifying-commit-dispatch-behavior-inline"></a>
#### Especificando Comportamiento de Despacho de Confirmaciones en Línea

Si no configuras la opción de configuración de conexión de cola `after_commit` a `true`, aún puedes indicar que un trabajo específico debe ser despachado después de que se hayan confirmado todas las transacciones de base de datos abiertas. Para lograr esto, puedes encadenar el método `afterCommit` a tu operación de despachado:


```php
use App\Jobs\ProcessPodcast;

ProcessPodcast::dispatch($podcast)->afterCommit();
```
Del mismo modo, si la opción de configuración `after_commit` está configurada en `true`, puedes indicar que un trabajo específico debe ser despachado inmediatamente sin esperar a que se confirmen las transacciones de base de datos abiertas:


```php
ProcessPodcast::dispatch($podcast)->beforeCommit();
```

<a name="job-chaining"></a>
### Encadenamiento de Trabajos

El encadenamiento de trabajos te permite especificar una lista de trabajos en cola que deben ejecutarse en secuencia después de que el trabajo principal se haya ejecutado con éxito. Si un trabajo en la secuencia falla, el resto de los trabajos no se ejecutarán. Para ejecutar un encadenamiento de trabajos en cola, puedes usar el método `chain` proporcionado por la fachada `Bus`. El bus de comandos de Laravel es un componente de nivel inferior sobre el cual se basa el despacho de trabajos en cola:


```php
use App\Jobs\OptimizePodcast;
use App\Jobs\ProcessPodcast;
use App\Jobs\ReleasePodcast;
use Illuminate\Support\Facades\Bus;

Bus::chain([
    new ProcessPodcast,
    new OptimizePodcast,
    new ReleasePodcast,
])->dispatch();
```
Además de encadenar instancias de clases de trabajo, también puedes encadenar funciones anónimas:


```php
Bus::chain([
    new ProcessPodcast,
    new OptimizePodcast,
    function () {
        Podcast::update(/* ... */);
    },
])->dispatch();
```
> [!WARNING]
Eliminar trabajos utilizando el método `$this->delete()` dentro del trabajo no evitará que se procesen trabajos en cadena. La cadena solo dejará de ejecutarse si un trabajo en la cadena falla.

<a name="chain-connection-queue"></a>
#### Conexión en Cadena y Cola

Si deseas especificar la conexión y la cola que se deben utilizar para los trabajos encadenados, puedes usar los métodos `onConnection` y `onQueue`. Estos métodos especifican la conexión de la cola y el nombre de la cola que se deben usar a menos que el trabajo en cola se asigne explícitamente a una conexión / cola diferente:


```php
Bus::chain([
    new ProcessPodcast,
    new OptimizePodcast,
    new ReleasePodcast,
])->onConnection('redis')->onQueue('podcasts')->dispatch();
```

<a name="adding-jobs-to-the-chain"></a>
#### Agregar Trabajos a la Cadena

Ocasionalmente, es posible que necesites añadir un trabajo al inicio o al final de una cadena de trabajos existente desde otro trabajo en esa cadena. Puedes lograr esto utilizando los métodos `prependToChain` y `appendToChain`:


```php
/**
 * Execute the job.
 */
public function handle(): void
{
    // ...

    // Prepend to the current chain, run job immediately after current job...
    $this->prependToChain(new TranscribePodcast);

    // Append to the current chain, run job at end of chain...
    $this->appendToChain(new TranscribePodcast);
}

```

<a name="chain-failures"></a>
#### Fallos en Cadena

Al encadenar trabajos, puedes usar el método `catch` para especificar una función anónima que se debe invocar si un trabajo dentro de la cadena falla. El callback dado recibirá la instancia `Throwable` que causó la falla del trabajo:


```php
use Illuminate\Support\Facades\Bus;
use Throwable;

Bus::chain([
    new ProcessPodcast,
    new OptimizePodcast,
    new ReleasePodcast,
])->catch(function (Throwable $e) {
    // A job within the chain has failed...
})->dispatch();
```
> [!WARNING]
Dado que los callbacks en cadena se serializan y se ejecutan más tarde mediante la cola de Laravel, no debes usar la variable `$this` dentro de los callbacks en cadena.

<a name="customizing-the-queue-and-connection"></a>
### Personalizando la Cola y la Conexión


<a name="dispatching-to-a-particular-queue"></a>
#### Despachando a una Cola Particular

Al enviar trabajos a diferentes colas, puedes "categorizar" tus trabajos en cola e incluso priorizar cuántos trabajadores asignas a varias colas. Ten en cuenta que esto no envía trabajos a diferentes "conexiones" de cola como se define en tu archivo de configuración de cola, sino solo a colas específicas dentro de una sola conexión. Para especificar la cola, utiliza el método `onQueue` al despachar el trabajo:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessPodcast;
use App\Models\Podcast;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PodcastController extends Controller
{
    /**
     * Store a new podcast.
     */
    public function store(Request $request): RedirectResponse
    {
        $podcast = Podcast::create(/* ... */);

        // Create podcast...

        ProcessPodcast::dispatch($podcast)->onQueue('processing');

        return redirect('/podcasts');
    }
}
```
Alternativamente, puedes especificar la cola del trabajo llamando al método `onQueue` dentro del constructor del trabajo:


```php
<?php

namespace App\Jobs;

 use Illuminate\Contracts\Queue\ShouldQueue;
 use Illuminate\Foundation\Queue\Queueable;

class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        $this->onQueue('processing');
    }
}
```

<a name="dispatching-to-a-particular-connection"></a>
#### Despachando a una Conexión Particular

Si tu aplicación interactúa con múltiples conexiones de cola, puedes especificar a qué conexión enviar un trabajo utilizando el método `onConnection`:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessPodcast;
use App\Models\Podcast;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PodcastController extends Controller
{
    /**
     * Store a new podcast.
     */
    public function store(Request $request): RedirectResponse
    {
        $podcast = Podcast::create(/* ... */);

        // Create podcast...

        ProcessPodcast::dispatch($podcast)->onConnection('sqs');

        return redirect('/podcasts');
    }
}
```
Puedes encadenar los métodos `onConnection` y `onQueue` para especificar la conexión y la cola para un trabajo:


```php
ProcessPodcast::dispatch($podcast)
              ->onConnection('sqs')
              ->onQueue('processing');
```
Alternativamente, puedes especificar la conexión del trabajo llamando al método `onConnection` dentro del constructor del trabajo:


```php
<?php

namespace App\Jobs;

 use Illuminate\Contracts\Queue\ShouldQueue;
 use Illuminate\Foundation\Queue\Queueable;

class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        $this->onConnection('sqs');
    }
}
```

<a name="max-job-attempts-and-timeout"></a>
### Especificando Valores Máximos de Intentos de Trabajo / Tiempo de Espera


<a name="max-attempts"></a>
#### Máximos Intentos

Si uno de tus trabajos en cola está encontrando un error, probablemente no quieras que siga reintentando indefinidamente. Por lo tanto, Laravel proporciona varias maneras de especificar cuántas veces o durante cuánto tiempo se puede intentar un trabajo.
Un enfoque para especificar el número máximo de veces que se puede intentar un trabajo es a través del interruptor `--tries` en la línea de comandos de Artisan. Esto se aplicará a todos los trabajos procesados por el trabajador a menos que el trabajo que se esté procesando especifique cuántas veces se puede intentar:


```shell
php artisan queue:work --tries=3

```
Si un trabajo supera su número máximo de intentos, se considerará un trabajo "fallido". Para obtener más información sobre cómo manejar trabajos fallidos, consulte la [documentación de trabajos fallidos](#dealing-with-failed-jobs). Si se proporciona `--tries=0` al comando `queue:work`, el trabajo se volverá a intentar indefinidamente.
Puedes adoptar un enfoque más granular definiendo el número máximo de veces que se puede intentar un trabajo en la clase del trabajo misma. Si se especifica el número máximo de intentos en el trabajo, tendrá prioridad sobre el valor `--tries` proporcionado en la línea de comando:


```php
<?php

namespace App\Jobs;

class ProcessPodcast implements ShouldQueue
{
    /**
     * The number of times the job may be attempted.
     *
     * @var int
     */
    public $tries = 5;
}
```
Si necesitas un control dinámico sobre los máximos intentos de un trabajo particular, puedes definir un método `tries` en el trabajo:


```php
/**
 * Determine number of times the job may be attempted.
 */
public function tries(): int
{
    return 5;
}
```

<a name="time-based-attempts"></a>
#### Intentos Basados en el Tiempo

Como alternativa a definir cuántas veces se puede intentar un trabajo antes de que falle, puedes definir un momento en el que el trabajo ya no debería ser intentado. Esto permite que un trabajo se intente cualquier número de veces dentro de un período de tiempo dado. Para definir el momento en el que un trabajo ya no debería ser intentado, añade un método `retryUntil` a tu clase de trabajo. Este método debe devolver una instancia de `DateTime`:


```php
use DateTime;

/**
 * Determine the time at which the job should timeout.
 */
public function retryUntil(): DateTime
{
    return now()->addMinutes(10);
}
```
> [!NOTA]
También puedes definir una propiedad `tries` o un método `retryUntil` en tus [escuchadores de eventos en cola](/docs/%7B%7Bversion%7D%7D/events#queued-event-listeners).

<a name="max-exceptions"></a>
#### Max Excepciones

A veces es posible que desees especificar que un trabajo puede intentarse muchas veces, pero debe fallar si se activan los reintentos por un número dado de excepciones no controladas (en lugar de ser liberado directamente por el método `release`). Para lograr esto, puedes definir una propiedad `maxExceptions` en tu clase de trabajo:


```php
<?php

namespace App\Jobs;

use Illuminate\Support\Facades\Redis;

class ProcessPodcast implements ShouldQueue
{
    /**
     * The number of times the job may be attempted.
     *
     * @var int
     */
    public $tries = 25;

    /**
     * The maximum number of unhandled exceptions to allow before failing.
     *
     * @var int
     */
    public $maxExceptions = 3;

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Redis::throttle('key')->allow(10)->every(60)->then(function () {
            // Lock obtained, process the podcast...
        }, function () {
            // Unable to obtain lock...
            return $this->release(10);
        });
    }
}
```
En este ejemplo, el trabajo se libera durante diez segundos si la aplicación no puede obtener un bloqueo de Redis y continuará siendo reintentado hasta 25 veces. Sin embargo, el trabajo fallará si se lanzan tres excepciones no controladas por el trabajo.

<a name="timeout"></a>
#### Tiempo de espera

A menudo, sabes aproximadamente cuánto tiempo esperas que tarden tus trabajos en cola. Por esta razón, Laravel te permite especificar un valor de "timeout". Por defecto, el valor de timeout es de 60 segundos. Si un trabajo está procesándose durante más tiempo del número de segundos especificados por el valor de timeout, el trabajador que procesa el trabajo saldrá con un error. Típicamente, el trabajador será reiniciado automáticamente por un [gestor de procesos configurado en tu servidor](#supervisor-configuration).
El número máximo de segundos que pueden ejecutarse los trabajos puede especificarse utilizando el switch `--timeout` en la línea de comandos de Artisan:


```shell
php artisan queue:work --timeout=30

```
Si el trabajo supera sus intentos máximos al agotar el tiempo de manera continua, será marcado como fallido.
También puedes definir el número máximo de segundos que se debe permitir que un trabajo se ejecute en la propia clase del trabajo. Si el tiempo de espera se especifica en el trabajo, tendrá prioridad sobre cualquier tiempo de espera especificado en la línea de comandos:


```php
<?php

namespace App\Jobs;

class ProcessPodcast implements ShouldQueue
{
    /**
     * The number of seconds the job can run before timing out.
     *
     * @var int
     */
    public $timeout = 120;
}
```
A veces, procesos de bloqueo de IO como sockets o conexiones HTTP salientes pueden no respetar tu tiempo de espera especificado. Por lo tanto, al utilizar estas características, siempre debes intentar especificar un tiempo de espera utilizando sus APIs también. Por ejemplo, al usar Guzzle, siempre debes especificar un valor de tiempo de espera de conexión y de solicitud.
> [!WARNING]
La extensión `pcntl` de PHP debe estar instalada para poder especificar tiempos de espera de trabajos. Además, el valor de "timeout" de un trabajo siempre debe ser menor que su valor de ["retry after"](#job-expiration). De lo contrario, el trabajo puede ser reintentado antes de haber terminado realmente su ejecución o haber agotado el tiempo.

<a name="failing-on-timeout"></a>
#### Falla por tiempo de espera

Si deseas indicar que un trabajo debe ser marcado como [fallido](#dealing-with-failed-jobs) en caso de tiempo de espera, puedes definir la propiedad `$failOnTimeout` en la clase del trabajo:


```php
/**
 * Indicate if the job should be marked as failed on timeout.
 *
 * @var bool
 */
public $failOnTimeout = true;

```

<a name="error-handling"></a>
### Manejo de Errores

Si se lanza una excepción mientras se procesa el trabajo, el trabajo se liberará automáticamente de nuevo en la cola para que se pueda intentar nuevamente. El trabajo seguirá siendo liberado hasta que se haya intentado el número máximo de veces permitido por su aplicación. El número máximo de intentos se define por el switch `--tries` utilizado en el comando Artisan `queue:work`. Alternativamente, el número máximo de intentos puede definirse en la propia clase del trabajo. Se pueden encontrar más detalles sobre cómo ejecutar el trabajador de la cola [a continuación](#running-the-queue-worker).

<a name="manually-releasing-a-job"></a>
#### Liberando un Trabajo Manualmente

A veces es posible que desees liberar manualmente un trabajo de nuevo en la cola para que se intente nuevamente en un momento posterior. Puedes lograr esto llamando al método `release`:


```php
/**
 * Execute the job.
 */
public function handle(): void
{
    // ...

    $this->release();
}
```
Por defecto, el método `release` devolverá el trabajo a la cola para su procesamiento inmediato. Sin embargo, puedes instruir a la cola para que no haga el trabajo disponible para procesamiento hasta que haya transcurrido un número dado de segundos pasando un entero o una instancia de fecha al método `release`:


```php
$this->release(10);

$this->release(now()->addSeconds(10));
```

<a name="manually-failing-a-job"></a>
#### Fallando un Trabajo Manualmente

Ocasionalmente es posible que necesites marcar un trabajo como "fallido" de forma manual. Para hacerlo, puedes llamar al método `fail`:


```php
/**
 * Execute the job.
 */
public function handle(): void
{
    // ...

    $this->fail();
}
```
Si deseas marcar tu trabajo como fallido debido a una excepción que has atrapado, puedes pasar la excepción al método `fail`. O, para mayor comodidad, puedes pasar un mensaje de error en forma de cadena que se convertirá en una excepción para ti:


```php
$this->fail($exception);

$this->fail('Something went wrong.');
```
> [!NOTE]
Para obtener más información sobre trabajos fallidos, consulta la [documentación sobre cómo tratar con fallos de trabajos](#dealing-with-failed-jobs).

<a name="job-batching"></a>
## Batching de Trabajo

La función de procesamiento por lotes de trabajos de Laravel te permite ejecutar fácilmente un lote de trabajos y luego realizar alguna acción cuando el lote de trabajos haya terminado de ejecutarse. Antes de comenzar, debes crear una migración de base de datos para construir una tabla que contendrá metainformación sobre tus lotes de trabajos, como su porcentaje de finalización. Esta migración puede generarse utilizando el comando Artisan `make:queue-batches-table`:


```shell
php artisan make:queue-batches-table

php artisan migrate

```

<a name="defining-batchable-jobs"></a>
### Definición de Trabajos Acumulables

Para definir un trabajo que se puede agrupar, debes [crear un trabajo en cola](#creating-jobs) como de costumbre; sin embargo, debes añadir el trait `Illuminate\Bus\Batchable` a la clase del trabajo. Este trait proporciona acceso a un método `batch` que se puede usar para recuperar el lote actual en el que se está ejecutando el trabajo:


```php
<?php

namespace App\Jobs;

use Illuminate\Bus\Batchable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ImportCsv implements ShouldQueue
{
    use Batchable, Queueable;

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        if ($this->batch()->cancelled()) {
            // Determine if the batch has been cancelled...

            return;
        }

        // Import a portion of the CSV file...
    }
}
```

<a name="dispatching-batches"></a>
### Despachando Lotes

Para despachar un lote de trabajos, debes usar el método `batch` de la fachada `Bus`. Por supuesto, el uso de lotes es principalmente útil cuando se combina con callbacks de finalización. Así que puedes usar los métodos `then`, `catch` y `finally` para definir callbacks de finalización para el lote. Cada uno de estos callbacks recibirá una instancia de `Illuminate\Bus\Batch` cuando se invoquen. En este ejemplo, imaginaremos que estamos encolando un lote de trabajos que procesan un número dado de filas de un archivo CSV:


```php
use App\Jobs\ImportCsv;
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;
use Throwable;

$batch = Bus::batch([
    new ImportCsv(1, 100),
    new ImportCsv(101, 200),
    new ImportCsv(201, 300),
    new ImportCsv(301, 400),
    new ImportCsv(401, 500),
])->before(function (Batch $batch) {
    // The batch has been created but no jobs have been added...
})->progress(function (Batch $batch) {
    // A single job has completed successfully...
})->then(function (Batch $batch) {
    // All jobs completed successfully...
})->catch(function (Batch $batch, Throwable $e) {
    // First batch job failure detected...
})->finally(function (Batch $batch) {
    // The batch has finished executing...
})->dispatch();

return $batch->id;
```
El ID del lote, que se puede acceder a través de la propiedad `$batch->id`, se puede usar para [consultar el bus de comandos de Laravel](#inspecting-batches) en busca de información sobre el lote después de que ha sido despachado.
> [!WARNING]
Dado que los callbacks por lotes se serializan y se ejecutan en un momento posterior por la cola de Laravel, no debes usar la variable `$this` dentro de los callbacks. Además, dado que los trabajos por lotes están envueltos en transacciones de base de datos, no se deben ejecutar declaraciones de base de datos que desencadenen confirmaciones implícitas dentro de los trabajos.

<a name="naming-batches"></a>
#### Nominando Lotes

Algunas herramientas como Laravel Horizon y Laravel Telescope pueden proporcionar información de depuración más amigable para los lotes si los lotes tienen nombres. Para asignar un nombre arbitrario a un lote, puedes llamar al método `name` mientras defines el lote:


```php
$batch = Bus::batch([
    // ...
])->then(function (Batch $batch) {
    // All jobs completed successfully...
})->name('Import CSV')->dispatch();
```

<a name="batch-connection-queue"></a>
#### Conexión por Lotes y Cola

Si deseas especificar la conexión y la cola que deben utilizarse para los trabajos por lotes, puedes usar los métodos `onConnection` y `onQueue`. Todos los trabajos por lotes deben ejecutarse dentro de la misma conexión y cola:


```php
$batch = Bus::batch([
    // ...
])->then(function (Batch $batch) {
    // All jobs completed successfully...
})->onConnection('redis')->onQueue('imports')->dispatch();
```

<a name="chains-and-batches"></a>
### Cadenas y Lotes

Puedes definir un conjunto de [jobs encadenados](#job-chaining) dentro de un lote colocando los trabajos encadenados en un array. Por ejemplo, podemos ejecutar dos cadenas de trabajos en paralelo y ejecutar un callback cuando ambas cadenas de trabajos hayan terminado de procesarse:


```php
use App\Jobs\ReleasePodcast;
use App\Jobs\SendPodcastReleaseNotification;
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;

Bus::batch([
    [
        new ReleasePodcast(1),
        new SendPodcastReleaseNotification(1),
    ],
    [
        new ReleasePodcast(2),
        new SendPodcastReleaseNotification(2),
    ],
])->then(function (Batch $batch) {
    // ...
})->dispatch();
```
Por el contrario, puedes ejecutar lotes de trabajos dentro de una [cadena](#job-chaining) definiendo lotes dentro de la cadena. Por ejemplo, podrías ejecutar primero un lote de trabajos para liberar múltiples pódcast y luego un lote de trabajos para enviar las notificaciones de liberación:


```php
use App\Jobs\FlushPodcastCache;
use App\Jobs\ReleasePodcast;
use App\Jobs\SendPodcastReleaseNotification;
use Illuminate\Support\Facades\Bus;

Bus::chain([
    new FlushPodcastCache,
    Bus::batch([
        new ReleasePodcast(1),
        new ReleasePodcast(2),
    ]),
    Bus::batch([
        new SendPodcastReleaseNotification(1),
        new SendPodcastReleaseNotification(2),
    ]),
])->dispatch();
```

<a name="adding-jobs-to-batches"></a>
### Agregar Trabajos a Lotes

A veces puede ser útil añadir trabajos adicionales a un lote desde dentro de un trabajo en lote. Este patrón puede ser útil cuando necesitas agrupar miles de trabajos que pueden tardar demasiado en despachar durante una solicitud web. Así que, en su lugar, es posible que desees despachar un lote inicial de trabajos de "carga" que hidraten el lote con aún más trabajos:


```php
$batch = Bus::batch([
    new LoadImportBatch,
    new LoadImportBatch,
    new LoadImportBatch,
])->then(function (Batch $batch) {
    // All jobs completed successfully...
})->name('Import Contacts')->dispatch();
```
En este ejemplo, utilizaremos el trabajo `LoadImportBatch` para llenar el lote con trabajos adicionales. Para lograr esto, podemos usar el método `add` en la instancia del lote que se puede acceder a través del método `batch` del trabajo:


```php
use App\Jobs\ImportContacts;
use Illuminate\Support\Collection;

/**
 * Execute the job.
 */
public function handle(): void
{
    if ($this->batch()->cancelled()) {
        return;
    }

    $this->batch()->add(Collection::times(1000, function () {
        return new ImportContacts;
    }));
}
```
> [!WARNING]
Solo puedes añadir trabajos a un lote desde dentro de un trabajo que pertenezca al mismo lote.

<a name="inspecting-batches"></a>
### Inspeccionando Lotes

La instancia de `Illuminate\Bus\Batch` que se proporciona a los callbacks de finalización de lotes tiene una variedad de propiedades y métodos para ayudarte a interactuar e inspeccionar un lote dado de trabajos:


```php
// The UUID of the batch...
$batch->id;

// The name of the batch (if applicable)...
$batch->name;

// The number of jobs assigned to the batch...
$batch->totalJobs;

// The number of jobs that have not been processed by the queue...
$batch->pendingJobs;

// The number of jobs that have failed...
$batch->failedJobs;

// The number of jobs that have been processed thus far...
$batch->processedJobs();

// The completion percentage of the batch (0-100)...
$batch->progress();

// Indicates if the batch has finished executing...
$batch->finished();

// Cancel the execution of the batch...
$batch->cancel();

// Indicates if the batch has been cancelled...
$batch->cancelled();
```

<a name="returning-batches-from-routes"></a>
#### Devolviendo Lotes Desde Rutas

Todas las instancias de `Illuminate\Bus\Batch` son serializables a JSON, lo que significa que puedes devolverlas directamente desde una de las rutas de tu aplicación para recuperar una carga útil JSON que contenga información sobre el lote, incluida su progresión de finalización. Esto facilita la visualización de información sobre el progreso de finalización del lote en la interfaz de usuario de tu aplicación.
Para recuperar un lote por su ID, puedes usar el método `findBatch` de la fachada `Bus`:


```php
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Route;

Route::get('/batch/{batchId}', function (string $batchId) {
    return Bus::findBatch($batchId);
});
```

<a name="cancelling-batches"></a>
### Cancelando Lotes

A veces es posible que necesites cancelar la ejecución de un lote dado. Esto se puede lograr llamando al método `cancel` en la instancia de `Illuminate\Bus\Batch`:


```php
/**
 * Execute the job.
 */
public function handle(): void
{
    if ($this->user->exceedsImportLimit()) {
        return $this->batch()->cancel();
    }

    if ($this->batch()->cancelled()) {
        return;
    }
}
```
Como habrás notado en los ejemplos anteriores, los trabajos en lotes típicamente deben determinar si su lote correspondiente ha sido cancelado antes de continuar con la ejecución. Sin embargo, por conveniencia, puedes asignar el middleware `SkipIfBatchCancelled` [middleware](#job-middleware) al trabajo en su lugar. Como indica su nombre, este middleware instruirá a Laravel a no procesar el trabajo si su lote correspondiente ha sido cancelado:


```php
use Illuminate\Queue\Middleware\SkipIfBatchCancelled;

/**
 * Get the middleware the job should pass through.
 */
public function middleware(): array
{
    return [new SkipIfBatchCancelled];
}
```

<a name="batch-failures"></a>
### Fallos por Lotes

Cuando un trabajo por lotes falla, el callback `catch` (si está asignado) se invocará. Este callback solo se invoca para el primer trabajo que falla dentro del lote.

<a name="allowing-failures"></a>
#### Permitiendo Fallos

Cuando un trabajo dentro de un lote falla, Laravel marcará automáticamente el lote como "cancelado". Si lo deseas, puedes desactivar este comportamiento para que un fallo en un trabajo no marque automáticamente el lote como cancelado. Esto se puede lograr llamando al método `allowFailures` mientras se despacha el lote:


```php
$batch = Bus::batch([
    // ...
])->then(function (Batch $batch) {
    // All jobs completed successfully...
})->allowFailures()->dispatch();
```

<a name="retrying-failed-batch-jobs"></a>
#### Reintentando Trabajos por Lote Fallidos

Por conveniencia, Laravel ofrece un comando Artisan `queue:retry-batch` que te permite reintentar fácilmente todos los trabajos fallidos de un batch dado. El comando `queue:retry-batch` acepta el UUID del batch cuyos trabajos fallidos deben ser reintentados:


```shell
php artisan queue:retry-batch 32dbc76c-4f82-4749-b610-a639fe0099b5

```

<a name="pruning-batches"></a>
### Eliminando Lotes

Sin eliminación, la tabla `job_batches` puede acumular registros muy rápidamente. Para mitigar esto, debes [programar](/docs/%7B%7Bversion%7D%7D/scheduling) el comando Artisan `queue:prune-batches` para que se ejecute a diario:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('queue:prune-batches')->daily();
```
Por defecto, todos los lotes finalizados que tienen más de 24 horas serán eliminados. Puedes usar la opción `hours` al llamar al comando para determinar cuánto tiempo retener los datos del lote. Por ejemplo, el siguiente comando eliminará todos los lotes que finalizaron hace más de 48 horas:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('queue:prune-batches --hours=48')->daily();
```
A veces, tu tabla `jobs_batches` puede acumular registros de lotes para lotes que nunca se completaron con éxito, como lotes donde un trabajo falló y ese trabajo nunca se volvió a intentar con éxito. Puedes instruir al comando `queue:prune-batches` para que elimine estos registros de lotes no terminados utilizando la opción `unfinished`:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('queue:prune-batches --hours=48 --unfinished=72')->daily();
```
Del mismo modo, tu tabla `jobs_batches` también puede acumular registros de lotes para lotes cancelados. Puedes instruir el comando `queue:prune-batches` para que elimine estos registros de lotes cancelados utilizando la opción `cancelled`:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('queue:prune-batches --hours=48 --cancelled=72')->daily();
```

<a name="storing-batches-in-dynamodb"></a>
### Almacenando Lotes en DynamoDB

Laravel también ofrece soporte para almacenar información meta de lotes en [DynamoDB](https://aws.amazon.com/dynamodb) en lugar de una base de datos relacional. Sin embargo, necesitarás crear manualmente una tabla de DynamoDB para almacenar todos los registros del lote.
Normalmente, esta tabla debería llamarse `job_batches`, pero debes nombrar la tabla en función del valor de la configuración `queue.batching.table` dentro del archivo de configuración `queue` de tu aplicación.

<a name="dynamodb-batch-table-configuration"></a>
#### Configuración de la Tabla Batch de DynamoDB

La tabla `job_batches` debe tener una clave de partición primaria de tipo string llamada `application` y una clave de ordenación primaria de tipo string llamada `id`. La porción `application` de la clave contendrá el nombre de tu aplicación tal como se define en el valor de configuración `name` dentro del archivo de configuración `app` de tu aplicación. Dado que el nombre de la aplicación es parte de la clave de la tabla DynamoDB, puedes usar la misma tabla para almacenar lotes de trabajos para múltiples aplicaciones Laravel.
Además, puedes definir el atributo `ttl` para tu tabla si deseas aprovechar el [purgado automático por lotes](#pruning-batches-in-dynamodb).

<a name="dynamodb-configuration"></a>
#### Configuración de DynamoDB

A continuación, instala el SDK de AWS para que tu aplicación Laravel pueda comunicarse con Amazon DynamoDB:
Luego, establece el valor de la opción de configuración `queue.batching.driver` en `dynamodb`. Además, deberías definir las opciones de configuración `key`, `secret` y `region` dentro del array de configuración `batching`. Estas opciones se utilizarán para autenticarte con AWS. Al usar el driver `dynamodb`, la opción de configuración `queue.batching.database` es innecesaria:


```php
'batching' => [
    'driver' => env('QUEUE_BATCHING_DRIVER', 'dynamodb'),
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    'table' => 'job_batches',
],

```

<a name="pruning-batches-in-dynamodb"></a>
#### Eliminando Lotes en DynamoDB

Al utilizar [DynamoDB](https://aws.amazon.com/dynamodb) para almacenar información de lotes de trabajos, los comandos de poda típicos que se usan para podar lotes almacenados en una base de datos relacional no funcionarán. En su lugar, puedes utilizar la [funcionalidad TTL nativa de DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html) para eliminar automáticamente los registros de lotes antiguos.
Si definiste tu tabla DynamoDB con un atributo `ttl`, puedes definir parámetros de configuración para instruir a Laravel sobre cómo eliminar registros por lotes. El valor de configuración `queue.batching.ttl_attribute` define el nombre del atributo que contiene el TTL, mientras que el valor de configuración `queue.batching.ttl` define el número de segundos después de los cuales un registro por lote puede ser eliminado de la tabla DynamoDB, en relación con la última vez que se actualizó el registro:


```php
'batching' => [
    'driver' => env('QUEUE_FAILED_DRIVER', 'dynamodb'),
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    'table' => 'job_batches',
    'ttl_attribute' => 'ttl',
    'ttl' => 60 * 60 * 24 * 7, // 7 days...
],

```

<a name="queueing-closures"></a>
## Encolando Funciones Anónimas

En lugar de despachar una clase de trabajo a la cola, también puedes despachar una función anónima. Esto es excelente para tareas rápidas y simples que deben ejecutarse fuera del ciclo de solicitud actual. Al despachar funciones anónimas a la cola, el contenido del código de la función anónima se firma criptográficamente para que no pueda ser modificado en tránsito:


```php
$podcast = App\Podcast::find(1);

dispatch(function () use ($podcast) {
    $podcast->publish();
});
```
Usando el método `catch`, puedes proporcionar una función anónima que se ejecutará si la función anónima en la cola no logra completarse con éxito después de agotar todos los [intentos de reintento configurados](#max-job-attempts-and-timeout) de tu cola:


```php
use Throwable;

dispatch(function () use ($podcast) {
    $podcast->publish();
})->catch(function (Throwable $e) {
    // This job has failed...
});
```
> [!WARNING]
Dado que los callbacks `catch` se serializan y se ejecutan más tarde por la cola de Laravel, no debes usar la variable `$this` dentro de los callbacks `catch`.

<a name="running-the-queue-worker"></a>
## Ejecutando el Trabajador de Cola


<a name="the-queue-work-command"></a>
### El comando `queue:work`

Laravel incluye un comando Artisan que iniciará un trabajador de cola y procesará nuevos trabajos a medida que se añaden a la cola. Puedes ejecutar el trabajador utilizando el comando Artisan `queue:work`. Ten en cuenta que una vez que se haya iniciado el comando `queue:work`, continuará en ejecución hasta que se detenga manualmente o cierres tu terminal:


```shell
php artisan queue:work

```
> [!NOTA]
Para mantener el proceso `queue:work` en funcionamiento de manera permanente en segundo plano, deberías usar un monitor de procesos como [Supervisor](#supervisor-configuration) para asegurar que el trabajador de la cola no deje de funcionar.
Puedes incluir la flag `-v` al invocar el comando `queue:work` si deseas que los IDs de los trabajos procesados se incluyan en la salida del comando:


```shell
php artisan queue:work -v

```
Recuerda que los workers de cola son procesos de larga duración y almacenan el estado de la aplicación iniciada en memoria. Como resultado, no notarán cambios en tu base de código después de haber sido iniciados. Así que, durante tu proceso de despliegue, asegúrate de [reiniciar tus workers de cola](#queue-workers-and-deployment). Además, recuerda que cualquier estado estático creado o modificado por tu aplicación no se restablecerá automáticamente entre trabajos.
Alternativamente, puedes ejecutar el comando `queue:listen`. Al usar el comando `queue:listen`, no tienes que reiniciar manualmente el worker cuando deseas recargar tu código actualizado o restablecer el estado de la aplicación; sin embargo, este comando es significativamente menos eficiente que el comando `queue:work`:


```shell
php artisan queue:listen

```

<a name="running-multiple-queue-workers"></a>
#### Ejecutando Múltiples Trabajadores de Cola

Para asignar múltiples trabajadores a una cola y procesar trabajos de manera concurrente, simplemente debes iniciar múltiples procesos `queue:work`. Esto se puede hacer localmente a través de múltiples pestañas en tu terminal o en producción utilizando la configuración de tu administrador de procesos. [Al usar Supervisor](#supervisor-configuration), puedes usar el valor de configuración `numprocs`.

<a name="specifying-the-connection-queue"></a>
#### Especificando la Conexión y la Cola

También puedes especificar qué conexión de cola debe utilizar el trabajador. El nombre de la conexión que se pasa al comando `work` debe corresponder a una de las conexiones definidas en tu archivo de configuración `config/queue.php`:


```shell
php artisan queue:work redis

```
Por defecto, el comando `queue:work` solo procesa trabajos para la cola predeterminada en una conexión dada. Sin embargo, puedes personalizar aún más tu trabajador de cola procesando solo colas particulares para una conexión dada. Por ejemplo, si todos tus correos electrónicos se procesan en una cola `emails` en tu conexión de cola `redis`, puedes emitir el siguiente comando para iniciar un trabajador que solo procese esa cola:


```shell
php artisan queue:work redis --queue=emails

```

<a name="processing-a-specified-number-of-jobs"></a>
#### Procesando un Número Especificado de Trabajos

La opción `--once` se puede usar para instruir al trabajador a que solo procese un solo trabajo de la cola:


```shell
php artisan queue:work --once

```
La opción `--max-jobs` se puede utilizar para instruir al trabajador a procesar el número dado de trabajos y luego salir. Esta opción puede ser útil cuando se combina con [Supervisor](#supervisor-configuration) para que tus trabajadores se reinicien automáticamente después de procesar un número dado de trabajos, liberando la memoria que pueden haber acumulado:


```shell
php artisan queue:work --max-jobs=1000

```

<a name="processing-all-queued-jobs-then-exiting"></a>
#### Procesando Todos los Trabajos en Cola y Luego Saliendo

La opción `--stop-when-empty` se puede usar para instruir al worker a que procese todos los trabajos y luego salga de manera elegante. Esta opción puede ser útil al procesar colas de Laravel dentro de un contenedor Docker si deseas apagar el contenedor después de que la cola esté vacía:


```shell
php artisan queue:work --stop-when-empty

```

<a name="processing-jobs-for-a-given-number-of-seconds"></a>
#### Procesando Trabajos durante un Número Dado de Segundos

La opción `--max-time` se puede utilizar para instruir al trabajador a procesar trabajos durante el número dado de segundos y luego salir. Esta opción puede ser útil cuando se combina con [Supervisor](#supervisor-configuration) para que tus trabajadores se reinicien automáticamente después de procesar trabajos durante un tiempo determinado, liberando cualquier memoria que puedan haber acumulado:


```shell
# Process jobs for one hour and then exit...
php artisan queue:work --max-time=3600

```

<a name="worker-sleep-duration"></a>
#### Duración del Sueño del Trabajador

Cuando hay trabajos disponibles en la cola, el trabajador seguirá procesando trabajos sin demora entre ellos. Sin embargo, la opción `sleep` determina cuántos segundos "dormirá" el trabajador si no hay trabajos disponibles. Por supuesto, mientras duerme, el trabajador no procesará nuevos trabajos:


```shell
php artisan queue:work --sleep=3

```

<a name="maintenance-mode-queues"></a>
#### Modo de Mantenimiento y Colas

Mientras tu aplicación esté en [modo de mantenimiento](/docs/%7B%7Bversion%7D%7D/configuration#maintenance-mode), no se manejarán trabajos en cola. Los trabajos continuarán siendo gestionados de forma normal una vez que la aplicación salga del modo de mantenimiento.
Para forzar a tus trabajadores de cola a procesar trabajos incluso si el modo de mantenimiento está habilitado, puedes usar la opción `--force`:


```shell
php artisan queue:work --force

```

<a name="resource-considerations"></a>
#### Consideraciones de Recursos

Los trabajadores de cola en modo daemon no "reinician" el framework antes de procesar cada trabajo. Por lo tanto, debes liberar cualquier recurso pesado después de que se complete cada trabajo. Por ejemplo, si estás haciendo manipulación de imágenes con la librería GD, debes liberar la memoria con `imagedestroy` cuando hayas terminado de procesar la imagen.

<a name="queue-priorities"></a>
### Prioridades de Cola

A veces es posible que desees priorizar cómo se procesan tus colas. Por ejemplo, en tu archivo de configuración `config/queue.php`, puedes establecer la `cola` predeterminada para tu conexión `redis` en `baja`. Sin embargo, de vez en cuando es posible que desees enviar un trabajo a una cola de alta prioridad así:


```php
dispatch((new Job)->onQueue('high'));
```
Para iniciar un trabajador que verifica que todos los trabajos de la cola `high` se procesen antes de continuar con cualquier trabajo en la cola `low`, pasa una lista de nombres de cola delimitada por comas al comando `work`:


```shell
php artisan queue:work --queue=high,low

```

<a name="queue-workers-and-deployment"></a>
### Trabajadores de cola y despliegue

Dado que los trabajadores de la cola son procesos de larga duración, no notarán los cambios en tu código sin ser reiniciados. Así que, la forma más sencilla de desplegar una aplicación utilizando trabajadores de cola es reiniciar los trabajadores durante tu proceso de despliegue. Puedes reiniciar todos los trabajadores de manera elegante emitiendo el comando `queue:restart`:


```shell
php artisan queue:restart

```
Este comando instruirá a todos los trabajadores de la cola a que salgan de manera controlada después de terminar de procesar su trabajo actual, de modo que no se pierdan trabajos existentes. Dado que los trabajadores de la cola saldrán cuando se ejecute el comando `queue:restart`, deberías estar ejecutando un gestor de procesos como [Supervisor](#supervisor-configuration) para reiniciar automáticamente los trabajadores de la cola.
> [!NOTA]
La cola utiliza la [cache](/docs/%7B%7Bversion%7D%7D/cache) para almacenar señales de reinicio, así que debes verificar que un driver de caché esté configurado correctamente para tu aplicación antes de usar esta función.

<a name="job-expirations-and-timeouts"></a>
### Expiraciones y Timeouts de Trabajos


<a name="job-expiration"></a>
#### Expiración de Trabajo

En tu archivo de configuración `config/queue.php`, cada conexión de cola define una opción `retry_after`. Esta opción especifica cuántos segundos debe esperar la conexión de cola antes de reintentar un trabajo que se está procesando. Por ejemplo, si el valor de `retry_after` se establece en `90`, el trabajo será liberado de nuevo en la cola si ha estado procesándose durante 90 segundos sin ser liberado o eliminado. Típicamente, debes establecer el valor de `retry_after` en el número máximo de segundos que tus trabajos deberían razonablemente tomar para completar el procesamiento.
> [!WARNING]
La única conexión de cola que no contiene un valor `retry_after` es Amazon SQS. SQS volverá a intentar el trabajo basado en el [Timeout de Visibilidad Predeterminado](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/AboutVT.html) que se gestiona dentro de la consola de AWS.

<a name="worker-timeouts"></a>
#### Tiempos de espera de trabajador

El comando Artisan `queue:work` expone una opción `--timeout`. Por defecto, el valor `--timeout` es de 60 segundos. Si un trabajo está procesándose durante más tiempo del número de segundos especificados por el valor de timeout, el trabajador que procesa el trabajo saldrá con un error. Típicamente, el trabajador será reiniciado automáticamente por un [gestor de procesos configurado en tu servidor](#supervisor-configuration):


```shell
php artisan queue:work --timeout=60

```
La opción de configuración `retry_after` y la opción de línea de comandos `--timeout` son diferentes, pero trabajan juntas para asegurar que los trabajos no se pierdan y que los trabajos solo se procesen con éxito una vez.
> [!WARNING]
El valor `--timeout` siempre debe ser al menos varios segundos más corto que tu valor de configuración `retry_after`. Esto asegurará que un trabajador que esté procesando un trabajo congelado sea siempre terminado antes de que se reintente el trabajo. Si tu opción `--timeout` es más larga que tu valor de configuración `retry_after`, es posible que tus trabajos se procesen dos veces.

<a name="supervisor-configuration"></a>
## Configuración del Supervisor

En producción, necesitas una forma de mantener tus procesos `queue:work` en funcionamiento. Un proceso `queue:work` puede dejar de ejecutarse por una variedad de razones, como un tiempo de espera de trabajador excedido o la ejecución del comando `queue:restart`.
Por esta razón, necesitas configurar un monitor de procesos que pueda detectar cuándo salen tus procesos `queue:work` y reiniciarlos automáticamente. Además, los monitores de procesos te permiten especificar cuántos procesos `queue:work` te gustaría ejecutar de manera concurrente. Supervisor es un monitor de procesos comúnmente utilizado en entornos Linux y discutiremos cómo configurarlo en la documentación siguiente.

<a name="installing-supervisor"></a>
#### Instalación de Supervisor

Supervisor es un monitor de procesos para el sistema operativo Linux, y reiniciará automáticamente tus procesos `queue:work` si fallan. Para instalar Supervisor en Ubuntu, puedes usar el siguiente comando:


```shell
sudo apt-get install supervisor

```
> [!NOTE]
Si configurar y gestionar Supervisor por ti mismo te parece abrumador, considera usar [Laravel Forge](https://forge.laravel.com), que instalará y configurará Supervisor automáticamente para tus proyectos Laravel en producción.

<a name="configuring-supervisor"></a>
#### Configurando Supervisor

Los archivos de configuración del supervisor suelen almacenarse en el directorio `/etc/supervisor/conf.d`. Dentro de este directorio, puedes crear cualquier número de archivos de configuración que indiquen al supervisor cómo se deben supervisar tus procesos. Por ejemplo, creemos un archivo `laravel-worker.conf` que inicie y supervise los procesos `queue:work`:


```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/forge/app.com/artisan queue:work sqs --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=forge
numprocs=8
redirect_stderr=true
stdout_logfile=/home/forge/app.com/worker.log
stopwaitsecs=3600

```
En este ejemplo, la directiva `numprocs` indicará a Supervisor que ejecute ocho procesos `queue:work` y los supervise a todos, reiniciándolos automáticamente si fallan. Debes cambiar la directiva `command` de la configuración para reflejar tu conexión de cola deseada y opciones del trabajador.
> [!WARNING]
Debes asegurarte de que el valor de `stopwaitsecs` sea mayor que el número de segundos consumidos por tu trabajo de mayor duración. De lo contrario, Supervisor puede matar el trabajo antes de que haya terminado de procesarse.

<a name="starting-supervisor"></a>
#### Iniciando Supervisor

Una vez que se haya creado el archivo de configuración, puedes actualizar la configuración del Supervisor y comenzar los procesos utilizando los siguientes comandos:


```shell
sudo supervisorctl reread

sudo supervisorctl update

sudo supervisorctl start "laravel-worker:*"

```
Para obtener más información sobre Supervisor, consulta la [documentación de Supervisor](http://supervisord.org/index.html).

<a name="dealing-with-failed-jobs"></a>
## Manejo de Trabajos Fallidos

A veces, tus trabajos en cola fallarán. ¡No te preocupes, las cosas no siempre salen según lo planeado! Laravel incluye una forma conveniente de [especificar el número máximo de veces que se debe intentar un trabajo](#max-job-attempts-and-timeout). Después de que un trabajo asíncrono haya superado este número de intentos, se insertará en la tabla `failed_jobs` de la base de datos. Los [trabajos despachados de forma sincrónica](/docs/%7B%7Bversion%7D%7D/queues#synchronous-dispatching) que fallan no se almacenan en esta tabla y sus excepciones son manejadas inmediatamente por la aplicación.
Una migración para crear la tabla `failed_jobs` generalmente ya está presente en nuevas aplicaciones Laravel. Sin embargo, si tu aplicación no contiene una migración para esta tabla, puedes usar el comando `make:queue-failed-table` para crear la migración:


```shell
php artisan make:queue-failed-table

php artisan migrate

```
Al ejecutar un proceso de [worker de cola](#running-the-queue-worker), puedes especificar el número máximo de veces que se debe intentar un trabajo usando el interruptor `--tries` en el comando `queue:work`. Si no especificas un valor para la opción `--tries`, los trabajos solo se intentarán una vez o tantas veces como lo especifique la propiedad `$tries` de la clase de trabajo:


```shell
php artisan queue:work redis --tries=3

```
Usando la opción `--backoff`, puedes especificar cuántos segundos debe esperar Laravel antes de reintentar un trabajo que ha encontrado una excepción. Por defecto, un trabajo se libera inmediatamente de nuevo en la cola para que se pueda intentar de nuevo:


```shell
php artisan queue:work redis --tries=3 --backoff=3

```
Si deseas configurar cuántos segundos debería esperar Laravel antes de reintentar un trabajo que ha encontrado una excepción de manera individual por trabajo, puedes hacerlo definiendo una propiedad `backoff` en tu clase de trabajo:


```php
/**
 * The number of seconds to wait before retrying the job.
 *
 * @var int
 */
public $backoff = 3;
```
Si necesitas una lógica más compleja para determinar el tiempo de reintento de la tarea, puedes definir un método `backoff` en tu clase de tarea:


```php
/**
* Calculate the number of seconds to wait before retrying the job.
*/
public function backoff(): int
{
    return 3;
}
```
Puedes configurar fácilmente los retrocesos "exponenciales" devolviendo un array de valores de retroceso desde el método `backoff`. En este ejemplo, el retraso de reintento será de 1 segundo para el primer reintento, 5 segundos para el segundo reintento, 10 segundos para el tercer reintento y 10 segundos para cada reintento posterior si hay más intentos restantes:


```php
/**
* Calculate the number of seconds to wait before retrying the job.
*
* @return array<int, int>
*/
public function backoff(): array
{
    return [1, 5, 10];
}
```

<a name="cleaning-up-after-failed-jobs"></a>
### Limpiando Después de Trabajos Fallidos

Cuando un trabajo particular falla, es posible que desees enviar una alerta a tus usuarios o revertir cualquier acción que se haya completado parcialmente por el trabajo. Para lograr esto, puedes definir un método `failed` en tu clase de trabajo. La instancia de `Throwable` que causó que el trabajo fallara se pasará al método `failed`:


```php
<?php

namespace App\Jobs;

use App\Models\Podcast;
use App\Services\AudioProcessor;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Throwable;

class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public Podcast $podcast,
    ) {}

    /**
     * Execute the job.
     */
    public function handle(AudioProcessor $processor): void
    {
        // Process uploaded podcast...
    }

    /**
     * Handle a job failure.
     */
    public function failed(?Throwable $exception): void
    {
        // Send user notification of failure, etc...
    }
}
```
> [!WARNING]
Se instancia una nueva instancia del trabajo antes de invocar el método `failed`; por lo tanto, cualquier modificación de propiedad de clase que haya podido ocurrir dentro del método `handle` se perderá.

<a name="retrying-failed-jobs"></a>
### Reintentando Trabajos Fallidos

Para ver todos los trabajos fallidos que han sido insertados en tu tabla de base de datos `failed_jobs`, puedes usar el comando Artisan `queue:failed`:


```shell
php artisan queue:failed

```
El comando `queue:failed` listará el ID del trabajo, la conexión, la cola, el tiempo de fallo y otra información sobre el trabajo. El ID del trabajo puede usarse para reintentar el trabajo fallido. Por ejemplo, para reintentar un trabajo fallido que tiene un ID de `ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece`, emite el siguiente comando:


```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece

```
Si es necesario, puedes pasar múltiples ID al comando:


```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece 91401d2c-0784-4f43-824c-34f94a33c24d

```
También puedes reintentar todos los trabajos fallidos para una cola en particular:


```shell
php artisan queue:retry --queue=name

```
Para reintentar todos tus trabajos fallidos, ejecuta el comando `queue:retry` y pasa `all` como el ID:


```shell
php artisan queue:retry all

```
Si deseas eliminar un trabajo fallido, puedes usar el comando `queue:forget`:


```shell
php artisan queue:forget 91401d2c-0784-4f43-824c-34f94a33c24d

```
> [!NOTE]
Al usar [Horizon](/docs/%7B%7Bversion%7D%7D/horizon), debes usar el comando `horizon:forget` para eliminar un trabajo fallido en lugar del comando `queue:forget`.
Para eliminar todos tus trabajos fallidos de la tabla `failed_jobs`, puedes usar el comando `queue:flush`:


```shell
php artisan queue:flush

```

<a name="ignoring-missing-models"></a>
### Ignorando Modelos Faltantes

Al inyectar un modelo Eloquent en un trabajo, el modelo se serializa automáticamente antes de ser colocado en la cola y se vuelve a recuperar de la base de datos cuando se procesa el trabajo. Sin embargo, si el modelo ha sido eliminado mientras el trabajo estaba esperando a ser procesado por un trabajador, tu trabajo puede fallar con una `ModelNotFoundException`.
Para mayor comodidad, puedes optar por eliminar automáticamente trabajos con modelos faltantes configurando la propiedad `deleteWhenMissingModels` de tu trabajo en `true`. Cuando esta propiedad se establece en `true`, Laravel descartará silenciosamente el trabajo sin generar una excepción:


```php
/**
 * Delete the job if its models no longer exist.
 *
 * @var bool
 */
public $deleteWhenMissingModels = true;
```

<a name="pruning-failed-jobs"></a>
### Eliminación de Trabajos Fallidos

Puedes eliminar los registros en la tabla `failed_jobs` de tu aplicación invocando el comando Artisan `queue:prune-failed`:


```shell
php artisan queue:prune-failed

```
Por defecto, todos los registros de trabajos fallidos que tienen más de 24 horas serán eliminados. Si proporcionas la opción `--hours` al comando, solo se conservarán los registros de trabajos fallidos que fueron insertados en las últimas N horas. Por ejemplo, el siguiente comando eliminará todos los registros de trabajos fallidos que fueron insertados hace más de 48 horas:


```shell
php artisan queue:prune-failed --hours=48

```

<a name="storing-failed-jobs-in-dynamodb"></a>
### Almacenando Trabajos Fallidos en DynamoDB

Laravel también ofrece soporte para almacenar tus registros de trabajos fallidos en [DynamoDB](https://aws.amazon.com/dynamodb) en lugar de una tabla de base de datos relacional. Sin embargo, debes crear manualmente una tabla de DynamoDB para almacenar todos los registros de trabajos fallidos. Típicamente, esta tabla debe llamarse `failed_jobs`, pero debes nombrar la tabla según el valor de la configuración `queue.failed.table` dentro del archivo de configuración `queue` de tu aplicación.
La tabla `failed_jobs` debe tener una clave de partición primaria de tipo cadena llamada `application` y una clave de ordenamiento primaria de tipo cadena llamada `uuid`. La porción de `application` de la clave contendrá el nombre de tu aplicación, tal como se define por el valor de configuración `name` dentro del archivo de configuración `app` de tu aplicación. Dado que el nombre de la aplicación es parte de la clave de la tabla DynamoDB, puedes usar la misma tabla para almacenar trabajos fallidos de múltiples aplicaciones Laravel.
Además, asegúrate de instalar el SDK de AWS para que tu aplicación Laravel pueda comunicarse con Amazon DynamoDB:


```shell
composer require aws/aws-sdk-php

```
A continuación, establece el valor de la opción de configuración `queue.failed.driver` en `dynamodb`. Además, debes definir las opciones de configuración `key`, `secret` y `region` dentro del array de configuración del trabajo fallido. Estas opciones se utilizarán para autenticarte con AWS. Al usar el driver `dynamodb`, la opción de configuración `queue.failed.database` es innecesaria:


```php
'failed' => [
    'driver' => env('QUEUE_FAILED_DRIVER', 'dynamodb'),
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    'table' => 'failed_jobs',
],

```

<a name="disabling-failed-job-storage"></a>
### Desactivando el Almacenamiento de Trabajos Fallidos

Puedes instruir a Laravel a que descarte los trabajos fallidos sin almacenarlos configurando el valor de la opción de configuración `queue.failed.driver` a `null`. Típicamente, esto se puede lograr a través de la variable de entorno `QUEUE_FAILED_DRIVER`:


```ini
QUEUE_FAILED_DRIVER=null

```

<a name="failed-job-events"></a>
### Eventos de Trabajo Fallidos

Si deseas registrar un escuchador de eventos que se invocará cuando un trabajo falle, puedes usar el método `failing` de la facade `Queue`. Por ejemplo, podemos adjuntar una función anónima a este evento desde el método `boot` del `AppServiceProvider` que se incluye con Laravel:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Queue;
use Illuminate\Support\ServiceProvider;
use Illuminate\Queue\Events\JobFailed;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // ...
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Queue::failing(function (JobFailed $event) {
            // $event->connectionName
            // $event->job
            // $event->exception
        });
    }
}
```

<a name="clearing-jobs-from-queues"></a>
## Limpiando Trabajos de Colas

> [!NOTA]
Al usar [Horizon](/docs/%7B%7Bversion%7D%7D/horizon), deberías usar el comando `horizon:clear` para eliminar trabajos de la cola en lugar del comando `queue:clear`.
Si deseas eliminar todos los trabajos de la cola predeterminada de la conexión predeterminada, puedes hacerlo utilizando el comando Artisan `queue:clear`:


```shell
php artisan queue:clear

```
También puedes proporcionar el argumento `connection` y la opción `queue` para eliminar trabajos de una conexión y cola específicas:


```shell
php artisan queue:clear redis --queue=emails

```
> [!WARNING]
Limpiar trabajos de las colas solo está disponible para los controladores de colas SQS, Redis y de base de datos. Además, el proceso de eliminación de mensajes de SQS tarda hasta 60 segundos, por lo que los trabajos enviados a la cola SQS hasta 60 segundos después de que limpies la cola también pueden ser eliminados.

<a name="monitoring-your-queues"></a>
## Monitoreando tus Colas

Si tu cola recibe un súbito aumento de trabajos, podría verse abrumada, lo que llevaría a un largo tiempo de espera para que los trabajos se completen. Si lo deseas, Laravel puede alertarte cuando el conteo de trabajos en tu cola excede un umbral especificado.
Para comenzar, deberías programar el comando `queue:monitor` para [ejecutarse cada minuto](/docs/%7B%7Bversion%7D%7D/scheduling). El comando acepta los nombres de las colas que deseas monitorear, así como tu umbral de conteo de trabajos deseado:


```shell
php artisan queue:monitor redis:default,redis:deployments --max=100

```
Programar este comando por sí solo no es suficiente para activar una notificación que te alerte sobre el estado de sobrecarga de la cola. Cuando el comando encuentra una cola que tiene un conteo de trabajos que supera tu umbral, se despachará un evento `Illuminate\Queue\Events\QueueBusy`. Puedes escuchar este evento dentro del `AppServiceProvider` de tu aplicación para enviar una notificación a ti o a tu equipo de desarrollo:


```php
use App\Notifications\QueueHasLongWaitTime;
use Illuminate\Queue\Events\QueueBusy;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(function (QueueBusy $event) {
        Notification::route('mail', 'dev@example.com')
                ->notify(new QueueHasLongWaitTime(
                    $event->connection,
                    $event->queue,
                    $event->size
                ));
    });
}

```

<a name="testing"></a>
## Pruebas

Al probar el código que despacha trabajos, es posible que desees instruir a Laravel para que no ejecute realmente el trabajo en sí, ya que el código del trabajo se puede probar de forma directa y separada del código que lo despacha. Por supuesto, para probar el trabajo en sí, puedes instanciar una instancia del trabajo e invocar el método `handle` directamente en tu prueba.
Puedes usar el método `fake` de la fachada `Queue` para evitar que los trabajos en cola se envíen realmente a la cola. Después de llamar al método `fake` de la fachada `Queue`, puedes afirmar que la aplicación intentó enviar trabajos a la cola:


```php
<?php

use App\Jobs\AnotherJob;
use App\Jobs\FinalJob;
use App\Jobs\ShipOrder;
use Illuminate\Support\Facades\Queue;

test('orders can be shipped', function () {
    Queue::fake();

    // Perform order shipping...

    // Assert that no jobs were pushed...
    Queue::assertNothingPushed();

    // Assert a job was pushed to a given queue...
    Queue::assertPushedOn('queue-name', ShipOrder::class);

    // Assert a job was pushed twice...
    Queue::assertPushed(ShipOrder::class, 2);

    // Assert a job was not pushed...
    Queue::assertNotPushed(AnotherJob::class);

    // Assert that a Closure was pushed to the queue...
    Queue::assertClosurePushed();

    // Assert the total number of jobs that were pushed...
    Queue::assertCount(3);
});

```


```php
<?php

namespace Tests\Feature;

use App\Jobs\AnotherJob;
use App\Jobs\FinalJob;
use App\Jobs\ShipOrder;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_orders_can_be_shipped(): void
    {
        Queue::fake();

        // Perform order shipping...

        // Assert that no jobs were pushed...
        Queue::assertNothingPushed();

        // Assert a job was pushed to a given queue...
        Queue::assertPushedOn('queue-name', ShipOrder::class);

        // Assert a job was pushed twice...
        Queue::assertPushed(ShipOrder::class, 2);

        // Assert a job was not pushed...
        Queue::assertNotPushed(AnotherJob::class);

        // Assert that a Closure was pushed to the queue...
        Queue::assertClosurePushed();

        // Assert the total number of jobs that were pushed...
        Queue::assertCount(3);
    }
}

```
Puedes pasar una función anónima a los métodos `assertPushed` o `assertNotPushed` para afirmar que se ha añadido un trabajo que pasa una "prueba de verdad" dada. Si al menos un trabajo fue añadido que pasa la prueba de verdad dada, entonces la afirmación será exitosa:


```php
Queue::assertPushed(function (ShipOrder $job) use ($order) {
    return $job->order->id === $order->id;
});
```

<a name="faking-a-subset-of-jobs"></a>
### Simulando un Conjunto de Trabajos

Si solo necesitas simular trabajos específicos mientras permites que tus otros trabajos se ejecuten normalmente, puedes pasar los nombres de las clases de los trabajos que deben simularse al método `fake`:


```php
test('orders can be shipped', function () {
    Queue::fake([
        ShipOrder::class,
    ]);

    // Perform order shipping...

    // Assert a job was pushed twice...
    Queue::assertPushed(ShipOrder::class, 2);
});

```


```php
public function test_orders_can_be_shipped(): void
{
    Queue::fake([
        ShipOrder::class,
    ]);

    // Perform order shipping...

    // Assert a job was pushed twice...
    Queue::assertPushed(ShipOrder::class, 2);
}

```
Puedes simular todos los trabajos excepto un conjunto de trabajos especificados utilizando el método `except`:


```php
Queue::fake()->except([
    ShipOrder::class,
]);
```

<a name="testing-job-chains"></a>
### Probando Cadenas de Trabajo

Para probar cadenas de trabajos, necesitarás utilizar las capacidades de simulación de la fachada `Bus`. El método `assertChained` de la fachada `Bus` puede usarse para afirmar que se despachó una [cadena de trabajos](/docs/%7B%7Bversion%7D%7D/queues#job-chaining). El método `assertChained` acepta un array de trabajos en cadena como su primer argumento:


```php
use App\Jobs\RecordShipment;
use App\Jobs\ShipOrder;
use App\Jobs\UpdateInventory;
use Illuminate\Support\Facades\Bus;

Bus::fake();

// ...

Bus::assertChained([
    ShipOrder::class,
    RecordShipment::class,
    UpdateInventory::class
]);
```
Como puedes ver en el ejemplo anterior, el array de trabajos encadenados puede ser un array de los nombres de clase del trabajo. Sin embargo, también puedes proporcionar un array de instancias de trabajo reales. Al hacerlo, Laravel se asegurará de que las instancias del trabajo sean de la misma clase y tengan los mismos valores de propiedades de los trabajos encadenados despachados por tu aplicación:


```php
Bus::assertChained([
    new ShipOrder,
    new RecordShipment,
    new UpdateInventory,
]);
```
Puedes usar el método `assertDispatchedWithoutChain` para afirmar que un trabajo fue encolado sin una cadena de trabajos:


```php
Bus::assertDispatchedWithoutChain(ShipOrder::class);
```

<a name="testing-chain-modifications"></a>
#### Probando Modificaciones en la Cadena

Si un trabajo encadenado [añade o añade trabajos a un encadenamiento existente](#adding-jobs-to-the-chain), puedes usar el método `assertHasChain` del trabajo para afirmar que el trabajo tiene la cadena esperada de trabajos restantes:


```php
$job = new ProcessPodcast;

$job->handle();

$job->assertHasChain([
    new TranscribePodcast,
    new OptimizePodcast,
    new ReleasePodcast,
]);

```
El método `assertDoesntHaveChain` se puede usar para afirmar que la cadena restante del trabajo está vacía:


```php
$job->assertDoesntHaveChain();

```

<a name="testing-chained-batches"></a>
#### Probando Lotes Encadenados

Si tu cadena de trabajos [contiene un lote de trabajos](#chains-and-batches), puedes afirmar que el lote encadenado coincide con tus expectativas insertando una definición de `Bus::chainedBatch` dentro de tu afirmación de cadena:


```php
use App\Jobs\ShipOrder;
use App\Jobs\UpdateInventory;
use Illuminate\Bus\PendingBatch;
use Illuminate\Support\Facades\Bus;

Bus::assertChained([
    new ShipOrder,
    Bus::chainedBatch(function (PendingBatch $batch) {
        return $batch->jobs->count() === 3;
    }),
    new UpdateInventory,
]);
```

<a name="testing-job-batches"></a>
### Pruebas de Lotes de Trabajo

El método `assertBatched` de la fachada `Bus` se puede utilizar para afirmar que un [lote de trabajos](/docs/%7B%7Bversion%7D%7D/queues#job-batching) fue despachado. La `función anónima` dada al método `assertBatched` recibe una instancia de `Illuminate\Bus\PendingBatch`, que se puede usar para inspeccionar los trabajos dentro del lote:


```php
use Illuminate\Bus\PendingBatch;
use Illuminate\Support\Facades\Bus;

Bus::fake();

// ...

Bus::assertBatched(function (PendingBatch $batch) {
    return $batch->name == 'import-csv' &&
           $batch->jobs->count() === 10;
});
```
Puedes usar el método `assertBatchCount` para afirmar que se despacharon un número dado de lotes:


```php
Bus::assertBatchCount(3);
```
Puedes usar `assertNothingBatched` para afirmar que no se enviaron lotes:


```php
Bus::assertNothingBatched();
```

<a name="testing-job-batch-interaction"></a>
#### Probando la Interacción de Job / Batch

Además, es posible que ocasionalmente necesites probar la interacción de un trabajo individual con su lote subyacente. Por ejemplo, es posible que necesites probar si un trabajo canceló el procesamiento adicional de su lote. Para lograr esto, necesitas asignar un lote falso al trabajo a través del método `withFakeBatch`. El método `withFakeBatch` devuelve una tupla que contiene la instancia del trabajo y el lote falso:


```php
[$job, $batch] = (new ShipOrder)->withFakeBatch();

$job->handle();

$this->assertTrue($batch->cancelled());
$this->assertEmpty($batch->added);
```

<a name="testing-job-queue-interactions"></a>
### Probando Interacciones de Trabajo / Cola

A veces, es posible que necesites probar que un trabajo en cola [se libera a sí mismo de nuevo en la cola](#manually-releasing-a-job). O, es posible que necesites probar que el trabajo se eliminó a sí mismo. Puedes probar estas interacciones con la cola instanciando el trabajo e invocando el método `withFakeQueueInteractions`.
Una vez que las interacciones de la cola del trabajo han sido simuladas, puedes invocar el método `handle` en el trabajo. Después de invocar el trabajo, se pueden usar los métodos `assertReleased`, `assertDeleted`, `assertNotDeleted`, `assertFailed` y `assertNotFailed` para hacer afirmaciones sobre las interacciones de la cola del trabajo:


```php
use App\Jobs\ProcessPodcast;

$job = (new ProcessPodcast)->withFakeQueueInteractions();

$job->handle();

$job->assertReleased(delay: 30);
$job->assertDeleted();
$job->assertNotDeleted();
$job->assertFailed();
$job->assertNotFailed();

```

<a name="job-events"></a>
## Eventos de Trabajo

Usando los métodos `before` y `after` en la [facade](/docs/{{version}}/facades) `Queue`, puedes especificar los callbacks que se ejecutarán antes o después de que se procese un trabajo en cola. Estos callbacks son una gran oportunidad para realizar registros adicionales o incrementar estadísticas para un panel de control. Típicamente, debes llamar a estos métodos desde el método `boot` de un [service provider](/docs/{{version}}/providers). Por ejemplo, podemos usar el `AppServiceProvider` que se incluye con Laravel:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Queue;
use Illuminate\Support\ServiceProvider;
use Illuminate\Queue\Events\JobProcessed;
use Illuminate\Queue\Events\JobProcessing;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // ...
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Queue::before(function (JobProcessing $event) {
            // $event->connectionName
            // $event->job
            // $event->job->payload()
        });

        Queue::after(function (JobProcessed $event) {
            // $event->connectionName
            // $event->job
            // $event->job->payload()
        });
    }
}
```
Utilizando el método `looping` en la `facade` de `Queue` [facade](/docs/%7B%7Bversion%7D%7D/facades), puedes especificar callbacks que se ejecutan antes de que el trabajador intente obtener un trabajo de una cola. Por ejemplo, podrías registrar una función anónima para revertir cualquier transacción que quedara abierta por un trabajo fallido previamente:


```php
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;

Queue::looping(function () {
    while (DB::transactionLevel() > 0) {
        DB::rollBack();
    }
});
```