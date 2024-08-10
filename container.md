# Contenedor de Servicios

- [Contenedor de Servicios](#contenedor-de-servicios)
  - [Introducción](#introducción)
    - [Resolución Sin Configuración](#resolución-sin-configuración)
    - [Cuándo Utilizar el Contenedor](#cuándo-utilizar-el-contenedor)
  - [Vinculación](#vinculación)
    - [Conceptos Básicos de Vinculación](#conceptos-básicos-de-vinculación)
      - [Vinculaciones Simples](#vinculaciones-simples)
      - [Vinculación de un Singleton](#vinculación-de-un-singleton)
      - [Vinculación de Singletons con Alcance](#vinculación-de-singletons-con-alcance)
      - [Vinculación de Instancias](#vinculación-de-instancias)
    - [Vinculación de Interfaces a Implementaciones](#vinculación-de-interfaces-a-implementaciones)
    - [Vinculación Contextual](#vinculación-contextual)
    - [Vinculación de Primitivos](#vinculación-de-primitivos)
    - [Vinculación de Variádicos Tipados](#vinculación-de-variádicos-tipados)
      - [Dependencias de Etiquetas Variádicas](#dependencias-de-etiquetas-variádicas)
    - [Etiquetado](#etiquetado)
    - [Extensión de Vinculaciones](#extensión-de-vinculaciones)
  - [Resolución](#resolución)
    - [El Método `make`](#el-método-make)
    - [Inyección Automática](#inyección-automática)
  - [Invocación de Métodos e Inyección](#invocación-de-métodos-e-inyección)
  - [Eventos del Contenedor](#eventos-del-contenedor)
  - [PSR-11](#psr-11)

<a name="introduction"></a>
## Introducción

El contenedor de servicios de Laravel es una herramienta poderosa para gestionar las dependencias de clases y realizar inyección de dependencias. La inyección de dependencias es una frase elegante que esencialmente significa esto: las dependencias de clase son "inyectadas" en la clase a través del constructor o, en algunos casos, métodos "setter".

Veamos un ejemplo simple:

    <?php

    namespace App\Http\Controllers;

    use App\Services\AppleMusic;
    use Illuminate\View\View;

    class PodcastController extends Controller
    {
        /**
         * Crear una nueva instancia del controlador.
         */
        public function __construct(
            protected AppleMusic $apple,
        ) {}

        /**
         * Mostrar información sobre el podcast dado.
         */
        public function show(string $id): View
        {
            return view('podcasts.show', [
                'podcast' => $this->apple->findPodcast($id)
            ]);
        }
    }

En este ejemplo, el `PodcastController` necesita recuperar podcasts de una fuente de datos como Apple Music. Así que, **inyectaremos** un servicio que sea capaz de recuperar podcasts. Dado que el servicio es inyectado, podemos "simular" fácilmente, o crear una implementación ficticia del servicio `AppleMusic` al probar nuestra aplicación.

Una comprensión profunda del contenedor de servicios de Laravel es esencial para construir una aplicación grande y poderosa, así como para contribuir al núcleo de Laravel mismo.

<a name="zero-configuration-resolution"></a>
### Resolución Sin Configuración

Si una clase no tiene dependencias o solo depende de otras clases concretas (no interfaces), el contenedor no necesita ser instruido sobre cómo resolver esa clase. Por ejemplo, puedes colocar el siguiente código en tu archivo `routes/web.php`:

    <?php

    class Service
    {
        // ...
    }

    Route::get('/', function (Service $service) {
        die($service::class);
    });

En este ejemplo, acceder a la ruta `/` de tu aplicación resolverá automáticamente la clase `Service` e inyectará en el manejador de tu ruta. Esto cambia las reglas del juego. Significa que puedes desarrollar tu aplicación y aprovechar la inyección de dependencias sin preocuparte por archivos de configuración inflados.

Afortunadamente, muchas de las clases que escribirás al construir una aplicación Laravel reciben automáticamente sus dependencias a través del contenedor, incluyendo [controladores](/docs/{{version}}/controllers), [escuchadores de eventos](/docs/{{version}}/events), [middleware](/docs/{{version}}/middleware), y más. Además, puedes indicar dependencias en el método `handle` de [trabajos en cola](/docs/{{version}}/queues). Una vez que pruebes el poder de la inyección de dependencias automática y sin configuración, parece imposible desarrollar sin ella.

<a name="when-to-use-the-container"></a>
### Cuándo Utilizar el Contenedor

Gracias a la resolución sin configuración, a menudo indicarás dependencias en rutas, controladores, escuchadores de eventos y en otros lugares sin interactuar manualmente con el contenedor. Por ejemplo, podrías indicar el objeto `Illuminate\Http\Request` en tu definición de ruta para que puedas acceder fácilmente a la solicitud actual. A pesar de que nunca tenemos que interactuar con el contenedor para escribir este código, está gestionando la inyección de estas dependencias en segundo plano:

    use Illuminate\Http\Request;

    Route::get('/', function (Request $request) {
        // ...
    });

En muchos casos, gracias a la inyección automática de dependencias y [facades](/docs/{{version}}/facades), puedes construir aplicaciones Laravel sin **nunca** vincular o resolver manualmente nada del contenedor. **Entonces, ¿cuándo interactuarías manualmente con el contenedor?** Examinemos dos situaciones.

Primero, si escribes una clase que implementa una interfaz y deseas indicar esa interfaz en una ruta o constructor de clase, debes [decirle al contenedor cómo resolver esa interfaz](#binding-interfaces-to-implementations). En segundo lugar, si estás [escribiendo un paquete de Laravel](/docs/{{version}}/packages) que planeas compartir con otros desarrolladores de Laravel, es posible que necesites vincular los servicios de tu paquete en el contenedor.

<a name="binding"></a>
## Vinculación

<a name="binding-basics"></a>
### Conceptos Básicos de Vinculación

<a name="simple-bindings"></a>
#### Vinculaciones Simples

Casi todas tus vinculaciones del contenedor de servicios se registrarán dentro de [proveedores de servicios](/docs/{{version}}/providers), por lo que la mayoría de estos ejemplos demostrarán el uso del contenedor en ese contexto.

Dentro de un proveedor de servicios, siempre tienes acceso al contenedor a través de la propiedad `$this->app`. Podemos registrar una vinculación usando el método `bind`, pasando el nombre de la clase o interfaz que deseamos registrar junto con una función anónima que devuelve una instancia de la clase:

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->bind(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });

Ten en cuenta que recibimos el contenedor mismo como argumento para el resolvedor. Luego podemos usar el contenedor para resolver sub-dependencias del objeto que estamos construyendo.

Como se mencionó, normalmente interactuarás con el contenedor dentro de proveedores de servicios; sin embargo, si deseas interactuar con el contenedor fuera de un proveedor de servicios, puedes hacerlo a través de la [facade](/docs/{{version}}/facades) `App`:

    use App\Services\Transistor;
    use Illuminate\Contracts\Foundation\Application;
    use Illuminate\Support\Facades\App;

    App::bind(Transistor::class, function (Application $app) {
        // ...
    });

Puedes usar el método `bindIf` para registrar una vinculación en el contenedor solo si no se ha registrado ya una vinculación para el tipo dado:

```php
$this->app->bindIf(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

> [!NOTE]  
> No es necesario vincular clases en el contenedor si no dependen de ninguna interfaz. El contenedor no necesita ser instruido sobre cómo construir estos objetos, ya que puede resolver automáticamente estos objetos utilizando reflexión.

<a name="binding-a-singleton"></a>
#### Vinculación de un Singleton

El método `singleton` vincula una clase o interfaz en el contenedor que solo debe resolverse una vez. Una vez que se resuelve una vinculación de singleton, la misma instancia de objeto se devolverá en llamadas posteriores al contenedor:

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->singleton(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });

Puedes usar el método `singletonIf` para registrar una vinculación de singleton en el contenedor solo si no se ha registrado ya una vinculación para el tipo dado:

```php
$this->app->singletonIf(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

<a name="binding-scoped"></a>
#### Vinculación de Singletons con Alcance

El método `scoped` vincula una clase o interfaz en el contenedor que solo debe resolverse una vez dentro de un ciclo de vida de solicitud / trabajo de Laravel dado. Aunque este método es similar al método `singleton`, las instancias registradas utilizando el método `scoped` se eliminarán cada vez que la aplicación Laravel inicie un nuevo "ciclo de vida", como cuando un trabajador de [Laravel Octane](/docs/{{version}}/octane) procesa una nueva solicitud o cuando un [trabajador de cola](/docs/{{version}}/queues) de Laravel procesa un nuevo trabajo:

    use App\Services\Transistor;
    use App\Services\PodcastParser;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->scoped(Transistor::class, function (Application $app) {
        return new Transistor($app->make(PodcastParser::class));
    });

<a name="binding-instances"></a>
#### Vinculación de Instancias

También puedes vincular una instancia de objeto existente en el contenedor utilizando el método `instance`. La instancia dada siempre se devolverá en llamadas posteriores al contenedor:

    use App\Services\Transistor;
    use App\Services\PodcastParser;

    $service = new Transistor(new PodcastParser);

    $this->app->instance(Transistor::class, $service);

<a name="binding-interfaces-to-implementations"></a>
### Vinculación de Interfaces a Implementaciones

Una característica muy poderosa del contenedor de servicios es su capacidad para vincular una interfaz a una implementación dada. Por ejemplo, supongamos que tenemos una interfaz `EventPusher` y una implementación `RedisEventPusher`. Una vez que hemos codificado nuestra implementación `RedisEventPusher` de esta interfaz, podemos registrarla con el contenedor de servicios de la siguiente manera:

    use App\Contracts\EventPusher;
    use App\Services\RedisEventPusher;

    $this->app->bind(EventPusher::class, RedisEventPusher::class);

Esta declaración le dice al contenedor que debe inyectar el `RedisEventPusher` cuando una clase necesita una implementación de `EventPusher`. Ahora podemos indicar la interfaz `EventPusher` en el constructor de una clase que es resuelta por el contenedor. Recuerda, los controladores, escuchadores de eventos, middleware y varios otros tipos de clases dentro de las aplicaciones Laravel siempre se resuelven utilizando el contenedor:

    use App\Contracts\EventPusher;

    /**
     * Crear una nueva instancia de clase.
     */
    public function __construct(
        protected EventPusher $pusher
    ) {}

<a name="contextual-binding"></a>
### Vinculación Contextual

A veces puedes tener dos clases que utilizan la misma interfaz, pero deseas inyectar diferentes implementaciones en cada clase. Por ejemplo, dos controladores pueden depender de diferentes implementaciones del [contrato](/docs/{{version}}/contracts) `Illuminate\Contracts\Filesystem\Filesystem`. Laravel proporciona una interfaz simple y fluida para definir este comportamiento:

    use App\Http\Controllers\PhotoController;
    use App\Http\Controllers\UploadController;
    use App\Http\Controllers\VideoController;
    use Illuminate\Contracts\Filesystem\Filesystem;
    use Illuminate\Support\Facades\Storage;

    $this->app->when(PhotoController::class)
              ->needs(Filesystem::class)
              ->give(function () {
                  return Storage::disk('local');
              });

    $this->app->when([VideoController::class, UploadController::class])
              ->needs(Filesystem::class)
              ->give(function () {
                  return Storage::disk('s3');
              });

<a name="binding-primitives"></a>
### Vinculación de Primitivos

A veces puedes tener una clase que recibe algunas clases inyectadas, pero también necesita un valor primitivo inyectado, como un entero. Puedes usar fácilmente la vinculación contextual para inyectar cualquier valor que tu clase pueda necesitar:

    use App\Http\Controllers\UserController;

    $this->app->when(UserController::class)
              ->needs('$variableName')
              ->give($value);

A veces una clase puede depender de un array de instancias [etiquetadas](#tagging). Usando el método `giveTagged`, puedes inyectar fácilmente todas las vinculaciones del contenedor con esa etiqueta:

    $this->app->when(ReportAggregator::class)
        ->needs('$reports')
        ->giveTagged('reports');

Si necesitas inyectar un valor de uno de los archivos de configuración de tu aplicación, puedes usar el método `giveConfig`:

    $this->app->when(ReportAggregator::class)
        ->needs('$timezone')
        ->giveConfig('app.timezone');

<a name="binding-typed-variadics"></a>
### Vinculación de Variádicos Tipados

Ocasionalmente, puedes tener una clase que recibe un array de objetos tipados utilizando un argumento de constructor variádico:

    <?php

    use App\Models\Filter;
    use App\Services\Logger;

    class Firewall
    {
        /**
         * Las instancias de filtro.
         *
         * @var array
         */
        protected $filters;

        /**
         * Crear una nueva instancia de clase.
         */
        public function __construct(
            protected Logger $logger,
            Filter ...$filters,
        ) {
            $this->filters = $filters;
        }
    }

Usando la vinculación contextual, puedes resolver esta dependencia proporcionando al método `give` una función anónima que devuelve un array de instancias de `Filter` resueltas:

    $this->app->when(Firewall::class)
              ->needs(Filter::class)
              ->give(function (Application $app) {
                    return [
                        $app->make(NullFilter::class),
                        $app->make(ProfanityFilter::class),
                        $app->make(TooLongFilter::class),
                    ];
              });

Para conveniencia, también puedes proporcionar simplemente un array de nombres de clases que serán resueltas por el contenedor cada vez que `Firewall` necesite instancias de `Filter`:

    $this->app->when(Firewall::class)
              ->needs(Filter::class)
              ->give([
                  NullFilter::class,
                  ProfanityFilter::class,
                  TooLongFilter::class,
              ]);

<a name="variadic-tag-dependencies"></a>
#### Dependencias de Etiquetas Variádicas

A veces una clase puede tener una dependencia variádica que está indicada como una clase dada (`Report ...$reports`). Usando los métodos `needs` y `giveTagged`, puedes inyectar fácilmente todas las vinculaciones del contenedor con esa [etiqueta](#tagging) para la dependencia dada:

    $this->app->when(ReportAggregator::class)
        ->needs(Report::class)
        ->giveTagged('reports');

<a name="tagging"></a>
### Etiquetado

Ocasionalmente, puedes necesitar resolver todas las vinculaciones de una cierta "categoría". Por ejemplo, tal vez estés construyendo un analizador de informes que recibe un array de muchas implementaciones diferentes de la interfaz `Report`. Después de registrar las implementaciones de `Report`, puedes asignarles una etiqueta usando el método `tag`:

    $this->app->bind(CpuReport::class, function () {
        // ...
    });

    $this->app->bind(MemoryReport::class, function () {
        // ...
    });

    $this->app->tag([CpuReport::class, MemoryReport::class], 'reports');

Una vez que los servicios han sido etiquetados, puedes resolverlos fácilmente todos a través del método `tagged` del contenedor:

    $this->app->bind(ReportAnalyzer::class, function (Application $app) {
        return new ReportAnalyzer($app->tagged('reports'));
    });

<a name="extending-bindings"></a>
### Extensión de Vinculaciones

El método `extend` permite la modificación de servicios resueltos. Por ejemplo, cuando un servicio es resuelto, puedes ejecutar código adicional para decorar o configurar el servicio. El método `extend` acepta dos argumentos, la clase de servicio que estás extendiendo y una función anónima que debe devolver el servicio modificado. La función anónima recibe el servicio que se está resolviendo y la instancia del contenedor:


    $this->app->extend(Service::class, function (Service $service, Application $app) {
        return new DecoratedService($service);
    });

<a name="resolving"></a>
## Resolución

<a name="the-make-method"></a>
### El Método `make`

Puedes usar el método `make` para resolver una instancia de clase desde el contenedor. El método `make` acepta el nombre de la clase o interfaz que deseas resolver:

    use App\Services\Transistor;

    $transistor = $this->app->make(Transistor::class);

Si algunas de las dependencias de tu clase no se pueden resolver a través del contenedor, puedes inyectarlas pasándolas como un array asociativo al método `makeWith`. Por ejemplo, podemos pasar manualmente el argumento del constructor `$id` requerido por el servicio `Transistor`:

    use App\Services\Transistor;

    $transistor = $this->app->makeWith(Transistor::class, ['id' => 1]);

El método `bound` se puede usar para determinar si una clase o interfaz ha sido vinculada explícitamente en el contenedor:

    if ($this->app->bound(Transistor::class)) {
        // ...
    }

Si estás fuera de un proveedor de servicios en una ubicación de tu código que no tiene acceso a la variable `$app`, puedes usar el [facade](/docs/{{version}}/facades) `App` o el [helper](/docs/{{version}}/helpers#method-app) `app` para resolver una instancia de clase desde el contenedor:

    use App\Services\Transistor;
    use Illuminate\Support\Facades\App;

    $transistor = App::make(Transistor::class);

    $transistor = app(Transistor::class);

Si deseas que la instancia del contenedor de Laravel se inyecte en una clase que está siendo resuelta por el contenedor, puedes indicar el tipo de la clase `Illuminate\Container\Container` en el constructor de tu clase:

    use Illuminate\Container\Container;

    /**
     * Crear una nueva instancia de clase.
     */
    public function __construct(
        protected Container $container
    ) {}

<a name="automatic-injection"></a>
### Inyección Automática

Alternativamente, y de manera importante, puedes indicar el tipo de la dependencia en el constructor de una clase que es resuelta por el contenedor, incluyendo [controladores](/docs/{{version}}/controllers), [escuchadores de eventos](/docs/{{version}}/events), [middleware](/docs/{{version}}/middleware), y más. Además, puedes indicar el tipo de las dependencias en el método `handle` de [trabajos en cola](/docs/{{version}}/queues). En la práctica, así es como la mayoría de tus objetos deberían ser resueltos por el contenedor.

Por ejemplo, puedes indicar el tipo de un servicio definido por tu aplicación en el constructor de un controlador. El servicio será resuelto e inyectado automáticamente en la clase:

    <?php

    namespace App\Http\Controllers;

    use App\Services\AppleMusic;

    class PodcastController extends Controller
    {
        /**
         * Crear una nueva instancia de controlador.
         */
        public function __construct(
            protected AppleMusic $apple,
        ) {}

        /**
         * Mostrar información sobre el podcast dado.
         */
        public function show(string $id): Podcast
        {
            return $this->apple->findPodcast($id);
        }
    }

<a name="method-invocation-and-injection"></a>
## Invocación de Métodos e Inyección

A veces puedes desear invocar un método en una instancia de objeto mientras permites que el contenedor inyecte automáticamente las dependencias de ese método. Por ejemplo, dada la siguiente clase:

    <?php

    namespace App;

    use App\Services\AppleMusic;

    class PodcastStats
    {
        /**
         * Generar un nuevo informe de estadísticas de podcast.
         */
        public function generate(AppleMusic $apple): array
        {
            return [
                // ...
            ];
        }
    }

Puedes invocar el método `generate` a través del contenedor de la siguiente manera:

    use App\PodcastStats;
    use Illuminate\Support\Facades\App;

    $stats = App::call([new PodcastStats, 'generate']);

El método `call` acepta cualquier callable de PHP. El método `call` del contenedor incluso se puede usar para invocar una función anónima mientras inyecta automáticamente sus dependencias:

    use App\Services\AppleMusic;
    use Illuminate\Support\Facades\App;

    $result = App::call(function (AppleMusic $apple) {
        // ...
    });

<a name="container-events"></a>
## Eventos del Contenedor

El contenedor de servicios dispara un evento cada vez que resuelve un objeto. Puedes escuchar este evento usando el método `resolving`:

    use App\Services\Transistor;
    use Illuminate\Contracts\Foundation\Application;

    $this->app->resolving(Transistor::class, function (Transistor $transistor, Application $app) {
        // Llamado cuando el contenedor resuelve objetos del tipo "Transistor"...
    });

    $this->app->resolving(function (mixed $object, Application $app) {
        // Llamado cuando el contenedor resuelve un objeto de cualquier tipo...
    });

Como puedes ver, el objeto que se está resolviendo se pasará al callback, lo que te permitirá establecer cualquier propiedad adicional en el objeto antes de que se le entregue a su consumidor.

<a name="psr-11"></a>
## PSR-11

El contenedor de servicios de Laravel implementa la interfaz [PSR-11](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-11-container.md). Por lo tanto, puedes indicar el tipo de la interfaz del contenedor PSR-11 para obtener una instancia del contenedor de Laravel:

    use App\Services\Transistor;
    use Psr\Container\ContainerInterface;

    Route::get('/', function (ContainerInterface $container) {
        $service = $container->get(Transistor::class);

        // ...
    });

Se lanza una excepción si el identificador dado no se puede resolver. La excepción será una instancia de `Psr\Container\NotFoundExceptionInterface` si el identificador nunca fue vinculado. Si el identificador fue vinculado pero no se pudo resolver, se lanzará una instancia de `Psr\Container\ContainerExceptionInterface`.
```
