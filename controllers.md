# Controladores

- [Introducción](#introduction)
- [Escribiendo Controladores](#writing-controllers)
    - [Controladores Básicos](#basic-controllers)
    - [Controladores de Acción Única](#single-action-controllers)
- [Middleware de Controlador](#controller-middleware)
- [Controladores de Recursos](#resource-controllers)
    - [Rutas de Recursos Parciales](#restful-partial-resource-routes)
    - [Recursos Anidados](#restful-nested-resources)
    - [Nombrando Rutas de Recursos](#restful-naming-resource-routes)
    - [Nombrando Parámetros de Rutas de Recursos](#restful-naming-resource-route-parameters)
    - [Limitando Rutas de Recursos](#restful-scoping-resource-routes)
    - [Localizando URIs de Recursos](#restful-localizing-resource-uris)
    - [Suplementando Controladores de Recursos](#restful-supplementing-resource-controllers)
    - [Controladores de Recursos Singleton](#singleton-resource-controllers)
- [Inyección de Dependencias y Controladores](#dependency-injection-and-controllers)

<a name="introduction"></a>
## Introducción

En lugar de definir toda tu lógica de manejo de solicitudes como funciones anónimas en tus archivos de rutas, es posible que desees organizar este comportamiento utilizando clases de "controlador". Los controladores pueden agrupar la lógica de manejo de solicitudes relacionadas en una sola clase. Por ejemplo, una clase `UserController` podría manejar todas las solicitudes entrantes relacionadas con los usuarios, incluyendo mostrar, crear, actualizar y eliminar usuarios. Por defecto, los controladores se almacenan en el directorio `app/Http/Controllers`.

<a name="writing-controllers"></a>
## Escribiendo Controladores

<a name="basic-controllers"></a>
### Controladores Básicos

Para generar rápidamente un nuevo controlador, puedes ejecutar el comando Artisan `make:controller`. Por defecto, todos los controladores para tu aplicación se almacenan en el directorio `app/Http/Controllers`:

```shell
php artisan make:controller UserController
```

Veamos un ejemplo de un controlador básico. Un controlador puede tener cualquier número de métodos públicos que responderán a las solicitudes HTTP entrantes:

    <?php

    namespace App\Http\Controllers;

    use App\Models\User;
    use Illuminate\View\View;

    class UserController extends Controller
    {
        /**
         * Mostrar el perfil de un usuario dado.
         */
        public function show(string $id): View
        {
            return view('user.profile', [
                'user' => User::findOrFail($id)
            ]);
        }
    }

Una vez que hayas escrito una clase y un método de controlador, puedes definir una ruta al método del controlador de la siguiente manera:

    use App\Http\Controllers\UserController;

    Route::get('/user/{id}', [UserController::class, 'show']);

Cuando una solicitud entrante coincide con la URI de ruta especificada, se invocará el método `show` de la clase `App\Http\Controllers\UserController` y los parámetros de la ruta se pasarán al método.

> [!NOTE]  
> Los controladores no son **requeridos** para extender una clase base. Sin embargo, a veces es conveniente extender una clase de controlador base que contenga métodos que deberían ser compartidos entre todos tus controladores.

<a name="single-action-controllers"></a>
### Controladores de Acción Única

Si una acción de controlador es particularmente compleja, podrías encontrar conveniente dedicar una clase de controlador entera a esa única acción. Para lograr esto, puedes definir un único método `__invoke` dentro del controlador:

    <?php

    namespace App\Http\Controllers;

    class ProvisionServer extends Controller
    {
        /**
         * Provisionar un nuevo servidor web.
         */
        public function __invoke()
        {
            // ...
        }
    }

Al registrar rutas para controladores de acción única, no necesitas especificar un método de controlador. En su lugar, simplemente puedes pasar el nombre del controlador al enrutador:

    use App\Http\Controllers\ProvisionServer;

    Route::post('/server', ProvisionServer::class);

Puedes generar un controlador invocable utilizando la opción `--invokable` del comando Artisan `make:controller`:

```shell
php artisan make:controller ProvisionServer --invokable
```

> [!NOTE]  
> Los stubs de controlador pueden ser personalizados utilizando [publicación de stubs](/docs/{{version}}/artisan#stub-customization).

<a name="controller-middleware"></a>
## Middleware de Controlador

[Middleware](/docs/{{version}}/middleware) puede ser asignado a las rutas del controlador en tus archivos de rutas:

    Route::get('/profile', [UserController::class, 'show'])->middleware('auth');

O, puedes encontrar conveniente especificar middleware dentro de tu clase de controlador. Para hacerlo, tu controlador debe implementar la interfaz `HasMiddleware`, que dicta que el controlador debe tener un método estático `middleware`. Desde este método, puedes devolver un array de middleware que deberían aplicarse a las acciones del controlador:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use Illuminate\Routing\Controllers\HasMiddleware;
    use Illuminate\Routing\Controllers\Middleware;

    class UserController extends Controller implements HasMiddleware
    {
        /**
         * Obtener el middleware que debería ser asignado al controlador.
         */
        public static function middleware(): array
        {
            return [
                'auth',
                new Middleware('log', only: ['index']),
                new Middleware('subscribed', except: ['store']),
            ];
        }

        // ...
    }

También puedes definir middleware de controlador como funciones anónimas, lo que proporciona una forma conveniente de definir un middleware en línea sin escribir una clase de middleware completa:

    use Closure;
    use Illuminate\Http\Request;

    /**
     * Obtener el middleware que debería ser asignado al controlador.
     */
    public static function middleware(): array
    {
        return [
            function (Request $request, Closure $next) {
                return $next($request);
            },
        ];
    }

<a name="resource-controllers"></a>
## Controladores de Recursos

Si piensas en cada modelo Eloquent en tu aplicación como un "recurso", es típico realizar los mismos conjuntos de acciones contra cada recurso en tu aplicación. Por ejemplo, imagina que tu aplicación contiene un modelo `Photo` y un modelo `Movie`. Es probable que los usuarios puedan crear, leer, actualizar o eliminar estos recursos.

Debido a este caso de uso común, el enrutamiento de recursos de Laravel asigna las rutas típicas de crear, leer, actualizar y eliminar ("CRUD") a un controlador con una sola línea de código. Para comenzar, podemos usar la opción `--resource` del comando Artisan `make:controller` para crear rápidamente un controlador que maneje estas acciones:

```shell
php artisan make:controller PhotoController --resource
```

Este comando generará un controlador en `app/Http/Controllers/PhotoController.php`. El controlador contendrá un método para cada una de las operaciones de recursos disponibles. A continuación, puedes registrar una ruta de recurso que apunte al controlador:

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class);

Esta declaración de ruta única crea múltiples rutas para manejar una variedad de acciones sobre el recurso. El controlador generado ya tendrá métodos preparados para cada una de estas acciones. Recuerda, siempre puedes obtener una visión rápida de las rutas de tu aplicación ejecutando el comando Artisan `route:list`.

Incluso puedes registrar muchos controladores de recursos a la vez pasando un array al método `resources`:

    Route::resources([
        'photos' => PhotoController::class,
        'posts' => PostController::class,
    ]);

<a name="actions-handled-by-resource-controllers"></a>
#### Acciones Manejadas por Controladores de Recursos

<div class="overflow-auto">

| Verbo      | URI                    | Acción  | Nombre de Ruta     |
| --------- | ---------------------- | ------- | -------------- |
| GET       | `/photos`              | index   | photos.index   |
| GET       | `/photos/create`       | create  | photos.create  |
| POST      | `/photos`              | store   | photos.store   |
| GET       | `/photos/{photo}`      | show    | photos.show    |
| GET       | `/photos/{photo}/edit` | edit    | photos.edit    |
| PUT/PATCH | `/photos/{photo}`      | update  | photos.update  |
| DELETE    | `/photos/{photo}`      | destroy | photos.destroy |

</div>

<a name="customizing-missing-model-behavior"></a>
#### Personalizando el Comportamiento de Modelos Faltantes

Típicamente, se generará una respuesta HTTP 404 si un modelo de recurso implícitamente vinculado no se encuentra. Sin embargo, puedes personalizar este comportamiento llamando al método `missing` al definir tu ruta de recurso. El método `missing` acepta una función anónima que se invocará si no se puede encontrar un modelo implícitamente vinculado para cualquiera de las rutas del recurso:

    use App\Http\Controllers\PhotoController;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Redirect;

    Route::resource('photos', PhotoController::class)
            ->missing(function (Request $request) {
                return Redirect::route('photos.index');
            });

<a name="soft-deleted-models"></a>
#### Modelos Suavemente Eliminados

Típicamente, la vinculación implícita de modelos no recuperará modelos que han sido [suavemente eliminados](/docs/{{version}}/eloquent#soft-deleting), y en su lugar devolverá una respuesta HTTP 404. Sin embargo, puedes instruir al framework para permitir modelos suavemente eliminados invocando el método `withTrashed` al definir tu ruta de recurso:

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->withTrashed();

Llamar a `withTrashed` sin argumentos permitirá modelos suavemente eliminados para las rutas de recurso `show`, `edit` y `update`. Puedes especificar un subconjunto de estas rutas pasando un array al método `withTrashed`:

    Route::resource('photos', PhotoController::class)->withTrashed(['show']);

<a name="specifying-the-resource-model"></a>
#### Especificando el Modelo de Recurso

Si estás utilizando [vinculación de modelos de ruta](/docs/{{version}}/routing#route-model-binding) y deseas que los métodos del controlador de recursos hagan referencia a una instancia de modelo, puedes usar la opción `--model` al generar el controlador:

```shell
php artisan make:controller PhotoController --model=Photo --resource
```

<a name="generating-form-requests"></a>
#### Generando Solicitudes de Formulario

Puedes proporcionar la opción `--requests` al generar un controlador de recursos para instruir a Artisan a generar [clases de solicitud de formulario](/docs/{{version}}/validation#form-request-validation) para los métodos de almacenamiento y actualización del controlador:

```shell
php artisan make:controller PhotoController --model=Photo --resource --requests
```

<a name="restful-partial-resource-routes"></a>
### Rutas de Recursos Parciales

Al declarar una ruta de recurso, puedes especificar un subconjunto de acciones que el controlador debería manejar en lugar del conjunto completo de acciones predeterminadas:

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->only([
        'index', 'show'
    ]);

    Route::resource('photos', PhotoController::class)->except([
        'create', 'store', 'update', 'destroy'
    ]);

<a name="api-resource-routes"></a>
#### Rutas de Recursos API

Al declarar rutas de recursos que serán consumidas por APIs, comúnmente querrás excluir rutas que presenten plantillas HTML como `create` y `edit`. Para conveniencia, puedes usar el método `apiResource` para excluir automáticamente estas dos rutas:

    use App\Http\Controllers\PhotoController;

    Route::apiResource('photos', PhotoController::class);

Puedes registrar muchos controladores de recursos API a la vez pasando un array al método `apiResources`:

    use App\Http\Controllers\PhotoController;
    use App\Http\Controllers\PostController;

    Route::apiResources([
        'photos' => PhotoController::class,
        'posts' => PostController::class,
    ]);

Para generar rápidamente un controlador de recursos API que no incluya los métodos `create` o `edit`, usa el interruptor `--api` al ejecutar el comando `make:controller`:

```shell
php artisan make:controller PhotoController --api
```

<a name="restful-nested-resources"></a>
### Recursos Anidados

A veces puede que necesites definir rutas para un recurso anidado. Por ejemplo, un recurso de foto puede tener múltiples comentarios que pueden estar adjuntos a la foto. Para anidar los controladores de recursos, puedes usar la notación de "punto" en tu declaración de ruta:

    use App\Http\Controllers\PhotoCommentController;

    Route::resource('photos.comments', PhotoCommentController::class);

Esta ruta registrará un recurso anidado que puede ser accedido con URIs como la siguiente:

    /photos/{photo}/comments/{comment}

<a name="scoping-nested-resources"></a>
#### Limitando Recursos Anidados

La función de [vinculación implícita de modelos](#restful-scoping-resource-routes) de Laravel puede limitar automáticamente las vinculaciones anidadas de tal manera que el modelo hijo resuelto se confirme que pertenece al modelo padre. Al usar el método `scoped` al definir tu recurso anidado, puedes habilitar la limitación automática así como instruir a Laravel qué campo debe ser utilizado para recuperar el recurso hijo. Para más información sobre cómo lograr esto, consulta la documentación sobre [limitando rutas de recursos](#restful-scoping-resource-routes).

<a name="shallow-nesting"></a>
#### Anidamiento Superficial

A menudo, no es completamente necesario tener tanto los IDs del padre como del hijo dentro de una URI, ya que el ID del hijo ya es un identificador único. Al usar identificadores únicos como claves primarias autoincrementales para identificar tus modelos en segmentos de URI, puedes optar por usar "anidamiento superficial":

    use App\Http\Controllers\CommentController;

    Route::resource('photos.comments', CommentController::class)->shallow();

Esta definición de ruta definirá las siguientes rutas:

<div class="overflow-auto">

| Verbo      | URI                               | Acción  | Nombre de Ruta             |
| --------- | --------------------------------- | ------- | ---------------------- |
| GET       | `/photos/{photo}/comments`        | index   | photos.comments.index  |
| GET       | `/photos/{photo}/comments/create` | create  | photos.comments.create |
| POST      | `/photos/{photo}/comments`        | store   | photos.comments.store  |
| GET       | `/comments/{comment}`             | show    | comments.show          |
| GET       | `/comments/{comment}/edit`        | edit    | comments.edit          |
| PUT/PATCH | `/comments/{comment}`             | update  | comments.update        |
| DELETE    | `/comments/{comment}`             | destroy | comments.destroy       |

</div>

<a name="restful-naming-resource-routes"></a>
### Nombrando Rutas de Recursos

Por defecto, todas las acciones del controlador de recursos tienen un nombre de ruta; sin embargo, puedes sobrescribir estos nombres pasando un array `names` con tus nombres de ruta deseados:

    use App\Http\Controllers\PhotoController;

    Route::resource('photos', PhotoController::class)->names([
        'create' => 'photos.build'
    ]);

<a name="restful-naming-resource-route-parameters"></a>
### Nombrando Parámetros de Rutas de Recursos

Por defecto, `Route::resource` creará los parámetros de ruta para tus rutas de recursos basándose en la versión "singular" del nombre del recurso. Puedes sobrescribir esto fácilmente en una base por recurso utilizando el método `parameters`. El array pasado al método `parameters` debe ser un array asociativo de nombres de recursos y nombres de parámetros:

```php
    use App\Http\Controllers\AdminUserController;

    Route::resource('users', AdminUserController::class)->parameters([
        'users' => 'admin_user'
    ]);

El ejemplo anterior genera la siguiente URI para la ruta `show` del recurso:

    /users/{admin_user}

<a name="restful-scoping-resource-routes"></a>
### Alcance de Rutas de Recursos

La función de [vinculación implícita con alcance](/docs/{{version}}/routing#implicit-model-binding-scoping) de Laravel puede automáticamente limitar las vinculaciones anidadas de tal manera que el modelo hijo resuelto se confirme que pertenece al modelo padre. Al usar el método `scoped` al definir tu recurso anidado, puedes habilitar el alcance automático así como instruir a Laravel sobre qué campo debe ser utilizado para recuperar el recurso hijo:

    use App\Http\Controllers\PhotoCommentController;

    Route::resource('photos.comments', PhotoCommentController::class)->scoped([
        'comment' => 'slug',
    ]);

Esta ruta registrará un recurso anidado con alcance que puede ser accedido con URIs como las siguientes:

    /photos/{photo}/comments/{comment:slug}

Al usar una vinculación implícita con clave personalizada como un parámetro de ruta anidado, Laravel automáticamente limitará la consulta para recuperar el modelo anidado por su padre utilizando convenciones para adivinar el nombre de la relación en el padre. En este caso, se asumirá que el modelo `Photo` tiene una relación llamada `comments` (el plural del nombre del parámetro de ruta) que puede ser utilizada para recuperar el modelo `Comment`.

<a name="restful-localizing-resource-uris"></a>
### Localización de URIs de Recursos

Por defecto, `Route::resource` creará URIs de recursos utilizando verbos en inglés y reglas de plural. Si necesitas localizar los verbos de acción `create` y `edit`, puedes usar el método `Route::resourceVerbs`. Esto se puede hacer al principio del método `boot` dentro de `App\Providers\AppServiceProvider` de tu aplicación:

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Route::resourceVerbs([
            'create' => 'crear',
            'edit' => 'editar',
        ]);
    }

El pluralizador de Laravel soporta [varios idiomas diferentes que puedes configurar según tus necesidades](/docs/{{version}}/localization#pluralization-language). Una vez que los verbos y el idioma de pluralización han sido personalizados, un registro de ruta de recurso como `Route::resource('publicacion', PublicacionController::class)` producirá las siguientes URIs:

    /publicacion/crear

    /publicacion/{publicaciones}/editar

<a name="restful-supplementing-resource-controllers"></a>
### Suplementando Controladores de Recursos

Si necesitas agregar rutas adicionales a un controlador de recursos más allá del conjunto predeterminado de rutas de recursos, debes definir esas rutas antes de tu llamada al método `Route::resource`; de lo contrario, las rutas definidas por el método `resource` pueden tomar precedencia sobre tus rutas suplementarias:

    use App\Http\Controller\PhotoController;

    Route::get('/photos/popular', [PhotoController::class, 'popular']);
    Route::resource('photos', PhotoController::class);

> [!NOTE]  
> Recuerda mantener tus controladores enfocados. Si te encuentras necesitando rutinariamente métodos fuera del conjunto típico de acciones de recursos, considera dividir tu controlador en dos controladores más pequeños.

<a name="singleton-resource-controllers"></a>
### Controladores de Recursos Singleton

A veces, tu aplicación tendrá recursos que pueden tener solo una única instancia. Por ejemplo, el "perfil" de un usuario puede ser editado o actualizado, pero un usuario no puede tener más de un "perfil". Del mismo modo, una imagen puede tener un único "thumbnail". Estos recursos se llaman "recursos singleton", lo que significa que solo puede existir una instancia del recurso. En estos escenarios, puedes registrar un controlador de recurso "singleton":

```php
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::singleton('profile', ProfileController::class);
```

La definición de recurso singleton anterior registrará las siguientes rutas. Como puedes ver, no se registran rutas de "creación" para recursos singleton, y las rutas registradas no aceptan un identificador ya que solo puede existir una instancia del recurso:

<div class="overflow-auto">

| Verb      | URI             | Action | Route Name     |
| --------- | --------------- | ------ | -------------- |
| GET       | `/profile`      | show   | profile.show   |
| GET       | `/profile/edit` | edit   | profile.edit   |
| PUT/PATCH | `/profile`      | update | profile.update |

</div>

Los recursos singleton también pueden estar anidados dentro de un recurso estándar:

```php
Route::singleton('photos.thumbnail', ThumbnailController::class);
```

En este ejemplo, el recurso `photos` recibiría todas las [rutas de recursos estándar](#actions-handled-by-resource-controller); sin embargo, el recurso `thumbnail` sería un recurso singleton con las siguientes rutas:

<div class="overflow-auto">

| Verb      | URI                              | Action | Route Name              |
| --------- | -------------------------------- | ------ | ----------------------- |
| GET       | `/photos/{photo}/thumbnail`      | show   | photos.thumbnail.show   |
| GET       | `/photos/{photo}/thumbnail/edit` | edit   | photos.thumbnail.edit   |
| PUT/PATCH | `/photos/{photo}/thumbnail`      | update | photos.thumbnail.update |

</div>

<a name="creatable-singleton-resources"></a>
#### Recursos Singleton Creables

Ocasionalmente, puede que desees definir rutas de creación y almacenamiento para un recurso singleton. Para lograr esto, puedes invocar el método `creatable` al registrar la ruta del recurso singleton:

```php
Route::singleton('photos.thumbnail', ThumbnailController::class)->creatable();
```

En este ejemplo, se registrarán las siguientes rutas. Como puedes ver, también se registrará una ruta `DELETE` para recursos singleton creables:

<div class="overflow-auto">

| Verb      | URI                                | Action  | Route Name               |
| --------- | ---------------------------------- | ------- | ------------------------ |
| GET       | `/photos/{photo}/thumbnail/create` | create  | photos.thumbnail.create  |
| POST      | `/photos/{photo}/thumbnail`        | store   | photos.thumbnail.store   |
| GET       | `/photos/{photo}/thumbnail`        | show    | photos.thumbnail.show    |
| GET       | `/photos/{photo}/thumbnail/edit`   | edit    | photos.thumbnail.edit    |
| PUT/PATCH | `/photos/{photo}/thumbnail`        | update  | photos.thumbnail.update  |
| DELETE    | `/photos/{photo}/thumbnail`        | destroy | photos.thumbnail.destroy |

</div>

Si deseas que Laravel registre la ruta `DELETE` para un recurso singleton pero no registre las rutas de creación o almacenamiento, puedes utilizar el método `destroyable`:

```php
Route::singleton(...)->destroyable();
```

<a name="api-singleton-resources"></a>
#### Recursos Singleton de API

El método `apiSingleton` puede ser utilizado para registrar un recurso singleton que será manipulado a través de una API, haciendo que las rutas `create` y `edit` sean innecesarias:

```php
Route::apiSingleton('profile', ProfileController::class);
```

Por supuesto, los recursos singleton de API también pueden ser `creables`, lo que registrará rutas `store` y `destroy` para el recurso:

```php
Route::apiSingleton('photos.thumbnail', ProfileController::class)->creatable();
```

<a name="dependency-injection-and-controllers"></a>
## Inyección de Dependencias y Controladores

<a name="constructor-injection"></a>
#### Inyección por Constructor

El [contenedor de servicios](/docs/{{version}}/container) de Laravel se utiliza para resolver todos los controladores de Laravel. Como resultado, puedes indicar cualquier dependencia que tu controlador pueda necesitar en su constructor. Las dependencias declaradas serán automáticamente resueltas e inyectadas en la instancia del controlador:

    <?php

    namespace App\Http\Controllers;

    use App\Repositories\UserRepository;

    class UserController extends Controller
    {
        /**
         * Create a new controller instance.
         */
        public function __construct(
            protected UserRepository $users,
        ) {}
    }

<a name="method-injection"></a>
#### Inyección por Método

Además de la inyección por constructor, también puedes indicar dependencias en los métodos de tu controlador. Un caso de uso común para la inyección por método es inyectar la instancia de `Illuminate\Http\Request` en los métodos de tu controlador:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class UserController extends Controller
    {
        /**
         * Store a new user.
         */
        public function store(Request $request): RedirectResponse
        {
            $name = $request->name;

            // Store the user...

            return redirect('/users');
        }
    }

Si tu método de controlador también está esperando entrada de un parámetro de ruta, enumera tus argumentos de ruta después de tus otras dependencias. Por ejemplo, si tu ruta está definida de la siguiente manera:

    use App\Http\Controllers\UserController;

    Route::put('/user/{id}', [UserController::class, 'update']);

Aún puedes indicar la `Illuminate\Http\Request` y acceder a tu parámetro `id` definiendo tu método de controlador de la siguiente manera:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class UserController extends Controller
    {
        /**
         * Update the given user.
         */
        public function update(Request $request, string $id): RedirectResponse
        {
            // Update the user...

            return redirect('/users');
        }
    }
```
