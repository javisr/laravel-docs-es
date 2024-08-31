# Contenedor de Servicios

- [Introducción](#introduction)
  - [Resolución de Cero Configuración](#zero-configuration-resolution)
  - [Cuándo Utilizar el Contenedor](#when-to-use-the-container)
- [Binding](#binding)
  - [Conceptos Básicos de Binding](#binding-basics)
  - [Vincular Interfaces a Implementaciones](#binding-interfaces-to-implementations)
  - [Binding Contextual](#contextual-binding)
  - [Binding Primitivos](#binding-primitives)
  - [Binding Variadics Tipados](#binding-typed-variadics)
  - [Etiquetado](#tagging)
  - [Extendiendo Bindings](#extending-bindings)
- [Resolviendo](#resolving)
  - [El Método Make](#the-make-method)
  - [Inyección Automática](#automatic-injection)
- [Invocación de Métodos e Inyección](#method-invocation-and-injection)
- [Eventos del Contenedor](#container-events)
- [PSR-11](#psr-11)

<a name="introduction"></a>
## Introducción

El contenedor de servicios de Laravel es una herramienta poderosa para gestionar las dependencias de clase y realizar la inyección de dependencias. La inyección de dependencias es una frase elegante que esencialmente significa esto: las dependencias de clase son "inyectadas" en la clase a través del constructor o, en algunos casos, métodos "setter".
Veamos un ejemplo simple:


```php
<?php

namespace App\Http\Controllers;

use App\Services\AppleMusic;
use Illuminate\View\View;

class PodcastController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected AppleMusic $apple,
    ) {}

    /**
     * Show information about the given podcast.
     */
    public function show(string $id): View
    {
        return view('podcasts.show', [
            'podcast' => $this->apple->findPodcast($id)
        ]);
    }
}
```
En este ejemplo, el `PodcastController` necesita recuperar podcasts de una fuente de datos como Apple Music. Así que, **inyectaremos** un servicio que sea capaz de recuperar podcasts. Dado que el servicio es inyectado, podemos fácilmente "simular" o crear una implementación ficticia del servicio `AppleMusic` al probar nuestra aplicación.
Una comprensión profunda del contenedor de servicios de Laravel es esencial para construir una aplicación grande y potente, así como para contribuir al núcleo de Laravel mismo.

<a name="zero-configuration-resolution"></a>
### Resolución de Cero Configuración

Si una clase no tiene dependencias o solo depende de otras clases concretas (no interfaces), el contenedor no necesita que se le indique cómo resolver esa clase. Por ejemplo, puedes colocar el siguiente código en tu archivo `routes/web.php`:


```php
<?php

class Service
{
    // ...
}

Route::get('/', function (Service $service) {
    die($service::class);
});
```
En este ejemplo, acceder a la ruta `/` de tu aplicación resolverá automáticamente la clase `Service` e inyectará en el manejador de tu ruta. Esto cambia las reglas del juego. Significa que puedes desarrollar tu aplicación y aprovechar la inyección de dependencias sin preocuparte por archivos de configuración abultados.
Afortunadamente, muchas de las clases que escribirás al construir una aplicación Laravel reciben automáticamente sus dependencias a través del contenedor, incluyendo [controladores](/docs/%7B%7Bversion%7D%7D/controllers), [escuchas de eventos](/docs/%7B%7Bversion%7D%7D/events), [middleware](/docs/%7B%7Bversion%7D%7D/middleware) y más. Además, puedes indicar las dependencias en el método `handle` de [trabajos en cola](/docs/%7B%7Bversion%7D%7D/queues). Una vez que pruebes el poder de la inyección de dependencias automática y sin configuración, te parecerá imposible desarrollar sin ella.

<a name="when-to-use-the-container"></a>
### Cuándo Utilizar el Contenedor

Gracias a la resolución de cero configuración, a menudo podrás indicar dependencias en rutas, controladores, oyentes de eventos y en otros lugares sin tener que interactuar manualmente con el contenedor. Por ejemplo, podrías indicar el objeto `Illuminate\Http\Request` en tu definición de ruta para que puedas acceder fácilmente a la solicitud actual. A pesar de que nunca tenemos que interactuar con el contenedor para escribir este código, este está gestionando la inyección de estas dependencias en segundo plano:


```php
use Illuminate\Http\Request;

Route::get('/', function (Request $request) {
    // ...
});
```
En muchos casos, gracias a la inyección de dependencia automática y a las [facades](/docs/%7B%7Bversion%7D%7D/facades), puedes construir aplicaciones Laravel sin **nunca** vincular o resolver manualmente nada desde el contenedor. **Entonces, ¿cuándo interactuarías manualmente con el contenedor?** Examinaré dos situaciones.
Primero, si escribes una clase que implementa una interfaz y deseas usar la sugerencia de tipo de esa interfaz en una ruta o en el constructor de una clase, debes [indicar al contenedor cómo resolver esa interfaz](#binding-interfaces-to-implementations). En segundo lugar, si estás [escribiendo un paquete de Laravel](/docs/%7B%7Bversion%7D%7D/packages) que planeas compartir con otros desarrolladores de Laravel, es posible que necesites vincular los servicios de tu paquete en el contenedor.

<a name="binding"></a>
## Vinculación


<a name="binding-basics"></a>
### Fundamentos de Binding


<a name="simple-bindings"></a>
#### Enlaces Simples

Casi todos tus enlaces de contenedor de servicio se registrarán dentro de [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers), por lo que la mayoría de estos ejemplos demostrarán el uso del contenedor en ese contexto.
Dentro de un proveedor de servicios, siempre tienes acceso al contenedor a través de la propiedad `$this->app`. Podemos registrar un enlace usando el método `bind`, pasando el nombre de la clase o interfaz que deseamos registrar junto con una función anónima que devuelve una instancia de la clase:


```php
use App\Services\Transistor;
use App\Services\PodcastParser;
use Illuminate\Contracts\Foundation\Application;

$this->app->bind(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```
Ten en cuenta que recibimos el contenedor mismo como argumento al resolutor. Luego podemos usar el contenedor para resolver subdependencias del objeto que estamos construyendo.
Como se mencionó, típicamente interactuarás con el contenedor dentro de los proveedores de servicios; sin embargo, si deseas interactuar con el contenedor fuera de un proveedor de servicios, puedes hacerlo a través de la [facade](/docs/%7B%7Bversion%7D%7D/facades) `App`:


```php
use App\Services\Transistor;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\App;

App::bind(Transistor::class, function (Application $app) {
    // ...
});
```
Puedes usar el método `bindIf` para registrar un enlace de contenedor solo si no se ha registrado un enlace para el tipo dado:


```php
$this->app->bindIf(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});

```
> [!NOTA]
No es necesario vincular clases en el contenedor si no dependen de ninguna interfaz. El contenedor no necesita instrucciones sobre cómo construir estos objetos, ya que puede resolver automáticamente estos objetos utilizando reflexión.

<a name="binding-a-singleton"></a>
#### Vinculando un Singleton

El método `singleton` vincula una clase o interfaz en el contenedor que solo debe resolverse una vez. Una vez que se resuelve un enlace singleton, se devolverá la misma instancia de objeto en llamadas posteriores al contenedor:


```php
use App\Services\Transistor;
use App\Services\PodcastParser;
use Illuminate\Contracts\Foundation\Application;

$this->app->singleton(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```
Puedes usar el método `singletonIf` para registrar un enlace de contenedor singleton solo si no se ha registrado un enlace para el tipo dado:


```php
$this->app->singletonIf(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});

```

<a name="binding-scoped"></a>
#### Enlazando Singletons con Alcance

El método `scoped` vincula una clase o interfaz en el contenedor que solo debe resolverse una vez dentro de un ciclo de vida de solicitud / trabajo dado en Laravel. Si bien este método es similar al método `singleton`, las instancias registradas utilizando el método `scoped` se eliminarán cada vez que la aplicación Laravel inicie un nuevo "ciclo de vida", como cuando un [trabajador de Laravel Octane](/docs/%7B%7Bversion%7D%7D/octane) procesa una nueva solicitud o cuando un [trabajador de cola de Laravel](/docs/%7B%7Bversion%7D%7D/queues) procesa un nuevo trabajo:


```php
use App\Services\Transistor;
use App\Services\PodcastParser;
use Illuminate\Contracts\Foundation\Application;

$this->app->scoped(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

<a name="binding-instances"></a>
#### Vinculación de Instancias

También puedes vincular una instancia de objeto existente en el contenedor utilizando el método `instance`. La instancia dada siempre se devolverá en llamadas subsecuentes al contenedor:


```php
use App\Services\Transistor;
use App\Services\PodcastParser;

$service = new Transistor(new PodcastParser);

$this->app->instance(Transistor::class, $service);
```

<a name="binding-interfaces-to-implementations"></a>
### Vinculando Interfaces a Implementaciones

Una característica muy potente del contenedor de servicios es su capacidad para enlazar una interfaz a una implementación dada. Por ejemplo, supongamos que tenemos una interfaz `EventPusher` y una implementación `RedisEventPusher`. Una vez que hemos codificado nuestra implementación `RedisEventPusher` de esta interfaz, podemos registrarla en el contenedor de servicios de la siguiente manera:


```php
use App\Contracts\EventPusher;
use App\Services\RedisEventPusher;

$this->app->bind(EventPusher::class, RedisEventPusher::class);
```
Esta declaración le dice al contenedor que debe inyectar el `RedisEventPusher` cuando una clase necesita una implementación de `EventPusher`. Ahora podemos usar hinting de tipo para la interfaz `EventPusher` en el constructor de una clase que es resuelta por el contenedor. Recuerda que los controladores, escuchadores de eventos, middleware y varios otros tipos de clases dentro de aplicaciones Laravel siempre se resuelven utilizando el contenedor:


```php
use App\Contracts\EventPusher;

/**
 * Create a new class instance.
 */
public function __construct(
    protected EventPusher $pusher
) {}
```

<a name="contextual-binding"></a>
### Binding Contextual

A veces puedes tener dos clases que utilizan la misma interfaz, pero deseas inyectar diferentes implementaciones en cada clase. Por ejemplo, dos controladores pueden depender de diferentes implementaciones del contrato `Illuminate\Contracts\Filesystem\Filesystem` [contract](/docs/%7B%7Bversion%7D%7D/contracts). Laravel proporciona una interfaz simple y fluida para definir este comportamiento:


```php
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
```

<a name="binding-primitives"></a>
### Vinculación de Primitivas

A veces es posible que tengas una clase que recibe algunas clases inyectadas, pero también necesita un valor primitivo inyectado, como un entero. Puedes usar el enlace contextual fácilmente para inyectar cualquier valor que tu clase pueda necesitar:


```php
use App\Http\Controllers\UserController;

$this->app->when(UserController::class)
          ->needs('$variableName')
          ->give($value);
```
A veces, una clase puede depender de un array de instancias [etiquetadas](#tagging). Usando el método `giveTagged`, puedes inyectar fácilmente todos los enlaces del contenedor con esa etiqueta:


```php
$this->app->when(ReportAggregator::class)
    ->needs('$reports')
    ->giveTagged('reports');
```
Si necesitas inyectar un valor de uno de los archivos de configuración de tu aplicación, puedes usar el método `giveConfig`:


```php
$this->app->when(ReportAggregator::class)
    ->needs('$timezone')
    ->giveConfig('app.timezone');
```

<a name="binding-typed-variadics"></a>
### Vinculación de Variadics Tipados

De vez en cuando, es posible que tengas una clase que recibe un array de objetos tipados utilizando un argumento de constructor variadic:


```php
<?php

use App\Models\Filter;
use App\Services\Logger;

class Firewall
{
    /**
     * The filter instances.
     *
     * @var array
     */
    protected $filters;

    /**
     * Create a new class instance.
     */
    public function __construct(
        protected Logger $logger,
        Filter ...$filters,
    ) {
        $this->filters = $filters;
    }
}
```
Usando binding contextual, puedes resolver esta dependencia proporcionando al método `give` una función anónima que devuelva un array de instancias de `Filter` resueltas:


```php
$this->app->when(Firewall::class)
          ->needs(Filter::class)
          ->give(function (Application $app) {
                return [
                    $app->make(NullFilter::class),
                    $app->make(ProfanityFilter::class),
                    $app->make(TooLongFilter::class),
                ];
          });
```
Para mayor conveniencia, también puedes proporcionar un array de nombres de clase que serán resolvidos por el contenedor cada vez que `Firewall` necesite instancias de `Filter`:


```php
$this->app->when(Firewall::class)
          ->needs(Filter::class)
          ->give([
              NullFilter::class,
              ProfanityFilter::class,
              TooLongFilter::class,
          ]);
```

<a name="variadic-tag-dependencies"></a>
#### Dependencias de Etiquetas Variádicas

A veces, una clase puede tener una dependencia variádica que se indica con tipo como una clase dada (`Report ...$reports`). Usando los métodos `needs` y `giveTagged`, puedes inyectar fácilmente todas las vinculaciones del contenedor con esa [etiqueta](#tagging) para la dependencia dada:


```php
$this->app->when(ReportAggregator::class)
    ->needs(Report::class)
    ->giveTagged('reports');
```

<a name="tagging"></a>
### Etiquetado

Ocasionalmente, es posible que necesites resolver todo un cierto "categoría" de vinculaciones. Por ejemplo, quizás estés construyendo un analizador de informes que recibe un array de muchas implementaciones diferentes de la interfaz `Report`. Después de registrar las implementaciones de `Report`, puedes asignarles una etiqueta utilizando el método `tag`:


```php
$this->app->bind(CpuReport::class, function () {
    // ...
});

$this->app->bind(MemoryReport::class, function () {
    // ...
});

$this->app->tag([CpuReport::class, MemoryReport::class], 'reports');
```
Una vez que los servicios han sido etiquetados, puedes resolverlos todos fácilmente a través del método `tagged` del contenedor:


```php
$this->app->bind(ReportAnalyzer::class, function (Application $app) {
    return new ReportAnalyzer($app->tagged('reports'));
});
```

<a name="extending-bindings"></a>
### Extendiendo Enlaces

El método `extend` permite la modificación de servicios resueltos. Por ejemplo, cuando se resuelve un servicio, puedes ejecutar código adicional para decorar o configurar el servicio. El método `extend` acepta dos argumentos, la clase de servicio que estás extendiendo y una función anónima que debe devolver el servicio modificado. La función anónima recibe el servicio que se está resolviendo y la instancia del contenedor:


```php
$this->app->extend(Service::class, function (Service $service, Application $app) {
    return new DecoratedService($service);
});
```

<a name="resolving"></a>
## Resolución


<a name="the-make-method"></a>
### El método `make`

Puedes usar el método `make` para resolver una instancia de clase desde el contenedor. El método `make` acepta el nombre de la clase o interfaz que deseas resolver:


```php
use App\Services\Transistor;

$transistor = $this->app->make(Transistor::class);
```
Si algunas de las dependencias de tu clase no son resolvibles a través del contenedor, puedes inyectarlas pasando un array asociativo en el método `makeWith`. Por ejemplo, podemos pasar manualmente el argumento del constructor `$id` requerido por el servicio `Transistor`:


```php
use App\Services\Transistor;

$transistor = $this->app->makeWith(Transistor::class, ['id' => 1]);
```
El método `bound` se puede utilizar para determinar si una clase o interfaz ha sido vinculada explícitamente en el contenedor:


```php
if ($this->app->bound(Transistor::class)) {
    // ...
}
```
Si estás fuera de un proveedor de servicios en una ubicación de tu código que no tiene acceso a la variable `$app`, puedes usar la `facade` de `App` o el `helper` de `app` para resolver una instancia de clase desde el contenedor:


```php
use App\Services\Transistor;
use Illuminate\Support\Facades\App;

$transistor = App::make(Transistor::class);

$transistor = app(Transistor::class);
```
Si deseas que la instancia del contenedor de Laravel se inyecte en una clase que está siendo resuelta por el contenedor, puedes indicar la clase `Illuminate\Container\Container` en el constructor de tu clase:


```php
use Illuminate\Container\Container;

/**
 * Create a new class instance.
 */
public function __construct(
    protected Container $container
) {}
```

<a name="automatic-injection"></a>
### Inyección Automática

Alternativamente, y lo que es más importante, puedes indicar la dependencia en el constructor de una clase que es resuelta por el contenedor, incluyendo [controladores](/docs/%7B%7Bversion%7D%7D/controllers), [escuchadores de eventos](/docs/%7B%7Bversion%7D%7D/events), [middleware](/docs/%7B%7Bversion%7D%7D/middleware), y más. Además, puedes indicar las dependencias en el método `handle` de [trabajos en cola](/docs/%7B%7Bversion%7D%7D/queues). En la práctica, esta es la forma en que la mayoría de tus objetos deberían ser resueltos por el contenedor.
Por ejemplo, puedes indicar un tipo de servicio definido por tu aplicación en el constructor de un controlador. El servicio se resolverá e inyectará automáticamente en la clase:


```php
<?php

namespace App\Http\Controllers;

use App\Services\AppleMusic;

class PodcastController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(
        protected AppleMusic $apple,
    ) {}

    /**
     * Show information about the given podcast.
     */
    public function show(string $id): Podcast
    {
        return $this->apple->findPodcast($id);
    }
}
```

<a name="method-invocation-and-injection"></a>
## Invocación de Método e Inyección

A veces es posible que desees invocar un método en una instancia de objeto mientras permites que el contenedor inyecte automáticamente las dependencias de ese método. Por ejemplo, dada la siguiente clase:


```php
<?php

namespace App;

use App\Services\AppleMusic;

class PodcastStats
{
    /**
     * Generate a new podcast stats report.
     */
    public function generate(AppleMusic $apple): array
    {
        return [
            // ...
        ];
    }
}
```
Puedes invocar el método `generate` a través del contenedor de la siguiente manera:


```php
use App\PodcastStats;
use Illuminate\Support\Facades\App;

$stats = App::call([new PodcastStats, 'generate']);
```
El método `call` acepta cualquier callable de PHP. El método `call` del contenedor incluso se puede usar para invocar una `función anónima` mientras se inyectan automáticamente sus dependencias:


```php
use App\Services\AppleMusic;
use Illuminate\Support\Facades\App;

$result = App::call(function (AppleMusic $apple) {
    // ...
});
```

<a name="container-events"></a>
## Eventos de Contenedor

El contenedor de servicios dispara un evento cada vez que resuelve un objeto. Puedes escuchar este evento utilizando el método `resolving`:


```php
use App\Services\Transistor;
use Illuminate\Contracts\Foundation\Application;

$this->app->resolving(Transistor::class, function (Transistor $transistor, Application $app) {
    // Called when container resolves objects of type "Transistor"...
});

$this->app->resolving(function (mixed $object, Application $app) {
    // Called when container resolves object of any type...
});
```
Como puedes ver, el objeto que se está resolviendo se pasará a la función de callback, lo que te permitirá establecer cualquier propiedad adicional en el objeto antes de que se entregue a su consumidor.

<a name="psr-11"></a>
## PSR-11

El contenedor de servicios de Laravel implementa la interfaz [PSR-11](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-11-container.md). Por lo tanto, puedes usar la sugerencia de tipo para la interfaz del contenedor PSR-11 para obtener una instancia del contenedor de Laravel:


```php
use App\Services\Transistor;
use Psr\Container\ContainerInterface;

Route::get('/', function (ContainerInterface $container) {
    $service = $container->get(Transistor::class);

    // ...
});
```
Se lanzará una excepción si el identificador dado no puede resolverse. La excepción será una instancia de `Psr\Container\NotFoundExceptionInterface` si el identificador nunca fue vinculado. Si el identificador fue vinculado pero no pudo ser resuelto, se lanzará una instancia de `Psr\Container\ContainerExceptionInterface`.