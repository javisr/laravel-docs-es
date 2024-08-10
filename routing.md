# Enrutamiento

- [Enrutamiento](#enrutamiento)
  - [Enrutamiento Básico](#enrutamiento-básico)
    - [Los Archivos de Ruta Predeterminados](#los-archivos-de-ruta-predeterminados)
      - [Rutas API](#rutas-api)
      - [Métodos de Enrutador Disponibles](#métodos-de-enrutador-disponibles)
      - [Inyección de Dependencias](#inyección-de-dependencias)
      - [Protección CSRF](#protección-csrf)
    - [Rutas de Redirección](#rutas-de-redirección)
    - [Rutas de Vista](#rutas-de-vista)
    - [Listando Tus Rutas](#listando-tus-rutas)
    - [Personalización del Enrutamiento](#personalización-del-enrutamiento)
  - [Parámetros de Ruta](#parámetros-de-ruta)
    - [Parámetros Requeridos](#parámetros-requeridos)
      - [Parámetros y Inyección de Dependencias](#parámetros-y-inyección-de-dependencias)
    - [Parámetros Opcionales](#parámetros-opcionales)
    - [Restricciones de Expresión Regular](#restricciones-de-expresión-regular)
      - [Restricciones Globales](#restricciones-globales)
      - [Barras Diagonales Codificadas](#barras-diagonales-codificadas)
  - [Rutas Nombradas](#rutas-nombradas)
      - [Generando URLs a Rutas Nombradas](#generando-urls-a-rutas-nombradas)
      - [Inspeccionando la Ruta Actual](#inspeccionando-la-ruta-actual)
  - [Grupos de Rutas](#grupos-de-rutas)
    - [Middleware](#middleware)
    - [Controladores](#controladores)
    - [Enrutamiento de Subdominios](#enrutamiento-de-subdominios)
    - [Prefijos de Ruta](#prefijos-de-ruta)
    - [Prefijos de Nombres de Ruta](#prefijos-de-nombres-de-ruta)
  - [Vinculación de Modelos de Ruta](#vinculación-de-modelos-de-ruta)
    - [Vinculación Implícita](#vinculación-implícita)
      - [Modelos Suavemente Eliminados](#modelos-suavemente-eliminados)
      - [Personalizando la Clave](#personalizando-la-clave)
      - [Claves Personalizadas y Alcance](#claves-personalizadas-y-alcance)
      - [Personalizando el Comportamiento de Modelo Faltante](#personalizando-el-comportamiento-de-modelo-faltante)
    - [Vinculación Implícita de Enum](#vinculación-implícita-de-enum)
    - [Vinculación Explícita](#vinculación-explícita)
      - [Personalizando la Lógica de Resolución](#personalizando-la-lógica-de-resolución)
  - [Rutas de Respaldo](#rutas-de-respaldo)
  - [Limitación de Tasa](#limitación-de-tasa)
    - [Definición de Limitadores de Tasa](#definición-de-limitadores-de-tasa)
      - [Segmentando Límites de Tasa](#segmentando-límites-de-tasa)
      - [Múltiples Límites de Tasa](#múltiples-límites-de-tasa)
    - [Adjuntando Limitadores de Tasa a Rutas](#adjuntando-limitadores-de-tasa-a-rutas)
      - [Limitación con Redis](#limitación-con-redis)
  - [Suplantación de Método de Formulario](#suplantación-de-método-de-formulario)
  - [Accediendo a la Ruta Actual](#accediendo-a-la-ruta-actual)
  - [Compartición de Recursos de Origen Cruzado (CORS)](#compartición-de-recursos-de-origen-cruzado-cors)
  - [Caché de Rutas](#caché-de-rutas)

<a name="basic-routing"></a>
## Enrutamiento Básico

Las rutas más básicas de Laravel aceptan una URI y una función anónima, proporcionando un método muy simple y expresivo para definir rutas y comportamientos sin archivos de configuración de enrutamiento complicados:

    use Illuminate\Support\Facades\Route;

    Route::get('/greeting', function () {
        return 'Hello World';
    });

<a name="the-default-route-files"></a>
### Los Archivos de Ruta Predeterminados

Todas las rutas de Laravel se definen en tus archivos de ruta, que se encuentran en el directorio `routes`. Estos archivos son cargados automáticamente por Laravel utilizando la configuración especificada en el archivo `bootstrap/app.php` de tu aplicación. El archivo `routes/web.php` define rutas que son para tu interfaz web. Estas rutas están asignadas al grupo de [middleware](/docs/{{version}}/middleware#laravels-default-middleware-groups) `web`, que proporciona características como el estado de sesión y la protección CSRF.

Para la mayoría de las aplicaciones, comenzarás definiendo rutas en tu archivo `routes/web.php`. Las rutas definidas en `routes/web.php` pueden ser accedidas ingresando la URL de la ruta definida en tu navegador. Por ejemplo, puedes acceder a la siguiente ruta navegando a `http://example.com/user` en tu navegador:

    use App\Http\Controllers\UserController;

    Route::get('/user', [UserController::class, 'index']);

<a name="api-routes"></a>
#### Rutas API

Si tu aplicación también ofrecerá una API sin estado, puedes habilitar el enrutamiento API utilizando el comando Artisan `install:api`:

```shell
php artisan install:api
```

El comando `install:api` instala [Laravel Sanctum](/docs/{{version}}/sanctum), que proporciona un guardia de autenticación de token API robusto, pero simple, que se puede utilizar para autenticar consumidores de API de terceros, SPAs o aplicaciones móviles. Además, el comando `install:api` crea el archivo `routes/api.php`:

    Route::get('/user', function (Request $request) {
        return $request->user();
    })->middleware('auth:sanctum');

Las rutas en `routes/api.php` son sin estado y están asignadas al grupo de [middleware](/docs/{{version}}/middleware#laravels-default-middleware-groups) `api`. Además, el prefijo de URI `/api` se aplica automáticamente a estas rutas, por lo que no necesitas aplicarlo manualmente a cada ruta en el archivo. Puedes cambiar el prefijo modificando el archivo `bootstrap/app.php` de tu aplicación:

    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api/admin',
        // ...
    )

<a name="available-router-methods"></a>
#### Métodos de Enrutador Disponibles

El enrutador te permite registrar rutas que responden a cualquier verbo HTTP:

    Route::get($uri, $callback);
    Route::post($uri, $callback);
    Route::put($uri, $callback);
    Route::patch($uri, $callback);
    Route::delete($uri, $callback);
    Route::options($uri, $callback);

A veces, puede que necesites registrar una ruta que responda a múltiples verbos HTTP. Puedes hacerlo utilizando el método `match`. O, incluso puedes registrar una ruta que responda a todos los verbos HTTP utilizando el método `any`:

    Route::match(['get', 'post'], '/', function () {
        // ...
    });

    Route::any('/', function () {
        // ...
    });

> [!NOTE]  
> Al definir múltiples rutas que comparten la misma URI, las rutas que utilizan los métodos `get`, `post`, `put`, `patch`, `delete` y `options` deben definirse antes que las rutas que utilizan los métodos `any`, `match` y `redirect`. Esto asegura que la solicitud entrante se empareje con la ruta correcta.

<a name="dependency-injection"></a>
#### Inyección de Dependencias

Puedes indicar cualquier dependencia requerida por tu ruta en la firma de la función de tu ruta. Las dependencias declaradas serán resueltas e inyectadas automáticamente en la función por el [contenedor de servicios](/docs/{{version}}/container) de Laravel. Por ejemplo, puedes indicar la clase `Illuminate\Http\Request` para que la solicitud HTTP actual se inyecte automáticamente en la función de tu ruta:

    use Illuminate\Http\Request;

    Route::get('/users', function (Request $request) {
        // ...
    });

<a name="csrf-protection"></a>
#### Protección CSRF

Recuerda, cualquier formulario HTML que apunte a rutas `POST`, `PUT`, `PATCH` o `DELETE` que estén definidas en el archivo de rutas `web` debe incluir un campo de token CSRF. De lo contrario, la solicitud será rechazada. Puedes leer más sobre la protección CSRF en la [documentación de CSRF](/docs/{{version}}/csrf):

    <form method="POST" action="/profile">
        @csrf
        ...
    </form>

<a name="redirect-routes"></a>
### Rutas de Redirección

Si estás definiendo una ruta que redirige a otra URI, puedes usar el método `Route::redirect`. Este método proporciona un atajo conveniente para que no tengas que definir una ruta completa o un controlador para realizar una redirección simple:

    Route::redirect('/here', '/there');

Por defecto, `Route::redirect` devuelve un código de estado `302`. Puedes personalizar el código de estado utilizando el tercer parámetro opcional:

    Route::redirect('/here', '/there', 301);

O, puedes usar el método `Route::permanentRedirect` para devolver un código de estado `301`:

    Route::permanentRedirect('/here', '/there');

> [!WARNING]  
> Al usar parámetros de ruta en rutas de redirección, los siguientes parámetros están reservados por Laravel y no se pueden usar: `destination` y `status`.

<a name="view-routes"></a>
### Rutas de Vista

Si tu ruta solo necesita devolver una [vista](/docs/{{version}}/views), puedes usar el método `Route::view`. Al igual que el método `redirect`, este método proporciona un atajo simple para que no tengas que definir una ruta completa o un controlador. El método `view` acepta una URI como su primer argumento y un nombre de vista como su segundo argumento. Además, puedes proporcionar un array de datos para pasar a la vista como un tercer argumento opcional:

    Route::view('/welcome', 'welcome');

    Route::view('/welcome', 'welcome', ['name' => 'Taylor']);

> [!WARNING]  
> Al usar parámetros de ruta en rutas de vista, los siguientes parámetros están reservados por Laravel y no se pueden usar: `view`, `data`, `status` y `headers`.

<a name="listing-your-routes"></a>
### Listando Tus Rutas

El comando Artisan `route:list` puede proporcionar fácilmente una visión general de todas las rutas que están definidas por tu aplicación:

```shell
php artisan route:list
```

Por defecto, los middleware de ruta que están asignados a cada ruta no se mostrarán en la salida de `route:list`; sin embargo, puedes instruir a Laravel para que muestre los middleware de ruta y los nombres de los grupos de middleware agregando la opción `-v` al comando:

```shell
php artisan route:list -v

# Expand middleware groups...
php artisan route:list -vv
```

También puedes instruir a Laravel para que solo muestre rutas que comiencen con una URI dada:

```shell
php artisan route:list --path=api
```

Además, puedes instruir a Laravel para que oculte cualquier ruta que esté definida por paquetes de terceros proporcionando la opción `--except-vendor` al ejecutar el comando `route:list`:

```shell
php artisan route:list --except-vendor
```

Del mismo modo, también puedes instruir a Laravel para que solo muestre rutas que están definidas por paquetes de terceros proporcionando la opción `--only-vendor` al ejecutar el comando `route:list`:

```shell
php artisan route:list --only-vendor
```

<a name="routing-customization"></a>
### Personalización del Enrutamiento

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

Sin embargo, a veces puede que desees definir un archivo completamente nuevo para contener un subconjunto de las rutas de tu aplicación. Para lograr esto, puedes proporcionar una función anónima `then` al método `withRouting`. Dentro de esta función, puedes registrar cualquier ruta adicional que sea necesaria para tu aplicación:

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

O, incluso puedes tomar el control total sobre el registro de rutas proporcionando una función anónima `using` al método `withRouting`. Cuando se pasa este argumento, no se registrarán rutas HTTP por el marco y serás responsable de registrar manualmente todas las rutas:

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

    Route::get('/user/{id}', function (string $id) {
        return 'User '.$id;
    });

Puedes definir tantos parámetros de ruta como requiera tu ruta:

    Route::get('/posts/{post}/comments/{comment}', function (string $postId, string $commentId) {
        // ...
    });

Los parámetros de ruta siempre están encerrados dentro de llaves `{}` y deben consistir en caracteres alfabéticos. Los guiones bajos (`_`) también son aceptables dentro de los nombres de los parámetros de ruta. Los parámetros de ruta se inyectan en las funciones de ruta / controladores según su orden; los nombres de los argumentos de la función de ruta / controlador no importan.

<a name="parameters-and-dependency-injection"></a>
#### Parámetros y Inyección de Dependencias

Si tu ruta tiene dependencias que te gustaría que el contenedor de servicios de Laravel inyectara automáticamente en la función de tu ruta, debes listar tus parámetros de ruta después de tus dependencias:

    use Illuminate\Http\Request;

    Route::get('/user/{id}', function (Request $request, string $id) {
        return 'User '.$id;
    });

<a name="parameters-optional-parameters"></a>
### Parámetros Opcionales

Ocasionalmente, puede que necesites especificar un parámetro de ruta que no siempre esté presente en la URI. Puedes hacerlo colocando un signo de `?` después del nombre del parámetro. Asegúrate de darle a la variable correspondiente de la ruta un valor predeterminado:

    Route::get('/user/{name?}', function (?string $name = null) {
        return $name;
    });

    Route::get('/user/{name?}', function (?string $name = 'John') {
        return $name;
    });

<a name="parameters-regular-expression-constraints"></a>
### Restricciones de Expresión Regular

Puedes restringir el formato de tus parámetros de ruta utilizando el método `where` en una instancia de ruta. El método `where` acepta el nombre del parámetro y una expresión regular que define cómo debe ser restringido el parámetro:

    Route::get('/user/{name}', function (string $name) {
        // ...
    })->where('name', '[A-Za-z]+');

    Route::get('/user/{id}', function (string $id) {
        // ...
    })->where('id', '[0-9]+');

    Route::get('/user/{id}/{name}', function (string $id, string $name) {
        // ...
    })->where(['id' => '[0-9]+', 'name' => '[a-z]+']);

Para conveniencia, algunos patrones de expresión regular comúnmente utilizados tienen métodos auxiliares que te permiten agregar rápidamente restricciones de patrón a tus rutas:

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

Si la solicitud entrante no coincide con las restricciones de patrón de la ruta, se devolverá una respuesta HTTP 404.

<a name="parameters-global-constraints"></a>
#### Restricciones Globales

Si deseas que un parámetro de ruta siempre esté restringido por una expresión regular dada, puedes usar el método `pattern`. Debes definir estos patrones en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    use Illuminate\Support\Facades\Route;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Route::pattern('id', '[0-9]+');
    }

Una vez que se ha definido el patrón, se aplica automáticamente a todas las rutas que utilizan ese nombre de parámetro:

    Route::get('/user/{id}', function (string $id) {
        // Solo se ejecuta si {id} es numérico...
    });

<a name="parameters-encoded-forward-slashes"></a>
#### Barras Diagonales Codificadas

El componente de enrutamiento de Laravel permite que todos los caracteres excepto `/` estén presentes dentro de los valores de los parámetros de ruta. Debes permitir explícitamente que `/` sea parte de tu marcador de posición utilizando una condición `where` con expresión regular:

    Route::get('/search/{search}', function (string $search) {
        return $search;
    })->where('search', '.*');

> [!WARNING]  
> Las barras diagonales codificadas solo son compatibles dentro del último segmento de la ruta.

<a name="named-routes"></a>
## Rutas Nombradas

Las rutas nombradas permiten la generación conveniente de URLs o redirecciones para rutas específicas. Puedes especificar un nombre para una ruta encadenando el método `name` a la definición de la ruta:

    Route::get('/user/profile', function () {
        // ...
    })->name('profile');

También puedes especificar nombres de ruta para acciones de controladores:

    Route::get(
        '/user/profile',
        [UserProfileController::class, 'show']
    )->name('profile');

> [!WARNING]  
> Los nombres de ruta siempre deben ser únicos.

<a name="generating-urls-to-named-routes"></a>
#### Generando URLs a Rutas Nombradas

Una vez que has asignado un nombre a una ruta dada, puedes usar el nombre de la ruta al generar URLs o redirecciones a través de las funciones auxiliares `route` y `redirect` de Laravel:

    // Generando URLs...
    $url = route('profile');

    // Generando Redirecciones...
    return redirect()->route('profile');

    return to_route('profile');

Si la ruta nombrada define parámetros, puedes pasar los parámetros como el segundo argumento a la función `route`. Los parámetros dados se insertarán automáticamente en la URL generada en sus posiciones correctas:

    Route::get('/user/{id}/profile', function (string $id) {
        // ...
    })->name('profile');

    $url = route('profile', ['id' => 1]);

Si pasas parámetros adicionales en el array, esos pares clave / valor se agregarán automáticamente a la cadena de consulta de la URL generada:

    Route::get('/user/{id}/profile', function (string $id) {
        // ...
    })->name('profile');

    $url = route('profile', ['id' => 1, 'photos' => 'yes']);

    // /user/1/profile?photos=yes

> [!NOTE]  
> A veces, es posible que desees especificar valores predeterminados para los parámetros de URL a nivel de solicitud, como la configuración regional actual. Para lograr esto, puedes usar el [`URL::defaults` method](/docs/{{version}}/urls#default-values).

<a name="inspecting-the-current-route"></a>
#### Inspeccionando la Ruta Actual

Si deseas determinar si la solicitud actual fue dirigida a una ruta nombrada específica, puedes usar el método `named` en una instancia de Route. Por ejemplo, puedes verificar el nombre de la ruta actual desde un middleware de ruta:

    use Closure;
    use Illuminate\Http\Request;
    use Symfony\Component\HttpFoundation\Response;

    /**
     * Manejar una solicitud entrante.
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

<a name="route-groups"></a>
## Grupos de Rutas

Los grupos de rutas te permiten compartir atributos de ruta, como middleware, a través de un gran número de rutas sin necesidad de definir esos atributos en cada ruta individual.

Los grupos anidados intentan "fusionar" inteligentemente los atributos con su grupo padre. Los middleware y las condiciones `where` se fusionan mientras que los nombres y prefijos se agregan. Los delimitadores de espacio de nombres y las barras en los prefijos de URI se agregan automáticamente donde sea apropiado.

<a name="route-group-middleware"></a>
### Middleware

Para asignar [middleware](/docs/{{version}}/middleware) a todas las rutas dentro de un grupo, puedes usar el método `middleware` antes de definir el grupo. Los middleware se ejecutan en el orden en que se enumeran en el array:

    Route::middleware(['first', 'second'])->group(function () {
        Route::get('/', function () {
            // Usa el primer y segundo middleware...
        });

        Route::get('/user/profile', function () {
            // Usa el primer y segundo middleware...
        });
    });

<a name="route-group-controllers"></a>
### Controladores

Si un grupo de rutas utiliza el mismo [controlador](/docs/{{version}}/controllers), puedes usar el método `controller` para definir el controlador común para todas las rutas dentro del grupo. Luego, al definir las rutas, solo necesitas proporcionar el método del controlador que invocan:

    use App\Http\Controllers\OrderController;

    Route::controller(OrderController::class)->group(function () {
        Route::get('/orders/{id}', 'show');
        Route::post('/orders', 'store');
    });

<a name="route-group-subdomain-routing"></a>
### Enrutamiento de Subdominios

Los grupos de rutas también se pueden usar para manejar el enrutamiento de subdominios. Los subdominios pueden asignarse parámetros de ruta al igual que las URIs de ruta, lo que te permite capturar una parte del subdominio para su uso en tu ruta o controlador. El subdominio puede especificarse llamando al método `domain` antes de definir el grupo:

    Route::domain('{account}.example.com')->group(function () {
        Route::get('/user/{id}', function (string $account, string $id) {
            // ...
        });
    });

> [!WARNING]  
> Para asegurarte de que tus rutas de subdominio sean accesibles, debes registrar las rutas de subdominio antes de registrar las rutas del dominio raíz. Esto evitará que las rutas del dominio raíz sobrescriban las rutas de subdominio que tienen la misma ruta URI.

<a name="route-group-prefixes"></a>
### Prefijos de Ruta

El método `prefix` se puede usar para prefijar cada ruta en el grupo con una URI dada. Por ejemplo, puedes querer prefijar todas las URIs de ruta dentro del grupo con `admin`:

    Route::prefix('admin')->group(function () {
        Route::get('/users', function () {
            // Coincide con la URL "/admin/users"
        });
    });

<a name="route-group-name-prefixes"></a>
### Prefijos de Nombres de Ruta

El método `name` se puede usar para prefijar cada nombre de ruta en el grupo con una cadena dada. Por ejemplo, puedes querer prefijar los nombres de todas las rutas en el grupo con `admin`. La cadena dada se prefija al nombre de la ruta exactamente como se especifica, por lo que nos aseguraremos de proporcionar el carácter `.` al final en el prefijo:

    Route::name('admin.')->group(function () {
        Route::get('/users', function () {
            // Ruta asignada con el nombre "admin.users"...
        })->name('users');
    });

<a name="route-model-binding"></a>
## Vinculación de Modelos de Ruta

Al inyectar un ID de modelo en una ruta o acción de controlador, a menudo consultarás la base de datos para recuperar el modelo que corresponde a ese ID. La vinculación de modelos de ruta de Laravel proporciona una forma conveniente de inyectar automáticamente las instancias de modelo directamente en tus rutas. Por ejemplo, en lugar de inyectar el ID de un usuario, puedes inyectar la instancia completa del modelo `User` que coincide con el ID dado.

<a name="implicit-binding"></a>
### Vinculación Implícita

Laravel resuelve automáticamente los modelos Eloquent definidos en rutas o acciones de controlador cuyos nombres de variables con tipo coinciden con el nombre de un segmento de ruta. Por ejemplo:

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        return $user->email;
    });

Dado que la variable `$user` está tipificada como el modelo Eloquent `App\Models\User` y el nombre de la variable coincide con el segmento de URI `{user}`, Laravel inyectará automáticamente la instancia del modelo que tiene un ID que coincide con el valor correspondiente de la URI de la solicitud. Si no se encuentra una instancia de modelo coincidente en la base de datos, se generará automáticamente una respuesta HTTP 404.

Por supuesto, la vinculación implícita también es posible al usar métodos de controlador. Nuevamente, ten en cuenta que el segmento de URI `{user}` coincide con la variable `$user` en el controlador que contiene un tipo de referencia `App\Models\User`:

    use App\Http\Controllers\UserController;
    use App\Models\User;

    // Definición de ruta...
    Route::get('/users/{user}', [UserController::class, 'show']);

    // Definición del método del controlador...
    public function show(User $user)
    {
        return view('user.profile', ['user' => $user]);
    }

<a name="implicit-soft-deleted-models"></a>
#### Modelos Suavemente Eliminados

Típicamente, la vinculación de modelos implícita no recuperará modelos que han sido [suavemente eliminados](/docs/{{version}}/eloquent#soft-deleting). Sin embargo, puedes instruir a la vinculación implícita para recuperar estos modelos encadenando el método `withTrashed` a la definición de tu ruta:

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        return $user->email;
    })->withTrashed();

<a name="customizing-the-key"></a>
<a name="customizing-the-default-key-name"></a>
#### Personalizando la Clave

A veces, es posible que desees resolver modelos Eloquent utilizando una columna diferente a `id`. Para hacerlo, puedes especificar la columna en la definición del parámetro de ruta:

    use App\Models\Post;

    Route::get('/posts/{post:slug}', function (Post $post) {
        return $post;
    });

Si deseas que la vinculación de modelos siempre use una columna de base de datos diferente a `id` al recuperar una clase de modelo dada, puedes sobrescribir el método `getRouteKeyName` en el modelo Eloquent:

    /**
     * Obtener la clave de ruta para el modelo.
     */
    public function getRouteKeyName(): string
    {
        return 'slug';
    }

<a name="implicit-model-binding-scoping"></a>
#### Claves Personalizadas y Alcance

Al vincular implícitamente múltiples modelos Eloquent en una sola definición de ruta, es posible que desees limitar el segundo modelo Eloquent de modo que deba ser un hijo del modelo Eloquent anterior. Por ejemplo, considera esta definición de ruta que recupera una publicación de blog por slug para un usuario específico:

    use App\Models\Post;
    use App\Models\User;

    Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
        return $post;
    });

Al usar una vinculación implícita con clave personalizada como un parámetro de ruta anidado, Laravel automáticamente limitará la consulta para recuperar el modelo anidado por su padre utilizando convenciones para adivinar el nombre de la relación en el padre. En este caso, se asumirá que el modelo `User` tiene una relación llamada `posts` (la forma plural del nombre del parámetro de ruta) que se puede usar para recuperar el modelo `Post`.

Si lo deseas, puedes instruir a Laravel para que limite las "vinculaciones" de "hijos" incluso cuando no se proporciona una clave personalizada. Para hacerlo, puedes invocar el método `scopeBindings` al definir tu ruta:

    use App\Models\Post;
    use App\Models\User;

    Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
        return $post;
    })->scopeBindings();

O, puedes instruir a todo un grupo de definiciones de ruta para que usen vinculaciones limitadas:

    Route::scopeBindings()->group(function () {
        Route::get('/users/{user}/posts/{post}', function (User $user, Post $post) {
            return $post;
        });
    });

De manera similar, puedes instruir explícitamente a Laravel para que no limite las vinculaciones invocando el método `withoutScopedBindings`:

    Route::get('/users/{user}/posts/{post:slug}', function (User $user, Post $post) {
        return $post;
    })->withoutScopedBindings();

<a name="customizing-missing-model-behavior"></a>
#### Personalizando el Comportamiento de Modelo Faltante

Típicamente, se generará una respuesta HTTP 404 si no se encuentra un modelo vinculado implícitamente. Sin embargo, puedes personalizar este comportamiento llamando al método `missing` al definir tu ruta. El método `missing` acepta una función anónima que se invocará si no se puede encontrar un modelo vinculado implícitamente:

    use App\Http\Controllers\LocationsController;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Redirect;

    Route::get('/locations/{location:slug}', [LocationsController::class, 'show'])
            ->name('locations.view')
            ->missing(function (Request $request) {
                return Redirect::route('locations.index');
            });

<a name="implicit-enum-binding"></a>
### Vinculación Implícita de Enum

PHP 8.1 introdujo soporte para [Enums](https://www.php.net/manual/en/language.enumerations.backed.php). Para complementar esta característica, Laravel te permite tipificar un [Enum respaldado](https://www.php.net/manual/en/language.enumerations.backed.php) en tu definición de ruta y Laravel solo invocará la ruta si ese segmento de ruta corresponde a un valor de Enum válido. De lo contrario, se devolverá automáticamente una respuesta HTTP 404. Por ejemplo, dado el siguiente Enum:

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

No estás obligado a usar la resolución de modelo basada en convenciones implícitas de Laravel para usar la vinculación de modelos. También puedes definir explícitamente cómo los parámetros de ruta corresponden a los modelos. Para registrar una vinculación explícita, usa el método `model` del enrutador para especificar la clase para un parámetro dado. Debes definir tus vinculaciones de modelo explícitas al comienzo del método `boot` de tu clase `AppServiceProvider`:

    use App\Models\User;
    use Illuminate\Support\Facades\Route;

    /**
     * Inicializar cualquier servicio de aplicación.
     */
    public function boot(): void
    {
        Route::model('user', User::class);
    }

A continuación, define una ruta que contenga un parámetro `{user}`:

    use App\Models\User;

    Route::get('/users/{user}', function (User $user) {
        // ...
    });

Dado que hemos vinculado todos los parámetros `{user}` al modelo `App\Models\User`, se inyectará una instancia de esa clase en la ruta. Así que, por ejemplo, una solicitud a `users/1` inyectará la instancia de `User` de la base de datos que tiene un ID de `1`.

Si no se encuentra una instancia de modelo coincidente en la base de datos, se generará automáticamente una respuesta HTTP 404.

<a name="customizing-the-resolution-logic"></a>
#### Personalizando la Lógica de Resolución

Si deseas definir tu propia lógica de resolución de vinculación de modelos, puedes usar el método `Route::bind`. La función anónima que pasas al método `bind` recibirá el valor del segmento de URI y debe devolver la instancia de la clase que debe inyectarse en la ruta. Nuevamente, esta personalización debe llevarse a cabo en el método `boot` de tu `AppServiceProvider` de la aplicación:

    use App\Models\User;
    use Illuminate\Support\Facades\Route;

    /**
     * Inicializar cualquier servicio de aplicación.
     */
    public function boot(): void
    {
        Route::bind('user', function (string $value) {
            return User::where('name', $value)->firstOrFail();
        });
    }

Alternativamente, puedes sobrescribir el método `resolveRouteBinding` en tu modelo Eloquent. Este método recibirá el valor del segmento de URI y debe devolver la instancia de la clase que debe inyectarse en la ruta:

    /**
     * Recuperar el modelo para un valor vinculado.
     *
     * @param  mixed  $value
     * @param  string|null  $field
     * @return \Illuminate\Database\Eloquent\Model|null
     */
    public function resolveRouteBinding($value, $field = null)
    {
        return $this->where('name', $value)->firstOrFail();
    }

Si una ruta está utilizando [alcance de vinculación implícita](#implicit-model-binding-scoping), se utilizará el método `resolveChildRouteBinding` para resolver la vinculación del modelo hijo del modelo padre:

    /**
     * Recuperar el modelo hijo para un valor vinculado.
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

<a name="fallback-routes"></a>
## Rutas de Respaldo

Usando el método `Route::fallback`, puedes definir una ruta que se ejecutará cuando ninguna otra ruta coincida con la solicitud entrante. Típicamente, las solicitudes no manejadas generarán automáticamente una página "404" a través del manejador de excepciones de tu aplicación. Sin embargo, dado que normalmente definirías la ruta `fallback` dentro de tu archivo `routes/web.php`, todos los middleware en el grupo de middleware `web` se aplicarán a la ruta. Eres libre de agregar middleware adicionales a esta ruta según sea necesario:

    Route::fallback(function () {
        // ...
    });

> [!WARNING]  
> La ruta de respaldo siempre debe ser la última ruta registrada por tu aplicación.

<a name="rate-limiting"></a>
## Limitación de Tasa

<a name="defining-rate-limiters"></a>
### Definición de Limitadores de Tasa

Laravel incluye servicios de limitación de tasa potentes y personalizables que puedes utilizar para restringir la cantidad de tráfico para una ruta dada o grupo de rutas. Para comenzar, debes definir configuraciones de limitadores de tasa que satisfagan las necesidades de tu aplicación.

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

Los limitadores de tasa se definen utilizando el método `for` del facade `RateLimiter`. El método `for` acepta un nombre de limitador de tasa y una función anónima que devuelve la configuración de límite que debe aplicarse a las rutas que están asignadas al limitador de tasa. La configuración de límite son instancias de la clase `Illuminate\Cache\RateLimiting\Limit`. Esta clase contiene métodos "constructor" útiles para que puedas definir rápidamente tu límite. El nombre del limitador de tasa puede ser cualquier cadena que desees:

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

Si la solicitud entrante excede el límite de tasa especificado, Laravel devolverá automáticamente una respuesta con un código de estado HTTP 429. Si deseas definir tu propia respuesta que debería ser devuelta por un límite de tasa, puedes usar el método `response`:

    RateLimiter::for('global', function (Request $request) {
        return Limit::perMinute(1000)->response(function (Request $request, array $headers) {
            return response('Respuesta personalizada...', 429, $headers);
        });
    });

Dado que los callbacks del limitador de tasa reciben la instancia de la solicitud HTTP entrante, puedes construir el límite de tasa apropiado dinámicamente en función de la solicitud entrante o del usuario autenticado:

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()->vipCustomer()
                    ? Limit::none()
                    : Limit::perMinute(100);
    });

<a name="segmenting-rate-limits"></a>
#### Segmentando Límites de Tasa

A veces, puedes desear segmentar los límites de tasa por algún valor arbitrario. Por ejemplo, puedes desear permitir que los usuarios accedan a una ruta dada 100 veces por minuto por dirección IP. Para lograr esto, puedes usar el método `by` al construir tu límite de tasa:

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()->vipCustomer()
                    ? Limit::none()
                    : Limit::perMinute(100)->by($request->ip());
    });

Para ilustrar esta característica usando otro ejemplo, podemos limitar el acceso a la ruta a 100 veces por minuto por ID de usuario autenticado o 10 veces por minuto por dirección IP para invitados:

    RateLimiter::for('uploads', function (Request $request) {
        return $request->user()
                    ? Limit::perMinute(100)->by($request->user()->id)
                    : Limit::perMinute(10)->by($request->ip());
    });

<a name="multiple-rate-limits"></a>
#### Múltiples Límites de Tasa

Si es necesario, puedes devolver un array de límites de tasa para una configuración de limitador de tasa dada. Cada límite de tasa será evaluado para la ruta en función del orden en que se colocan dentro del array:

    RateLimiter::for('login', function (Request $request) {
        return [
            Limit::perMinute(500),
            Limit::perMinute(3)->by($request->input('email')),
        ];
    });

<a name="attaching-rate-limiters-to-routes"></a>
### Adjuntando Limitadores de Tasa a Rutas

Los limitadores de tasa pueden ser adjuntados a rutas o grupos de rutas usando el middleware `throttle` [middleware](/docs/{{version}}/middleware). El middleware de limitación acepta el nombre del limitador de tasa que deseas asignar a la ruta:

    Route::middleware(['throttle:uploads'])->group(function () {
        Route::post('/audio', function () {
            // ...
        });

        Route::post('/video', function () {
            // ...
        });
    });

<a name="throttling-with-redis"></a>
#### Limitación con Redis

Por defecto, el middleware `throttle` está mapeado a la clase `Illuminate\Routing\Middleware\ThrottleRequests`. Sin embargo, si estás usando Redis como el controlador de caché de tu aplicación, puedes desear instruir a Laravel para que use Redis para gestionar la limitación de tasa. Para hacerlo, debes usar el método `throttleWithRedis` en el archivo `bootstrap/app.php` de tu aplicación. Este método mapea el middleware `throttle` a la clase de middleware `Illuminate\Routing\Middleware\ThrottleRequestsWithRedis`:

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->throttleWithRedis();
        // ...
    })

<a name="form-method-spoofing"></a>
## Suplantación de Método de Formulario

Los formularios HTML no soportan acciones `PUT`, `PATCH` o `DELETE`. Por lo tanto, al definir rutas `PUT`, `PATCH` o `DELETE` que son llamadas desde un formulario HTML, necesitarás agregar un campo oculto `_method` al formulario. El valor enviado con el campo `_method` se usará como el método de solicitud HTTP:

    <form action="/example" method="POST">
        <input type="hidden" name="_method" value="PUT">
        <input type="hidden" name="_token" value="{{ csrf_token() }}">
    </form>

Para conveniencia, puedes usar la directiva `@method` [Blade directive](/docs/{{version}}/blade) para generar el campo de entrada `_method`:

    <form action="/example" method="POST">
        @method('PUT')
        @csrf
    </form>

<a name="accessing-the-current-route"></a>
## Accediendo a la Ruta Actual

Puedes usar los métodos `current`, `currentRouteName` y `currentRouteAction` en el facade `Route` para acceder a información sobre la ruta que maneja la solicitud entrante:

    use Illuminate\Support\Facades\Route;

    $route = Route::current(); // Illuminate\Routing\Route
    $name = Route::currentRouteName(); // string
    $action = Route::currentRouteAction(); // string

Puedes consultar la documentación de la API para ambas [clases subyacentes del facade Route](https://laravel.com/api/{{version}}/Illuminate/Routing/Router.html) y [instancia Route](https://laravel.com/api/{{version}}/Illuminate/Routing/Route.html) para revisar todos los métodos que están disponibles en las clases de enrutador y ruta.

<a name="cors"></a>
## Compartición de Recursos de Origen Cruzado (CORS)

Laravel puede responder automáticamente a las solicitudes HTTP `OPTIONS` de CORS con los valores que configures. Las solicitudes `OPTIONS` serán manejadas automáticamente por el middleware `HandleCors` [middleware](/docs/{{version}}/middleware) que se incluye automáticamente en la pila de middleware global de tu aplicación.

A veces, puede que necesites personalizar los valores de configuración de CORS para tu aplicación. Puedes hacerlo publicando el archivo de configuración `cors` usando el comando Artisan `config:publish`:

```shell
php artisan config:publish cors
```

Este comando colocará un archivo de configuración `cors.php` dentro del directorio `config` de tu aplicación.

> [!NOTE]  
> Para más información sobre CORS y los encabezados de CORS, consulta la [documentación web de MDN sobre CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#The_HTTP_response_headers).

<a name="route-caching"></a>
## Caché de Rutas

Al desplegar tu aplicación en producción, deberías aprovechar la caché de rutas de Laravel. Usar la caché de rutas disminuirá drásticamente el tiempo que toma registrar todas las rutas de tu aplicación. Para generar una caché de rutas, ejecuta el comando Artisan `route:cache`:

```shell
php artisan route:cache
```

Después de ejecutar este comando, tu archivo de rutas en caché se cargará en cada solicitud. Recuerda, si agregas nuevas rutas necesitarás generar una nueva caché de rutas. Debido a esto, solo deberías ejecutar el comando `route:cache` durante el despliegue de tu proyecto.

Puedes usar el comando `route:clear` para limpiar la caché de rutas:

```shell
php artisan route:clear
```