# Colas

- [Introducción](#introduction)
  - [Conexiones Vs. Colas](#connections-vs-queues)
  - [Notas sobre el driver y requisitos previos](#driver-prerequisites)
- [Creación de trabajos](#creating-jobs)
  - [Generación de Clases de Trabajos](#generating-job-classes)
  - [Estructura de Clases](#class-structure)
  - [Trabajos únicos](#unique-jobs)
- [Middleware trabajos](#job-middleware)
  - [Limitación de uso](#rate-limiting)
  - [Prevención de solapamientos de trabajos](#preventing-job-overlaps)
  - [Limitación de excepciones](#throttling-exceptions)
- [Envío de trabajos](#dispatching-jobs)
  - [Envío diferido](#delayed-dispatching)
  - [Envío sincrónico](#synchronous-dispatching)
  - [Trabajos y transacciones de base de datos](#jobs-and-database-transactions)
  - [Encadenamiento de trabajos](#job-chaining)
  - [Personalización de la cola y la conexión](#customizing-the-queue-and-connection)
  - [Especificación de intentos máximos / Valores de tiempo de espera](#max-job-attempts-and-timeout)
  - [Gestión de Errores](#error-handling)
- [Trabajo por lotes](#job-batching)
  - [Definición de trabajos por lotes](#defining-batchable-jobs)
  - [Envío de lotes](#dispatching-batches)
  - [Añadir trabajos a lotes](#adding-jobs-to-batches)
  - [Inspección de Lotes](#inspecting-batches)
  - [Cancelación de lotes](#cancelling-batches)
  - [Fallos en lotes](#batch-failures)
  - [Poda de lotes](#pruning-batches)
- [Encolando Closures](#queueing-closures)
- [Ejecución del Queue Worker](#running-the-queue-worker)
  - [El comando `queue:work`](#the-queue-work-command)
  - [Prioridades de la cola](#queue-priorities)
  - [workers de cola y despliegue](#queue-workers-and-deployment)
  - [Expiración de trabajos y tiempos de espera](#job-expirations-and-timeouts)
- [Configuración del supervisor](#supervisor-configuration)
- [Trabajos fallidos](#dealing-with-failed-jobs)
  - [Limpieza de trabajos fallidos](#cleaning-up-after-failed-jobs)
  - [Reintento de trabajos fallidos](#retrying-failed-jobs)
  - [Ignorar modelos perdidos](#ignoring-missing-models)
  - [Eliminación de trabajos fallidos](#pruning-failed-jobs)
  - [Almacenamiento de trabajos fallidos en DynamoDB](#storing-failed-jobs-in-dynamodb)
  - [Desactivación del Almacenamiento de Trabajos Fallidos](#disabling-failed-job-storage)
  - [Eventos de trabajos fallidos](#failed-job-events)
- [Borrado de trabajos de las colas](#clearing-jobs-from-queues)
- [Monitorización de Colas](#monitoring-your-queues)
- [Eventos de trabajos](#job-events)

<a name="introduction"></a>
## Introducción

Mientras crea su aplicación web, puede que tenga algunas tareas, como analizar y almacenar un archivo CSV, que tarden demasiado en realizarse durante una petición web típica. Afortunadamente, Laravel te permite crear fácilmente tareas en cola que pueden ser procesadas en segundo plano. Al mover las tareas de tiempo intensivo a una cola, tu aplicación puede responder a las peticiones web con una velocidad de vértigo y proporcionar una mejor experiencia de usuario a tus clientes.

Laravel proporciona una API unificada para trabajar con una gran variedad de backends de cola, como [Amazon SQS](https://aws.amazon.com/sqs/), [Redis](https://redis.io), o incluso una base de datos relacional.

Las opciones de configuración de colas de Laravel se almacenan en el archivo de configuración `config/queue.php` de tu aplicación. En este archivo, encontrarás configuraciones de conexión para cada uno de los drivers de cola que se incluyen con el framework, incluyendo los drivers de base de datos, [Amazon SQS](https://aws.amazon.com/sqs/), [Redis](https://redis.io) y [Beanstalkd](https://beanstalkd.github.io/), así como un driver síncrono que ejecutará los trabajos inmediatamente (para su uso durante el desarrollo local). También se incluye un driver de cola `null` que descarta los trabajos en cola.

> **Nota**  
> Laravel ahora ofrece Horizon, un bonito panel de control y sistema de configuración para tus colas basadas por Redis. Consulta la [documentación de Horizon](/docs/{{version}}/horizon) para más información.

<a name="connections-vs-queues"></a>
### Conexiones vs. Colas

Antes de empezar con las colas de Laravel, es importante entender la diferencia entre "conexiones" y "colas". En el archivo de configuración `config/queue.php`, hay una opcion de configuración llamada `connections`. Esta opción define las conexiones a servicios backends de cola como Amazon SQS, Beanstalk o Redis. Sin embargo, cualquier conexión de cola dada puede tener múltiples "colas" que pueden ser entendidas diferentes pilas de trabajos en espera.

Tenga en cuenta que cada ejemplo de configuración de conexión en el archivo de configuración `queue` contiene un atributo de `queue`. Esta es la cola predeterminada a la que se enviarán los trabajos cuando se envíen a una conexión determinada. En otras palabras, si envías un trabajo sin definir explícitamente a qué cola debe enviarse, el trabajo se colocará en la cola definida en el atributo de `queue` de la configuración de conexión:

    use App\Jobs\ProcessPodcast;

    // This job is sent to the default connection's default queue...
    ProcessPodcast::dispatch();

    // This job is sent to the default connection's "emails" queue...
    ProcessPodcast::dispatch()->onQueue('emails');

Algunas aplicaciones pueden no necesitar nunca enviar trabajos a múltiples colas, prefiriendo tener una cola simple. Sin embargo, enviar trabajos a múltiples colas puede ser especialmente útil para aplicaciones que desean priorizar o segmentar cómo se procesan los trabajos, ya que el "worker" de colas de Laravel permite especificar qué colas debe procesar por prioridad. Por ejemplo, si envías trabajos a una cola `high`, puedes ejecutar un worker que les dé mayor prioridad de procesamiento:

```shell
php artisan queue:work --queue=high,default
```

<a name="driver-prerequisites"></a>
### Notas sobre el driver y requisitos previos

<a name="database"></a>
#### Base de datos

Para utilizar el driver de colas de `base de datos`, necesitará una tabla de base de datos que contenga los trabajos. Para generar una migración que cree esta tabla, ejecute el comando `queue:table` Artisan. Una vez creada la migración, puede migrar su base de datos utilizando el comando `migrate`:

```shell
php artisan queue:table

php artisan migrate
```

Finalmente, no olvides indicar a tu aplicación que utilice el driver de `database` actualizando la variable `QUEUE_CONNECTION` en el archivo `.env` de tu aplicación:

    QUEUE_CONNECTION=database

<a name="redis"></a>
#### Redis

Para utilizar el driver de cola `redis`, debes configurar una conexión de base de datos Redis en tu archivo de configuración `config/database.php`.

**Cluster Redis**

Si su conexión de cola Redis utiliza un clúster Redis, sus nombres de cola deben contener una [key hash tag](https://redis.io/topics/cluster-spec#keys-hash-tags). Esto es necesario para garantizar que todas las claves Redis de una cola determinada se colocan en el mismo hash slot:

    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => '{default}',
        'retry_after' => 90,
    ],

**Bloqueo**

Cuando se utiliza la cola Redis, puede utilizar la opción de configuración `block_for` para especificar cuánto tiempo debe esperar el driver a que un trabajo esté disponible antes de iterar a través del bucle del worker y volver a consultar la base de datos Redis.

Ajustar este valor basándose en la carga de la cola puede ser más eficiente que sondear continuamente la base de datos Redis en busca de nuevos trabajos. Por ejemplo, puede establecer el valor a `5` para indicar que el driver debe bloquearse durante cinco segundos mientras espera a que un trabajo esté disponible:

    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
        'queue' => 'default',
        'retry_after' => 90,
        'block_for' => 5,
    ],

> **Advertencia**  
> Establecer `block_for` a `0` hará que los workers de la cola se bloqueen indefinidamente hasta que un trabajo esté disponible. Esto también evitará que señales como `SIGTERM` sean manejadas hasta que el siguiente trabajo haya sido procesado.

<a name="other-driver-prerequisites"></a>
#### Otros requisitos previos del driver

Las siguientes dependencias son necesarias para los drivers de cola listados. Estas dependencias pueden instalarse a través del gestor de paquetes Composer:

<div class="content-list" markdown="1">

- Amazon SQS: `aws/aws-sdk-php ~3.0`
- Beanstalkd: `pda/pheanstalk ~4.0`
- Redis: `predis/predis ~1.0` or phpredis PHP extension

</div>

<a name="creating-jobs"></a>
## Creación de trabajos

<a name="generating-job-classes"></a>
### Generación de Clases de Trabajos

Por defecto, todos los trabajos en cola de tu aplicación se almacenan en el directorio `app/Jobs`. Si el directorio `app/Jobs` no existe, será creado cuando ejecutes el comando `make:job` Artisan:

```shell
php artisan make:job ProcessPodcast
```

La clase generada implementará la interfaz `Illuminate\Contracts\Queue\ShouldQueue`, indicando a Laravel que el trabajo debe ser enviado a la cola para ejecutarse de forma asíncrona.

> **Nota**  
> El código template con el que se generan los trabajos puede personalizarse publicando sus [templates (stubs)](/docs/{{version}}/artisan#stub-customization).

<a name="class-structure"></a>
### Estructura de Clases

Las clases de trabajos son muy simples, normalmente contienen sólo un método `handle` que es invocado cuando el trabajo es procesado por la cola. Para empezar, veamos un ejemplo de una de estas clases. En este ejemplo, supondremos que gestionamos un servicio de publicación de podcasts y que necesitamos procesar los archivos de podcasts subidos antes de publicarlos:

    <?php

    namespace App\Jobs;

    use App\Models\Podcast;
    use App\Services\AudioProcessor;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Foundation\Bus\Dispatchable;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * The podcast instance.
         *
         * @var \App\Models\Podcast
         */
        public $podcast;

        /**
         * Create a new job instance.
         *
         * @param  App\Models\Podcast  $podcast
         * @return void
         */
        public function __construct(Podcast $podcast)
        {
            $this->podcast = $podcast;
        }

        /**
         * Execute the job.
         *
         * @param  App\Services\AudioProcessor  $processor
         * @return void
         */
        public function handle(AudioProcessor $processor)
        {
            // Process uploaded podcast...
        }
    }

En este ejemplo, observa que hemos podido pasar un [modelo Eloquent](/docs/{{version}}/eloquent) directamente al constructor del trabajo en cola. Debido al trait `SerializesModels` que utiliza el trabajo, los modelos Eloquent y sus relaciones cargadas se serializarán y deserializarán cuando el trabajo se esté procesando.

Si tu trabajo en cola acepta un modelo de Eloquent en su constructor, sólo el identificador del modelo será serializado en la cola. Cuando se gestione realmente el trabajo, el sistema de colas recuperará automáticamente de la base de datos la instancia completa del modelo y sus relaciones cargadas. Este enfoque de la serialización del modelo permite enviar cargas de trabajo mucho más pequeñas al driver de cola.

<a name="handle-method-dependency-injection"></a>
#### Inyección de dependencia en el método `handle`

El método `handle` es invocado cuando el trabajo es procesado por la cola. Nótese que es posible tipar dependencias en el método `handle` del trabajo. El [contenedor de servicios](/docs/{{version}}/container) de Laravel inyecta automáticamente estas dependencias.

Si quieres tener un control total sobre cómo el contenedor inyecta dependencias en el método `handle`, puedes utilizar el método `bindMethod` del contenedor. El método `bindMethod` acepta una llamada de retorno que recibe el trabajo y el contenedor. Dentro del callback, eres libre de invocar el método `handle` como desees. Típicamente, deberías llamar a este método desde el método `boot` de tu [proveedor de servicios](/docs/{{version}}/providers) `AppProviders\AppServiceProvider`:

    use App\Jobs\ProcessPodcast;
    use App\Services\AudioProcessor;

    $this->app->bindMethod([ProcessPodcast::class, 'handle'], function ($job, $app) {
        return $job->handle($app->make(AudioProcessor::class));
    });

> **Advertencia**  
> Los datos binarios, como el contenido de imágenes sin procesar, deben pasarse a través de la función `base64_encode` antes de pasarlos a un trabajo en cola. De lo contrario, es posible que el trabajo no se serialice correctamente a JSON cuando se coloque en la cola.

<a name="handling-relationships"></a>
#### Relaciones en cola

Debido a que las relaciones cargadas también se serializan, la cadena serializada del trabajo a veces puede llegar a ser bastante grande. Para evitar que las relaciones se serialicen, puede llamar al método `withoutRelations` en el modelo cuando establezca un valor de propiedad. Este método devolverá una instancia del modelo sin sus relaciones cargadas:

    /**
     * Create a new job instance.
     *
     * @param  \App\Models\Podcast  $podcast
     * @return void
     */
    public function __construct(Podcast $podcast)
    {
        $this->podcast = $podcast->withoutRelations();
    }

Además, cuando un trabajo se deserializa y las relaciones del modelo se vuelven a recuperar de la base de datos, se recuperarán en su totalidad. Cualquier restricción de relación previa que se haya aplicado antes de serializar el modelo durante el proceso de puesta en cola del trabajo no se aplicará cuando se deserialice el trabajo. Por lo tanto, si desea trabajar con un subconjunto de una relación dada, debe volver a restringir esa relación dentro de su trabajo en cola.

<a name="unique-jobs"></a>
### Trabajos únicos

> **Advertencia**  
> Los trabajos únicos requieren un driver de cache que soporte [bloqueos atómicos](/docs/{{version}}/cache#atomic-locks). Actualmente, los drivers de cache `memcached`, `redis`, `dynamodb`, `database`, `file` y `array` soportan bloqueos atómicos. Además, las restricciones de trabajos únicos no se aplican a trabajos dentro de lotes.

A veces, es posible que desee asegurarse de que sólo una instancia de un trabajo específico está en la cola en cualquier momento en el tiempo. Puedes hacerlo implementando la interfaz `ShouldBeUnique` en tu clase job. Esta interfaz no requiere que definas ningún método adicional en tu clase:

    <?php

    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Contracts\Queue\ShouldBeUnique;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
    {
        ...
    }

En el ejemplo anterior, el trabajo `UpdateSearchIndex` es único. Por lo tanto, el trabajo no se enviará si otra instancia del trabajo ya está en la cola y no ha terminado de procesarse.

En ciertos casos, es posible que desee definir una "clave" específica que haga que el trabajo sea único o que desee especificar un tiempo de espera más allá del cual el trabajo ya no permanece único. Para ello, puede definir propiedades o métodos `uniqueId` y `uniqueFor` en su clase de trabajo:

    <?php

    use App\Product;
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
         * The unique ID of the job.
         *
         * @return string
         */
        public function uniqueId()
        {
            return $this->product->id;
        }
    }

En el ejemplo anterior, la tarea `UpdateSearchIndex` es única por un ID de producto. Por lo tanto, cualquier nuevo envío del trabajo con el mismo ID de producto se ignorará hasta que el trabajo existente haya terminado de procesarse. Además, si el trabajo existente no se procesa en el plazo de una hora, se liberará el bloqueo único y se podrá enviar a la cola otro trabajo con la misma clave única.

> **Advertencia**  
> Si tu aplicación envia trabajos desde múltiples servidores web o contenedores, debes asegurarte de que todos tus servidores se comunican con el mismo servidor central de cache para que Laravel pueda determinar con precisión si un trabajo es único.

<a name="keeping-jobs-unique-until-processing-begins"></a>
#### Mantener los Trabajos Únicos Hasta que Comienza su Procesamiento

Por defecto, los trabajos únicos se "desbloquean" después de que un trabajo finaliza su procesamiento o falla todos sus intentos de reintento. Sin embargo, puede haber situaciones en las que quieras que tu trabajo se desbloquee inmediatamente antes de ser procesado. Para conseguir esto, tu trabajo debería implementar el contrato `ShouldBeUniqueUntilProcessing` en lugar del contrato `ShouldBeUnique`:

    <?php

    use App\Product;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Contracts\Queue\ShouldBeUniqueUntilProcessing;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUniqueUntilProcessing
    {
        // ...
    }

<a name="unique-job-locks"></a>
#### Bloqueos de trabajos únicos

Entre bastidores, cuando un trabajo `ShouldBeUnique` es enviado a una cola, Laravel intenta adquirir un [bloqueo atómico](/docs/{{version}}/cache#atomic-locks) con la clave `uniqueId`. Si el bloqueo no se adquiere, el trabajo no se envía. Este bloqueo se libera cuando el trabajo termina de procesarse o falla todos sus intentos de reintento. Por defecto, Laravel utilizará el driver de cache por defecto para obtener este bloqueo. Sin embargo, si deseas utilizar otro driver para adquirir el bloqueo, puedes definir un método `uniqueVia` que devuelva el driver de cache que debería utilizarse:

    use Illuminate\Support\Facades\Cache;

    class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
    {
        ...

        /**
         * Get the cache driver for the unique job lock.
         *
         * @return \Illuminate\Contracts\Cache\Repository
         */
        public function uniqueVia()
        {
            return Cache::driver('redis');
        }
    }

> **Nota**  
> Si sólo necesitas limitar el procesamiento concurrente de un trabajo, utiliza en su lugar el middleware [`WithoutOverlapping`](/docs/{{version}}/queues#preventing-job-overlaps) job.

<a name="job-middleware"></a>
## Middleware trabajos

Los middlewares de trabajos le permite envolver lógica personalizada alrededor de la ejecución de trabajos en cola, reduciendo la repetición de tareas en los propios trabajos. Por ejemplo, considera el siguiente método `handle` que aprovecha las características de limitación de velocidad de Redis de Laravel para permitir que sólo se procese un trabajo cada cinco segundos:

    use Illuminate\Support\Facades\Redis;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        Redis::throttle('key')->block(0)->allow(1)->every(5)->then(function () {
            info('Lock obtained...');

            // Handle job...
        }, function () {
            // Could not obtain lock...

            return $this->release(5);
        });
    }

Aunque este código es válido, la implementación del método `handle` se vuelve ruidosa ya que está llena de lógica de limitación de velocidad de Redis. Además, esta lógica de limitación de velocidad debe ser duplicada para cualquier otro trabajo que queramos limitar.

En lugar de limitar la tasa de uso en el método handle, podríamos definir un middleware de trabajo que se encargue de la limitación de la tasa. Laravel no tiene una ubicación predeterminada para middlewars de trabajo, por lo que puedes colocar el middleware de trabajo en cualquier lugar de tu aplicación. En este ejemplo, colocaremos el middleware en un directorio `app/Jobs/Middleware`:

    <?php

    namespace App\Jobs\Middleware;

    use Illuminate\Support\Facades\Redis;

    class RateLimited
    {
        /**
         * Process the queued job.
         *
         * @param  mixed  $job
         * @param  callable  $next
         * @return mixed
         */
        public function handle($job, $next)
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

Como puedes ver, al igual que los [middlewares de ruta](/docs/{{version}}/middleware), un middleware de trabajo recibe el trabajo que está siendo procesado y una llamada de retorno que debe ser invocada para continuar procesando el trabajo.

Después de crear middleware de trabajo, pueden ser adjuntados a un trabajo devolviéndolos desde el método `middleware` del trabajo. Este método no existe en los trabajos creados con el comando Artisan `make:job`, por lo que tendrás que añadirlo manualmente a tu clase:

    use App\Jobs\Middleware\RateLimited;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [new RateLimited];
    }

> **Nota**  
> Un middlewares de trabajo también puede ser asignado a escuchadores de eventos en cola, mailables y notificaciones.

<a name="rate-limiting"></a>
### Limitación de uso

Aunque acabamos de enseñar cómo escribir tu propio middleware de limitación de tasa de uso de trabajos, Laravel en realidad ya incluye un middleware para realizar esta función. Al igual que [los limitadores de tasa de ruta](/docs/{{version}}/routing#defining-rate-limiters), los limitadores de tasa de trabajo se definen utilizando el método `for` de la facade `RateLimiter`.

Por ejemplo, es posible que desee permitir a los usuarios realizar copias de seguridad de sus datos una vez por hora, sin imponer tal límite a los clientes premium. Para lograr esto, puede definir un `RateLimiter` en el método `boot` de su `AppServiceProvider`:

    use Illuminate\Cache\RateLimiting\Limit;
    use Illuminate\Support\Facades\RateLimiter;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        RateLimiter::for('backups', function ($job) {
            return $job->user->vipCustomer()
                        ? Limit::none()
                        : Limit::perHour(1)->by($job->user->id);
        });
    }

En el ejemplo anterior, definimos un límite de uso por hora; sin embargo, puede definir fácilmente un límite de uso basado en minutos utilizando el método `perMinute`. Además, puede pasar cualquier valor que desee al método `by` del limitador; sin embargo, este valor se utiliza más a menudo para segmentar los límites de uso por cliente:

    return Limit::perMinute(50)->by($job->user->id);

Una vez que haya definido su límite de uso, puede adjuntar el limitador a su trabajo de copia de seguridad utilizando el middleware `Illuminate\Queue\Middleware\RateLimited`. Cada vez que el trabajo supere el límite, este middleware devolverá el trabajo a la cola con un retardo adecuado basado en la duración del límite.

    use Illuminate\Queue\Middleware\RateLimited;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [new RateLimited('backups')];
    }

Liberar un trabajo de uso limitado y enviarlo de nuevo a la cola seguirá incrementando el número total de intentos (`attempts`) del trabajo. Es posible que desee ajustar el número de intentos y excepciones máximas, para ello modifique las propiedades `tries` y `maxExceptions` en su clase de trabajo. También puede utilizar el método [`retryUntil`](#time-based-attempts) para definir el tiempo hasta que el trabajo ya no debe ser reintentado de nuevo.

Si no desea que un trabajo sea reintentado cuando está limitado por un limitador de uso, puede utilizar el método `dontRelease`:

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new RateLimited('backups'))->dontRelease()];
    }

> **Nota**  
> Si estás utilizando Redis, puedes utilizar el middleware `Illuminate\Queue\Middleware\RateLimitedWithRedis`, que está optimizado para Redis y es más eficiente que el middleware básico de limitación de uso.

<a name="preventing-job-overlaps"></a>
### Prevención de solapamientos de trabajos

Laravel incluye un middleware `Illuminate\Queue\Middleware\WithoutOverlapping` que permite evitar solapamientos de trabajos basándose en una clave arbitraria. Esto puede ser útil cuando un trabajo en cola está modificando un recurso que sólo debe ser modificado por un trabajo a la vez.

Por ejemplo, imaginemos que tiene un trabajo en cola que actualiza la puntuación crediticia de un usuario y desea evitar que se superpongan trabajos de actualización de puntuación crediticia para el mismo ID de usuario. Para conseguirlo, puedes devolver el middleware `WithoutOverlapping` desde el método `middleware` de tu trabajo:

    use Illuminate\Queue\Middleware\WithoutOverlapping;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [new WithoutOverlapping($this->user->id)];
    }

Cualquier trabajo solapado del mismo tipo se devolverá a la cola. También puede especificar el número de segundos que deben transcurrir antes de que el trabajo liberado se intente de nuevo:

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new WithoutOverlapping($this->order->id))->releaseAfter(60)];
    }

Si desea eliminar inmediatamente cualquier trabajo solapado para que no se vuelva a intentar, puede utilizar el método `dontRelease`:

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new WithoutOverlapping($this->order->id))->dontRelease()];
    }

El middleware `WithoutOverlapping` está potenciado por la característica de bloqueo atómico de Laravel. A veces, tu trabajo puede fallar inesperadamente o exceder el tiempo de espera de tal manera que el bloqueo no se libere. Por lo tanto, puedes definir explícitamente un tiempo de expiración del bloqueo utilizando el método `expireAfter`. Por ejemplo, el siguiente ejemplo indicará a Laravel que libere el bloqueo `WithoutOverlapping` tres minutos después de que el trabajo haya comenzado a procesarse:

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new WithoutOverlapping($this->order->id))->expireAfter(180)];
    }

> **Aviso** 
> El middleware `WithoutOverlapping` requiere un driver de cache que soporte [bloqueos atómicos](/docs/{{version}}/cache#atomic-locks). Actualmente, los drivers de cache `memcached`, `redis`, `dynamodb`, `database`, `file` y `array` soportan bloqueos atómicos.

<a name="sharing-lock-keys"></a>
#### Compartiendo Claves de Bloqueo entre Clases de Trabajos

Por defecto, el middleware `WithoutOverlapping` sólo evitará la superposición de trabajos de la misma clase. Por lo tanto, aunque dos clases de trabajos diferentes puedan utilizar la misma clave de bloqueo, no se evitará que se solapen. Sin embargo, puedes instruir a Laravel para que aplique la clave a través de las clases de trabajos utilizando el método `shared`:

```php
use Illuminate\Queue\Middleware\WithoutOverlapping;

class ProviderIsDown
{
    // ...


    public function middleware()
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}

class ProviderIsUp
{
    // ...


    public function middleware()
    {
        return [
            (new WithoutOverlapping("status:{$this->provider}"))->shared(),
        ];
    }
}
```

<a name="throttling-exceptions"></a>
### Limitación de excepciones

Laravel incluye un middleware `Illuminate\Queue\ThrottlesExceptions` que permite limitar las excepciones. Una vez que el trabajo lanza un número determinado de excepciones, todos los intentos posteriores para ejecutar el trabajo se retrasan hasta que transcurre un intervalo de tiempo especificado. Este middleware es particularmente útil para trabajos que interactúan con servicios de terceros que son inestables.

Por ejemplo, imaginemos un trabajo en cola que interactúa con una API de terceros que empieza a lanzar excepciones. Para controlar las excepciones, puedes devolver el middleware `ThrottlesExceptions` desde el método `middleware` de tu trabajo. Normalmente, este middleware debe ser usado junto con un trabajo que implemente [intentos basados en tiempo](#time-based-attempts):

    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [new ThrottlesExceptions(10, 5)];
    }

    /**
     * Determine the time at which the job should timeout.
     *
     * @return \DateTime
     */
    public function retryUntil()
    {
        return now()->addMinutes(5);
    }

El primer argumento del constructor del middleware es el número de excepciones que el trabajo puede lanzar antes de ser limitado, mientras que el segundo argumento es el número de minutos que deben transcurrir antes de que el trabajo se intente de nuevo tras haber sido limitado. En el ejemplo de código anterior, si el trabajo lanza 10 excepciones en 5 minutos, esperaremos 5 minutos antes de volver a intentarlo.

Cuando un trabajo lanza una excepción pero aún no se ha alcanzado el umbral de excepción, el trabajo normalmente se reintentará inmediatamente. Sin embargo, puedes especificar el número de minutos que un trabajo debe ser retrasado llamando al método `backoff` cuando adjuntas el middleware al trabajo:

    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new ThrottlesExceptions(10, 5))->backoff(5)];
    }

Internamente, este middleware utiliza el sistema de cache de Laravel para implementar la limitación de uso, y el nombre de la clase del trabajo se utiliza como la "clave" cache. Puedes anular esta clave llamando al método `by` cuando adjuntes el middleware a tu trabajo. Esto puede ser útil si tienes varios trabajos interactuando con el mismo servicio de terceros y quieres que compartan un "cubo" común de limitacion:

    use Illuminate\Queue\Middleware\ThrottlesExceptions;

    /**
     * Get the middleware the job should pass through.
     *
     * @return array
     */
    public function middleware()
    {
        return [(new ThrottlesExceptions(10, 10))->by('key')];
    }

> **Nota**  
> Si está utilizando Redis, puede utilizar el middleware `Illuminate\Queue\Middleware\ThrottlesExceptionsWithRedis`, que está optimizado para Redis y es más eficiente que el middleware básico de limitación de excepciones.

<a name="dispatching-jobs"></a>
## Envío de trabajos

Una vez que hayas escrito tu clase de trabajo, puedes enviarlo utilizando el método `dispatch` en el propio trabajo. Los argumentos pasados al método `dispatch` serán dados al constructor del job:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * Store a new podcast.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $podcast = Podcast::create(/* ... */);

            // ...

            ProcessPodcast::dispatch($podcast);
        }
    }

Si quieres enviar un trabajo en función de una condición, puedes usar los métodos `dispatchIf` y `dispatchUnless`:

    ProcessPodcast::dispatchIf($accountActive, $podcast);

    ProcessPodcast::dispatchUnless($accountSuspended, $podcast);

En las nuevas aplicaciones Laravel, el driver `sync` es el driver de cola por defecto. Este driver ejecuta los trabajos de forma sincrónica en el primer plano de la solicitud actual, lo que a menudo es conveniente durante el desarrollo local. Si desea comenzar a poner trabajos en cola para su procesamiento en segundo plano, puede especificar un driver de cola diferente en el archivo de configuración `config/queue.php` de su aplicación.

<a name="delayed-dispatching"></a>
### Envíos en diferido

Si desea especificar que un trabajo no debe estar disponible inmediatamente para ser procesado por un worker de cola, puede utilizar el método `delay` al enviar el trabajo. Por ejemplo, especifiquemos que un trabajo no debe estar disponible para su procesamiento hasta 10 minutos después de haber sido enviado:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * Store a new podcast.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $podcast = Podcast::create(/* ... */);

            // ...

            ProcessPodcast::dispatch($podcast)
                        ->delay(now()->addMinutes(10));
        }
    }

> **Advertencia**  
> El servicio de cola de Amazon SQS tiene un tiempo de retardo máximo de 15 minutos.

<a name="dispatching-after-the-response-is-sent-to-browser"></a>
#### Enviar después de devolver la respuesta al navegador

De manera alternativa, el método `dispatchAfterResponse` retrasa el envío de un trabajo hasta después de que la respuesta HTTP se envíe al navegador del usuario si su servidor web utiliza FastCGI. Esto permitirá al usuario comenzar a utilizar la aplicación aunque el trabajo en cola aún se esté ejecutando. Esto debería usarse típicamente sólo para trabajos que tarden alrededor de un segundo, como enviar un correo electrónico. Dado que se procesan dentro de la petición HTTP en curso, los trabajos enviados de esta forma no requieren que se esté ejecutando un worker de cola para ser procesados:

    use App\Jobs\SendNotification;

    SendNotification::dispatchAfterResponse();

También usar el helper `dispatch`  para enviar un closure y encadenar el método `afterResponse` para que el closure se ejecute después de que la respuesta HTTP haya sido enviada al navegador:

    use App\Mail\WelcomeMessage;
    use Illuminate\Support\Facades\Mail;

    dispatch(function () {
        Mail::to('taylor@example.com')->send(new WelcomeMessage);
    })->afterResponse();

<a name="synchronous-dispatching"></a>
### Envios síncronos

Si desea enviar un trabajo inmediatamente (forma síncrona), puede utilizar el método `dispatchSync`. Al utilizar este método, el trabajo no se pondrá en cola y se ejecutará inmediatamente dentro del proceso actual:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * Store a new podcast.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $podcast = Podcast::create(/* ... */);

            // Create podcast...

            ProcessPodcast::dispatchSync($podcast);
        }
    }

<a name="jobs-and-database-transactions"></a>
### Trabajos y transacciones de base de datos

Aunque es perfectamente correcto enviar trabajos dentro de transacciones de base de datos, debes tener especial cuidado para asegurarte de que tu trabajo será capaz de ejecutarse con éxito. Al enviar un trabajo dentro de una transacción, es posible que el trabajo sea procesado por un worker antes de que la transacción padre se haya confirmado. Cuando esto ocurre, cualquier actualización que se haya hecho a los modelos o registros de la base de datos durante la(s) transacción(es) de la base de datos puede no reflejarse todavía en la base de datos. Además, cualquier modelo o registro de base de datos creado durante la(s) transacción(es) puede no existir en la base de datos.

Afortunadamente, Laravel proporciona varios métodos para solucionar este problema. En primer lugar, puede establecer la opción de conexión `after_commit` en la array configuración de su conexión de cola:

    'redis' => [
        'driver' => 'redis',
        // ...
        'after_commit' => true,
    ],

Cuando la opción `after_commit` es `true`, puedes enviar trabajos dentro de transacciones de base de datos; sin embargo, Laravel esperará hasta que las transacciones de base de datos  abiertas hayan sido "commiteadas" antes de enviar el trabajo a la cola. Por supuesto, si no hay transacciones abiertas en la base de datos, el trabajo se enviará inmediatamente.

Si una transacción es revertida debido a una excepción que ocurre durante la transacción, los trabajos que fueron enviados durante esa transacción serán descartados.

> **Nota**  
> Si se establece la opción de configuración `after_commit` en `true`, causará que todos los escuchadores de eventos en cola (listeners), mailables, notificaciones y eventos de difusión sean enviados después de que todas las transacciones de base de datos abiertas se hayan "commiteado".

<a name="specifying-commit-dispatch-behavior-inline"></a>
#### Especificación del Comportamiento de Envío de Commit Inline

Si no establece la opción de configuración de conexión de cola `after_commit` en `true`, puede indicar que un trabajo específico se envíe después de que se hayan "commiteado" todas las transacciones de base de datos abiertas. Para ello, puede encadenar el método `afterCommit` a su operación de envío:

    use App\Jobs\ProcessPodcast;

    ProcessPodcast::dispatch($podcast)->afterCommit();

Del mismo modo, si la opción de configuración `after_commit` está establecida en `true`, puede indicar que un trabajo específico debe enviarse inmediatamente sin esperar a que se hayan "commiteado". ninguna transacción abierta de la base de datos:

    ProcessPodcast::dispatch($podcast)->beforeCommit();

<a name="job-chaining"></a>
### Encadenamiento de trabajos

El encadenamiento de trabajos permite especificar una lista de trabajos en cola que deben ejecutarse en secuencia después de que el trabajo principal se haya ejecutado correctamente. Si uno de los trabajos de la secuencia falla, el resto de los trabajos no se ejecutarán. Para ejecutar una cadena de trabajos en cola, puede utilizar el método `chain` proporcionado por la facade `Bus`. El bus de comandos de Laravel es un componente de nivel inferior sobre el que se basa el envío de trabajos en cola:

    use App\Jobs\OptimizePodcast;
    use App\Jobs\ProcessPodcast;
    use App\Jobs\ReleasePodcast;
    use Illuminate\Support\Facades\Bus;

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->dispatch();

Además de encadenar instancias de clases de trabajos, también puedes encadenar closures:

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        function () {
            Podcast::update(/* ... */);
        },
    ])->dispatch();

> **Advertencia**  
> Eliminar trabajos usando el método `$this->delete()` dentro del trabajo no impedirá que los trabajos encadenados sean procesados. La cadena sólo dejará de ejecutarse si un trabajo de la cadena falla.

<a name="chain-connection-queue"></a>
#### Conexión y Cola de la Cadena

Si desea especificar la conexión y la cola que deben utilizarse para los trabajos encadenados, puede utilizar los métodos `onConnection` y `onQueue`. Estos métodos especifican la conexión y el nombre de la cola que deben utilizarse a menos que al trabajo encadenado se le asigne explícitamente una conexión / cola diferente:

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->onConnection('redis')->onQueue('podcasts')->dispatch();

<a name="chain-failures"></a>
#### Fallos en cadena

Al encadenar trabajos, puede utilizar el método `catch` para especificar un closure que debe ser invocado si un trabajo dentro de la cadena falla. La llamada de retorno recibirá la instancia `Throwable` que causó el fallo:

    use Illuminate\Support\Facades\Bus;
    use Throwable;

    Bus::chain([
        new ProcessPodcast,
        new OptimizePodcast,
        new ReleasePodcast,
    ])->catch(function (Throwable $e) {
        // A job within the chain has failed...
    })->dispatch();

> {nota} Dado que los callbacks de cadena son serializados y ejecutados posteriormente por la cola de Laravel, no se debe utilizar la variable `$this` dentro de los mismos.

<a name="customizing-the-queue-and-connection"></a>
### Personalización de la cola y la conexión

<a name="dispatching-to-a-particular-queue"></a>
#### Envío a una cola concreta

Enviando trabajos a diferentes colas, puedes "categorizarlos" e incluso priorizar cuántos workers asignas a varias colas. Tenga en cuenta que esto no envía los trabajos a diferentes "conexiones" de colas como se define en su archivo de configuración de colas, sino sólo a colas específicas dentro de una única conexión. Para especificar la cola, utilice el método `onQueue` al enviar el trabajo:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * Store a new podcast.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $podcast = Podcast::create(/* ... */);

            // Create podcast...

            ProcessPodcast::dispatch($podcast)->onQueue('processing');
        }
    }

De manera alternativa, puedes especificar la cola del trabajo llamando al método `onQueue` dentro del constructor del trabajo:

    <?php

    namespace App\Jobs;

     use Illuminate\Bus\Queueable;
     use Illuminate\Contracts\Queue\ShouldQueue;
     use Illuminate\Foundation\Bus\Dispatchable;
     use Illuminate\Queue\InteractsWithQueue;
     use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * Create a new job instance.
         *
         * @return void
         */
        public function __construct()
        {
            $this->onQueue('processing');
        }
    }

<a name="dispatching-to-a-particular-connection"></a>
#### Envío a una conexión particular

Si tu aplicación interactúa con múltiples conexiones de cola, puedes especificar a qué conexión enviar un trabajo utilizando el método `onConnection`:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Jobs\ProcessPodcast;
    use App\Models\Podcast;
    use Illuminate\Http\Request;

    class PodcastController extends Controller
    {
        /**
         * Store a new podcast.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            $podcast = Podcast::create(/* ... */);

            // Create podcast...

            ProcessPodcast::dispatch($podcast)->onConnection('sqs');
        }
    }

Puedes encadenar los métodos `onConnection` y `onQueue` para especificar la conexión y la cola de un trabajo:

    ProcessPodcast::dispatch($podcast)
                  ->onConnection('sqs')
                  ->onQueue('processing');

De manera alternativa, puedes especificar la conexión del trabajo llamando al método `onConnection` dentro del constructor del trabajo:

    <?php

    namespace App\Jobs;

     use Illuminate\Bus\Queueable;
     use Illuminate\Contracts\Queue\ShouldQueue;
     use Illuminate\Foundation\Bus\Dispatchable;
     use Illuminate\Queue\InteractsWithQueue;
     use Illuminate\Queue\SerializesModels;

    class ProcessPodcast implements ShouldQueue
    {
        use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * Create a new job instance.
         *
         * @return void
         */
        public function __construct()
        {
            $this->onConnection('sqs');
        }
    }

<a name="max-job-attempts-and-timeout"></a>
### Especificación de Máximos Intentos de Trabajo / Valores de Tiempo de Espera

<a name="max-attempts"></a>
#### Número máximo de intentos

Si uno de tus trabajos en cola se encuentra con un error, es probable que no quieras que siga reintentándolo indefinidamente. Por lo tanto, Laravel proporciona varias maneras de especificar cuántas veces o durante cuánto tiempo se puede intentar un trabajo.

Una forma de especificar el número máximo de veces que un trabajo puede ser intentado es a través del parámetro `--tries` en la línea de comandos de Artisan. Esto se aplicará a todos los trabajos procesados por el worker a menos que el trabajo que está siendo procesado especifique el número de veces que puede ser intentado:

```shell
php artisan queue:work --tries=3
```

Si un trabajo supera su número máximo de intentos, se considerará un trabajo "fallido". Para obtener más información sobre la gestión de trabajos fallidos, consulte la [documentación sobre trabajos fallidos](#dealing-with-failed-jobs). Si se proporciona `--tries=0` al comando `queue:` work, el trabajo se reintentará indefinidamente.

Puede adoptar un enfoque más granular definiendo el número máximo de veces que un trabajo puede ser intentado en la propia clase de trabajo. Si el número máximo de intentos se especifica en el trabajo, tendrá prioridad sobre el valor `--tries` proporcionado en la línea de comandos:

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

<a name="time-based-attempts"></a>
#### Intentos basados en el tiempo

Como alternativa a la definición de cuántas veces se puede intentar un trabajo antes de que falle, puede definir un tiempo en el que el trabajo ya no debe intentarse. Esto permite que un trabajo se intente cualquier número de veces dentro de un periodo de tiempo determinado. Para definir el momento en el que un trabajo ya no debe intentarse, añada un método `retryUntil` a su clase job. Este método debe devolver una instancia `DateTime`:

    /**
     * Determine the time at which the job should timeout.
     *
     * @return \DateTime
     */
    public function retryUntil()
    {
        return now()->addMinutes(10);
    }

> **Nota**  
> También puede definir una propiedad `tries` o un método `retryUntil` en sus [escuchadores de eventos en cola](/docs/{{version}}/events#queued-event-listeners).

<a name="max-exceptions"></a>
#### Excepciones máximas

A veces puede que desee especificar que un trabajo puede ser intentado muchas veces, pero debe fallar si los reintentos son desencadenados por un número determinado de excepciones no manejadas (en lugar de ser liberado por el método `release` directamente). Para conseguir esto, puedes definir una propiedad `maxExceptions` en tu clase de trabajo:

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
         *
         * @return void
         */
        public function handle()
        {
            Redis::throttle('key')->allow(10)->every(60)->then(function () {
                // Lock obtained, process the podcast...
            }, function () {
                // Unable to obtain lock...
                return $this->release(10);
            });
        }
    }

En este ejemplo, el trabajo es liberado durante diez segundos si la aplicación es incapaz de obtener un bloqueo de Redis y continuará siendo reintentado hasta 25 veces. Sin embargo, el trabajo fallará si tres excepciones no manejadas son lanzadas por el trabajo.

<a name="timeout"></a>
#### Tiempo de espera (Timeout)

> **Advertencia**  
> La extensión PHP `pcntl` debe estar instalada para poder especificar los tiempos de espera de los trabajos.

A menudo, sabes aproximadamente cuánto tiempo esperas que tarden tus trabajos en cola. Por esta razón, Laravel te permite especificar un valor de "timeout". Por defecto, el valor de tiempo de espera es de 60 segundos. Si un trabajo se está procesando durante más tiempo que el número de segundos especificado por el valor de tiempo de espera, el worker que procesa el trabajo saldrá con un error. Normalmente, el worker será reiniciado automáticamente por un [gestor de procesos configurado en tu servidor](#supervisor-configuration).

El número máximo de segundos que los trabajos pueden ser ejecutados puede ser especificado utilizando el parámetro `--timeout` en la línea de comandos de Artisan:

```shell
php artisan queue:work --timeout=30
```

Si el trabajo excede su máximo de intentos por timeout continuo, será marcado como fallido.

También puedes definir el número máximo de segundos que un trabajo puede ejecutarse en la propia clase de trabajo. Si el tiempo de espera se especifica en el trabajo, tendrá prioridad sobre cualquier tiempo de espera especificado en la línea de comandos:

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

A veces, los procesos de bloqueo IO como sockets o conexiones HTTP salientes pueden no respetar el timeout especificado. Por lo tanto, al utilizar estas funciones, siempre debe intentar especificar un timeout utilizando también sus API. Por ejemplo, al utilizar Guzzle, siempre debe especificar un valor de timeout para la conexión y la solicitud.

<a name="failing-on-timeout"></a>
#### Fallo por Timeout

Si desea indicar que un trabajo debe ser marcado como [fallido](#dealing-with-failed-jobs) cuando se produce un timeout, puede definir la propiedad `$failOnTimeout` en la clase job:

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

Si se lanza una excepción mientras el trabajo está siendo procesado, el trabajo será automáticamente devuelto a la cola para que pueda ser intentado de nuevo. El trabajo continuará siendo liberado hasta que se haya intentado el número máximo de veces permitido por su aplicación. El número máximo de intentos se define mediante el parámetro `--tries` utilizado en el comando `queue:work` de Artisan. De manera alternativa, el número máximo de intentos puede definirse en la propia clase de trabajo. Encontrará más información sobre la ejecución del worker de cola [en este mismo documento](#running-the-queue-worker).

<a name="manually-releasing-a-job"></a>
#### Liberación manual de un trabajo

A veces es posible que desee liberar manualmente un trabajo de nuevo en la cola para que se pueda intentar de nuevo posteriormente. Para ello, llame al método `release`:

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        // ...

        $this->release();
    }

Por defecto, el método `release` devolverá el trabajo a la cola para su procesamiento inmediato. Sin embargo, si le pasas un número entero al método `release`, puedes indicar a la cola que no libere el trabajo para su procesamiento hasta que haya transcurrido un determinado número de segundos:

    $this->release(10);

<a name="manually-failing-a-job"></a>
#### Fallo manual de un trabajo

Ocasionalmente puede necesitar marcar manualmente un trabajo como "fallido". Para ello, puede llamar al método `fail`:

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        // ...

        $this->fail();
    }

Si quieres marcar tu trabajo como fallido debido a una excepción que hayas capturado, puedes pasar la excepción al método `fail`:

    $this->fail($exception);

> **Nota**  
> Para más información sobre trabajos fallidos, consulte la [documentación sobre cómo tratar los fallos de trabajos](#dealing-with-failed-jobs).

<a name="job-batching"></a>
## Trabajo por lotes

La característica de trabajo por lotes (batches) de Laravel te permite ejecutar fácilmente un lote de trabajos y luego realizar alguna acción cuando el lote de trabajos haya terminado de ejecutarse. Antes de empezar, deberías crear una migración de base de datos para construir una tabla que contenga meta información sobre tus lotes de trabajos, como su porcentaje de finalización. Esta migración puede ser generada utilizando el comando `queue:batches-table` de Artisan:

```shell
php artisan queue:batches-table

php artisan migrate
```

<a name="defining-batchable-jobs"></a>
### Definición de Trabajos por Lotes

Para definir un trabajo por lotes, debe [crear un trabajo](#creating-jobs) de forma normal; sin embargo, debe añadir el trait `Illuminate\Bus\Batchable` a la clase job. Este trait proporciona acceso a un método de `batch` que puede utilizarse para recuperar el lote actual en el que se está ejecutando el trabajo:

    <?php

    namespace App\Jobs;

    use Illuminate\Bus\Batchable;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Foundation\Bus\Dispatchable;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;

    class ImportCsv implements ShouldQueue
    {
        use Batchable, Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

        /**
         * Execute the job.
         *
         * @return void
         */
        public function handle()
        {
            if ($this->batch()->cancelled()) {
                // Determine if the batch has been cancelled...

                return;
            }

            // Import a portion of the CSV file...
        }
    }

<a name="dispatching-batches"></a>
### Envío de lotes

Para enviar un lote de trabajos, debes utilizar el método `batch` de la facade `Bus`. Por supuesto, el envío por lotes es principalmente útil cuando se combina con llamadas de finalización. Por lo tanto, puede utilizar los métodos `then`, `catch` y `finally` para definir retrollamadas de finalización para el lote. Cada una de estas retrollamadas recibirá una instancia `Illuminate\Bus\Batch` cuando sean invocadas. En este ejemplo, imaginaremos que estamos poniendo en cola un lote de trabajos que procesan un número determinado de filas de un archivo CSV:

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
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->catch(function (Batch $batch, Throwable $e) {
        // First batch job failure detected...
    })->finally(function (Batch $batch) {
        // The batch has finished executing...
    })->dispatch();

    return $batch->id;

El ID del lote, al que se puede acceder mediante la propiedad `$batch->id`, se puede utilizar para [consultar el bus de comandos de Laravel](#inspecting-batches) para obtener información sobre el lote después de que haya sido enviado.

> **Advertencia**  
> Dado que los callbacks de los lotes son serializados y ejecutados posteriormente por la cola de Laravel, no debes utilizar la variable `$this` dentro de los callbacks.

<a name="naming-batches"></a>
#### Nombrando Lotes

Algunas herramientas como Laravel Horizon y Laravel Telescope pueden proporcionar información de depuración más fácil de usar para los lotes si éstos tienen un nombre. Para asignar un nombre arbitrario a un lote, puede llamar al método `name` mientras define el lote:

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->name('Import CSV')->dispatch();

<a name="batch-connection-queue"></a>
#### Conexión y cola de lotes

Si desea especificar la conexión y la cola que deben utilizarse para los trabajos por lotes, puede utilizar los métodos `onConnection` y `onQueue`. Todos los trabajos por lotes deben ejecutarse dentro de la misma conexión y cola:

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->onConnection('redis')->onQueue('imports')->dispatch();

<a name="chains-within-batches"></a>
#### Cadenas dentro de lotes

Puede definir un conjunto de [trabajos encadenados](#job-chaining) dentro de un lote colocando los trabajos encadenados dentro de un array. Por ejemplo, podemos ejecutar dos cadenas de trabajos en paralelo y ejecutar una llamada de retorno cuando ambas cadenas de trabajos hayan terminado de procesarse:

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

<a name="adding-jobs-to-batches"></a>
### Añadir trabajos a lotes

A veces puede ser útil añadir trabajos adicionales a un lote desde dentro de un trabajo encadenado. Este patrón puede ser útil cuando se necesita procesar por lotes miles de trabajos que pueden tardar demasiado en despacharse durante una petición web. Así que, en su lugar, puede que desee despachar un lote inicial de trabajos "cargadores" que hidraten el lote con aún más trabajos:

    $batch = Bus::batch([
        new LoadImportBatch,
        new LoadImportBatch,
        new LoadImportBatch,
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->name('Import Contacts')->dispatch();

En este ejemplo, utilizaremos el trabajo `LoadImportBatch` para hidratar el lote con trabajos adicionales. Para lograrlo, podemos utilizar el método `add` en la instancia batch a la que se puede acceder a través del método `batch` del trabajo:

    use App\Jobs\ImportContacts;
    use Illuminate\Support\Collection;

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        if ($this->batch()->cancelled()) {
            return;
        }

        $this->batch()->add(Collection::times(1000, function () {
            return new ImportContacts;
        }));
    }

> **Aviso**  
> Sólo se pueden añadir trabajos a un lote desde dentro de un trabajo que pertenezca al mismo lote.

<a name="inspecting-batches"></a>
### Inspección de lotes

La instancia `Illuminate\Bus\Batch` que se proporciona a las retrollamadas de finalización de lote tiene una variedad de propiedades y métodos para ayudarle a interactuar e inspeccionar un determinado lote de trabajos:

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

<a name="returning-batches-from-routes"></a>
#### Devolución de lotes desde rutas

Todas las instancias `Illuminate\Bus\Batch` son serializables JSON, lo que significa que puede devolverlas directamente desde una de las rutas de su aplicación para recuperar una carga útil JSON que contenga información sobre el lote, incluido su progreso de finalización. Esto hace que sea conveniente mostrar información sobre el progreso de finalización del lote en la interfaz de usuario de su aplicación.

Para recuperar un lote por su ID, puede utilizar el método `findBatch` de la facade `Bus`:

    use Illuminate\Support\Facades\Bus;
    use Illuminate\Support\Facades\Route;

    Route::get('/batch/{batchId}', function (string $batchId) {
        return Bus::findBatch($batchId);
    });

<a name="cancelling-batches"></a>
### Cancelación de lotes

A veces puede ser necesario cancelar la ejecución de un lote determinado. Para ello, llame al método `cancel` de la instancia `Illuminate\Bus\Batch`:

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        if ($this->user->exceedsImportLimit()) {
            return $this->batch()->cancel();
        }

        if ($this->batch()->cancelled()) {
            return;
        }
    }

Como habrá observado en ejemplos anteriores, los trabajos por lotes normalmente deben comprobar si el lote ha sido cancelado al principio de su método `handle`:

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        if ($this->batch()->cancelled()) {
            return;
        }

        // Continue processing...
    }

<a name="batch-failures"></a>
### Fallos de lotes

Cuando un trabajo por lotes falla, la llamada de retorno `catch` (si está asignada) será invocada. Esta llamada de retorno sólo se invoca para el primer trabajo que falla dentro del lote.

<a name="allowing-failures"></a>
#### Permitir fallos

Cuando un trabajo dentro de un lote falla, Laravel marcará automáticamente el lote como "cancelado". Si lo desea, puede desactivar este comportamiento para que el fallo de un trabajo no marque automáticamente el lote como cancelado. Esto puede lograrse llamando al método `allowFailures` mientras se despacha el lote:

    $batch = Bus::batch([
        // ...
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->allowFailures()->dispatch();

<a name="retrying-failed-batch-jobs"></a>
#### Reintentar trabajos por lotes fallidos

Para mayor comodidad, Laravel proporciona un comando Artisan `queue:retry-batch` que permite reintentar fácilmente todos los trabajos fallidos de un lote determinado. El comando `queue:re` try-batch acepta el UUID del lote cuyos trabajos fallidos deben ser reintentados:

```shell
php artisan queue:retry-batch 32dbc76c-4f82-4749-b610-a639fe0099b5
```

<a name="pruning-batches"></a>
### Limpiando lotes

Sin mantenimiento, la tabla `job_batches` puede acumular registros muy rápidamente. Para mitigar esto, debe [programar](/docs/{{version}}/scheduling) el comando `queue:prune-batches` de Artisan para que se ejecute diariamente:

    $schedule->command('queue:prune-batches')->daily();

Por defecto, se eliminarán todos los lotes finalizados que tengan más de 24 horas de antigüedad. Puede utilizar la opción `hours` al llamar al comando para determinar durante cuánto tiempo se conservarán los datos del lote. Por ejemplo, el siguiente comando eliminará todos los lotes que hayan finalizado hace más de 48 horas:

    $schedule->command('queue:prune-batches --hours=48')->daily();

A veces, la tabla `jobs_batches` puede acumular registros de lotes que nunca se completaron con éxito, como lotes en los que un trabajo falló y nunca se volvió a intentar con éxito. Puede indicar al comando `queue:prune-batches` que elimine estos registros de lotes inacabados mediante la opción `unfinished`:

    $schedule->command('queue:prune-batches --hours=48 --unfinished=72')->daily();

Del mismo modo, la tabla `jobs_batches` también puede acumular registros de lotes cancelados. Puede indicar al comando `queue:prune-batches` que elimine estos registros de lotes cancelados mediante la opción `cancelled`:

    $schedule->command('queue:prune-batches --hours=48 --cancelled=72')->daily();

<a name="queueing-closures"></a>
## Closures de colas

En lugar de enviar una clase de trabajo a la cola, también puede enviar un closure. Esto es ideal para tareas rápidas y sencillas que deben ejecutarse fuera del ciclo de solicitud actual. Cuando se envían closures a la cola, el contenido del código del closure se firma criptográficamente para que no pueda ser modificado en tránsito:

    $podcast = App\Podcast::find(1);

    dispatch(function () use ($podcast) {
        $podcast->publish();
    });

Utilizando el método `catch`, puede proporcionar un closure que debe ejecutarse si el closure en cola no se completa con éxito después de agotar todos los [reintentos configurados](#max-job-attempts-and-timeout) en su cola:

    use Throwable;

    dispatch(function () use ($podcast) {
        $podcast->publish();
    })->catch(function (Throwable $e) {
        // This job has failed...
    });

> {nota} Dado que los callbacks `catch` son serializados y ejecutados posteriormente por la cola de Laravel, no se debe utilizar la variable `$this` dentro de los callbacks `catch`.

<a name="running-the-queue-worker"></a>
## Ejecución del Queue Worker

<a name="the-queue-work-command"></a>
### El comando `queue:work`

Laravel incluye un comando Artisan que iniciará un worker de cola y procesará nuevos trabajos a medida que son enviados a la cola. Puedes ejecutar el worker usando el comando Artisan `queue:work`. Ten en cuenta que una vez que el comando `queue:work` se ha iniciado, continuará ejecutándose hasta que se detenga manualmente o hasta que cierres tu terminal:

```shell
php artisan queue:work
```

> **Nota**  
> Para mantener el proceso `queue:work` ejecutándose permanentemente en segundo plano, debe utilizar un monitor de procesos como [Supervisor](#supervisor-configuration) para asegurarse de que el worker de cola no deja de ejecutarse.

Puede incluir la bandera `-v` cuando invoque el comando `queue:work` si desea que los IDs de los trabajos procesados sean incluidos en la salida del comando:

```shell
php artisan queue:work -v
```

Recuerde que los queue workers (trabajdores de colas) son procesos de larga duración y almacenan el estado de la aplicación arrancada en memoria. Como resultado, no notarán cambios en tu código base después de haber sido iniciados. Así que, durante tu proceso de despliegue, asegúrate de [reiniciar](#queue-workers-and-deployment) tus queue workers. Además, recuerde que cualquier estado estático creado o modificado por su aplicación no se restablecerá automáticamente entre trabajos.

De manera alternativa, puedes ejecutar el comando `queue:listen`. Cuando se utiliza el comando `queue:listen`, no es necesario reiniciar manualmente el worker cuando se desea recargar el código actualizado o restablecer el estado de la aplicación; sin embargo, este comando es significativamente menos eficiente que el comando `queue:work`

```shell
php artisan queue:listen
```

<a name="running-multiple-queue-workers"></a>
#### Ejecución de múltiples Queue Workers

Para asignar múltiples workers a una cola y procesar trabajos concurrentemente, simplemente debes iniciar múltiples procesos `queue:work`. Esto puede hacerse localmente a través de múltiples pestañas en su terminal o en producción utilizando los ajustes de configuración de su gestor de procesos. [Cuando utilice Supervisor](#supervisor-configuration), puede utilizar el valor de configuración `numprocs`.

<a name="specifying-the-connection-queue"></a>
#### Especificando la Conexión y la Cola

También puede especificar qué conexión de cola debe utilizar el worker. El nombre de la conexión pasada al comando `work` debe corresponder a una de las conexiones definidas en su archivo de configuración `config/queue.` php:

```shell
php artisan queue:work redis
```

Por defecto, el comando `queue:work` sólo procesa trabajos para la cola por defecto en una conexión dada. Sin embargo, puede personalizar su worker de colas aún más procesando sólo colas particulares para una conexión dada. Por ejemplo, si todos tus correos electrónicos se procesan en una cola de `emails` en tu conexión de cola `redis`, puedes ejecutar el siguiente comando para iniciar un worker que sólo procese esa cola:

```shell
php artisan queue:work redis --queue=emails
```

<a name="processing-a-specified-number-of-jobs"></a>
#### Procesando un número especificado de trabajos

La opción `--once` se puede utilizar para indicar al worker que sólo procese un único trabajo de la cola:

```shell
php artisan queue:work --once
```

La opción `--max-jobs` puede utilizarse para indicar al worker que procese el número de trabajos dado y luego salga. Esta opción puede ser útil cuando se combina con [Supervisor](#supervisor-configuration) para que sus workers se reinicien automáticamente después de procesar un número determinado de trabajos, liberando la memoria que puedan haber acumulado:

```shell
php artisan queue:work --max-jobs=1000
```

<a name="processing-all-queued-jobs-then-exiting"></a>
#### Procesar todos los trabajos en cola y salir

La opción `--stop-when-empty` puede utilizarse para indicar al worker que procese todos los trabajos y luego salga de la cola. Esta opción puede ser útil cuando se procesan colas Laravel dentro de un contenedor Docker si desea cerrar el contenedor después de la cola está vacía:

```shell
php artisan queue:work --stop-when-empty
```

<a name="processing-jobs-for-a-given-number-of-seconds"></a>
#### Procesamiento de trabajos durante un número determinado de segundos

La opción `--max-time` puede utilizarse para indicar al worker que procese los trabajos durante un número determinado de segundos y luego salga. Esta opción puede ser útil cuando se combina con [Supervisor](#supervisor-configuration) para que sus workers se reinicien automáticamente después de procesar trabajos durante un tiempo determinado, liberando la memoria que puedan haber acumulado:

```shell
# Process jobs for one hour and then exit...
php artisan queue:work --max-time=3600
```

<a name="worker-sleep-duration"></a>
#### Duración del reposo del worker

Cuando haya trabajos disponibles en la cola, el worker seguirá procesando trabajos sin demora entre ellos. Sin embargo, la opción `sleep` determina cuántos segundos "dormirá" el worker si no hay nuevos trabajos disponibles. Mientras duerme, el worker no procesará nuevos trabajos - los trabajos serán procesados después de que el worker se despierte de nuevo.

```shell
php artisan queue:work --sleep=3
```

<a name="resource-considerations"></a>
#### Consideraciones sobre los recursos

Los workers de cola daemon no "reinician" la estructura antes de procesar cada trabajo. Por lo tanto, debes liberar cualquier recurso pesado después de completar cada trabajo. Por ejemplo, si está manipulando imágenes con la librería GD, debe liberar la memoria con `imagedestroy` cuando termine de procesar la imagen.

<a name="queue-priorities"></a>
### Prioridades de la cola

A veces es posible que desee dar prioridad a cómo se procesan las colas. Por ejemplo, en tu archivo de configuración `config/queue.php`, puedes establecer la cola `low` como la cola por defecto para tu conexión `redis`. Sin embargo, ocasionalmente puede que desee enviar un trabajo a una cola llamada `high` como esta:

    dispatch((new Job)->onQueue('high'));

Para iniciar un worker que verifique que todos los trabajos de la cola `high` son procesados antes de continuar con cualquier trabajo de la cola `low`, pase una lista delimitada por comas de nombres de colas al comando `work`:

```shell
php artisan queue:work --queue=high,low
```

<a name="queue-workers-and-deployment"></a>
### Workers de cola y despliegue

Dado que los workers de cola son procesos de larga duración, no notarán los cambios en su código sin ser reiniciados. Por lo tanto, la forma más sencilla de desplegar una aplicación utilizando workers de cola es reiniciar los workers durante el proceso de despliegue. Puedes reiniciar todos los workers de forma automática mediante el comando `queue:restart`:

```shell
php artisan queue:restart
```

Este comando ordenará a todos los workers de la cola que salgan de forma ordenada cuando terminen de procesar su trabajo actual, de forma que no se pierda ningún trabajo existente. Dado que los workers de la cola saldrán cuando se ejecute el comando `queue:restart`, debe ejecutar un gestor de procesos como [Supervisor](#supervisor-configuration) para reiniciar automáticamente los workers de la cola.

> **Nota**  
> La cola utiliza la [cache](/docs/{{version}}/cache) para almacenar las señales de reinicio, por lo que debe verificar que un driver de cache está configurado correctamente para su aplicación antes de utilizar esta función.

<a name="job-expirations-and-timeouts"></a>
### Expiración de trabajos y tiempos de espera (timeouts)

<a name="job-expiration"></a>
#### Expiración de trabajos

En el archivo de configuración `config/queue.php`, cada conexión de cola define una opción `retry_after`. Esta opción especifica cuántos segundos debe esperar la conexión de cola antes de reintentar un trabajo que está siendo procesado. Por ejemplo, si el valor de `retry_after` se establece en `90`, el trabajo será liberado de nuevo a la cola si ha estado procesándose durante 90 segundos sin ser liberado o eliminado. Por lo general, usted debe establecer el valor de `retry_after` al número máximo de segundos que sus trabajos deben tomar para completar el procesamiento.

> **Advertencia**  
> La única conexión de cola que no contiene un valor `retry_after` es Amazon SQS. SQS reintentará el trabajo basándose en el [Default Visibility Timeout](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/AboutVT.html) que se gestiona en la consola de AWS.

<a name="worker-timeouts"></a>
#### Tiempos de espera de los Workers

El comando `queue:work` Artisan expone una opción `--timeout`. Por defecto, el valor de `--timeout` es de 60 segundos. Si un trabajo se está procesando durante más tiempo que el número de segundos especificado por el valor de tiempo de espera, el worker que procesa el trabajo saldrá con un error. Normalmente, el worker será reiniciado automáticamente por un [gestor de procesos configurado en tu servidor](#supervisor-configuration):

```shell
php artisan queue:work --timeout=60
```

La opción de configuración `retry_after` y la opción CLI `--timeout` son diferentes, pero trabajan juntas para asegurar que los trabajos no se pierdan y que los trabajos sólo se procesen con éxito una vez.

> **Advertencia**  
> El valor de `--timeout` debe ser siempre al menos varios segundos más corto que el valor de configuración de `retry_after`. Esto asegurará que un worker procesando un trabajo congelado siempre termine antes de que el trabajo sea reintentado. Si su opción `--timeout` es más larga que su valor de configuración `retry_after`, sus trabajos pueden ser procesados dos veces.

<a name="supervisor-configuration"></a>
## Configuración de Supervisor

En producción, necesitas una forma de mantener tus procesos `queue:work` funcionando. Un proceso `queue:work` puede dejar de ejecutarse por una variedad de razones, tales como un tiempo de espera excedido del worker o la ejecución del comando `queue:restart`.

Por esta razón, necesitas configurar un monitor de procesos que pueda detectar cuando tus procesos `queue`:work salen y reiniciarlos automáticamente. Además, los monitores de procesos pueden permitirle especificar cuántos procesos `queue`:work desea ejecutar simultáneamente. Supervisor es un monitor de procesos comúnmente utilizado en entornos Linux y discutiremos cómo configurarlo en la siguiente documentación.

<a name="installing-supervisor"></a>
#### Instalación de Supervisor

Supervisor es un monitor de procesos para el sistema operativo Linux que reiniciará automáticamente sus procesos `queue:work` si fallan. Para instalar Supervisor en Ubuntu, puede utilizar el siguiente comando:

```shell
sudo apt-get install supervisor
```

> **Nota**  
> Si configurar y administrar Supervisor usted mismo suena abrumador, considere el uso de [Laravel Forge](https://forge.laravel.com), que instalará y configurará automáticamente Supervisor para sus proyectos Laravel en producción.

<a name="configuring-supervisor"></a>
#### Configuración de Supervisor

Los archivos de configuración de Supervisor se almacenan normalmente en el directorio `/etc/supervisor/conf.d`. Dentro de este directorio, puede crear cualquier número de archivos de configuración que indiquen a Supervisor cómo deben ser monitorizados sus procesos. Por ejemplo, creemos un fichero `laravel-worker.conf` que inicie y monitorice los procesos `queue:work`:

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

En este ejemplo, la directiva `numprocs` indicará a Supervisor que ejecute ocho procesos `queue:work` y los monitorice todos, reiniciándolos automáticamente si fallan. Deberá cambiar la directiva `command` de la configuración para reflejar sus opciones deseadas de conexión a colas y workers.

> **Advertencia**  
> Debe asegurarse de que el valor de `stopwaitsecs` es mayor que el número de segundos consumidos por su trabajo en ejecución más largo. De lo contrario, Supervisor puede matar el trabajo antes de que termine de procesarse.

<a name="starting-supervisor"></a>
#### Arrancar Supervisor

Una vez creado el fichero de configuración, puede actualizar la configuración de Supervisor e iniciar los procesos utilizando los siguientes comandos:

```shell
sudo supervisorctl reread

sudo supervisorctl update

sudo supervisorctl start laravel-worker:*
```

Para más información sobre Supervisor, consulte la [documentación de Supervisor](http://supervisord.org/index.html).

<a name="dealing-with-failed-jobs"></a>
## Trabajos fallidos

A veces sus trabajos en cola fallarán. No te preocupes, ¡las cosas no siempre salen según lo planeado! Laravel incluye una forma conveniente de [especificar el número máximo de veces que un trabajo debe ser intentado](#max-job-attempts-and-timeout). Después de que un trabajo asíncrono haya superado este número de intentos, se insertará en la tabla de base de datos `failed_jobs`. Los trabajos [síncronos](/docs/{{version}}/queues#synchronous-dispatching) que fallan no se almacenan en esta tabla y sus excepciones son gestionadas inmediatamente por la aplicación.

Una migración para crear la tabla `failed_jobs` suele estar ya presente en las nuevas aplicaciones Laravel. Sin embargo, si su aplicación no contiene una migración para esta tabla, puede utilizar el comando `queue:failed-table` para crear la migración:

```shell
php artisan queue:failed-table

php artisan migrate
```

Cuando se ejecuta un proceso [queue worker](#running-the-queue-worker), se puede especificar el número máximo de veces que se debe intentar un trabajo utilizando el modificador `--tries` en el comando `queue:work`. Si no especifica un valor para la opción `--tries`, los trabajos sólo se intentarán una vez o tantas veces como especifique la propiedad `$tries` de la clase job:

```shell
php artisan queue:work redis --tries=3
```

Usando la opción `--backoff`, puedes especificar cuántos segundos Laravel debe esperar antes de reintentar un trabajo que ha encontrado una excepción. Por defecto, un trabajo se devuelve inmediatamente a la cola para que pueda intentarse de nuevo:

```shell
php artisan queue:work redis --tries=3 --backoff=3
```

Si desea configurar por trabajo cuántos segundos debe esperar Laravel antes de reintentar un trabajo que se ha encontrado con una excepción, puede hacerlo mediante la definición de una propiedad `backoff` en su clase de trabajo:

    /**
     * The number of seconds to wait before retrying the job.
     *
     * @var int
     */
    public $backoff = 3;

Si necesitas una lógica más compleja para determinar el tiempo de reintento de la tarea, puedes definir un método de `backoff` en tu clase de tarea:

    /**
    * Calculate the number of seconds to wait before retrying the job.
    *
    * @return int
    */
    public function backoff()
    {
        return 3;
    }

Puede configurar fácilmente reintentos "exponenciales" devolviendo un array de valores de reintento desde el método de `backoff`. En este ejemplo, el retardo de reintento será de 1 segundo para el primer reintento, 5 segundos para el segundo reintento y 10 segundos para el tercer reintento:

    /**
    * Calculate the number of seconds to wait before retrying the job.
    *
    * @return array
    */
    public function backoff()
    {
        return [1, 5, 10];
    }

<a name="cleaning-up-after-failed-jobs"></a>
### Limpieza de trabajos fallidos

Cuando un trabajo en particular falla, es posible que desee enviar una alerta a sus usuarios o revertir las acciones que fueron parcialmente completadas por el trabajo. Para ello, puedes definir un método `failed` en tu clase de trabajo. La instancia de `Throwable` que causó el fallo del trabajo se pasará al método `failed`:

    <?php

    namespace App\Jobs;

    use App\Models\Podcast;
    use App\Services\AudioProcessor;
    use Illuminate\Bus\Queueable;
    use Illuminate\Contracts\Queue\ShouldQueue;
    use Illuminate\Queue\InteractsWithQueue;
    use Illuminate\Queue\SerializesModels;
    use Throwable;

    class ProcessPodcast implements ShouldQueue
    {
        use InteractsWithQueue, Queueable, SerializesModels;

        /**
         * The podcast instance.
         *
         * @var \App\Podcast
         */
        public $podcast;

        /**
         * Create a new job instance.
         *
         * @param  \App\Models\Podcast  $podcast
         * @return void
         */
        public function __construct(Podcast $podcast)
        {
            $this->podcast = $podcast;
        }

        /**
         * Execute the job.
         *
         * @param  \App\Services\AudioProcessor  $processor
         * @return void
         */
        public function handle(AudioProcessor $processor)
        {
            // Process uploaded podcast...
        }

        /**
         * Handle a job failure.
         *
         * @param  \Throwable  $exception
         * @return void
         */
        public function failed(Throwable $exception)
        {
            // Send user notification of failure, etc...
        }
    }

> **Advertencia**  
> Una nueva instancia del trabajo es instanciada antes de invocar el método `failed`; por lo tanto, cualquier modificación de las propiedades de la clase que pueda haber ocurrido dentro del método `handle` se perderá.

<a name="retrying-failed-jobs"></a>
### Reintento de trabajos fallidos

Para ver todos los trabajos fallidos que han sido insertados en su tabla de base de datos `failed_jobs`, puede utilizar el comando queue: `failed` de Artisan:

```shell
php artisan queue:failed
```

El comando `queue:failed` listará el ID del trabajo, la conexión, la cola, el timeout y otra información sobre el trabajo. El ID del trabajo puede ser utilizado para reintentar el trabajo fallido. Por ejemplo, para reintentar un trabajo fallido que tiene un ID de `ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece`, emita el siguiente comando:

```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece
```

Si es necesario, puede pasar varios ID al comando:

```shell
php artisan queue:retry ce7bb17c-cdd8-41f0-a8ec-7b4fef4e5ece 91401d2c-0784-4f43-824c-34f94a33c24d
```

También puede reintentar todos los trabajos fallidos de una cola en particular:

```shell
php artisan queue:retry --queue=name
```

Para reintentar todos los trabajos fallidos, ejecute el comando `queue:retry` y pase `all` como ID:

```shell
php artisan queue:retry all
```

Si desea eliminar un trabajo fallido, puede utilizar el comando `queue:forget`:

```shell
php artisan queue:forget 91401d2c-0784-4f43-824c-34f94a33c24d
```

> **Nota**  
> Cuando uses [Horizon](/docs/{{version}}/horizon), deberías usar el comando `horizon:forget` para borrar un trabajo fallido en lugar del comando `queue:forget`.

Para eliminar todos los trabajos fallidos de la tabla `failed_jobs`, puede utilizar el comando `queue:flush`:

```shell
php artisan queue:flush
```

<a name="ignoring-missing-models"></a>
### Ignorar modelos perdidos

Cuando se inyecta un modelo Eloquent en un trabajo, el modelo se serializa automáticamente antes de colocarse en la cola y se recupera de la base de datos cuando se procesa el trabajo. Sin embargo, si el modelo ha sido borrado mientras el trabajo estaba esperando a ser procesado por un worker, tu trabajo puede fallar con una `ModelNotFoundException`.

Para mayor comodidad, puede elegir eliminar automáticamente los trabajos con modelos perdidos estableciendo la propiedad `deleteWhenMissingModels` de su trabajo a `true`. Cuando esta propiedad se establece en `true`, Laravel descartará silenciosamente el trabajo sin lanzar una excepción:

    /**
     * Delete the job if its models no longer exist.
     *
     * @var bool
     */
    public $deleteWhenMissingModels = true;

<a name="pruning-failed-jobs"></a>
### Eliminación de trabajos fallidos

Puedes eliminar los registros en la tabla `failed_jobs` de tu aplicación invocando el comando `queue:prune-failed` de Artisan:

```shell
php artisan queue:prune-failed
```

Por defecto, todos los registros de trabajos fallidos con más de 24 horas de antigüedad serán eliminados. Si proporciona la opción `--hours` al comando, sólo se conservarán los registros de trabajos fallidos que se insertaron en las últimas N horas. Por ejemplo, el siguiente comando eliminará todos los registros de trabajos fallidos que se insertaron hace más de 48 horas:

```shell
php artisan queue:prune-failed --hours=48
```

<a name="storing-failed-jobs-in-dynamodb"></a>
### Almacenamiento de trabajos fallidos en DynamoDB

Laravel también permite almacenar los registros de trabajos fallidos en [DynamoDB](https://aws.amazon.com/dynamodb) en lugar de en una tabla de base de datos relacional. Sin embargo, debe crear una tabla DynamoDB para almacenar todos los registros de trabajos fallidos. Normalmente, esta tabla debe llamarse `failed_jobs`, pero debe asignarle un nombre basado en el valor de configuración `queue.failed.table` del archivo de configuración de colas su aplicación.

La tabla `failed_jobs` debe tener una clave de partición primaria de cadena denominada `application` y una clave de ordenación primaria de cadena denominada `uuid`. La parte de la clave correspondiente a `application` contendrá el nombre de la aplicación definido por el valor de configuración `name` en el archivo de configuración de `app.php`. Dado que el nombre de la aplicación forma parte de la clave de la tabla de DynamoDB, puede utilizar la misma tabla para almacenar trabajos fallidos de varias aplicaciones de Laravel.

Además, asegúrese de instalar el SDK de AWS para que su aplicación Laravel pueda comunicarse con Amazon DynamoDB:

```shell
composer require aws/aws-sdk-php
```

A continuación, establece el valor de la opción de configuración `queue.failed.driver` en `dynamodb`. Además, debe definir las opciones de configuración de `key`, `secret` y `region` dentro de la array configuración de trabajos fallidos. Estas opciones se utilizarán para autenticarse con AWS. Cuando se utiliza el driver `dynamodb`, la opción de configuración `queue.failed.database` es innecesaria:

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
### Desactivación del Almacenamiento de Trabajos Fallidos

Puedes indicar a Laravel que descarte los trabajos fallidos sin almacenarlos estableciendo el valor de la opción de configuración `queue.failed.driver` en `null`. Normalmente, esto puede hacerse mediante la variable de entorno `QUEUE_FAILED_DRIVER`:

```ini
QUEUE_FAILED_DRIVER=null
```

<a name="failed-job-events"></a>
### Eventos de Trabajos Fallidos

Si queremos registrar un evento que sea invocado cuando un trabajo falle, podemos utilizar el método `failing` de la facade `Queue`. Por ejemplo, podemos adjuntar un closure a este evento desde el método `boot` del `AppServiceProvider` que se incluye con Laravel:

    <?php

    namespace App\Providers;

    use Illuminate\Support\Facades\Queue;
    use Illuminate\Support\ServiceProvider;
    use Illuminate\Queue\Events\JobFailed;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Register any application services.
         *
         * @return void
         */
        public function register()
        {
            //
        }

        /**
         * Bootstrap any application services.
         *
         * @return void
         */
        public function boot()
        {
            Queue::failing(function (JobFailed $event) {
                // $event->connectionName
                // $event->job
                // $event->exception
            });
        }
    }

<a name="clearing-jobs-from-queues"></a>
## Eliminación de trabajos de las colas

> **Nota**  
> Cuando utilice [Horizon](/docs/{{version}}/horizon), debe utilizar el comando `horizon:clear` para borrar trabajos de la cola en lugar del comando `queue:clear`.

Si deseas eliminar todos los trabajos de la cola por defecto de la conexión por defecto, puedes hacerlo utilizando el comando Artisan `queue:clear`:

```shell
php artisan queue:clear
```

También puedes proporcionar el argumento `connection` y la opción `queue` para borrar trabajos de una conexión y cola específicas:

```shell
php artisan queue:clear redis --queue=emails
```

> **Advertencia**  
> Borrar trabajos de las colas sólo está disponible para los drivers de cola `sqs`, `redis`y `database` . Además, el proceso de borrado de mensajes SQS tarda hasta 60 segundos, por lo que los trabajos enviados a la cola SQS hasta 60 segundos después de que borres la cola también podrían ser borrados.

<a name="monitoring-your-queues"></a>
## Monitorización de Colas

Si tu cola recibe una afluencia repentina de trabajos, podría verse desbordada, dando lugar a un largo tiempo de espera para que los trabajos se completen. Si lo deseas, Laravel puede alertarte cuando el número de trabajos en la cola exceda un umbral especificado.

Para empezar, debe programar el comando `queue:monitor` para que [se ejecute cada minuto](/docs/{{version}}/scheduling). El comando acepta los nombres de las colas que desea supervisar, así como el umbral de recuento de trabajos deseado:

```shell
php artisan queue:monitor redis:default,redis:deployments --max=100
```

La programación de este comando por sí sola no es suficiente para activar una notificación que le avise del estado de saturación de la cola. Cuando el comando encuentra una cola que tiene un recuento de trabajos superior a su umbral, se enviará un evento `Illuminate\Queue\Events\QueueBusy`. Puede escuchar este evento en el `EventServiceProvider` de su aplicación para enviarle una notificación a usted o a su equipo de desarrollo:

```php
use App\Notifications\QueueHasLongWaitTime;
use Illuminate\Queue\Events\QueueBusy;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Notification;

/**
 * Register any other events for your application.
 *
 * @return void
 */
public function boot()
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

<a name="job-events"></a>
## Eventos de trabajos

Usando los métodos `before` y `after` de la [facade](/docs/{{version}}/facades) `Queue`, puedes especificar callbacks para ser ejecutados antes o después de que un trabajo en cola sea procesado. Estos callbacks son una gran oportunidad para realizar un registro adicional o incrementar las estadísticas para un panel de control. Por lo  general, deberías llamar a estos métodos desde el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers). Por ejemplo, podemos utilizar el `AppServiceProvider` que se incluye con Laravel:

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
         *
         * @return void
         */
        public function register()
        {
            //
        }

        /**
         * Bootstrap any application services.
         *
         * @return void
         */
        public function boot()
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

Usando el método `looping` de la [facade](/docs/{{version}}/facades) `Queue`, puedes especificar callbacks que se ejecuten antes de que el worker intente obtener un trabajo de una cola. Por ejemplo, puedes registrar un closure para revertir cualquier transacción que haya sido dejada abierta por un trabajo previamente fallido:

    use Illuminate\Support\Facades\DB;
    use Illuminate\Support\Facades\Queue;

    Queue::looping(function () {
        while (DB::transactionLevel() > 0) {
            DB::rollBack();
        }
    });
