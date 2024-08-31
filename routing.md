# Enrutamiento

- [Enrutamiento Básico](#basic-routing)
  - [Los Archivos de Ruta por Defecto](#the-default-route-files)
  - [Rutas de Redireccionamiento](#redirect-routes)
  - [Rutas de Vista](#view-routes)
  - [Listar tus Rutas](#listing-your-routes)
  - [Personalización de Enrutamiento](#routing-customization)
- [Parámetros de Ruta](#route-parameters)
  - [Parámetros Requeridos](#required-parameters)
  - [Parámetros Opcionales](#parameters-optional-parameters)
  - [Restricciones de Expresión Regular](#parameters-regular-expression-constraints)
- [Rutas Nombradas](#named-routes)
- [Grupos de Rutas](#route-groups)
  - [Middleware](#route-group-middleware)
  - [Controladores](#route-group-controllers)
  - [Enrutamiento de Subdominio](#route-group-subdomain-routing)
  - [Prefijos de Ruta](#route-group-prefixes)
  - [Prefijos de Nombres de Ruta](#route-group-name-prefixes)
- [Vinculación de Modelos de Ruta](#route-model-binding)
  - [Vinculación Implícita](#implicit-binding)
  - [Vinculación de Enum Implícita](#implicit-enum-binding)
  - [Vinculación Explícita](#explicit-binding)
- [Rutas de Respaldo](#fallback-routes)
- [Limitación de Tasa](#rate-limiting)
  - [Definiendo Limitadores de Tasa](#defining-rate-limiters)
  - [Adjuntando Limitadores de Tasa a Rutas](#attaching-rate-limiters-to-routes)
- [Suplantación de Método de Formulario](#form-method-spoofing)
- [Accediendo a la Ruta Actual](#accessing-the-current-route)
- [Intercambio de Recursos de Origen Cruzado (CORS)](#cors)
- [Caché de Rutas](#route-caching)

<a name="basic-routing"></a>
## Enrutamiento Básico

Las rutas más básicas de Laravel aceptan una URI y una función anónima, proporcionando un método muy simple y expresivo para definir rutas y comportamientos sin archivos de configuración de enrutamiento complicados:


```php
use Illuminate\Support\Facades\Route;

Route::get('/greeting', function () {
    return 'Hello World';
});
```

<a name="the-default-route-files"></a>
### Los Archivos de Ruta Predeterminados

Todas las rutas de Laravel se definen en tus archivos de ruta, que se encuentran en el directorio `routes`. Estos archivos se cargan automáticamente en Laravel utilizando la configuración especificada en el archivo `bootstrap/app.php` de tu aplicación. El archivo `routes/web.php` define rutas que son para tu interfaz web. Estas rutas se asignan al grupo de middleware `web` [middleware group](/docs/%7B%7Bversion%7D%7D/middleware#laravels-default-middleware-groups), que ofrece características como estado de sesión y protección CSRF.
Para la mayoría de las aplicaciones, comenzarás definiendo rutas en tu archivo `routes/web.php`. Las rutas definidas en `routes/web.php` se pueden acceder ingresando la URL de la ruta definida en tu navegador. Por ejemplo, puedes acceder a la siguiente ruta navegando a `http://example.com/user` en tu navegador:


```php
use App\Http\Controllers\UserController;

Route::get('/user', [UserController::class, 'index']);
```

<a name="api-routes"></a>
#### Rutas de API

Si tu aplicación también ofrecerá una API sin estado, puedes habilitar el enrutamiento de API utilizando el comando Artisan `install:api`:


```shell
php artisan install:api

```
El comando `install:api` instala [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum), que proporciona un guardia de autenticación de token API robusto pero simple que se puede usar para autenticar consumidores de API de terceros, SPA o aplicaciones móviles. Además, el comando `install:api` crea el archivo `routes/api.php`:


```php
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
```
Las rutas en `routes/api.php` son sin estado y están asignadas al grupo de [middleware](/docs/%7B%7Bversion%7D%7D/middleware#laravels-default-middleware-groups) `api`. Además, el prefijo de URI `/api` se aplica automáticamente a estas rutas, por lo que no necesitas aplicarlo manualmente a cada ruta en el archivo. Puedes cambiar el prefijo modificando el archivo `bootstrap/app.php` de tu aplicación:


```php
->withRouting(
    api: __DIR__.'/../routes/api.php',
    apiPrefix: 'api/admin',
    // ...
)
```

<a name="available-router-methods"></a>
#### Métodos de Router Disponibles

El enrutador te permite registrar rutas que responden a cualquier verbo HTTP:


```php
Route::get($uri, $callback);
Route::post($uri, $callback);
Route::put($uri, $callback);
Route::patch($uri, $callback);
Route::delete($uri, $callback);
Route::options($uri, $callback);
```
A veces es posible que necesites registrar una ruta que responda a múltiples verbos HTTP. Puedes hacerlo utilizando el método `match`. O, incluso puedes registrar una ruta que responda a todos los verbos HTTP utilizando el método `any`:


```php
Route::match(['get', 'post'], '/', function () {
    // ...
});

Route::any('/', function () {
    // ...
});
```
> [!NOTE]
Al definir múltiples rutas que comparten la misma URI, las rutas que utilizan los métodos `get`, `post`, `put`, `patch`, `delete` y `options` deben definirse antes que las rutas que utilizan los métodos `any`, `match` y `redirect`. Esto asegura que la solicitud entrante se coincida con la ruta correcta.

<a name="dependency-injection"></a>
#### Inyección de Dependencias

Puedes indicar cualquier dependencia necesaria para tu ruta en la firma de devolución de llamada de tu ruta. Las dependencias declaradas se resolverán e inyectarán automáticamente en la devolución de llamada por el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel. Por ejemplo, puedes indicar la clase `Illuminate\Http\Request` para que la solicitud HTTP actual se inyecte automáticamente en la devolución de llamada de tu ruta:


```php
use Illuminate\Http\Request;

Route::get('/users', function (Request $request) {
    // ...
});
```

<a name="csrf-protection"></a>
#### Protección CSRF

Recuerda que cualquier formulario HTML que apunte a rutas `POST`, `PUT`, `PATCH` o `DELETE` que estén definidas en el archivo de rutas `web` debe incluir un campo de token CSRF. De lo contrario, la solicitud será rechazada. Puedes leer más sobre la protección CSRF en la [documentación de CSRF](/docs/%7B%7Bversion%7D%7D/csrf):


```php
<form method="POST" action="/profile">
    @csrf
    ...
</form>
```

<a name="redirect-routes"></a>
### Rutas de Redirección

Si estás definiendo una ruta que redirige a otra URI, puedes usar el método `Route::redirect`. Este método proporciona un atajo conveniente para que no tengas que definir una ruta completa o un controlador para realizar una simple redirección:


```php
Route::redirect('/here', '/there');
```
Por defecto, `Route::redirect` devuelve un código de estado `302`. Puedes personalizar el código de estado utilizando el tercer parámetro opcional:


```php
Route::redirect('/here', '/there', 301);
```
O puedes usar el método `Route::permanentRedirect` para devolver un código de estado `301`:


```php
Route::permanentRedirect('/here', '/there');
```
> [!WARNING]
Al utilizar parámetros de ruta en rutas de redirección, los siguientes parámetros están reservados por Laravel y no se pueden usar: `destination` y `status`.

<a name="view-routes"></a>
### Ver Rutas

Si tu ruta solo necesita devolver una [vista](/docs/%7B%7Bversion%7D%7D/views), puedes usar el método `Route::view`. Al igual que el método `redirect`, este método proporciona un atajo simple para que no tengas que definir una ruta completa o un controlador. El método `view` acepta una URI como su primer argumento y un nombre de vista como su segundo argumento. Además, puedes proporcionar un array de datos para pasar a la vista como un tercer argumento opcional:


```php
Route::view('/welcome', 'welcome');

Route::view('/welcome', 'welcome', ['name' => 'Taylor']);
```
> [!WARNING]
Al usar parámetros de ruta en rutas de vista, los siguientes parámetros están reservados por Laravel y no pueden ser utilizados: `view`, `data`, `status` y `headers`.

<a name="listing-your-routes"></a>
### Listando tus Rutas

El comando Artisan `route:list` puede proporcionar fácilmente una visión general de todas las rutas que están definidas por tu aplicación:


```shell
php artisan route:list

```
Por defecto, los middleware de ruta que están asignados a cada ruta no se mostrarán en la salida de `route:list`; sin embargo, puedes instruir a Laravel a que muestre los middleware de ruta y los nombres de los grupos de middleware agregando la opción `-v` al comando:


```shell
php artisan route:list -v

# Expand middleware groups...
php artisan route:list -vv

```
También puedes instruir a Laravel para que solo muestre rutas que comienzan con una URI dada:


```shell
php artisan route:list --path=api

```
Además, puedes instruir a Laravel para que oculte cualquier ruta que esté definida por paquetes de terceros proporcionando la opción `--except-vendor` al ejecutar el comando `route:list`:


```shell
php artisan route:list --except-vendor

```
Del mismo modo, también puedes instruir a Laravel para que solo muestre las rutas que están definidas por paquetes de terceros proporcionando la opción `--only-vendor` al ejecutar el comando `route:list`:


```shell
php artisan route:list --only-vendor

```

<a name="routing-customization"></a>
### Personalización de Rutas

Por defecto, las rutas de tu aplicación están configuradas y cargadas por el archivo `bootstrap/app.php`:


```php
<?php

use Illuminate\Foundation\Application;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )->create();

```
Sin embargo, a veces es posible que desees definir un archivo completamente nuevo para contener un subconjunto de las rutas de tu aplicación. Para lograr esto, puedes proporcionar una `función anónima` `then` al método `withRouting`. Dentro de esta `función anónima`, puedes registrar cualquier ruta adicional que sea necesaria para tu aplicación:


```php
use Illuminate\Support\Facades\Route;

->withRouting(
    web: __DIR__.'/../routes/web.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
    then: function () {
        Route::middleware('api')
            ->prefix('webhooks')
            ->name('webhooks.')
            ->group(base_path('routes/webhooks.php'));
    },
)

```
O, incluso puedes tomar el control completo sobre el registro de rutas proporcionando una `función anónima` `using` al método `withRouting`. Cuando se pasa este argumento, no se registrarán rutas HTTP por parte del framework y serás responsable de registrar todas las rutas manualmente:


```php
use Illuminate\Support\Facades\Route;

->withRouting(
    commands: __DIR__.'/../routes/console.php',
    using: function () {
        Route::middleware('api')
            ->prefix('api')
            ->group(base_path('routes/api.php'));

        Route::middleware('web')
            ->group(base_path('routes/web.php'));
    },
)

```

<a name="route-parameters"></a>
## Parámetros de Ruta


<a name="required-parameters"></a>
### Parámetros Requeridos

A veces necesitarás capturar segmentos de la URI dentro de tu ruta. Por ejemplo, puede que necesites capturar el ID de un usuario desde la URL. Puedes hacerlo definiendo parámetros de ruta:


```php
Route::get('/user/{id}', function (string $id) {
    return 'User '.$id;
});
```
Puedes definir tantos parámetros de ruta como requiera tu ruta:


```php
Route::get('/posts/{post}/comments/{comment}', function (string $postId, string $commentId) {
    // ...
});
```
Los parámetros de ruta siempre están encerrados entre llaves `{}` y deben consistir en caracteres alfabéticos. También se aceptan guiones bajos (`_`) dentro de los nombres de los parámetros de ruta. Los parámetros de ruta se inyectan en los callbacks / controladores de ruta según su orden: los nombres de los argumentos del callback / controlador de ruta no importan.

<a name="parameters-and-dependency-injection"></a>
#### Parámetros e Inyección de Dependencias

Si tu ruta tiene dependencias que te gustaría que el contenedor de servicios de Laravel inyectara automáticamente en el callback de tu ruta, debes listar tus parámetros de ruta después de tus dependencias:


```php
use Illuminate\Http\Request;

Route::get('/user/{id}', function (Request $request, string $id) {
    return 'User '.$id;
});
```

<a name="parameters-optional-parameters"></a>
### Parámetros Opcionales

Ocasionalmente es posible que necesites especificar un parámetro de ruta que no siempre puede estar presente en la URI. Puedes hacerlo colocando un símbolo de `?` después del nombre del parámetro. Asegúrate de darle a la variable correspondiente de la ruta un valor predeterminado:


```php
Route::get('/user/{name?}', function (?string $name = null) {
    return $name;
});

Route::get('/user/{name?}', function (?string $name = 'John') {
    return $name;
});
```

<a name="parameters-regular-expression-constraints"></a>
### Restricciones de Expresión Regular

Puedes restringir el formato de tus parámetros de ruta utilizando el método `where` en una instancia de ruta. El método `where` acepta el nombre del parámetro y una expresión regular que define cómo se debe restringir el parámetro:


```php
Route::get('/user/{name}', function (string $name) {
    // ...
})->where('name', '[A-Za-z]+');

Route::get('/user/{id}', function (string $id) {
    // ...
})->where('id', '[0-9]+');

Route::get('/user/{id}/{name}', function (string $id, string $name) {
    // ...
})->where(['id' => '[0-9]+', 'name' => '[a-z]+']);
```
Para mayor comodidad, algunos patrones de expresión regular comúnmente utilizados tienen métodos auxiliares que te permiten añadir rápidamente restricciones de patrón a tus rutas:


```php
Route::get('/user/{id}/{name}', function (string $id, string $name) {
    // ...
})->whereNumber('id')->whereAlpha('name');

Route::get('/user/{name}', function (string $name) {
    // ...
})->whereAlphaNumeric('name');

Route::get('/user/{id}', function (string $id) {
    // ...
})->whereUuid('id');

Route::get('/user/{id}', function (string $id) {
    // ...
})->whereUlid('id');

Route::get('/category/{category}', function (string $category) {
    // ...
})->whereIn('category', ['movie', 'song', 'painting']);

Route::get('/category/{category}', function (string $category) {
    // ...
})->whereIn('category', CategoryEnum::cases());
```
Si la solicitud entrante no coincide con las restricciones de patrón de ruta, se devolverá una respuesta HTTP 404.

<a name="parameters-global-constraints"></a>
#### Restricciones Globales

Si deseas que un parámetro de ruta siempre esté limitado por una expresión regular dada, puedes usar el método `pattern`. Debes definir estos patrones en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Route;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Route::pattern('id', '[0-9]+');
}
```
Una vez que se ha definido el patrón, se aplica automáticamente a todas las rutas que utilizan ese nombre de parámetro:


```php
Route::get('/user/{id}', function (string $id) {
    // Only executed if {id} is numeric...
});
```

<a name="parameters-encoded-forward-slashes"></a>
#### Diagonal Bar Forward Codificada

El componente de enrutamiento de Laravel permite que todos los caracteres excepto `/` estén presentes dentro de los valores de los parámetros de ruta. Debes permitir explícitamente que `/` sea parte de tu marcador de posición utilizando una expresión regular de condición `where`:


```php
Route::get('/search/{search}', function (string $search) {
    return $search;
})->where('search', '.*');
```
> [!WARNING]
Las barras diagonales hacia adelante codificadas solo son compatibles dentro del último segmento de la ruta.

<a name="named-routes"></a>
## Rutas Nombradas

Las rutas nombradas permiten la generación conveniente de URL o redirecciones para rutas específicas. Puedes especificar un nombre para una ruta encadenando el método `name` a la definición de la ruta:


```php
Route::get('/user/profile', function () {
    // ...
})->name('profile');
```
También puedes especificar nombres de rutas para las acciones del controlador:


```php
Route::get(
    '/user/profile',
    [UserProfileController::class, 'show']
)->name('profile');
```
> [!WARNING]
Los nombres de las rutas deben ser siempre únicos.

<a name="generating-urls-to-named-routes"></a>
#### Generando URLs a Rutas Nombradas

Una vez que hayas asignado un nombre a una ruta dada, puedes usar el nombre de la ruta al generar URLs o redirecciones a través de las funciones helpers `route` y `redirect` de Laravel:


```php
// Generating URLs...
$url = route('profile');

// Generating Redirects...
return redirect()->route('profile');

return to_route('profile');
```
Si la ruta nombrada define parámetros, puedes pasar los parámetros como segundo argumento a la función `route`. Los parámetros dados se insertarán automáticamente en la URL generada en sus posiciones correctas:


```php
Route::get('/user/{id}/profile', function (string $id) {
    // ...
})->name('profile');

$url = route('profile', ['id' => 1]);
```
Si pasas parámetros adicionales en el array, esos pares de clave / valor se añadirán automáticamente a la cadena de consulta de la URL generada:


```php
Route::get('/user/{id}/profile', function (string $id) {
    // ...
})->name('profile');

$url = route('profile', ['id' => 1, 'photos' => 'yes']);

// /user/1/profile?photos=yes
```
> [!NOTA]
A veces, es posible que desees especificar valores predeterminados a nivel de solicitud para los parámetros de URL, como la configuración regional actual. Para lograr esto, puedes usar el método [`URL::defaults`]() (/docs/%7B%7Bversion%7D%7D/urls#default-values).

<a name="inspecting-the-current-route"></a>
#### Inspeccionando la Ruta Actual

Si deseas determinar si la solicitud actual fue dirigida a una ruta nombrada dada, puedes usar el método `named` en una instancia de Route. Por ejemplo, puedes verificar el nombre de la ruta actual desde un middleware de ruta:


```php
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Handle an incoming request.
 *
 * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
 */
public function handle(Request $request, Closure $next): Response
{
    if ($request->route()->named('profile')) {
        // ...
    }

    return $next($request);
}
```

<a name="route-groups"></a>
## Grupos de Rutas

Los grupos de rutas te permiten compartir atributos de ruta, como middleware, en un gran número de rutas sin necesidad de definir esos atributos en cada ruta individual.
Los grupos anidados intentan "fusionar" atributos de manera inteligente con su grupo padre. Middleware y condiciones `where` se fusionan, mientras que nombres y prefijos se añaden. Los delimitadores de espacio de nombres y las barras en los prefijos URI se añaden automáticamente donde sea apropiado.

<a name="route-group-middleware"></a>
### Middleware

Para asignar [middleware](/docs/%7B%7Bversion%7D%7D/middleware) a todas las rutas dentro de un grupo, puedes usar el método `middleware` antes de definir el grupo. Los middleware se ejecutan en el orden en que están listados en el array:


```php
Route::middleware(['first', 'second'])->group(function () {
    Route::get('/', function () {
        // Uses first & second middleware...
    });

    Route::get('/user/profile', function () {
        // Uses first & second middleware...
    });
});
```

<a name="route-group-controllers"></a>
### Controladores

Si un grupo de rutas utiliza el mismo [controlador](/docs/%7B%7Bversion%7D%7D/controllers), puedes usar el método `controller` para definir el controlador común para todas las rutas dentro del grupo. Luego, al definir las rutas, solo necesitas proporcionar el método del controlador que invocan:


```php
use App\Http\Controllers\OrderController;

Route::controller(OrderController::class)->group(function () {
    Route::get('/orders/{id}', 'show');
    Route::post('/orders', 'store');
});
```

<a name="route-group-subdomain-routing"></a>
### Enrutamiento de Subdominios

Los grupos de rutas también se pueden usar para manejar el enrutamiento de subdominios. Se pueden asignar parámetros de ruta a los subdominios de la misma manera que a las URI de ruta, lo que te permite capturar una porción del subdominio para usarla en tu ruta o controlador. El subdominio se puede especificar llamando al método `domain` antes de definir el grupo:


```php
Route::domain('{account}.example.com')->group(function () {
    Route::get('/user/{id}', function (string $account, string $id) {
        // ...
    });
});
```
> [!WARNING]
Para asegurarte de que las rutas de tu subdominio sean accesibles, debes registrar las rutas del subdominio antes de registrar las rutas del dominio raíz. Esto evitará que las rutas del dominio raíz sobrescriban las rutas del subdominio que tienen la misma ruta URI.

<a name="route-group-prefixes"></a>
### Prefijos de Ruta

El método `prefix` se puede utilizar para prefijar cada ruta en el grupo con una URI dada. Por ejemplo, es posible que desees prefijar todas las URIs de ruta dentro del grupo con `admin`:


```php
Route::prefix('admin')->group(function () {
    Route::get('/users', function () {
        // Matches The "/admin/users" URL
    });
});
```

<a name="route-group-name-prefixes"></a>
### Prefijos de Nombres de Ruta

El método `name` se puede utilizar para prefijar cada nombre de ruta en el grupo con una cadena dada. Por ejemplo, es posible que desees prefijar los nombres de todas las rutas en el grupo con `admin`. La cadena dada se añade al nombre de la ruta exactamente como se especifica, así que nos aseguraremos de proporcionar el carácter `.` al final del prefijo:


```php
Route::name('admin.')->group(function () {
    Route::get('/users', function () {
        // Route assigned name "admin.users"...
    })->name('users');
});
```

<a name="route-model-binding"></a>
## Enlace de Modelo de Ruta

Al inyectar un ID de modelo a una ruta o acción del controlador, a menudo consultarás la base de datos para recuperar el modelo que corresponde a ese ID. El enlace de modelo de ruta de Laravel proporciona una manera conveniente de inyectar automáticamente las instancias del modelo directamente en tus rutas. Por ejemplo, en lugar de inyectar el ID de un usuario, puedes inyectar la instancia completa del modelo `User` que coincide con el ID dado.

<a name="implicit-binding"></a>
### Vínculo Implícito

Laravel resuelve automáticamente los modelos Eloquent definidos en las rutas o acciones del controlador cuyos nombres de variables tipo indicados coinciden con un nombre de segmento de la ruta. Por ejemplo:


```php
use App\Models\User;

Route::get('/users/{user}', function (User $user) {
    return $user->email;
});
```
Dado que la variable `$user` tiene un tipo de sugerencia como el modelo Eloquent `App\Models\User` y el nombre de la variable coincide con el segmento URI `{user}`, Laravel inyectará automáticamente la instancia del modelo que tiene un ID que coincide con el valor correspondiente de la URI de la solicitud. Si no se encuentra una instancia de modelo coincidente en la base de datos, se generará automáticamente una respuesta HTTP 404.
Por supuesto, el enlace implícito también es posible al utilizar métodos de controlador. Nuevamente, nota que el segmento de URI `{user}` coincide con la variable `$user` en el controlador, que contiene un tipo `App\Models\User`:


```php
use App\Http\Controllers\UserController;
use App\Models\User;

// Route definition...
Route::get('/users/{user}', [UserController::class, 'show']);

// Controller method definition...
public function show(User $user)
{
    return view('user.profile', ['user' => $user]);
}
```

<a name="implicit-soft-deleted-models"></a>
#### Modelos Suaves Eliminados

Típicamente, el enlace de modelo implícito no recuperará modelos que han sido [eliminados suavemente](/docs/%7B%7Bversion%7D%7D/eloquent#soft-deleting). Sin embargo, puedes instruir al enlace implícito para que recupere estos modelos encadenando el método `withTrashed` a la definición de tu ruta:


```php
use App\Models\User;

Route::get('/users/{user}', function (User $user) {
    return $user->email;
})->withTrashed();
```

<a name="customizing-the-default-key-name"></a>
#### Personalizando la Clave

A veces es posible que desees resolver modelos Eloquent utilizando una columna diferente a `id`. Para hacerlo, puedes especificar la columna en la definición del parámetro de ruta:


```php
use App\Models\Post;

Route::get('/posts/{post:slug}', function (Post $post) {
    return $post;
});
```
Si deseas que el enlace de modelo siempre utilice una columna de base de datos diferente a `id` al recuperar una clase de modelo dada, puedes sobrescribir el método `getRouteKeyName` en el modelo Eloquent:


```php
/**
 * Get the route key for the model.
 */
public function getRouteKeyName(): string
{
    return 'slug';
}
```

<a name="implicit-model-binding-scoping"></a>
#### Claves Personalizadas y Alcance

Al enlazar implícitamente múltiples modelos de Eloquent en una sola definición de ruta, es posible que desees limitar el segundo modelo de Eloquent de modo que debe ser un hijo del modelo de Eloquent anterior. Por ejemplo, considera esta definición de ruta que recupera una publicación de blog por slug para un usuario específico:


```php
use App\Models\Post;
use App\Models\User;

Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
    return $post;
});
```
Al usar un enlace implícito con clave personalizada como un parámetro de ruta anidado, Laravel automáticamente limitará la consulta para recuperar el modelo anidado por su padre utilizando convenciones para adivinar el nombre de la relación en el padre. En este caso, se asumirá que el modelo `User` tiene una relación llamada `posts` (la forma plural del nombre del parámetro de ruta) que se puede usar para recuperar el modelo `Post`.
Si lo deseas, puedes instruir a Laravel a que delimite los "child" bindings incluso cuando no se proporciona una clave personalizada. Para hacerlo, puedes invocar el método `scopeBindings` al definir tu ruta:


```php
use App\Models\Post;
use App\Models\User;

Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
    return $post;
})->scopeBindings();
```
O bien, puedes instruir a todo un grupo de definiciones de rutas para que utilicen enlaces con alcance:


```php
Route::scopeBindings()->group(function () {
    Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
        return $post;
    });
});
```
De manera similar, puedes instruir explícitamente a Laravel para que no limite los enlaces invocando el método `withoutScopedBindings`:


```php
Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
    return $post;
})->withoutScopedBindings();
```

<a name="customizing-missing-model-behavior"></a>
#### Personalizando el Comportamiento de Modelos Faltantes

Típicamente, se generará una respuesta HTTP 404 si no se encuentra un modelo vinculado implícitamente. Sin embargo, puedes personalizar este comportamiento llamando al método `missing` al definir tu ruta. El método `missing` acepta una función anónima que se invocará si no se puede encontrar un modelo vinculado implícitamente:


```php
use App\Http\Controllers\LocationsController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

Route::get('/locations/{location:slug}', [LocationsController::class, 'show'])
        ->name('locations.view')
        ->missing(function (Request $request) {
            return Redirect::route('locations.index');
        });
```

<a name="implicit-enum-binding"></a>
### Vínculo de Enum Implícito

PHP 8.1 introdujo soporte para [Enums](https://www.php.net/manual/en/language.enumerations.backed.php). Para complementar esta función, Laravel te permite indicar un [Enum respaldado](https://www.php.net/manual/en/language.enumerations.backed.php) en tu definición de ruta y Laravel solo invocará la ruta si ese segmento de ruta corresponde a un valor Enum válido. De lo contrario, se devolverá automáticamente una respuesta HTTP 404. Por ejemplo, dado el siguiente Enum:


```php
<?php

namespace App\Enums;

enum Category: string
{
    case Fruits = 'fruits';
    case People = 'people';
}

```
Puedes definir una ruta que solo se invocará si el segmento de ruta `{category}` es `fruits` o `people`. De lo contrario, Laravel devolverá una respuesta HTTP 404:


```php
use App\Enums\Category;
use Illuminate\Support\Facades\Route;

Route::get('/categories/{category}', function (Category $category) {
    return $category->value;
});

```

<a name="explicit-binding"></a>
### Vinculación Explícita

No es necesario utilizar la resolución de modelos implícita basada en convenciones de Laravel para usar el enlace de modelos. También puedes definir explícitamente cómo los parámetros de ruta corresponden a los modelos. Para registrar un enlace explícito, utiliza el método `model` del enrutador para especificar la clase para un parámetro dado. Debes definir tus enlaces de modelo explícitos al principio del método `boot` de tu clase `AppServiceProvider`:


```php
use App\Models\User;
use Illuminate\Support\Facades\Route;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Route::model('user', User::class);
}
```
A continuación, define una ruta que contenga un parámetro `{user}`:


```php
use App\Models\User;

Route::get('/users/{user}', function (User $user) {
    // ...
});
```
Dado que hemos vinculado todos los parámetros `{user}` al modelo `App\Models\User`, se inyectará una instancia de esa clase en la ruta. Así que, por ejemplo, una solicitud a `users/1` inyectará la instancia de `User` de la base de datos que tiene un ID de `1`.
Si no se encuentra una instancia de modelo coincidente en la base de datos, se generará automáticamente una respuesta HTTP 404.

<a name="customizing-the-resolution-logic"></a>
#### Personalizando la Lógica de Resolución

Si deseas definir tu propia lógica de resolución de enlace de modelo, puedes usar el método `Route::bind`. La función anónima que pases al método `bind` recibirá el valor del segmento de la URI y debe devolver la instancia de la clase que debe ser inyectada en la ruta. Nuevamente, esta personalización debe realizarse en el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use App\Models\User;
use Illuminate\Support\Facades\Route;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Route::bind('user', function (string $value) {
        return User::where('name', $value)->firstOrFail();
    });
}
```
Alternativamente, puedes sobrescribir el método `resolveRouteBinding` en tu modelo Eloquent. Este método recibirá el valor del segmento de URI y debería devolver la instancia de la clase que debe ser inyectada en la ruta:


```php
/**
 * Retrieve the model for a bound value.
 *
 * @param  mixed  $value
 * @param  string|null  $field
 * @return \Illuminate\Database\Eloquent\Model|null
 */
public function resolveRouteBinding($value, $field = null)
{
    return $this->where('name', $value)->firstOrFail();
}
```
Si una ruta está utilizando [el alcance de enlace implícito](#implicit-model-binding-scoping), se utilizará el método `resolveChildRouteBinding` para resolver el enlace hijo del modelo padre:


```php
/**
 * Retrieve the child model for a bound value.
 *
 * @param  string  $childType
 * @param  mixed  $value
 * @param  string|null  $field
 * @return \Illuminate\Database\Eloquent\Model|null
 */
public function resolveChildRouteBinding($childType, $value, $field)
{
    return parent::resolveChildRouteBinding($childType, $value, $field);
}
```

<a name="fallback-routes"></a>
## Rutas de Respaldo

Usando el método `Route::fallback`, puedes definir una ruta que se ejecutará cuando ninguna otra ruta coincida con la solicitud entrante. Típicamente, las solicitudes no manejadas renderizarán automáticamente una página "404" a través del manejador de excepciones de tu aplicación. Sin embargo, dado que típicamente definirías la ruta `fallback` dentro de tu archivo `routes/web.php`, todo el middleware en el grupo de middleware `web` se aplicará a la ruta. Puedes añadir middleware adicionales a esta ruta según sea necesario:


```php
Route::fallback(function () {
    // ...
});
```
> [!WARNING]
La ruta de fallback siempre debe ser la última ruta registrada por tu aplicación.

<a name="rate-limiting"></a>
## Limitación de Tasa


<a name="defining-rate-limiters"></a>
### Definiendo Limitadores de Tasa

Laravel incluye potentes y personalizables servicios de limitación de tasa que puedes utilizar para restringir la cantidad de tráfico para una ruta dada o un grupo de rutas. Para comenzar, debes definir configuraciones de limitador de tasa que satisfagan las necesidades de tu aplicación.
Los limitadores de tasa pueden definirse dentro del método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:


```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Bootstrap any application services.
 */
protected function boot(): void
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
    });
}

```
Los limitadores de tasa se definen utilizando el método `for` de la fachada `RateLimiter`. El método `for` acepta un nombre de limitador de tasa y una función anónima que devuelve la configuración de límite que debe aplicarse a las rutas que están asignadas al limitador de tasa. La configuración de límite son instancias de la clase `Illuminate\Cache\RateLimiting\Limit`. Esta clase contiene métodos de "construcción" útiles para que puedas definir rápidamente tu límite. El nombre del limitador de tasa puede ser cualquier cadena que desees:


```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Bootstrap any application services.
 */
protected function boot(): void
{
    RateLimiter::for('global', function (Request $request) {
        return Limit::perMinute(1000);
    });
}
```
Si la solicitud entrante excede el límite de tasa especificado, Laravel devolverá automáticamente una respuesta con un código de estado HTTP 429. Si deseas definir tu propia respuesta que debería ser devuelta por un límite de tasa, puedes usar el método `response`:


```php
RateLimiter::for('global', function (Request $request) {
    return Limit::perMinute(1000)->response(function (Request $request, array $headers) {
        return response('Custom response...', 429, $headers);
    });
});
```
Dado que los callbacks del limitador de tasa reciben la instancia de la solicitud HTTP entrante, puedes construir el límite de tasa apropiado de manera dinámica según la solicitud entrante o el usuario autenticado:


```php
RateLimiter::for('uploads', function (Request $request) {
    return $request->user()->vipCustomer()
                ? Limit::none()
                : Limit::perMinute(100);
});
```

<a name="segmenting-rate-limits"></a>
#### Segmentando Límites de Tasa

A veces es posible que desees segmentar los límites de tasa por algún valor arbitrario. Por ejemplo, es posible que desees permitir que los usuarios accedan a una ruta dada 100 veces por minuto por dirección IP. Para lograr esto, puedes usar el método `by` al construir tu límite de tasa:


```php
RateLimiter::for('uploads', function (Request $request) {
    return $request->user()->vipCustomer()
                ? Limit::none()
                : Limit::perMinute(100)->by($request->ip());
});
```
Para ilustrar esta función utilizando otro ejemplo, podemos limitar el acceso a la ruta a 100 veces por minuto por ID de usuario autenticado o 10 veces por minuto por dirección IP para invitados:


```php
RateLimiter::for('uploads', function (Request $request) {
    return $request->user()
                ? Limit::perMinute(100)->by($request->user()->id)
                : Limit::perMinute(10)->by($request->ip());
});
```

<a name="multiple-rate-limits"></a>
#### Múltiples Límites de Tasa

Si es necesario, puedes devolver un array de límites de tasa para una configuración de limitador de tasa dada. Cada límite de tasa se evaluará para la ruta según el orden en que están colocados dentro del array:


```php
RateLimiter::for('login', function (Request $request) {
    return [
        Limit::perMinute(500),
        Limit::perMinute(3)->by($request->input('email')),
    ];
});
```

<a name="attaching-rate-limiters-to-routes"></a>
### Adjuntando Limitadores de Tasa a Rutas

Los limitadores de tasa pueden ser adjuntados a rutas o grupos de rutas utilizando el middleware `throttle` [middleware](/docs/%7B%7Bversion%7D%7D/middleware). El middleware de limitación acepta el nombre del limitador de tasa que deseas asignar a la ruta:


```php
Route::middleware(['throttle:uploads'])->group(function () {
    Route::post('/audio', function () {
        // ...
    });

    Route::post('/video', function () {
        // ...
    });
});
```

<a name="throttling-with-redis"></a>
#### Limitación con Redis

Por defecto, el middleware `throttle` está mapeado a la clase `Illuminate\Routing\Middleware\ThrottleRequests`. Sin embargo, si estás utilizando Redis como el driver de caché de tu aplicación, es posible que desees indicar a Laravel que use Redis para gestionar el límite de tasa. Para hacerlo, debes usar el método `throttleWithRedis` en el archivo `bootstrap/app.php` de tu aplicación. Este método mapea el middleware `throttle` a la clase de middleware `Illuminate\Routing\Middleware\ThrottleRequestsWithRedis`:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->throttleWithRedis();
    // ...
})
```

<a name="form-method-spoofing"></a>
## Suplantación del Método de Formulario

Los formularios HTML no soportan acciones `PUT`, `PATCH` o `DELETE`. Así que, al definir rutas `PUT`, `PATCH` o `DELETE` que son llamadas desde un formulario HTML, necesitarás añadir un campo oculto `_method` al formulario. El valor enviado con el campo `_method` se utilizará como el método de solicitud HTTP:


```php
<form action="/example" method="POST">
    <input type="hidden" name="_method" value="PUT">
    <input type="hidden" name="_token" value="{{ csrf_token() }}">
</form>
```
Para mayor comodidad, puedes usar la directiva `@method` [Blade](/docs/%7B%7Bversion%7D%7D/blade) para generar el campo de entrada `_method`:


```php
<form action="/example" method="POST">
    @method('PUT')
    @csrf
</form>
```

<a name="accessing-the-current-route"></a>
## Accediendo a la Ruta Actual

Puedes usar los métodos `current`, `currentRouteName` y `currentRouteAction` en la facada `Route` para acceder a información sobre la ruta que maneja la solicitud entrante:


```php
use Illuminate\Support\Facades\Route;

$route = Route::current(); // Illuminate\Routing\Route
$name = Route::currentRouteName(); // string
$action = Route::currentRouteAction(); // string
```
Puedes consultar la documentación de la API tanto de la [clase subyacente de la fachada Route](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Routing/Router.html) como de la [instancia de Route](https://laravel.com/api/%7B%7Bversion%7D%7D/Illuminate/Routing/Route.html) para revisar todos los métodos que están disponibles en las clases de router y ruta.

<a name="cors"></a>
## Intercambio de Recursos de Origen Cruzado (CORS)

Laravel puede responder automáticamente a las solicitudes HTTP `OPTIONS` de CORS con los valores que configures. Las solicitudes `OPTIONS` serán gestionadas automáticamente por el middleware `HandleCors` [middleware](/docs/%7B%7Bversion%7D%7D/middleware) que se incluye automáticamente en la pila global de middleware de tu aplicación.
A veces, es posible que necesites personalizar los valores de configuración de CORS para tu aplicación. Puedes hacerlo publicando el archivo de configuración `cors` utilizando el comando Artisan `config:publish`:


```shell
php artisan config:publish cors

```
Este comando colocará un archivo de configuración `cors.php` dentro del directorio `config` de tu aplicación.
> [!NOTA]
Para obtener más información sobre CORS y los encabezados CORS, consulta la [documentación web de MDN sobre CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#The_HTTP_response_headers).

<a name="route-caching"></a>
## Caché de Rutas

Al desplegar tu aplicación en producción, deberías aprovechar la caché de rutas de Laravel. Utilizar la caché de rutas disminuirá drásticamente el tiempo que tarda en registrar todas las rutas de tu aplicación. Para generar una caché de rutas, ejecuta el comando Artisan `route:cache`:


```shell
php artisan route:cache

```
Después de ejecutar este comando, tu archivo de rutas en caché se cargará en cada solicitud. Recuerda que, si agregas nuevas rutas, necesitarás generar una nueva caché de rutas. Debido a esto, solo debes ejecutar el comando `route:cache` durante el despliegue de tu proyecto.
Puedes usar el comando `route:clear` para limpiar la caché de rutas:


```shell
php artisan route:clear

```