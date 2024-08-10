# Context

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

Las capacidades de "contexto" de Laravel te permiten capturar, recuperar y compartir información a lo largo de solicitudes, trabajos y comandos que se ejecutan dentro de tu aplicación. Esta información capturada también se incluye en los registros escritos por tu aplicación, dándote una visión más profunda de la historia de ejecución del código circundante que ocurrió antes de que se escribiera una entrada de registro y permitiéndote rastrear flujos de ejecución a lo largo de un sistema distribuido.

<a name="how-it-works"></a>
### Cómo Funciona

La mejor manera de entender las capacidades de contexto de Laravel es verlo en acción utilizando las características de registro integradas. Para comenzar, puedes [agregar información al contexto](#capturing-context) utilizando el facade `Context`. En este ejemplo, utilizaremos un [middleware](/docs/{{version}}/middleware) para agregar la URL de la solicitud y un ID de traza único al contexto en cada solicitud entrante:

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

La información agregada al contexto se adjunta automáticamente como metadatos a cualquier [entrada de registro](/docs/{{version}}/logging) que se escriba a lo largo de la solicitud. Adjuntar contexto como metadatos permite diferenciar la información pasada a entradas de registro individuales de la información compartida a través de `Context`. Por ejemplo, imagina que escribimos la siguiente entrada de registro:

```php
Log::info('Usuario autenticado.', ['auth_id' => Auth::id()]);
```

El registro escrito contendrá el `auth_id` pasado a la entrada de registro, pero también contendrá la `url` y `trace_id` del contexto como metadatos:

```
Usuario autenticado. {"auth_id":27} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}
```

La información agregada al contexto también está disponible para trabajos enviados a la cola. Por ejemplo, imagina que enviamos un trabajo `ProcessPodcast` a la cola después de agregar algo de información al contexto:

```php
// In our middleware...
Context::add('url', $request->url());
Context::add('trace_id', Str::uuid()->toString());

// In our controller...
ProcessPodcast::dispatch($podcast);
```

Cuando se envía el trabajo, cualquier información actualmente almacenada en el contexto se captura y se comparte con el trabajo. La información capturada se hidrata de nuevo en el contexto actual mientras se ejecuta el trabajo. Así que, si el método handle de nuestro trabajo escribiera en el registro:

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

La entrada de registro resultante contendría la información que se agregó al contexto durante la solicitud que originalmente envió el trabajo:

```
Procesando podcast. {"podcast_id":95} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}
```

Aunque nos hemos centrado en las características relacionadas con el registro integradas de las capacidades de contexto de Laravel, la siguiente documentación ilustrará cómo el contexto te permite compartir información a través del límite de solicitud HTTP / trabajo en cola e incluso cómo agregar [datos de contexto oculto](#hidden-context) que no se escriben con entradas de registro.

<a name="capturing-context"></a>
## Capturando Contexto

Puedes almacenar información en el contexto actual utilizando el método `add` del facade `Context`:

```php
use Illuminate\Support\Facades\Context;

Context::add('key', 'value');
```

Para agregar múltiples elementos a la vez, puedes pasar un array asociativo al método `add`:

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

El método `when` puede ser utilizado para agregar datos al contexto basado en una condición dada. La primera función anónima proporcionada al método `when` será invocada si la condición dada evalúa a `true`, mientras que la segunda función anónima será invocada si la condición evalúa a `false`:

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

El contexto ofrece la capacidad de crear "pilas", que son listas de datos almacenadas en el orden en que fueron agregadas. Puedes agregar información a una pila invocando el método `push`:

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

Las pilas pueden ser útiles para capturar información histórica sobre una solicitud, como eventos que están ocurriendo a lo largo de tu aplicación. Por ejemplo, podrías crear un listener de eventos para agregar a una pila cada vez que se ejecute una consulta, capturando el SQL de la consulta y la duración como una tupla:

```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Facades\DB;

DB::listen(function ($event) {
    Context::push('queries', [$event->time, $event->sql]);
});
```

<a name="retrieving-context"></a>
## Recuperando Contexto

Puedes recuperar información del contexto utilizando el método `get` del facade `Context`:

```php
use Illuminate\Support\Facades\Context;

$value = Context::get('key');
```

El método `only` puede ser utilizado para recuperar un subconjunto de la información en el contexto:

```php
$data = Context::only(['first_key', 'second_key']);
```

El método `pull` puede ser utilizado para recuperar información del contexto y eliminarla inmediatamente del contexto:

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

El método `has` devolverá `true` independientemente del valor almacenado. Así que, por ejemplo, una clave con un valor `null` será considerada presente:

```php
Context::add('key', null);

Context::has('key');
// true
```

<a name="removing-context"></a>
## Eliminando Contexto

El método `forget` puede ser utilizado para eliminar una clave y su valor del contexto actual:

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

El contexto ofrece la capacidad de almacenar datos "ocultos". Esta información oculta no se adjunta a los registros y no es accesible a través de los métodos de recuperación de datos documentados anteriormente. El contexto proporciona un conjunto diferente de métodos para interactuar con la información de contexto oculta:

```php
use Illuminate\Support\Facades\Context;

Context::addHidden('key', 'value');

Context::getHidden('key');
// 'value'

Context::get('key');
// null
```

Los métodos "ocultos" reflejan la funcionalidad de los métodos no ocultos documentados anteriormente:

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

Para ilustrar cómo se pueden usar estos eventos, imagina que en un middleware de tu aplicación estableces el valor de configuración `app.locale` basado en el encabezado `Accept-Language` de la solicitud HTTP entrante. Los eventos del contexto te permiten capturar este valor durante la solicitud y restaurarlo en la cola, asegurando que las notificaciones enviadas en la cola tengan el valor correcto de `app.locale`. Podemos usar los eventos del contexto y los datos [ocultos](#hidden-context) para lograr esto, lo cual ilustrará la siguiente documentación.

<a name="dehydrating"></a>
### Deshidratando

Cada vez que se envía un trabajo a la cola, los datos en el contexto son "deshidratados" y capturados junto con la carga útil del trabajo. El método `Context::dehydrating` te permite registrar una función anónima que será invocada durante el proceso de deshidratación. Dentro de esta función anónima, puedes hacer cambios a los datos que se compartirán con el trabajo en cola.

Típicamente, deberías registrar callbacks de `dehydrating` dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:

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

> [!NOTE]  
> No debes usar el facade `Context` dentro del callback de `dehydrating`, ya que eso cambiará el contexto del proceso actual. Asegúrate de solo hacer cambios en el repositorio pasado al callback.

<a name="hydrated"></a>
### Hidratado

Cada vez que un trabajo en cola comienza a ejecutarse en la cola, cualquier contexto que se compartió con el trabajo será "hidratado" de nuevo en el contexto actual. El método `Context::hydrated` te permite registrar una función anónima que será invocada durante el proceso de hidratación.

Típicamente, deberías registrar callbacks de `hydrated` dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:

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

> [!NOTE]  
> No debes usar el facade `Context` dentro del callback de `hydrated` y en su lugar asegurarte de solo hacer cambios en el repositorio pasado al callback.
