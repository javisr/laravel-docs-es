# Laravel Pennant

- [Introducción](#introduction)
- [Instalación](#installation)
- [Configuración](#configuration)
- [Definiendo Características](#defining-features)
    - [Características Basadas en Clases](#class-based-features)
- [Comprobando Características](#checking-features)
    - [Ejecución Condicional](#conditional-execution)
    - [El Trait `HasFeatures`](#the-has-features-trait)
    - [Directiva Blade](#blade-directive)
    - [Middleware](#middleware)
    - [Interceptando Comprobaciones de Características](#intercepting-feature-checks)
    - [Cache en Memoria](#in-memory-cache)
- [Alcance](#scope)
    - [Especificando el Alcance](#specifying-the-scope)
    - [Alcance Predeterminado](#default-scope)
    - [Alcance Nullable](#nullable-scope)
    - [Identificando Alcance](#identifying-scope)
    - [Serializando Alcance](#serializing-scope)
- [Valores de Características Ricas](#rich-feature-values)
- [Recuperando Múltiples Características](#retrieving-multiple-features)
- [Carga Eager](#eager-loading)
- [Actualizando Valores](#updating-values)
    - [Actualizaciones Masivas](#bulk-updates)
    - [Purga de Características](#purging-features)
- [Pruebas](#testing)
- [Añadiendo Controladores de Pennant Personalizados](#adding-custom-pennant-drivers)
    - [Implementando el Controlador](#implementing-the-driver)
    - [Registrando el Controlador](#registering-the-driver)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

[Laravel Pennant](https://github.com/laravel/pennant) es un paquete de banderas de características simple y ligero, sin complicaciones. Las banderas de características te permiten implementar nuevas características de la aplicación de manera incremental con confianza, realizar pruebas A/B de nuevos diseños de interfaz, complementar una estrategia de desarrollo basada en trunk, y mucho más.

<a name="installation"></a>
## Instalación

Primero, instala Pennant en tu proyecto utilizando el gestor de paquetes Composer:

```shell
composer require laravel/pennant
```

A continuación, deberías publicar los archivos de configuración y migración de Pennant utilizando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --provider="Laravel\Pennant\PennantServiceProvider"
```

Finalmente, deberías ejecutar las migraciones de la base de datos de tu aplicación. Esto creará una tabla `features` que Pennant utiliza para alimentar su controlador `database`:

```shell
php artisan migrate
```

<a name="configuration"></a>
## Configuración

Después de publicar los activos de Pennant, su archivo de configuración se ubicará en `config/pennant.php`. Este archivo de configuración te permite especificar el mecanismo de almacenamiento predeterminado que se utilizará para almacenar los valores de las banderas de características resueltas.

Pennant incluye soporte para almacenar valores de banderas de características resueltas en un array en memoria a través del controlador `array`. O, Pennant puede almacenar valores de banderas de características resueltas de manera persistente en una base de datos relacional a través del controlador `database`, que es el mecanismo de almacenamiento predeterminado utilizado por Pennant.

<a name="defining-features"></a>
## Definiendo Características

Para definir una característica, puedes usar el método `define` ofrecido por el facade `Feature`. Necesitarás proporcionar un nombre para la característica, así como una función anónima que se invocará para resolver el valor inicial de la característica.

Típicamente, las características se definen en un proveedor de servicios utilizando el facade `Feature`. La función anónima recibirá el "alcance" para la comprobación de la característica. Más comúnmente, el alcance es el usuario autenticado actualmente. En este ejemplo, definiremos una característica para implementar de manera incremental una nueva API para los usuarios de nuestra aplicación:

```php
<?php

namespace App\Providers;

use App\Models\User;
use Illuminate\Support\Lottery;
use Illuminate\Support\ServiceProvider;
use Laravel\Pennant\Feature;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Feature::define('new-api', fn (User $user) => match (true) {
            $user->isInternalTeamMember() => true,
            $user->isHighTrafficCustomer() => false,
            default => Lottery::odds(1 / 100),
        });
    }
}
```

Como puedes ver, tenemos las siguientes reglas para nuestra característica:

- Todos los miembros del equipo interno deberían estar usando la nueva API.
- Cualquier cliente de alto tráfico no debería estar usando la nueva API.
- De lo contrario, la característica debería ser asignada aleatoriamente a los usuarios con una probabilidad de 1 en 100 de estar activa.

La primera vez que se comprueba la característica `new-api` para un usuario dado, el resultado de la función anónima será almacenado por el controlador de almacenamiento. La próxima vez que se compruebe la característica contra el mismo usuario, el valor se recuperará del almacenamiento y la función anónima no se invocará.

Para conveniencia, si una definición de característica solo devuelve una lotería, puedes omitir completamente la función anónima:

    Feature::define('site-redesign', Lottery::odds(1, 1000));

<a name="class-based-features"></a>
### Características Basadas en Clases

Pennant también te permite definir características basadas en clases. A diferencia de las definiciones de características basadas en funciones anónimas, no es necesario registrar una característica basada en clases en un proveedor de servicios. Para crear una característica basada en clases, puedes invocar el comando Artisan `pennant:feature`. Por defecto, la clase de característica se colocará en el directorio `app/Features` de tu aplicación:

```shell
php artisan pennant:feature NewApi
```

Al escribir una clase de característica, solo necesitas definir un método `resolve`, que se invocará para resolver el valor inicial de la característica para un alcance dado. Nuevamente, el alcance será típicamente el usuario autenticado actualmente:

```php
<?php

namespace App\Features;

use App\Models\User;
use Illuminate\Support\Lottery;

class NewApi
{
    /**
     * Resolve the feature's initial value.
     */
    public function resolve(User $user): mixed
    {
        return match (true) {
            $user->isInternalTeamMember() => true,
            $user->isHighTrafficCustomer() => false,
            default => Lottery::odds(1 / 100),
        };
    }
}
```

> [!NOTE]   
> Las clases de características se resuelven a través del [contenedor](/docs/{{version}}/container), por lo que puedes inyectar dependencias en el constructor de la clase de característica cuando sea necesario.

#### Personalizando el Nombre de la Característica Almacenada

Por defecto, Pennant almacenará el nombre de clase completamente calificado de la clase de característica. Si deseas desacoplar el nombre de la característica almacenada de la estructura interna de la aplicación, puedes especificar una propiedad `$name` en la clase de característica. El valor de esta propiedad se almacenará en lugar del nombre de la clase:

```php
<?php

namespace App\Features;

class NewApi
{
    /**
     * The stored name of the feature.
     *
     * @var string
     */
    public $name = 'new-api';

    // ...
}
```

<a name="checking-features"></a>
## Comprobando Características

Para determinar si una característica está activa, puedes usar el método `active` en el facade `Feature`. Por defecto, las características se comprueban contra el usuario autenticado actualmente:

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Pennant\Feature;

class PodcastController
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): Response
    {
        return Feature::active('new-api')
                ? $this->resolveNewApiResponse($request)
                : $this->resolveLegacyApiResponse($request);
    }

    // ...
}
```

Aunque las características se comprueban contra el usuario autenticado actualmente por defecto, puedes comprobar fácilmente la característica contra otro usuario o [alcance](#scope). Para lograr esto, usa el método `for` ofrecido por el facade `Feature`:

```php
return Feature::for($user)->active('new-api')
        ? $this->resolveNewApiResponse($request)
        : $this->resolveLegacyApiResponse($request);
```

Pennant también ofrece algunos métodos de conveniencia adicionales que pueden resultar útiles al determinar si una característica está activa o no:

```php
// Determine if all of the given features are active...
Feature::allAreActive(['new-api', 'site-redesign']);

// Determine if any of the given features are active...
Feature::someAreActive(['new-api', 'site-redesign']);

// Determine if a feature is inactive...
Feature::inactive('new-api');

// Determine if all of the given features are inactive...
Feature::allAreInactive(['new-api', 'site-redesign']);

// Determine if any of the given features are inactive...
Feature::someAreInactive(['new-api', 'site-redesign']);
```

> [!NOTE]  
> Al usar Pennant fuera de un contexto HTTP, como en un comando Artisan o un trabajo en cola, deberías [especificar explícitamente el alcance de la característica](#specifying-the-scope). Alternativamente, puedes definir un [alcance predeterminado](#default-scope) que tenga en cuenta tanto los contextos HTTP autenticados como los no autenticados.

<a name="checking-class-based-features"></a>
#### Comprobando Características Basadas en Clases

Para características basadas en clases, deberías proporcionar el nombre de la clase al comprobar la característica:

```php
<?php

namespace App\Http\Controllers;

use App\Features\NewApi;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Pennant\Feature;

class PodcastController
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): Response
    {
        return Feature::active(NewApi::class)
                ? $this->resolveNewApiResponse($request)
                : $this->resolveLegacyApiResponse($request);
    }

    // ...
}
```

<a name="conditional-execution"></a>
### Ejecución Condicional

El método `when` puede ser utilizado para ejecutar de manera fluida una función anónima dada si una característica está activa. Además, se puede proporcionar una segunda función anónima que se ejecutará si la característica está inactiva:

    <?php

    namespace App\Http\Controllers;

    use App\Features\NewApi;
    use Illuminate\Http\Request;
    use Illuminate\Http\Response;
    use Laravel\Pennant\Feature;

    class PodcastController
    {
        /**
         * Mostrar una lista del recurso.
         */
        public function index(Request $request): Response
        {
            return Feature::when(NewApi::class,
                fn () => $this->resolveNewApiResponse($request),
                fn () => $this->resolveLegacyApiResponse($request),
            );
        }

        // ...
    }

El método `unless` sirve como el inverso del método `when`, ejecutando la primera función anónima si la característica está inactiva:

    return Feature::unless(NewApi::class,
        fn () => $this->resolveLegacyApiResponse($request),
        fn () => $this->resolveNewApiResponse($request),
    );

<a name="the-has-features-trait"></a>
### El Trait `HasFeatures`

El trait `HasFeatures` de Pennant puede ser añadido al modelo `User` de tu aplicación (o cualquier otro modelo que tenga características) para proporcionar una forma fluida y conveniente de comprobar características directamente desde el modelo:

```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Pennant\Concerns\HasFeatures;

class User extends Authenticatable
{
    use HasFeatures;

    // ...
}
```

Una vez que el trait ha sido añadido a tu modelo, puedes comprobar fácilmente las características invocando el método `features`:

```php
if ($user->features()->active('new-api')) {
    // ...
}
```

Por supuesto, el método `features` proporciona acceso a muchos otros métodos convenientes para interactuar con las características:

```php
// Values...
$value = $user->features()->value('purchase-button')
$values = $user->features()->values(['new-api', 'purchase-button']);

// State...
$user->features()->active('new-api');
$user->features()->allAreActive(['new-api', 'server-api']);
$user->features()->someAreActive(['new-api', 'server-api']);

$user->features()->inactive('new-api');
$user->features()->allAreInactive(['new-api', 'server-api']);
$user->features()->someAreInactive(['new-api', 'server-api']);

// Conditional execution...
$user->features()->when('new-api',
    fn () => /* ... */,
    fn () => /* ... */,
);

$user->features()->unless('new-api',
    fn () => /* ... */,
    fn () => /* ... */,
);
```

<a name="blade-directive"></a>
### Directiva Blade

Para hacer que la comprobación de características en Blade sea una experiencia fluida, Pennant ofrece una directiva `@feature`:

```blade
@feature('site-redesign')
    <!-- 'site-redesign' is active -->
@else
    <!-- 'site-redesign' is inactive -->
@endfeature
```

<a name="middleware"></a>
### Middleware

Pennant también incluye un [middleware](/docs/{{version}}/middleware) que puede ser utilizado para verificar que el usuario autenticado actualmente tiene acceso a una característica antes de que se invoque una ruta. Puedes asignar el middleware a una ruta y especificar las características que son requeridas para acceder a la ruta. Si alguna de las características especificadas está inactiva para el usuario autenticado actualmente, se devolverá una respuesta HTTP `400 Bad Request` por la ruta. Se pueden pasar múltiples características al método estático `using`.

```php
use Illuminate\Support\Facades\Route;
use Laravel\Pennant\Middleware\EnsureFeaturesAreActive;

Route::get('/api/servers', function () {
    // ...
})->middleware(EnsureFeaturesAreActive::using('new-api', 'servers-api'));
```

<a name="customizing-the-response"></a>
#### Personalizando la Respuesta

Si deseas personalizar la respuesta que se devuelve por el middleware cuando una de las características listadas está inactiva, puedes usar el método `whenInactive` proporcionado por el middleware `EnsureFeaturesAreActive`. Típicamente, este método debería ser invocado dentro del método `boot` de uno de los proveedores de servicios de tu aplicación:

```php
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Pennant\Middleware\EnsureFeaturesAreActive;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    EnsureFeaturesAreActive::whenInactive(
        function (Request $request, array $features) {
            return new Response(status: 403);
        }
    );

    // ...
}
```

<a name="intercepting-feature-checks"></a>
### Interceptando Comprobaciones de Características

A veces puede ser útil realizar algunas comprobaciones en memoria antes de recuperar el valor almacenado de una característica dada. Imagina que estás desarrollando una nueva API detrás de una bandera de característica y deseas la capacidad de desactivar la nueva API sin perder ninguno de los valores de características resueltas en almacenamiento. Si notas un error en la nueva API, podrías desactivarla fácilmente para todos excepto para los miembros del equipo interno, corregir el error y luego volver a habilitar la nueva API para los usuarios que previamente tenían acceso a la característica.

Puedes lograr esto con el método `before` de una [característica basada en clases](#class-based-features). Cuando está presente, el método `before` siempre se ejecuta en memoria antes de recuperar el valor del almacenamiento. Si se devuelve un valor no `null` desde el método, se utilizará en lugar del valor almacenado de la característica durante la duración de la solicitud:

```php
<?php

namespace App\Features;

use App\Models\User;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Lottery;

class NewApi
{
    /**
     * Run an always-in-memory check before the stored value is retrieved.
     */
    public function before(User $user): mixed
    {
        if (Config::get('features.new-api.disabled')) {
            return $user->isInternalTeamMember();
        }
    }

    /**
     * Resolve the feature's initial value.
     */
    public function resolve(User $user): mixed
    {
        return match (true) {
            $user->isInternalTeamMember() => true,
            $user->isHighTrafficCustomer() => false,
            default => Lottery::odds(1 / 100),
        };
    }
}
```

También podrías usar esta característica para programar la implementación global de una característica que anteriormente estaba detrás de una bandera de característica:

```php
<?php

namespace App\Features;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;

class NewApi
{
    /**
     * Run an always-in-memory check before the stored value is retrieved.
     */
    public function before(User $user): mixed
    {
        if (Config::get('features.new-api.disabled')) {
            return $user->isInternalTeamMember();
        }

        if (Carbon::parse(Config::get('features.new-api.rollout-date'))->isPast()) {
            return true;
        }
    }

    // ...
}
```

<a name="in-memory-cache"></a>
### Cache en Memoria

Al comprobar una característica, Pennant creará un cache en memoria del resultado. Si estás utilizando el controlador `database`, esto significa que volver a comprobar la misma bandera de característica dentro de una sola solicitud no activará consultas adicionales a la base de datos. Esto también asegura que la característica tenga un resultado consistente durante la duración de la solicitud.

Si necesitas vaciar manualmente el cache en memoria, puedes usar el método `flushCache` ofrecido por el facade `Feature`:

    Feature::flushCache();

<a name="scope"></a>
## Alcance

<a name="specifying-the-scope"></a>
### Especificando el Alcance

Como se discutió, las características se comprueban típicamente contra el usuario autenticado actualmente. Sin embargo, esto puede no siempre satisfacer tus necesidades. Por lo tanto, es posible especificar el alcance contra el cual te gustaría comprobar una característica dada a través del método `for` del facade `Feature`:

```php
return Feature::for($user)->active('new-api')
        ? $this->resolveNewApiResponse($request)
        : $this->resolveLegacyApiResponse($request);
```

Por supuesto, los alcances de características no están limitados a "usuarios". Imagina que has construido una nueva experiencia de facturación que estás implementando a equipos enteros en lugar de usuarios individuales. Quizás te gustaría que los equipos más antiguos tuvieran una implementación más lenta que los equipos más nuevos. La función anónima de resolución de tu característica podría verse algo así:

```php
use App\Models\Team;
use Carbon\Carbon;
use Illuminate\Support\Lottery;
use Laravel\Pennant\Feature;

Feature::define('billing-v2', function (Team $team) {
    if ($team->created_at->isAfter(new Carbon('1st Jan, 2023'))) {
        return true;
    }

    if ($team->created_at->isAfter(new Carbon('1st Jan, 2019'))) {
        return Lottery::odds(1 / 100);
    }

    return Lottery::odds(1 / 1000);
});
```

Notarás que la función anónima que hemos definido no está esperando un `User`, sino que está esperando un modelo `Team`. Para determinar si esta característica está activa para el equipo de un usuario, deberías pasar el equipo al método `for` ofrecido por el facade `Feature`:

```php
if (Feature::for($user->team)->active('billing-v2')) {
    return redirect('/billing/v2');
}

// ...
```

<a name="default-scope"></a>
### Alcance Predeterminado

También es posible personalizar el alcance predeterminado que Pennant utiliza para comprobar características. Por ejemplo, tal vez todas tus características se comprueben contra el equipo del usuario autenticado actualmente en lugar del usuario. En lugar de tener que llamar a `Feature::for($user->team)` cada vez que compruebas una característica, puedes especificar el equipo como el alcance predeterminado. Típicamente, esto debería hacerse en uno de los proveedores de servicios de tu aplicación:

```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;
use Laravel\Pennant\Feature;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Feature::resolveScopeUsing(fn ($driver) => Auth::user()?->team);

        // ...
    }
}
```

Si no se proporciona un alcance explícitamente a través del método `for`, la comprobación de la característica ahora utilizará el equipo del usuario autenticado actualmente como el alcance predeterminado:

```php
Feature::active('billing-v2');

// Is now equivalent to...

Feature::for($user->team)->active('billing-v2');
```

<a name="nullable-scope"></a>
### Alcance Nullable

Si el alcance que proporcionas al comprobar una característica es `null` y la definición de la característica no admite `null` a través de un tipo nullable o incluyendo `null` en un tipo de unión, Pennant devolverá automáticamente `false` como el valor de resultado de la característica.

Así que, si el alcance que estás pasando a una característica es potencialmente `null` y deseas que se invoque el resolvedor de valor de la característica, deberías tener en cuenta eso en la definición de tu característica. Un alcance `null` puede ocurrir si compruebas una característica dentro de un comando Artisan, un trabajo en cola o una ruta no autenticada. Dado que generalmente no hay un usuario autenticado en estos contextos, el alcance predeterminado será `null`.

Si no siempre [especificas explícitamente tu alcance de característica](#specifying-the-scope), entonces deberías asegurarte de que el tipo del alcance sea "nullable" y manejar el valor de alcance `null` dentro de la lógica de definición de tu característica:

```php
use App\Models\User;
use Illuminate\Support\Lottery;
use Laravel\Pennant\Feature;

Feature::define('new-api', fn (User $user) => match (true) {// [tl! remove]
Feature::define('new-api', fn (User|null $user) => match (true) {// [tl! add]
    $user === null => true,// [tl! add]
    $user->isInternalTeamMember() => true,
    $user->isHighTrafficCustomer() => false,
    default => Lottery::odds(1 / 100),
});
```

<a name="identifying-scope"></a>
### Identificando Alcance

Los controladores de almacenamiento `array` y `database` integrados de Pennant saben cómo almacenar correctamente los identificadores de alcance para todos los tipos de datos PHP, así como para modelos Eloquent. Sin embargo, si tu aplicación utiliza un controlador de Pennant de terceros, ese controlador puede no saber cómo almacenar correctamente un identificador para un modelo Eloquent u otros tipos personalizados en tu aplicación.

A la luz de esto, Pennant te permite formatear los valores de alcance para almacenamiento implementando el contrato `FeatureScopeable` en los objetos de tu aplicación que se utilizan como alcances de Pennant.

Por ejemplo, imagina que estás utilizando dos controladores de características diferentes en una sola aplicación: el controlador `database` integrado y un controlador de terceros "Flag Rocket". El controlador "Flag Rocket" no sabe cómo almacenar correctamente un modelo Eloquent. En su lugar, requiere una instancia de `FlagRocketUser`. Al implementar el método `toFeatureIdentifier` definido por el contrato `FeatureScopeable`, podemos personalizar el valor de alcance almacenable proporcionado a cada controlador utilizado por nuestra aplicación:

```php
<?php

namespace App\Models;

use FlagRocket\FlagRocketUser;
use Illuminate\Database\Eloquent\Model;
use Laravel\Pennant\Contracts\FeatureScopeable;

class User extends Model implements FeatureScopeable
{
    /**
     * Cast the object to a feature scope identifier for the given driver.
     */
    public function toFeatureIdentifier(string $driver): mixed
    {
        return match($driver) {
            'database' => $this,
            'flag-rocket' => FlagRocketUser::fromId($this->flag_rocket_id),
        };
    }
}
```

<a name="serializing-scope"></a>
### Serializando Alcance

Por defecto, Pennant utilizará un nombre de clase completamente calificado al almacenar una característica asociada con un modelo Eloquent. Si ya estás utilizando un [mapa de morfismos Eloquent](/docs/{{version}}/eloquent-relationships#custom-polymorphic-types), puedes optar por que Pennant también use el mapa de morfismos para desacoplar la característica almacenada de la estructura de tu aplicación.

Para lograr esto, después de definir tu mapa de morfismos Eloquent en un proveedor de servicios, puedes invocar el método `useMorphMap` de la fachada `Feature`:

```php
use Illuminate\Database\Eloquent\Relations\Relation;
use Laravel\Pennant\Feature;

Relation::enforceMorphMap([
    'post' => 'App\Models\Post',
    'video' => 'App\Models\Video',
]);

Feature::useMorphMap();
```

<a name="rich-feature-values"></a>
## Valores de Características Ricas

Hasta ahora, hemos mostrado principalmente características como si estuvieran en un estado binario, lo que significa que están "activas" o "inactivas", pero Pennant también te permite almacenar valores ricos.

Por ejemplo, imagina que estás probando tres nuevos colores para el botón "Comprar ahora" de tu aplicación. En lugar de devolver `true` o `false` de la definición de la característica, puedes devolver una cadena:

```php
use Illuminate\Support\Arr;
use Laravel\Pennant\Feature;

Feature::define('purchase-button', fn (User $user) => Arr::random([
    'blue-sapphire',
    'seafoam-green',
    'tart-orange',
]));
```

Puedes recuperar el valor de la característica `purchase-button` utilizando el método `value`:

```php
$color = Feature::value('purchase-button');
```

La directiva Blade incluida de Pennant también facilita renderizar contenido condicionalmente basado en el valor actual de la característica:

```blade
@feature('purchase-button', 'blue-sapphire')
    <!-- 'blue-sapphire' is active -->
@elsefeature('purchase-button', 'seafoam-green')
    <!-- 'seafoam-green' is active -->
@elsefeature('purchase-button', 'tart-orange')
    <!-- 'tart-orange' is active -->
@endfeature
```

> [!NOTE]   
> Al usar valores ricos, es importante saber que una característica se considera "activa" cuando tiene cualquier valor diferente de `false`.

Al llamar al método [condicional `when`](#conditional-execution), el valor rico de la característica se proporcionará a la primera función anónima:

    Feature::when('purchase-button',
        fn ($color) => /* ... */,
        fn () => /* ... */,
    );

Del mismo modo, al llamar al método condicional `unless`, el valor rico de la característica se proporcionará a la segunda función anónima opcional:

    Feature::unless('purchase-button',
        fn () => /* ... */,
        fn ($color) => /* ... */,
    );

<a name="retrieving-multiple-features"></a>
## Recuperando Múltiples Características

El método `values` permite la recuperación de múltiples características para un alcance dado:

```php
Feature::values(['billing-v2', 'purchase-button']);

// [
//     'billing-v2' => false,
//     'purchase-button' => 'blue-sapphire',
// ]
```

O, puedes usar el método `all` para recuperar los valores de todas las características definidas para un alcance dado:

```php
Feature::all();

// [
//     'billing-v2' => false,
//     'purchase-button' => 'blue-sapphire',
//     'site-redesign' => true,
// ]
```

Sin embargo, las características basadas en clases se registran dinámicamente y no son conocidas por Pennant hasta que se verifican explícitamente. Esto significa que las características basadas en clases de tu aplicación pueden no aparecer en los resultados devueltos por el método `all` si no se han verificado durante la solicitud actual.

Si deseas asegurarte de que las clases de características siempre se incluyan al usar el método `all`, puedes utilizar las capacidades de descubrimiento de características de Pennant. Para comenzar, invoca el método `discover` en uno de los proveedores de servicios de tu aplicación:

    <?php

    namespace App\Providers;

    use Illuminate\Support\ServiceProvider;
    use Laravel\Pennant\Feature;

    class AppServiceProvider extends ServiceProvider
    {
        /**
         * Bootstrap any application services.
         */
        public function boot(): void
        {
            Feature::discover();

            // ...
        }
    }

El método `discover` registrará todas las clases de características en el directorio `app/Features` de tu aplicación. El método `all` ahora incluirá estas clases en sus resultados, independientemente de si se han verificado durante la solicitud actual:

```php
Feature::all();

// [
//     'App\Features\NewApi' => true,
//     'billing-v2' => false,
//     'purchase-button' => 'blue-sapphire',
//     'site-redesign' => true,
// ]
```

<a name="eager-loading"></a>
## Carga Anticipada

Aunque Pennant mantiene una caché en memoria de todas las características resueltas para una sola solicitud, aún es posible encontrar problemas de rendimiento. Para aliviar esto, Pennant ofrece la capacidad de cargar anticipadamente los valores de las características.

Para ilustrar esto, imagina que estamos verificando si una característica está activa dentro de un bucle:

```php
use Laravel\Pennant\Feature;

foreach ($users as $user) {
    if (Feature::for($user)->active('notifications-beta')) {
        $user->notify(new RegistrationSuccess);
    }
}
```

Suponiendo que estamos usando el controlador de base de datos, este código ejecutará una consulta de base de datos para cada usuario en el bucle, ejecutando potencialmente cientos de consultas. Sin embargo, utilizando el método `load` de Pennant, podemos eliminar este posible cuello de botella de rendimiento cargando anticipadamente los valores de las características para una colección de usuarios o alcances:

```php
Feature::for($users)->load(['notifications-beta']);

foreach ($users as $user) {
    if (Feature::for($user)->active('notifications-beta')) {
        $user->notify(new RegistrationSuccess);
    }
}
```

Para cargar los valores de las características solo cuando no se han cargado previamente, puedes usar el método `loadMissing`:

```php
Feature::for($users)->loadMissing([
    'new-api',
    'purchase-button',
    'notifications-beta',
]);
```

Puedes cargar todas las características definidas utilizando el método `loadAll`:

```php
Feature::for($user)->loadAll();
```

<a name="updating-values"></a>
## Actualizando Valores

Cuando se resuelve el valor de una característica por primera vez, el controlador subyacente almacenará el resultado en el almacenamiento. Esto es a menudo necesario para asegurar una experiencia consistente para tus usuarios a través de las solicitudes. Sin embargo, a veces, puede que desees actualizar manualmente el valor almacenado de la característica.

Para lograr esto, puedes usar los métodos `activate` y `deactivate` para alternar una característica "encendida" o "apagada":

```php
use Laravel\Pennant\Feature;

// Activate the feature for the default scope...
Feature::activate('new-api');

// Deactivate the feature for the given scope...
Feature::for($user->team)->deactivate('billing-v2');
```

También es posible establecer manualmente un valor rico para una característica proporcionando un segundo argumento al método `activate`:

```php
Feature::activate('purchase-button', 'seafoam-green');
```

Para instruir a Pennant a olvidar el valor almacenado de una característica, puedes usar el método `forget`. Cuando la característica se verifique nuevamente, Pennant resolverá el valor de la característica a partir de su definición:

```php
Feature::forget('purchase-button');
```

<a name="bulk-updates"></a>
### Actualizaciones Masivas

Para actualizar los valores de características almacenados en masa, puedes usar los métodos `activateForEveryone` y `deactivateForEveryone`.

Por ejemplo, imagina que ahora estás seguro de la estabilidad de la característica `new-api` y has decidido el mejor color `'purchase-button'` para tu flujo de pago; puedes actualizar el valor almacenado para todos los usuarios en consecuencia:

```php
use Laravel\Pennant\Feature;

Feature::activateForEveryone('new-api');

Feature::activateForEveryone('purchase-button', 'seafoam-green');
```

Alternativamente, puedes desactivar la característica para todos los usuarios:

```php
Feature::deactivateForEveryone('new-api');
```

> [!NOTE]   
> Esto solo actualizará los valores de características resueltas que han sido almacenadas por el controlador de almacenamiento de Pennant. También necesitarás actualizar la definición de la característica en tu aplicación.

<a name="purging-features"></a>
### Purga de Características

A veces, puede ser útil purgar una característica completa del almacenamiento. Esto es típicamente necesario si has eliminado la característica de tu aplicación o has realizado ajustes en la definición de la característica que te gustaría implementar para todos los usuarios.

Puedes eliminar todos los valores almacenados para una característica utilizando el método `purge`:

```php
// Purging a single feature...
Feature::purge('new-api');

// Purging multiple features...
Feature::purge(['new-api', 'purchase-button']);
```

Si deseas purgar _todas_ las características del almacenamiento, puedes invocar el método `purge` sin argumentos:

```php
Feature::purge();
```

Como puede ser útil purgar características como parte de la canalización de implementación de tu aplicación, Pennant incluye un comando Artisan `pennant:purge` que purgará las características proporcionadas del almacenamiento:

```sh
php artisan pennant:purge new-api

php artisan pennant:purge new-api purchase-button
```

También es posible purgar todas las características _excepto_ aquellas en una lista de características dada. Por ejemplo, imagina que deseas purgar todas las características pero mantener los valores para las características "new-api" y "purchase-button" en el almacenamiento. Para lograr esto, puedes pasar esos nombres de características a la opción `--except`:

```sh
php artisan pennant:purge --except=new-api --except=purchase-button
```

Para conveniencia, el comando `pennant:purge` también admite una bandera `--except-registered`. Esta bandera indica que se deben purgar todas las características excepto aquellas registradas explícitamente en un proveedor de servicios:

```sh
php artisan pennant:purge --except-registered
```

<a name="testing"></a>
## Pruebas

Al probar código que interactúa con las banderas de características, la forma más fácil de controlar el valor devuelto de la bandera de características en tus pruebas es simplemente redefinir la característica. Por ejemplo, imagina que tienes la siguiente característica definida en uno de los proveedores de servicios de tu aplicación:

```php
use Illuminate\Support\Arr;
use Laravel\Pennant\Feature;

Feature::define('purchase-button', fn () => Arr::random([
    'blue-sapphire',
    'seafoam-green',
    'tart-orange',
]));
```

Para modificar el valor devuelto de la característica en tus pruebas, puedes redefinir la característica al comienzo de la prueba. La siguiente prueba siempre pasará, incluso si la implementación de `Arr::random()` todavía está presente en el proveedor de servicios:

```php tab=Pest
use Laravel\Pennant\Feature;

test('it can control feature values', function () {
    Feature::define('purchase-button', 'seafoam-green');

    expect(Feature::value('purchase-button'))->toBe('seafoam-green');
});
```

```php tab=PHPUnit
use Laravel\Pennant\Feature;

public function test_it_can_control_feature_values()
{
    Feature::define('purchase-button', 'seafoam-green');

    $this->assertSame('seafoam-green', Feature::value('purchase-button'));
}
```

El mismo enfoque se puede usar para características basadas en clases:

```php tab=Pest
use Laravel\Pennant\Feature;

test('it can control feature values', function () {
    Feature::define(NewApi::class, true);

    expect(Feature::value(NewApi::class))->toBeTrue();
});
```

```php tab=PHPUnit
use App\Features\NewApi;
use Laravel\Pennant\Feature;

public function test_it_can_control_feature_values()
{
    Feature::define(NewApi::class, true);

    $this->assertTrue(Feature::value(NewApi::class));
}
```

Si tu característica está devolviendo una instancia de `Lottery`, hay un puñado de [ayudantes de prueba útiles disponibles](/docs/{{version}}/helpers#testing-lotteries).

<a name="store-configuration"></a>
#### Configuración de Almacenamiento

Puedes configurar el almacenamiento que Pennant utilizará durante las pruebas definiendo la variable de entorno `PENNANT_STORE` en el archivo `phpunit.xml` de tu aplicación:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit colors="true">
    <!-- ... -->
    <php>
        <env name="PENNANT_STORE" value="array"/>
        <!-- ... -->
    </php>
</phpunit>
```

<a name="adding-custom-pennant-drivers"></a>
## Agregar Controladores Personalizados de Pennant

<a name="implementing-the-driver"></a>
#### Implementando el Controlador

Si ninguno de los controladores de almacenamiento existentes de Pennant se ajusta a las necesidades de tu aplicación, puedes escribir tu propio controlador de almacenamiento. Tu controlador personalizado debe implementar la interfaz `Laravel\Pennant\Contracts\Driver`:

```php
<?php

namespace App\Extensions;

use Laravel\Pennant\Contracts\Driver;

class RedisFeatureDriver implements Driver
{
    public function define(string $feature, callable $resolver): void {}
    public function defined(): array {}
    public function getAll(array $features): array {}
    public function get(string $feature, mixed $scope): mixed {}
    public function set(string $feature, mixed $scope, mixed $value): void {}
    public function setForAllScopes(string $feature, mixed $value): void {}
    public function delete(string $feature, mixed $scope): void {}
    public function purge(array|null $features): void {}
}
```

Ahora, solo necesitamos implementar cada uno de estos métodos utilizando una conexión Redis. Para un ejemplo de cómo implementar cada uno de estos métodos, echa un vistazo a `Laravel\Pennant\Drivers\DatabaseDriver` en el [código fuente de Pennant](https://github.com/laravel/pennant/blob/1.x/src/Drivers/DatabaseDriver.php)

> [!NOTE]  
> Laravel no incluye un directorio para contener tus extensiones. Eres libre de colocarlas donde desees. En este ejemplo, hemos creado un directorio `Extensions` para albergar el `RedisFeatureDriver`.

<a name="registering-the-driver"></a>
#### Registrando el Controlador

Una vez que tu controlador ha sido implementado, estás listo para registrarlo con Laravel. Para agregar controladores adicionales a Pennant, puedes usar el método `extend` proporcionado por la fachada `Feature`. Debes llamar al método `extend` desde el método `boot` de uno de los [proveedores de servicios](/docs/{{version}}/providers) de tu aplicación:

```php
<?php

namespace App\Providers;

use App\Extensions\RedisFeatureDriver;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\ServiceProvider;
use Laravel\Pennant\Feature;

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
        Feature::extend('redis', function (Application $app) {
            return new RedisFeatureDriver($app->make('redis'), $app->make('events'), []);
        });
    }
}
```

Una vez que el controlador ha sido registrado, puedes usar el controlador `redis` en el archivo de configuración `config/pennant.php` de tu aplicación:

    'stores' => [

        'redis' => [
            'driver' => 'redis',
            'connection' => null,
        ],

        // ...

    ],

<a name="events"></a>
## Eventos

Pennant despacha una variedad de eventos que pueden ser útiles al rastrear las banderas de características a lo largo de tu aplicación.

### `Laravel\Pennant\Events\FeatureRetrieved`

Este evento se despacha cada vez que se [verifica una característica](#checking-features). Este evento puede ser útil para crear y rastrear métricas sobre el uso de una bandera de características a lo largo de tu aplicación.

### `Laravel\Pennant\Events\FeatureResolved`

Este evento se despacha la primera vez que se resuelve el valor de una característica para un alcance específico.

### `Laravel\Pennant\Events\UnknownFeatureResolved`

Este evento se despacha la primera vez que se resuelve una característica desconocida para un alcance específico. Escuchar este evento puede ser útil si has tenido la intención de eliminar una bandera de características pero accidentalmente has dejado referencias errantes a ella en tu aplicación:

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;
use Laravel\Pennant\Events\UnknownFeatureResolved;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Event::listen(function (UnknownFeatureResolved $event) {
            Log::error("Resolving unknown feature [{$event->feature}].");
        });
    }
}
```

### `Laravel\Pennant\Events\DynamicallyRegisteringFeatureClass`

Este evento se despacha cuando una [característica basada en clase](#class-based-features) se verifica dinámicamente por primera vez durante una solicitud.

### `Laravel\Pennant\Events\UnexpectedNullScopeEncountered`

Este evento se despacha cuando se pasa un alcance `null` a una definición de característica que [no admite null](#nullable-scope).

Esta situación se maneja de manera adecuada y la característica devolverá `false`. Sin embargo, si deseas optar por no participar en el comportamiento predeterminado de gracia de esta característica, puedes registrar un oyente para este evento en el método `boot` de tu `AppServiceProvider` de la aplicación:

```php
use Illuminate\Support\Facades\Log;
use Laravel\Pennant\Events\UnexpectedNullScopeEncountered;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Event::listen(UnexpectedNullScopeEncountered::class, fn () => abort(500));
}

```

### `Laravel\Pennant\Events\FeatureUpdated`

Este evento se despacha al actualizar una característica para un alcance, generalmente al llamar a `activate` o `deactivate`.

### `Laravel\Pennant\Events\FeatureUpdatedForAllScopes`

Este evento se despacha al actualizar una característica para todos los alcances, generalmente al llamar a `activateForEveryone` o `deactivateForEveryone`.

### `Laravel\Pennant\Events\FeatureDeleted`

Este evento se despacha al eliminar una característica para un alcance, generalmente al llamar a `forget`.

### `Laravel\Pennant\Events\FeaturesPurged`

Este evento se despacha al purgar características específicas.

### `Laravel\Pennant\Events\AllFeaturesPurged`

Este evento se despacha al purgar todas las características.
