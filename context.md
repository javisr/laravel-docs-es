# Contexto

- [Introducción](#introduction)
  - [Cómo Funciona](#how-it-works)
- [Capturando Contexto](#capturing-context)
  - [Pilas](#stacks)
- [Recuperando Contexto](#retrieving-context)
  - [Determinando la Existencia de un Elemento](#determining-item-existence)
- [Eliminando Contexto](#removing-context)
- [Contexto Oculto](#hidden-context)
- [Eventos](#events)
  - [Deshidratando](#dehydrating)
  - [Hidratado](#hydrated)

<a name="introduction"></a>
## Introducción

Las capacidades de "contexto" de Laravel te permiten capturar, recuperar y compartir información a lo largo de solicitudes, trabajos y comandos que se ejecutan dentro de tu aplicación. Esta información capturada también se incluye en los registros escritos por tu aplicación, brindándote una visión más profunda de la historia de ejecución del código circundante que ocurrió antes de que se escribiera una entrada de registro y permitiéndote rastrear flujos de ejecución a lo largo de un sistema distribuido.

<a name="how-it-works"></a>
### Cómo Funciona

La mejor manera de entender las capacidades de contexto de Laravel es verlo en acción utilizando las funciones de registro integradas. Para comenzar, puedes [agregar información al contexto](#capturing-context) usando la facade `Context`. En este ejemplo, utilizaremos un [middleware](/docs/%7B%7Bversion%7D%7D/middleware) para añadir la URL de la solicitud y un ID de seguimiento único al contexto en cada solicitud entrante:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AddContext
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        Context::add('url', $request->url());
        Context::add('trace_id', Str::uuid()->toString());

        return $next($request);
    }
}

```
La información añadida al contexto se apena automáticamente como metadatos a cualquier [entrada de log](/docs/%7B%7Bversion%7D%7D/logging) que se escriba a lo largo de la solicitud. Añadir contexto como metadatos permite que la información pasada a las entradas de log individuales se diferencie de la información compartida a través de `Context`. Por ejemplo, imagina que escribimos la siguiente entrada de log:


```php
Log::info('User authenticated.', ['auth_id' => Auth::id()]);

```
El registro escrito contendrá el `auth_id` pasado a la entrada del registro, pero también incluirá la `url` del contexto y `trace_id` como metadatos:


```
User authenticated. {"auth_id":27} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}

```
La información añadida al contexto también se pone a disposición de los trabajos despachados a la cola. Por ejemplo, imagina que despachamos un trabajo `ProcessPodcast` a la cola después de añadir información al contexto:


```php
// In our middleware...
Context::add('url', $request->url());
Context::add('trace_id', Str::uuid()->toString());

// In our controller...
ProcessPodcast::dispatch($podcast);

```
Cuando se despacha el trabajo, cualquier información que actualmente se almacene en el contexto se captura y se comparte con el trabajo. La información capturada se rehidrata de nuevo en el contexto actual mientras se ejecuta el trabajo. Así que, si el método handle de nuestro trabajo escribiera en el registro:


```php
class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    // ...

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Log::info('Processing podcast.', [
            'podcast_id' => $this->podcast->id,
        ]);

        // ...
    }
}

```
La entrada de registro resultante contendría la información que se añadió al contexto durante la solicitud que despachó originalmente el trabajo:


```
Processing podcast. {"podcast_id":95} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}

```
Aunque nos hemos centrado en las características de registro integradas relacionadas con el contexto de Laravel, la documentación siguiente ilustrará cómo el contexto te permite compartir información a través del límite de la solicitud HTTP / el trabajo en cola y incluso cómo añadir [datos de contexto ocultos](#hidden-context) que no se escriben junto con las entradas de registro.

<a name="capturing-context"></a>
## Capturando Contexto

Puedes almacenar información en el contexto actual utilizando el método `add` de la fachada `Context`:


```php
use Illuminate\Support\Facades\Context;

Context::add('key', 'value');

```
Para añadir múltiples elementos a la vez, puedes pasar un array asociativo al método `add`:


```php
Context::add([
    'first_key' => 'value',
    'second_key' => 'value',
]);

```
El método `add` sobrescribirá cualquier valor existente que comparta la misma clave. Si solo deseas agregar información al contexto si la clave no existe ya, puedes usar el método `addIf`:


```php
Context::add('key', 'first');

Context::get('key');
// "first"

Context::addIf('key', 'second');

Context::get('key');
// "first"

```

<a name="conditional-context"></a>
#### Contexto Condicional

El método `when` se puede utilizar para añadir datos al contexto en función de una condición dada. La primera `función anónima` proporcionada al método `when` se invocará si la condición dada evalúa a `true`, mientras que la segunda `función anónima` se invocará si la condición evalúa a `false`:


```php
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Context;

Context::when(
    Auth::user()->isAdmin(),
    fn ($context) => $context->add('permissions', Auth::user()->permissions),
    fn ($context) => $context->add('permissions', []),
);

```

<a name="stacks"></a>
### Pilas

El contexto ofrece la capacidad de crear "pilas", que son listas de datos almacenadas en el orden en que se añadieron. Puedes añadir información a una pila invocando el método `push`:


```php
use Illuminate\Support\Facades\Context;

Context::push('breadcrumbs', 'first_value');

Context::push('breadcrumbs', 'second_value', 'third_value');

Context::get('breadcrumbs');
// [
//     'first_value',
//     'second_value',
//     'third_value',
// ]

```
Las pilas pueden ser útiles para capturar información histórica sobre una solicitud, como eventos que están ocurriendo a lo largo de tu aplicación. Por ejemplo, podrías crear un oyente de eventos para añadir a una pila cada vez que se ejecute una consulta, capturando la SQL de la consulta y la duración como una tupla:


```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Facades\DB;

DB::listen(function ($event) {
    Context::push('queries', [$event->time, $event->sql]);
});

```
Puedes determinar si un valor está en una pila utilizando los métodos `stackContains` y `hiddenStackContains`:


```php
if (Context::stackContains('breadcrumbs', 'first_value')) {
    //
}

if (Context::hiddenStackContains('secrets', 'first_value')) {
    //
}

```
Los métodos `stackContains` y `hiddenStackContains` también aceptan una función anónima como su segundo argumento, lo que permite un mayor control sobre la operación de comparación de valores:


```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Str;

return Context::stackContains('breadcrumbs', function ($value) {
    return Str::startsWith($value, 'query_');
});

```

<a name="retrieving-context"></a>
## Recuperando Contexto

Puedes recuperar información del contexto utilizando el método `get` de la fachada `Context`.


```php
use Illuminate\Support\Facades\Context;

$value = Context::get('key');

```
El método `only` se puede utilizar para recuperar un subconjunto de la información en el contexto:


```php
$data = Context::only(['first_key', 'second_key']);

```
El método `pull` se puede usar para recuperar información del contexto y eliminarla inmediatamente del contexto:


```php
$value = Context::pull('key');

```
Si deseas recuperar toda la información almacenada en el contexto, puedes invocar el método `all`:


```php
$data = Context::all();

```

<a name="determining-item-existence"></a>
### Determinando la Existencia de un Elemento

Puedes usar el método `has` para determinar si el contexto tiene algún valor almacenado para la clave dada:


```php
use Illuminate\Support\Facades\Context;

if (Context::has('key')) {
    // ...
}

```
El método `has` devolverá `true` independientemente del valor almacenado. Entonces, por ejemplo, una clave con un valor `null` será considerada presente:


```php
Context::add('key', null);

Context::has('key');
// true

```

<a name="removing-context"></a>
## Eliminando Contexto

El método `forget` se puede utilizar para eliminar una clave y su valor del contexto actual:


```php
use Illuminate\Support\Facades\Context;

Context::add(['first_key' => 1, 'second_key' => 2]);

Context::forget('first_key');

Context::all();

// ['second_key' => 2]

```
Puedes olvidar varias claves a la vez proporcionando un array al método `forget`:


```php
Context::forget(['first_key', 'second_key']);

```

<a name="hidden-context"></a>
## Contexto Oculto

El contexto ofrece la posibilidad de almacenar datos "ocultos". Esta información oculta no se añade a los registros y no es accesible a través de los métodos de recuperación de datos documentados arriba. El contexto proporciona un conjunto diferente de métodos para interactuar con la información de contexto oculta:


```php
use Illuminate\Support\Facades\Context;

Context::addHidden('key', 'value');

Context::getHidden('key');
// 'value'

Context::get('key');
// null

```
Los métodos "ocultos" reflejan la funcionalidad de los métodos no ocultos documentados arriba:


```php
Context::addHidden(/* ... */);
Context::addHiddenIf(/* ... */);
Context::pushHidden(/* ... */);
Context::getHidden(/* ... */);
Context::pullHidden(/* ... */);
Context::onlyHidden(/* ... */);
Context::allHidden(/* ... */);
Context::hasHidden(/* ... */);
Context::forgetHidden(/* ... */);

```

<a name="events"></a>
## Eventos

El contexto despacha dos eventos que te permiten engancharte en el proceso de hidratación y deshidratación del contexto.
Para ilustrar cómo se pueden utilizar estos eventos, imagina que en un middleware de tu aplicación estableces el valor de configuración `app.locale` basado en el encabezado `Accept-Language` de la solicitud HTTP entrante. Los eventos del contexto te permiten capturar este valor durante la solicitud y restaurarlo en la cola, asegurando que las notificaciones enviadas en la cola tengan el valor `app.locale` correcto. Podemos usar los eventos del contexto y datos [ocultos](#hidden-context) para lograr esto, lo cual ilustrará la siguiente documentación.

<a name="dehydrating"></a>
### Deshidratación

Cada vez que un trabajo se envía a la cola, los datos en el contexto son "deshidratados" y capturados junto con la carga útil del trabajo. El método `Context::dehydrating` te permite registrar una función anónima que se invocará durante el proceso de deshidratación. Dentro de esta función anónima, puedes hacer cambios en los datos que se compartirán con el trabajo en cola.
Típicamente, deberías registrar los callbacks `dehydrating` dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Log\Context\Repository;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Context;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Context::dehydrating(function (Repository $context) {
        $context->addHidden('locale', Config::get('app.locale'));
    });
}

```
> [!NOTA]
No debes usar la fachada `Context` dentro del callback `dehydrating`, ya que eso cambiará el contexto del proceso actual. Asegúrate de solo hacer cambios en el repositorio pasado al callback.

<a name="hydrated"></a>
### Hidratado

Siempre que un trabajo en cola comience a ejecutarse en la cola, cualquier contexto que se haya compartido con el trabajo será "hidratado" de vuelta en el contexto actual. El método `Context::hydrated` te permite registrar una función anónima que se invocará durante el proceso de hidratación.
Típicamente, debes registrar callbacks `hydrated` dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Log\Context\Repository;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Context;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Context::hydrated(function (Repository $context) {
        if ($context->hasHidden('locale')) {
            Config::set('app.locale', $context->getHidden('locale'));
        }
    });
}

```
> [!NOTA]
No debes usar la facade `Context` dentro del callback `hydrated` y en su lugar, asegúrate de que solo hagas cambios en el repositorio pasado al callback.