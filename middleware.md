# Middleware

- [Introducción](#introduction)
- [Definiendo Middleware](#defining-middleware)
- [Registrando Middleware](#registering-middleware)
  - [Middleware Global](#global-middleware)
  - [Asignando Middleware a Rutas](#assigning-middleware-to-routes)
  - [Grupos de Middleware](#middleware-groups)
  - [Aliased de Middleware](#middleware-aliases)
  - [Ordenando Middleware](#sorting-middleware)
- [Parámetros de Middleware](#middleware-parameters)
- [Middleware Terminable](#terminable-middleware)

<a name="introduction"></a>
## Introducción

Los middleware proporcionan un mecanismo conveniente para inspeccionar y filtrar las solicitudes HTTP que entran en tu aplicación. Por ejemplo, Laravel incluye un middleware que verifica si el usuario de tu aplicación está autenticado. Si el usuario no está autenticado, el middleware redirigirá al usuario a la pantalla de inicio de sesión de tu aplicación. Sin embargo, si el usuario está autenticado, el middleware permitirá que la solicitud avance más en la aplicación.
Se puede escribir middleware adicional para realizar una variedad de tareas además de la autenticación. Por ejemplo, un middleware de registro podría registrar todas las solicitudes entrantes a tu aplicación. Se incluye una variedad de middleware en Laravel, incluidos middleware para autenticación y protección CSRF; sin embargo, todo el middleware definido por el usuario suele estar ubicado en el directorio `app/Http/Middleware` de tu aplicación.

<a name="defining-middleware"></a>
## Definiendo Middleware

Para crear un nuevo middleware, utiliza el comando Artisan `make:middleware`:


```shell
php artisan make:middleware EnsureTokenIsValid

```
Este comando colocará una nueva clase `EnsureTokenIsValid` dentro de tu directorio `app/Http/Middleware`. En este middleware, solo permitiremos el acceso a la ruta si la entrada `token` suministrada coincide con un valor específico. De lo contrario, redirigiremos a los usuarios de vuelta a la URI `/home`:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureTokenIsValid
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->input('token') !== 'my-secret-token') {
            return redirect('/home');
        }

        return $next($request);
    }
}
```
Como puedes ver, si el `token` dado no coincide con nuestro token secreto, el middleware devolverá una redirección HTTP al cliente; de lo contrario, la solicitud se pasará más adentro de la aplicación. Para pasar la solicitud más allá en la aplicación (permitiendo que el middleware "pase"), debes llamar al callback `$next` con la `$request`.
Es mejor imaginar el middleware como una serie de "capas" que deben atravesar las solicitudes HTTP antes de llegar a tu aplicación. Cada capa puede examinar la solicitud e incluso rechazarla por completo.
> [!NOTE]
Todos los middleware se resuelven a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container), así que puedes indicar cualquier dependencia que necesites dentro del constructor de un middleware.

<a name="middleware-and-responses"></a>
#### Middleware y Respuestas

Por supuesto, un middleware puede realizar tareas antes o después de pasar la solicitud más dentro de la aplicación. Por ejemplo, el siguiente middleware realizaría alguna tarea **antes** de que la solicitud sea manejada por la aplicación:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BeforeMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        // Perform action

        return $next($request);
    }
}
```
Sin embargo, este middleware realizaría su tarea **después** de que la solicitud sea manejada por la aplicación:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AfterMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Perform action

        return $response;
    }
}
```

<a name="registering-middleware"></a>
## Registrando Middleware


<a name="global-middleware"></a>
### Middleware Global

Si deseas que un middleware se ejecute durante cada solicitud HTTP a tu aplicación, puedes añadirlo a la pila de middleware global en el archivo `bootstrap/app.php` de tu aplicación:


```php
use App\Http\Middleware\EnsureTokenIsValid;

->withMiddleware(function (Middleware $middleware) {
     $middleware->append(EnsureTokenIsValid::class);
})
```
El objeto `$middleware` proporcionado a la función anónima `withMiddleware` es una instancia de `Illuminate\Foundation\Configuration\Middleware` y es responsable de gestionar el middleware asignado a las rutas de tu aplicación. El método `append` añade el middleware al final de la lista de middleware global. Si deseas añadir un middleware al principio de la lista, debes usar el método `prepend`.

<a name="manually-managing-laravels-default-global-middleware"></a>
#### Gestionando Manualmente el Middleware Global Predeterminado de Laravel

Si deseas administrar manualmente la pila de middleware global de Laravel, puedes proporcionar la pila de middleware global predeterminada de Laravel al método `use`. Luego, puedes ajustar la pila de middleware predeterminada según sea necesario:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->use([
        // \Illuminate\Http\Middleware\TrustHosts::class,
        \Illuminate\Http\Middleware\TrustProxies::class,
        \Illuminate\Http\Middleware\HandleCors::class,
        \Illuminate\Foundation\Http\Middleware\PreventRequestsDuringMaintenance::class,
        \Illuminate\Http\Middleware\ValidatePostSize::class,
        \Illuminate\Foundation\Http\Middleware\TrimStrings::class,
        \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
    ]);
})
```

<a name="assigning-middleware-to-routes"></a>
### Asignando Middleware a Rutas

Si deseas asignar middleware a rutas específicas, puedes invocar el método `middleware` al definir la ruta:


```php
use App\Http\Middleware\EnsureTokenIsValid;

Route::get('/profile', function () {
    // ...
})->middleware(EnsureTokenIsValid::class);
```
Puedes asignar múltiples middleware a la ruta pasando un array de nombres de middleware al método `middleware`:


```php
Route::get('/', function () {
    // ...
})->middleware([First::class, Second::class]);
```

<a name="excluding-middleware"></a>
#### Excluyendo Middleware

Al asignar middleware a un grupo de rutas, es posible que ocasionalmente necesites evitar que el middleware se aplique a una ruta individual dentro del grupo. Puedes lograr esto utilizando el método `withoutMiddleware`:


```php
use App\Http\Middleware\EnsureTokenIsValid;

Route::middleware([EnsureTokenIsValid::class])->group(function () {
    Route::get('/', function () {
        // ...
    });

    Route::get('/profile', function () {
        // ...
    })->withoutMiddleware([EnsureTokenIsValid::class]);
});
```
También puedes excluir un conjunto dado de middleware de un [grupo](/docs/%7B%7Bversion%7D%7D/routing#route-groups) completo de definiciones de rutas:


```php
use App\Http\Middleware\EnsureTokenIsValid;

Route::withoutMiddleware([EnsureTokenIsValid::class])->group(function () {
    Route::get('/profile', function () {
        // ...
    });
});
```
El método `withoutMiddleware` solo puede eliminar middleware de ruta y no se aplica a [middleware global](#global-middleware).

<a name="middleware-groups"></a>
### Grupos de Middleware

A veces es posible que desees agrupar varios middleware bajo una sola clave para facilitar su asignación a rutas. Puedes lograr esto utilizando el método `appendToGroup` dentro del archivo `bootstrap/app.php` de tu aplicación:


```php
use App\Http\Middleware\First;
use App\Http\Middleware\Second;

->withMiddleware(function (Middleware $middleware) {
    $middleware->appendToGroup('group-name', [
        First::class,
        Second::class,
    ]);

    $middleware->prependToGroup('group-name', [
        First::class,
        Second::class,
    ]);
})
```
Los grupos de middleware se pueden asignar a rutas y acciones del controlador utilizando la misma sintaxis que el middleware individual:


```php
Route::get('/', function () {
    // ...
})->middleware('group-name');

Route::middleware(['group-name'])->group(function () {
    // ...
});
```

<a name="laravels-default-middleware-groups"></a>
#### Grupos de Middleware Predeterminados de Laravel

Laravel incluye grupos de middleware predefinidos `web` y `api` que contienen middleware comunes que puedes querer aplicar a tus rutas web y API. Recuerda que Laravel aplica automáticamente estos grupos de middleware a los archivos correspondientes `routes/web.php` y `routes/api.php`:
<div class="overflow-auto">

| El Grupo de Middleware `web` |
| --- |
| `Illuminate\Cookie\Middleware\EncryptCookies` |
| `Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse` |
| `Illuminate\Session\Middleware\StartSession` |
| `Illuminate\View\Middleware\ShareErrorsFromSession` |
| `Illuminate\Foundation\Http\Middleware\ValidateCsrfToken` |
| `Illuminate\Routing\Middleware\SubstituteBindings` |
</div>
<div class="overflow-auto">

| El Grupo de Middleware `api` |
| --- |
| `Illuminate\Routing\Middleware\SubstituteBindings` |
</div>
Si deseas añadir o anteponer middleware a estos grupos, puedes usar los métodos `web` y `api` dentro del archivo `bootstrap/app.php` de tu aplicación. Los métodos `web` y `api` son alternativas convenientes al método `appendToGroup`:


```php
use App\Http\Middleware\EnsureTokenIsValid;
use App\Http\Middleware\EnsureUserIsSubscribed;

->withMiddleware(function (Middleware $middleware) {
    $middleware->web(append: [
        EnsureUserIsSubscribed::class,
    ]);

    $middleware->api(prepend: [
        EnsureTokenIsValid::class,
    ]);
})
```
Puedes incluso reemplazar una de las entradas del grupo de middleware predeterminado de Laravel con un middleware personalizado propio:


```php
use App\Http\Middleware\StartCustomSession;
use Illuminate\Session\Middleware\StartSession;

$middleware->web(replace: [
    StartSession::class => StartCustomSession::class,
]);
```
O bien, puedes eliminar un middleware por completo:


```php
$middleware->web(remove: [
    StartSession::class,
]);
```

<a name="manually-managing-laravels-default-middleware-groups"></a>
#### Gestión Manual de los Grupos de Middleware Predeterminados de Laravel

Si deseas gestionar manualmente todo el middleware dentro de los grupos de middleware `web` y `api` predeterminados de Laravel, puedes redefinir los grupos por completo. El ejemplo a continuación definirá los grupos de middleware `web` y `api` con su middleware predeterminado, lo que te permitirá personalizarlos según sea necesario:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->group('web', [
        \Illuminate\Cookie\Middleware\EncryptCookies::class,
        \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        // \Illuminate\Session\Middleware\AuthenticateSession::class,
    ]);

    $middleware->group('api', [
        // \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        // 'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ]);
})
```
> [!NOTA]
Por defecto, los grupos de middleware `web` y `api` se aplican automáticamente a los archivos correspondientes `routes/web.php` y `routes/api.php` de tu aplicación a través del archivo `bootstrap/app.php`.

<a name="middleware-aliases"></a>
### Alias de Middleware

Puedes asignar alias a middleware en el archivo `bootstrap/app.php` de tu aplicación. Los alias de middleware te permiten definir un alias corto para una clase de middleware dada, lo que puede ser especialmente útil para middleware con nombres de clase largos:


```php
use App\Http\Middleware\EnsureUserIsSubscribed;

->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'subscribed' => EnsureUserIsSubscribed::class
    ]);
})
```
Una vez que el alias del middleware ha sido definido en el archivo `bootstrap/app.php` de tu aplicación, puedes usar el alias al asignar el middleware a las rutas:


```php
Route::get('/profile', function () {
    // ...
})->middleware('subscribed');
```
Para mayor comodidad, algunos de los middleware integrados de Laravel están aliased por defecto. Por ejemplo, el middleware `auth` es un alias para el middleware `Illuminate\Auth\Middleware\Authenticate`. A continuación se muestra una lista de los alias de middleware predeterminados:
<div class="overflow-auto">

| Alias | Middleware |
| --- | --- |
| `auth` | `Illuminate\Auth\Middleware\Authenticate` |
| `auth.basic` | `Illuminate\Auth\Middleware\AuthenticateWithBasicAuth` |
| `auth.session` | `Illuminate\Session\Middleware\AuthenticateSession` |
| `cache.headers` | `Illuminate\Http\Middleware\SetCacheHeaders` |
| `can` | `Illuminate\Auth\Middleware\Authorize` |
| `guest` | `Illuminate\Auth\Middleware\RedirectIfAuthenticated` |
| `password.confirm` | `Illuminate\Auth\Middleware\RequirePassword` |
| `precognitive` | `Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests` |
| `signed` | `Illuminate\Routing\Middleware\ValidateSignature` |
| `subscribed` | `\Spark\Http\Middleware\VerifyBillableIsSubscribed` |
| `throttle` | `Illuminate\Routing\Middleware\ThrottleRequests` o `Illuminate\Routing\Middleware\ThrottleRequestsWithRedis` |
| `verified` | `Illuminate\Auth\Middleware\EnsureEmailIsVerified` |
</div>

<a name="sorting-middleware"></a>
### Ordenando Middleware

Rara vez, es posible que necesites que tu middleware se ejecute en un orden específico pero no tengas control sobre su orden cuando se asignan a la ruta. En estas situaciones, puedes especificar tu prioridad de middleware utilizando el método `priority` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->priority([
        \Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests::class,
        \Illuminate\Cookie\Middleware\EncryptCookies::class,
        \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        \Illuminate\Routing\Middleware\ThrottleRequests::class,
        \Illuminate\Routing\Middleware\ThrottleRequestsWithRedis::class,
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        \Illuminate\Contracts\Auth\Middleware\AuthenticatesRequests::class,
        \Illuminate\Auth\Middleware\Authorize::class,
    ]);
})
```

<a name="middleware-parameters"></a>
## Parámetros de Middleware

El middleware también puede recibir parámetros adicionales. Por ejemplo, si tu aplicación necesita verificar que el usuario autenticado tiene un "rol" dado antes de realizar una acción dada, podrías crear un middleware `EnsureUserHasRole` que reciba un nombre de rol como argumento adicional.
Se pasarán parámetros adicionales del middleware al middleware después del argumento `$next`:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        if (! $request->user()->hasRole($role)) {
            // Redirect...
        }

        return $next($request);
    }

}
```
Los parámetros del middleware pueden especificarse al definir la ruta separando el nombre del middleware y los parámetros con un `:`:


```php
Route::put('/post/{id}', function (string $id) {
    // ...
})->middleware('role:editor');
```
Se pueden delimitar múltiples parámetros con comas:


```php
Route::put('/post/{id}', function (string $id) {
    // ...
})->middleware('role:editor,publisher');
```

<a name="terminable-middleware"></a>
## Middleware Terminable

A veces, un middleware puede necesitar realizar algunas tareas después de que la respuesta HTTP se haya enviado al navegador. Si defines un método `terminate` en tu middleware y tu servidor web está utilizando FastCGI, el método `terminate` se llamará automáticamente después de que la respuesta se envíe al navegador:


```php
<?php

namespace Illuminate\Session\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TerminatingMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        return $next($request);
    }

    /**
     * Handle tasks after the response has been sent to the browser.
     */
    public function terminate(Request $request, Response $response): void
    {
        // ...
    }
}
```
El método `terminate` debe recibir tanto la solicitud como la respuesta. Una vez que hayas definido un middleware terminable, debes agregarlo a la lista de rutas o middleware global en el archivo `bootstrap/app.php` de tu aplicación.
Al llamar al método `terminate` en tu middleware, Laravel resolverá una nueva instancia del middleware desde el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container). Si deseas utilizar la misma instancia de middleware cuando se llamen los métodos `handle` y `terminate`, registra el middleware con el contenedor utilizando el método `singleton` del contenedor. Típicamente, esto debe hacerse en el método `register` de tu `AppServiceProvider`:


```php
use App\Http\Middleware\TerminatingMiddleware;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->app->singleton(TerminatingMiddleware::class);
}
```