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
  - [Caché en Memoria](#in-memory-cache)
- [Ámbito](#scope)
  - [Especificando el Ámbito](#specifying-the-scope)
  - [Ámbito Predeterminado](#default-scope)
  - [Ámbito Nullable](#nullable-scope)
  - [Identificando Ámbito](#identifying-scope)
  - [Serializando Ámbito](#serializing-scope)
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

[Laravel Pennant](https://github.com/laravel/pennant) es un paquete de flags de características simple y ligero - sin complicaciones. Los flags de características te permiten implementar nuevas funciones de la aplicación de manera incremental con confianza, realizar pruebas A/B en nuevos diseños de interfaz, complementar una estrategia de desarrollo basada en trunk, y mucho más.

<a name="installation"></a>
## Instalación

Primero, instala Pennant en tu proyecto utilizando el gestor de paquetes Composer:


```shell
composer require laravel/pennant

```
A continuación, debes publicar los archivos de configuración y migración de Pennant utilizando el comando Artisan `vendor:publish`:


```shell
php artisan vendor:publish --provider="Laravel\Pennant\PennantServiceProvider"

```
Finalmente, debes ejecutar las migraciones de la base de datos de tu aplicación. Esto creará una tabla `features` que Pennant utiliza para alimentar su driver `database`:


```shell
php artisan migrate

```

<a name="configuration"></a>
## Configuración

Después de publicar los activos de Pennant, su archivo de configuración se ubicará en `config/pennant.php`. Este archivo de configuración te permite especificar el mecanismo de almacenamiento predeterminado que utilizará Pennant para almacenar los valores de los flags de características resueltos.
Pennant incluye soporte para almacenar los valores de las banderas de características resueltas en un array en memoria a través del driver `array`. O bien, Pennant puede almacenar los valores de las banderas de características resueltas de forma persistente en una base de datos relacional a través del driver `database`, que es el mecanismo de almacenamiento predeterminado utilizado por Pennant.

<a name="defining-features"></a>
## Definiendo Características

Para definir una función, puedes usar el método `define` ofrecido por la fachada `Feature`. Deberás proporcionar un nombre para la función, así como una función anónima que se invocará para resolver el valor inicial de la función.
Típicamente, las características se definen en un proveedor de servicios utilizando la fachada `Feature`. La función anónima recibirá el "scope" para la verificación de la característica. Más comúnmente, el scope es el usuario autenticado actualmente. En este ejemplo, definiremos una característica para implementar incrementalmente una nueva API a los usuarios de nuestra aplicación:


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
Como puedes ver, tenemos las siguientes reglas para nuestra función:
- Todos los miembros del equipo interno deben estar utilizando la nueva API.
- Cualquier cliente de alto tráfico no debe estar utilizando la nueva API.
- De lo contrario, la función debe ser asignada aleatoriamente a los usuarios con una probabilidad de 1 en 100 de estar activa.
La primera vez que se verifica la función `new-api` para un usuario dado, el resultado de la `función anónima` se almacenará por el driver de almacenamiento. La próxima vez que se verifique la función contra el mismo usuario, el valor se recuperará del almacenamiento y la `función anónima` no se invocará.
Por conveniencia, si una definición de característica solo devuelve una lotería, puedes omitir la función anónima por completo:


```php
Feature::define('site-redesign', Lottery::odds(1, 1000));
```

<a name="class-based-features"></a>
### Características Basadas en Clases

Pennant también te permite definir características basadas en clases. A diferencia de las definiciones de características basadas en funciones anónimas, no es necesario registrar una característica basada en clases en un proveedor de servicios. Para crear una característica basada en clases, puedes invocar el comando Artisan `pennant:feature`. Por defecto, la clase de la característica se colocará en el directorio `app/Features` de tu aplicación:


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
Si deseas resolver manualmente una instancia de una característica basada en una clase, puedes invocar el método `instance` en la facade `Feature`:


```php
use Illuminate\Support\Facades\Feature;

$instance = Feature::instance(NewApi::class);

```
> [!NOTA]
Las clases de características se resuelven a través del [contenedor](/docs/%7B%7Bversion%7D%7D/container), así que puedes inyectar dependencias en el constructor de la clase de características cuando sea necesario.
#### Personalizando el Nombre de la Función Almacenada

Por defecto, Pennant almacenará el nombre de la clase completamente cualificada de la clase de función. Si deseas desacoplar el nombre de la función almacenada de la estructura interna de la aplicación, puedes especificar una propiedad `$name` en la clase de función. El valor de esta propiedad se almacenará en lugar del nombre de la clase:


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

Para determinar si una función está activa, puedes usar el método `active` en la fachada `Feature`. Por defecto, las funciones se verifican contra el usuario autenticado actualmente:


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
Aunque las características se verifican en función del usuario autenticado actualmente por defecto, puedes verificar fácilmente la característica contra otro usuario o [alcance](#scope). Para lograr esto, utiliza el método `for` que ofrece la fachada `Feature`:
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
> [!NOTA]
Cuando utilices Pennant fuera de un contexto HTTP, como en un comando Artisan o un trabajo en cola, generalmente deberías [especificar explícitamente el alcance de la función](#specifying-the-scope). Alternativamente, puedes definir un [alcance predeterminado](#default-scope) que contemple tanto contextos HTTP autenticados como contextos no autenticados.

<a name="checking-class-based-features"></a>
#### Comprobando Características Basadas en Clases

Para características basadas en clases, debes proporcionar el nombre de la clase al verificar la característica:


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

El método `when` puede utilizarse para ejecutar de forma fluida una `función anónima` dada si una función está activa. Además, se puede proporcionar una segunda `función anónima`, que se ejecutará si la función está inactiva:


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
        return Feature::when(NewApi::class,
            fn () => $this->resolveNewApiResponse($request),
            fn () => $this->resolveLegacyApiResponse($request),
        );
    }

    // ...
}
```
El método `unless` sirve como el inverso del método `when`, ejecutando la primera función anónima si la característica está inactiva:


```php
return Feature::unless(NewApi::class,
    fn () => $this->resolveLegacyApiResponse($request),
    fn () => $this->resolveNewApiResponse($request),
);
```

<a name="the-has-features-trait"></a>
### El Trait `HasFeatures`

El rasgo `HasFeatures` de Pennant se puede añadir al modelo `User` de tu aplicación (o cualquier otro modelo que tenga características) para proporcionar una manera fluida y conveniente de comprobar características directamente desde el modelo:


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
Por supuesto, el método `features` proporciona acceso a muchos otros métodos convenientes para interactuar con características:


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
### Directiva de Blade

Para hacer que la verificación de características en Blade sea una experiencia fluida, Pennant ofrece una directiva `@feature`:


```blade
@feature('site-redesign')
    <!-- 'site-redesign' is active -->
@else
    <!-- 'site-redesign' is inactive -->
@endfeature

```

<a name="middleware"></a>
### Middleware

Pennant también incluye un [middleware](/docs/%7B%7Bversion%7D%7D/middleware) que se puede usar para verificar si el usuario autenticado actualmente tiene acceso a una función antes de que se invoque incluso una ruta. Puedes asignar el middleware a una ruta y especificar las funciones que se requieren para acceder a la ruta. Si cualquiera de las funciones especificadas está inactiva para el usuario autenticado actualmente, se devolverá una respuesta HTTP `400 Bad Request` por la ruta. Se pueden pasar múltiples funciones al método estático `using`.


```php
use Illuminate\Support\Facades\Route;
use Laravel\Pennant\Middleware\EnsureFeaturesAreActive;

Route::get('/api/servers', function () {
    // ...
})->middleware(EnsureFeaturesAreActive::using('new-api', 'servers-api'));

```

<a name="customizing-the-response"></a>
#### Personalizando la Respuesta

Si deseas personalizar la respuesta que devuelve el middleware cuando una de las funciones en la lista está inactiva, puedes usar el método `whenInactive` proporcionado por el middleware `EnsureFeaturesAreActive`. Típicamente, este método debe invocarse dentro del método `boot` de uno de los proveedores de servicios de tu aplicación:


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

A veces puede ser útil realizar algunas comprobaciones en memoria antes de recuperar el valor almacenado de una función dada. Imagina que estás desarrollando una nueva API detrás de un flag de función y deseas la capacidad de deshabilitar la nueva API sin perder ninguno de los valores de función resueltos en el almacenamiento. Si notas un error en la nueva API, podrías desactivarla fácilmente para todos excepto para los miembros del equipo interno, corregir el error y luego reactivar la nueva API para los usuarios que previamente tenían acceso a la función.
Puedes lograr esto con un método `before` de una [función basada en clases](#class-based-features). Cuando está presente, el método `before` siempre se ejecuta en memoria antes de recuperar el valor del almacenamiento. Si se devuelve un valor no `null` del método, se utilizará en lugar del valor almacenado de la función durante la duración de la solicitud:


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
También podrías utilizar esta función para programar el lanzamiento global de una característica que estaba previamente detrás de un flag de característica:


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
### Caché en Memoria

Al comprobar una función, Pennant creará un caché en memoria del resultado. Si estás utilizando el driver `database`, esto significa que volver a verificar la misma bandera de función dentro de una sola solicitud no activará consultas adicionales a la base de datos. Esto también asegura que la función tenga un resultado consistente durante la duración de la solicitud.
Si necesitas vaciar manualmente la caché en memoria, puedes usar el método `flushCache` que ofrece la fachada `Feature`:


```php
Feature::flushCache();
```

<a name="scope"></a>
## Alcance


<a name="specifying-the-scope"></a>
### Especificando el Alcance

Como se discutió, las funciones generalmente se verifican contra el usuario autenticado actualmente. Sin embargo, esto puede que no siempre se ajuste a tus necesidades. Por lo tanto, es posible especificar el ámbito que te gustaría verificar en relación con una función dada a través del método `for` de la facade `Feature`:


```php
return Feature::for($user)->active('new-api')
        ? $this->resolveNewApiResponse($request)
        : $this->resolveLegacyApiResponse($request);

```
Por supuesto, los scopes de características no están limitados a "usuarios". Imagina que has creado una nueva experiencia de facturación que estás implementando para equipos enteros en lugar de usuarios individuales. Quizás te gustaría que los equipos más antiguos tuvieran un despliegue más lento que los equipos más nuevos. Tu cierre de resolución de características podría verse algo como lo siguiente:


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
Notarás que la `función anónima` que hemos definido no está esperando un `User`, sino que está esperando un modelo `Team`. Para determinar si esta función está activa para el equipo de un usuario, debes pasar el equipo al método `for` que ofrece la `facade` de `Feature`:


```php
if (Feature::for($user->team)->active('billing-v2')) {
    return redirect('/billing/v2');
}

// ...

```

<a name="default-scope"></a>
### Alcance Predeterminado

También es posible personalizar el alcance predeterminado que utiliza Pennant para verificar características. Por ejemplo, tal vez todas tus características se verifiquen contra el equipo del usuario autenticado actualmente en lugar del usuario. En lugar de tener que llamar a `Feature::for($user->team)` cada vez que verificas una característica, puedes especificar el equipo como el alcance predeterminado. Típicamente, esto debería hacerse en uno de los proveedores de servicios de tu aplicación:


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
Si no se proporciona ningún alcance explícitamente a través del método `for`, la verificación de características ahora utilizará el equipo del usuario autenticado actualmente como el alcance predeterminado:


```php
Feature::active('billing-v2');

// Is now equivalent to...

Feature::for($user->team)->active('billing-v2');

```

<a name="nullable-scope"></a>
### Alcance Nullable

Si el alcance que proporcionas al verificar una característica es `null` y la definición de la característica no admite `null` a través de un tipo anulable o incluyendo `null` en un tipo de unión, Pennant devolverá automáticamente `false` como el valor de resultado de la característica.
Entonces, si el alcance que estás pasando a una característica es potencialmente `null` y quieres que se invoque el resolvedor de valores de la característica, debes tener eso en cuenta en la definición de tu característica. Un alcance `null` puede ocurrir si verificas una característica dentro de un comando Artisan, un trabajo en cola o una ruta no autenticada. Dado que generalmente no hay un usuario autenticado en estos contextos, el alcance predeterminado será `null`.
Si no siempre [especificas explícitamente el alcance de tu función](#specifying-the-scope), entonces debes asegurarte de que el tipo del alcance sea "nullable" y manejar el valor de alcance `null` dentro de la lógica de definición de tu función:


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
### Identificando el Alcance

Los controladores de almacenamiento `array` y `database` integrados de Pennant saben cómo almacenar correctamente los identificadores de ámbito para todos los tipos de datos de PHP, así como para modelos de Eloquent. Sin embargo, si tu aplicación utiliza un controlador Pennant de terceros, ese controlador puede no saber cómo almacenar correctamente un identificador para un modelo de Eloquent u otros tipos personalizados en tu aplicación.
A la luz de esto, Pennant te permite formatear los valores de alcance para su almacenamiento implementando el contrato `FeatureScopeable` en los objetos de tu aplicación que se utilizan como alcances de Pennant.
Por ejemplo, imagina que estás utilizando dos controladores de funciones diferentes en una sola aplicación: el controlador `database` incorporado y un controlador "Flag Rocket" de terceros. El controlador "Flag Rocket" no sabe cómo almacenar correctamente un modelo Eloquent. En su lugar, requiere una instancia de `FlagRocketUser`. Al implementar el `toFeatureIdentifier` definido por el contrato `FeatureScopeable`, podemos personalizar el valor de alcance almacenable que se proporciona a cada controlador utilizado por nuestra aplicación:


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
### Serializando el Alcance

Por defecto, Pennant utilizará un nombre de clase completamente calificado al almacenar una característica asociada con un modelo Eloquent. Si ya estás utilizando un [mapeo morfológico de Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent-relationships#custom-polymorphic-types), puedes optar por que Pennant también utilice el mapeo morfológico para desacoplar la característica almacenada de la estructura de tu aplicación.
Para lograr esto, después de definir tu mapa morfológico de Eloquent en un proveedor de servicios, puedes invocar el método `useMorphMap` de la facade `Feature`:


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

Hasta ahora, hemos mostrado principalmente las características como si estuvieran en un estado binario, lo que significa que están "activas" o "inactivas", pero Pennant también te permite almacenar valores enriquecidos.
Por ejemplo, imagina que estás probando tres nuevos colores para el botón "Comprar ahora" de tu aplicación. En lugar de devolver `true` o `false` desde la definición de la función, puedes devolver una cadena:


```php
use Illuminate\Support\Arr;
use Laravel\Pennant\Feature;

Feature::define('purchase-button', fn (User $user) => Arr::random([
    'blue-sapphire',
    'seafoam-green',
    'tart-orange',
]));

```
Puedes recuperar el valor de la función `purchase-button` utilizando el método `value`:


```php
$color = Feature::value('purchase-button');

```
La directiva Blade incluida de Pennant también facilita la representación condicional de contenido en función del valor actual de la característica:


```blade
@feature('purchase-button', 'blue-sapphire')
    <!-- 'blue-sapphire' is active -->
@elsefeature('purchase-button', 'seafoam-green')
    <!-- 'seafoam-green' is active -->
@elsefeature('purchase-button', 'tart-orange')
    <!-- 'tart-orange' is active -->
@endfeature

```
> [!NOTA]
Al utilizar valores ricos, es importante saber que una función se considera "activa" cuando tiene cualquier valor diferente de `false`.
Al llamar al método [condicional `when`](#conditional-execution), el valor enriquecido de la característica se proporcionará a la primera `función anónima`:


```php
Feature::when('purchase-button',
    fn ($color) => /* ... */,
    fn () => /* ... */,
);
```
Del mismo modo, al llamar al método condicional `unless`, el valor rico de la función se proporcionará a la segunda `función anónima` opcional:


```php
Feature::unless('purchase-button',
    fn () => /* ... */,
    fn ($color) => /* ... */,
);
```

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
O también puedes usar el método `all` para recuperar los valores de todas las características definidas para un alcance dado:


```php
Feature::all();

// [
//     'billing-v2' => false,
//     'purchase-button' => 'blue-sapphire',
//     'site-redesign' => true,
// ]

```
Sin embargo, las características basadas en clases se registran de manera dinámica y no son conocidas por Pennant hasta que se verifiquen explícitamente. Esto significa que las características basadas en clases de tu aplicación pueden no aparecer en los resultados devueltos por el método `all` si no se han verificado previamente durante la solicitud actual.
Si deseas asegurarte de que las clases de características siempre se incluyan al usar el método `all`, puedes utilizar las capacidades de descubrimiento de características de Pennant. Para comenzar, invoca el método `discover` en uno de los proveedores de servicios de tu aplicación:


```php
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
```
El método `discover` registrará todas las clases de características en el directorio `app/Features` de tu aplicación. El método `all` ahora incluirá estas clases en sus resultados, independientemente de si han sido verificadas durante la solicitud actual:


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

Aunque Pennant mantiene una caché en memoria de todas las características resueltas para una sola solicitud, aún es posible encontrar problemas de rendimiento. Para aliviar esto, Pennant ofrece la posibilidad de cargar con anticipación los valores de las características.
Para ilustrar esto, imagina que estamos verificando si una función está activa dentro de un bucle:


```php
use Laravel\Pennant\Feature;

foreach ($users as $user) {
    if (Feature::for($user)->active('notifications-beta')) {
        $user->notify(new RegistrationSuccess);
    }
}

```
Asumiendo que estamos utilizando el driver de base de datos, este código ejecutará una consulta a la base de datos por cada usuario en el bucle, lo que puede resultar en la ejecución de cientos de consultas. Sin embargo, utilizando el método `load` de Pennant, podemos eliminar este posible cuello de botella de rendimiento cargando de manera anticipada los valores de las características para una colección de usuarios o scopes:


```php
Feature::for($users)->load(['notifications-beta']);

foreach ($users as $user) {
    if (Feature::for($user)->active('notifications-beta')) {
        $user->notify(new RegistrationSuccess);
    }
}

```
Para cargar los valores de características solo cuando no se han cargado previamente, puedes usar el método `loadMissing`:


```php
Feature::for($users)->loadMissing([
    'new-api',
    'purchase-button',
    'notifications-beta',
]);

```
Puedes cargar todas las funciones definidas utilizando el método `loadAll`:


```php
Feature::for($user)->loadAll();

```

<a name="updating-values"></a>
## Actualizando Valores

Cuando el valor de una función se resuelve por primera vez, el driver subyacente almacenará el resultado en el almacenamiento. Esto a menudo es necesario para garantizar una experiencia coherente para sus usuarios a lo largo de las solicitudes. Sin embargo, a veces es posible que desee actualizar manualmente el valor almacenado de la función.
Para lograr esto, puedes usar los métodos `activate` y `deactivate` para activar o desactivar una función:


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
Para instruir a Pennant a que olvide el valor almacenado para una función, puedes usar el método `forget`. Cuando la función se verifique nuevamente, Pennant resolverá el valor de la función a partir de su definición:


```php
Feature::forget('purchase-button');

```

<a name="bulk-updates"></a>
### Actualizaciones Masivas

Para actualizar los valores de características almacenados en bloque, puedes usar los métodos `activateForEveryone` y `deactivateForEveryone`.
Por ejemplo, imagina que ahora confías en la estabilidad de la función `new-api` y has elegido el mejor color de `'purchase-button'` para tu flujo de pago: puedes actualizar el valor almacenado para todos los usuarios en consecuencia:


```php
use Laravel\Pennant\Feature;

Feature::activateForEveryone('new-api');

Feature::activateForEveryone('purchase-button', 'seafoam-green');

```
Alternativamente, puedes desactivar la función para todos los usuarios:


```php
Feature::deactivateForEveryone('new-api');

```
> [!NOTA]
Esto solo actualizará los valores de características resueltas que han sido almacenados por el driver de almacenamiento de Pennant. También necesitarás actualizar la definición de la característica en tu aplicación.

<a name="purging-features"></a>
### Purging Features

A veces, puede ser útil purgar una función completa del almacenamiento. Esto es típicamente necesario si has eliminado la función de tu aplicación o si has realizado ajustes en la definición de la función que te gustaría implementar para todos los usuarios.
Puedes eliminar todos los valores almacenados para una función utilizando el método `purge`:


```php
// Purging a single feature...
Feature::purge('new-api');

// Purging multiple features...
Feature::purge(['new-api', 'purchase-button']);

```
Si deseas purgar *todas* las características del almacenamiento, puedes invocar el método `purge` sin argumentos:


```php
Feature::purge();

```
Como puede ser útil purgar características como parte del pipeline de despliegue de tu aplicación, Pennant incluye un comando Artisan `pennant:purge` que eliminará las características proporcionadas del almacenamiento:


```sh
php artisan pennant:purge new-api

php artisan pennant:purge new-api purchase-button

```
También es posible purgar todas las características *excepto* aquellas en una lista de características dada. Por ejemplo, imagina que quieres purgar todas las características pero mantener los valores para las características "new-api" y "purchase-button" en almacenamiento. Para lograr esto, puedes pasar esos nombres de características a la opción `--except`:


```sh
php artisan pennant:purge --except=new-api --except=purchase-button

```
Para mayor comodidad, el comando `pennant:purge` también admite un flag `--except-registered`. Este flag indica que se deben eliminar todas las características excepto aquellas que están explícitamente registradas en un proveedor de servicios:


```sh
php artisan pennant:purge --except-registered

```

<a name="testing"></a>
## Pruebas

Al probar código que interactúa con flags de características, la forma más fácil de controlar el valor devuelto del flag de características en tus pruebas es simplemente redefinir la característica. Por ejemplo, imagina que tienes la siguiente característica definida en uno de los proveedores de servicios de tu aplicación:


```php
use Illuminate\Support\Arr;
use Laravel\Pennant\Feature;

Feature::define('purchase-button', fn () => Arr::random([
    'blue-sapphire',
    'seafoam-green',
    'tart-orange',
]));

```
Para modificar el valor devuelto por la función en tus pruebas, puedes redefinir la función al inicio de la prueba. La siguiente prueba siempre pasará, aunque la implementación de `Arr::random()` todavía esté presente en el proveedor de servicios:


```php
use Laravel\Pennant\Feature;

test('it can control feature values', function () {
    Feature::define('purchase-button', 'seafoam-green');

    expect(Feature::value('purchase-button'))->toBe('seafoam-green');
});

```


```php
use Laravel\Pennant\Feature;

public function test_it_can_control_feature_values()
{
    Feature::define('purchase-button', 'seafoam-green');

    $this->assertSame('seafoam-green', Feature::value('purchase-button'));
}

```
El mismo enfoque se puede utilizar para características basadas en clases:


```php
use Laravel\Pennant\Feature;

test('it can control feature values', function () {
    Feature::define(NewApi::class, true);

    expect(Feature::value(NewApi::class))->toBeTrue();
});

```


```php
use App\Features\NewApi;
use Laravel\Pennant\Feature;

public function test_it_can_control_feature_values()
{
    Feature::define(NewApi::class, true);

    $this->assertTrue(Feature::value(NewApi::class));
}

```
Si tu funcionalidad está devolviendo una instancia de `Lottery`, hay un puñado de [ayudas de prueba útiles disponibles](/docs/%7B%7Bversion%7D%7D/helpers#testing-lotteries).

<a name="store-configuration"></a>
#### Configuración de Almacén

Puedes configurar la tienda que Pennant utilizará durante las pruebas definiendo la variable de entorno `PENNANT_STORE` en el archivo `phpunit.xml` de tu aplicación:


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
## Agregar Controladores de Pennant Personalizados


<a name="implementing-the-driver"></a>
#### Implementando el Driver

Si ninguno de los controladores de almacenamiento existentes de Pennant se adapta a las necesidades de tu aplicación, puedes escribir tu propio controlador de almacenamiento. Tu controlador personalizado debe implementar la interfaz `Laravel\Pennant\Contracts\Driver`:


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
Ahora, solo necesitamos implementar cada uno de estos métodos utilizando una conexión Redis. Para un ejemplo de cómo implementar cada uno de estos métodos, echa un vistazo a la `Laravel\Pennant\Drivers\DatabaseDriver` en el [código fuente de Pennant](https://github.com/laravel/pennant/blob/1.x/src/Drivers/DatabaseDriver.php)
> [!NOTA]
Laravel no incluye un directorio para contener tus extensiones. Eres libre de colocarlas donde desees. En este ejemplo, hemos creado un directorio `Extensions` para albergar el `RedisFeatureDriver`.

<a name="registering-the-driver"></a>
#### Registrando el Driver

Una vez que tu driver haya sido implementado, estás listo para registrarlo con Laravel. Para añadir drivers adicionales a Pennant, puedes usar el método `extend` proporcionado por la fachada `Feature`. Debes llamar al método `extend` desde el método `boot` de uno de los [provedores de servicios](#/docs/%7B%7Bversion%7D%7D/providers) de tu aplicación:


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
Una vez que el driver ha sido registrado, puedes usar el driver `redis` en el archivo de configuración `config/pennant.php` de tu aplicación:


```php
'stores' => [

    'redis' => [
        'driver' => 'redis',
        'connection' => null,
    ],

    // ...

],
```

<a name="events"></a>
## Eventos

Pennant despacha una variedad de eventos que pueden ser útiles al rastrear flags de características a lo largo de tu aplicación.
### `Laravel\Pennant\Events\FeatureRetrieved`

Este evento se despacha cada vez que se [verifica una función](#checking-features). Este evento puede ser útil para crear y rastrear métricas sobre el uso de un flag de función a lo largo de su aplicación.
### `Laravel\Pennant\Events\FeatureResolved`

Este evento se despacha la primera vez que se resuelve el valor de una característica para un alcance específico.
### `Laravel\Pennant\Events\UnknownFeatureResolved`

Este evento se despacha la primera vez que se resuelve una característica desconocida para un alcance específico. Escuchar este evento puede ser útil si has intentado eliminar un flag de característica pero has dejado accidentalmente referencias sueltas a él a lo largo de tu aplicación:


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

Este evento se despacha cuando se verifica dinámicamente por primera vez un [feature basado en clase](#class-based-features) durante una solicitud.
### `Laravel\Pennant\Events\UnexpectedNullScopeEncountered`

Este evento se despacha cuando se pasa un alcance `null` a una definición de característica que [no admite null](#nullable-scope).
Esta situación se maneja de manera elegante y la función devolverá `false`. Sin embargo, si deseas optar por no utilizar el comportamiento elegante predeterminado de esta función, puedes registrar un listener para este evento en el método `boot` del `AppServiceProvider` de tu aplicación:


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

Este evento se despacha al actualizar una función para un alcance, generalmente llamando a `activate` o `deactivate`.
### `Laravel\Pennant\Events\FeatureUpdatedForAllScopes`

Este evento se despacha al actualizar una característica para todos los alcances, generalmente llamando a `activateForEveryone` o `deactivateForEveryone`.
### `Laravel\Pennant\Events\FeatureDeleted`

Este evento se despacha al eliminar una característica para un alcance, generalmente llamando a `forget`.
### `Laravel\Pennant\Events\FeaturesPurged`

Este evento se despacha al purgar características específicas.
### `Laravel\Pennant\Events\AllFeaturesPurged`

Este evento se despacha al purgar todas las funciones.