# Controladores

- [Introducción](#introduction)
- [Escribiendo Controladores](#writing-controllers)
  - [Controladores Básicos](#basic-controllers)
  - [Controladores de Acción Única](#single-action-controllers)
- [Middleware de Controlador](#controller-middleware)
- [Controladores de Recursos](#resource-controllers)
  - [Rutas de Recursos Parciales](#restful-partial-resource-routes)
  - [Recursos Anidados](#restful-nested-resources)
  - [Nombrar Rutas de Recursos](#restful-naming-resource-routes)
  - [Nombrar Parámetros de Ruta de Recursos](#restful-naming-resource-route-parameters)
  - [Acotar Rutas de Recursos](#restful-scoping-resource-routes)
  - [Localizar URIs de Recursos](#restful-localizing-resource-uris)
  - [Suplementar Controladores de Recursos](#restful-supplementing-resource-controllers)
  - [Controladores de Recursos Singleton](#singleton-resource-controllers)
- [Inyección de Dependencias y Controladores](#dependency-injection-and-controllers)

<a name="introduction"></a>
## Introducción

En lugar de definir toda tu lógica de manejo de solicitudes como `funciones anónimas` en tus archivos de ruta, es posible que desees organizar este comportamiento utilizando clases de "controlador". Los controladores pueden agrupar la lógica de manejo de solicitudes relacionadas en una sola clase. Por ejemplo, una clase `UserController` podría manejar todas las solicitudes entrantes relacionadas con los usuarios, incluyendo mostrar, crear, actualizar y eliminar usuarios. Por defecto, los controladores se almacenan en el directorio `app/Http/Controllers`.

<a name="writing-controllers"></a>
## Escribiendo Controladores


<a name="basic-controllers"></a>
### Controladores Básicos

Para generar rápidamente un nuevo controlador, puedes ejecutar el comando Artisan `make:controller`. Por defecto, todos los controladores de tu aplicación se almacenan en el directorio `app/Http/Controllers`:


```shell
php artisan make:controller UserController

```
Vamos a echar un vistazo a un ejemplo de un controlador básico. Un controlador puede tener cualquier número de métodos públicos que responderán a las solicitudes HTTP entrantes:


```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show the profile for a given user.
     */
    public function show(string $id): View
    {
        return view('user.profile', [
            'user' => User::findOrFail($id)
        ]);
    }
}
```
Una vez que hayas escrito una clase y método de controlador, puedes definir una ruta al método del controlador de la siguiente manera:


```php
use App\Http\Controllers\UserController;

Route::get('/user/{id}', [UserController::class, 'show']);
```
Cuando una solicitud entrante coincide con la URI de ruta especificada, se invocará el método `show` en la clase `App\Http\Controllers\UserController` y los parámetros de la ruta se pasarán al método.
> [!NOTE]
Los controladores no **necesitan** extender una clase base. Sin embargo, a veces es conveniente extender una clase de controlador base que contenga métodos que deben compartirse entre todos tus controladores.

<a name="single-action-controllers"></a>
### Controladores de Acción Única

Si una acción del controlador es particularmente compleja, es posible que te resulte conveniente dedicar toda una clase de controlador a esa única acción. Para lograr esto, puedes definir un solo método `__invoke` dentro del controlador:


```php
<?php

namespace App\Http\Controllers;

class ProvisionServer extends Controller
{
    /**
     * Provision a new web server.
     */
    public function __invoke()
    {
        // ...
    }
}
```
Al registrar rutas para controladores de acción única, no necesitas especificar un método del controlador. En su lugar, puedes simplemente pasar el nombre del controlador al enrutador:


```php
use App\Http\Controllers\ProvisionServer;

Route::post('/server', ProvisionServer::class);
```
Puedes generar un controlador invocable utilizando la opción `--invokable` del comando Artisan `make:controller`:


```shell
php artisan make:controller ProvisionServer --invokable

```
> [!NOTA]
Los stubs de controlador pueden personalizarse utilizando [publicación de stubs](/docs/%7B%7Bversion%7D%7D/artisan#stub-customization).

<a name="controller-middleware"></a>
## Middleware de Controlador

[Middleware](/docs/%7B%7Bversion%7D%7D/middleware) puede ser asignado a las rutas del controlador en tus archivos de rutas:


```php
Route::get('/profile', [UserController::class, 'show'])->middleware('auth');
```
O, puede que te resulte conveniente especificar middleware dentro de tu clase de controlador. Para hacerlo, tu controlador debe implementar la interfaz `HasMiddleware`, que dicta que el controlador debe tener un método estático `middleware`. Desde este método, puedes devolver un array de middleware que deben aplicarse a las acciones del controlador:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class UserController extends Controller implements HasMiddleware
{
    /**
     * Get the middleware that should be assigned to the controller.
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
```
También puedes definir middleware de controlador como funciones anónimas, lo que proporciona una forma conveniente de definir un middleware en línea sin escribir una clase de middleware completa:


```php
use Closure;
use Illuminate\Http\Request;

/**
 * Get the middleware that should be assigned to the controller.
 */
public static function middleware(): array
{
    return [
        function (Request $request, Closure $next) {
            return $next($request);
        },
    ];
}
```

<a name="resource-controllers"></a>
## Controladores de Recursos

Si piensas en cada modelo Eloquent en tu aplicación como un "recurso", es típico realizar los mismos conjuntos de acciones contra cada recurso en tu aplicación. Por ejemplo, imagina que tu aplicación contiene un modelo `Photo` y un modelo `Movie`. Es probable que los usuarios puedan crear, leer, actualizar o eliminar estos recursos.
Debido a este caso de uso común, el enrutamiento de recursos de Laravel asigna las rutas típicas de crear, leer, actualizar y eliminar ("CRUD") a un controlador con una sola línea de código. Para comenzar, podemos usar la opción `--resource` del comando Artisan `make:controller` para crear rápidamente un controlador que maneje estas acciones:


```shell
php artisan make:controller PhotoController --resource

```
Este comando generará un controlador en `app/Http/Controllers/PhotoController.php`. El controlador contendrá un método para cada una de las operaciones de recurso disponibles. A continuación, puedes registrar una ruta de recurso que apunte al controlador:


```php
use App\Http\Controllers\PhotoController;

Route::resource('photos', PhotoController::class);
```
Esta única declaración de ruta crea múltiples rutas para manejar una variedad de acciones en el recurso. El controlador generado ya tendrá métodos predefinidos para cada una de estas acciones. Recuerda, siempre puedes obtener una visión rápida de las rutas de tu aplicación ejecutando el comando Artisan `route:list`.
Puedes registrar múltiples controladores de recursos a la vez pasando un array al método `resources`:


```php
Route::resources([
    'photos' => PhotoController::class,
    'posts' => PostController::class,
]);
```

<a name="actions-handled-by-resource-controllers"></a>
#### Acciones Manejado por Controladores de Recursos

<div class="overflow-auto">

| Verbo     | URI                    | Acción  | Nombre de Ruta  |
| --------- | ---------------------- | ------- | --------------- |
| GET       | `/photos`              | index   | photos.index    |
| GET       | `/photos/create`       | create  | photos.create   |
| POST      | `/photos`              | store   | photos.store    |
| GET       | `/photos/{photo}`      | show    | photos.show     |
| GET       | `/photos/{photo}/edit` | edit    | photos.edit     |
| PUT/PATCH | `/photos/{photo}`      | update  | photos.update   |
| DELETE    | `/photos/{photo}`      | destroy | photos.destroy   |
</div>

<a name="customizing-missing-model-behavior"></a>
#### Personalizando el Comportamiento de Modelos Faltantes

Típicamente, se generará una respuesta HTTP 404 si no se encuentra un modelo de recurso vinculado implícitamente. Sin embargo, puedes personalizar este comportamiento llamando al método `missing` al definir tu ruta de recurso. El método `missing` acepta una función anónima que se invocará si no se puede encontrar un modelo vinculado implícitamente para cualquiera de las rutas del recurso:


```php
use App\Http\Controllers\PhotoController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redirect;

Route::resource('photos', PhotoController::class)
        ->missing(function (Request $request) {
            return Redirect::route('photos.index');
        });
```

<a name="soft-deleted-models"></a>
#### Modelos Suavemente Eliminados

Típicamente, el enlace de modelo implícito no recuperará modelos que han sido [eliminados suavemente](/docs/%7B%7Bversion%7D%7D/eloquent#soft-deleting), y en su lugar devolverá una respuesta HTTP 404. Sin embargo, puedes instruir al framework para que permita modelos eliminados suavemente invocando el método `withTrashed` al definir tu ruta de recurso:


```php
use App\Http\Controllers\PhotoController;

Route::resource('photos', PhotoController::class)->withTrashed();
```
Llamar a `withTrashed` sin argumentos permitirá modelos eliminados suavemente para las rutas de recursos `show`, `edit` y `update`. Puedes especificar un subconjunto de estas rutas pasando un array al método `withTrashed`:


```php
Route::resource('photos', PhotoController::class)->withTrashed(['show']);
```

<a name="specifying-the-resource-model"></a>
#### Especificando el Modelo de Recurso

Si estás utilizando [route model binding](/docs/%7B%7Bversion%7D%7D/routing#route-model-binding) y deseas que los métodos del controlador de recursos tipen un modelo de instancia, puedes usar la opción `--model` al generar el controlador:


```shell
php artisan make:controller PhotoController --model=Photo --resource

```

<a name="generating-form-requests"></a>
#### Generando Solicitudes de Formulario

Puedes proporcionar la opción `--requests` al generar un controlador de recursos para instruir a Artisan a que genere [clases de solicitud de formulario](/docs/%7B%7Bversion%7D%7D/validation#form-request-validation) para los métodos de almacenamiento y actualización del controlador:


```shell
php artisan make:controller PhotoController --model=Photo --resource --requests

```

<a name="restful-partial-resource-routes"></a>
### Rutas de Recursos Parciales

Al declarar una ruta de recurso, puedes especificar un subconjunto de acciones que el controlador debe manejar en lugar del conjunto completo de acciones predeterminadas:


```php
use App\Http\Controllers\PhotoController;

Route::resource('photos', PhotoController::class)->only([
    'index', 'show'
]);

Route::resource('photos', PhotoController::class)->except([
    'create', 'store', 'update', 'destroy'
]);
```

<a name="api-resource-routes"></a>
#### Rutas de Recursos de API

Al declarar rutas de recursos que serán consumidas por APIs, comúnmente querrás excluir rutas que presentan plantillas HTML como `create` y `edit`. Para mayor comodidad, puedes usar el método `apiResource` para excluir automáticamente estas dos rutas:


```php
use App\Http\Controllers\PhotoController;

Route::apiResource('photos', PhotoController::class);
```
Puedes registrar muchos controladores de recursos de API a la vez pasando un array al método `apiResources`:


```php
use App\Http\Controllers\PhotoController;
use App\Http\Controllers\PostController;

Route::apiResources([
    'photos' => PhotoController::class,
    'posts' => PostController::class,
]);
```
Para generar rápidamente un controlador de recursos de API que no incluya los métodos `create` o `edit`, utiliza el interruptor `--api` al ejecutar el comando `make:controller`:


```shell
php artisan make:controller PhotoController --api

```

<a name="restful-nested-resources"></a>
### Recursos Anidados

A veces es posible que necesites definir rutas a un recurso anidado. Por ejemplo, un recurso de foto puede tener múltiples comentarios que pueden estar anexados a la foto. Para anidar los controladores de recursos, puedes usar la notación de "punto" en tu declaración de ruta:


```php
use App\Http\Controllers\PhotoCommentController;

Route::resource('photos.comments', PhotoCommentController::class);
```
Esta ruta registrará un recurso anidado que puede ser accedido con URIs como las siguientes:


```php
/photos/{photo}/comments/{comment}
```

<a name="scoping-nested-resources"></a>
#### Alcance de Recursos Anidados

La función de [vinculación de modelo implícita](/docs/%7B%7Bversion%7D%7D/routing#implicit-model-binding-scoping) de Laravel puede hacer que el alcance de los vínculos anidados se realice automáticamente, de modo que el modelo hijo resuelto esté confirmado como perteneciente al modelo padre. Al usar el método `scoped` al definir tu recurso anidado, puedes habilitar el alcance automático así como instruir a Laravel sobre qué campo debe utilizarse para recuperar el recurso hijo. Para obtener más información sobre cómo lograr esto, consulta la documentación sobre [el alcance de rutas de recursos](#restful-scoping-resource-routes).

<a name="shallow-nesting"></a>
#### Anidamiento Superficial

A menudo, no es completamente necesario tener tanto los IDs del padre como del hijo dentro de una URI, ya que el ID del hijo ya es un identificador único. Al usar identificadores únicos como claves primarias autoincrementales para identificar tus modelos en segmentos de URI, puedes optar por usar "anidamiento superficial":


```php
use App\Http\Controllers\CommentController;

Route::resource('photos.comments', CommentController::class)->shallow();
```
Esta definición de ruta definirá las siguientes rutas:
<div class="overflow-auto">

| Verbo     | URI                              | Acción  | Nombre de Ruta         |
| --------- | -------------------------------- | ------- | ---------------------- |
| GET       | `/photos/{photo}/comments`       | índice  | photos.comments.index   |
| GET       | `/photos/{photo}/comments/create`| crear   | photos.comments.create  |
| POST      | `/photos/{photo}/comments`       | almacenar| photos.comments.store   |
| GET       | `/comments/{comment}`            | mostrar | comments.show           |
| GET       | `/comments/{comment}/edit`       | editar  | comments.edit           |
| PUT/PATCH | `/comments/{comment}`            | actualizar| comments.update       |
| DELETE    | `/comments/{comment}`            | destruir| comments.destroy        |
</div>

<a name="restful-naming-resource-routes"></a>
### Nombrando Rutas de Recursos

Por defecto, todas las acciones del controlador de recursos tienen un nombre de ruta; sin embargo, puedes sobrescribir estos nombres pasando un array `names` con tus nombres de ruta deseados:


```php
use App\Http\Controllers\PhotoController;

Route::resource('photos', PhotoController::class)->names([
    'create' => 'photos.build'
]);
```

<a name="restful-naming-resource-route-parameters"></a>
### Nombrando Parámetros de Ruta de Recursos

Por defecto, `Route::resource` creará los parámetros de ruta para tus rutas de recurso basándose en la versión "singular" del nombre del recurso. Puedes anular esto fácilmente en una base por recurso utilizando el método `parameters`. El array pasado al método `parameters` debe ser un array asociativo de nombres de recursos y nombres de parámetros:


```php
use App\Http\Controllers\AdminUserController;

Route::resource('users', AdminUserController::class)->parameters([
    'users' => 'admin_user'
]);
```
El ejemplo anterior genera la siguiente URI para la ruta `show` del recurso:


```php
/users/{admin_user}
```

<a name="restful-scoping-resource-routes"></a>
### Limitando Rutas de Recursos

La función de [vinculación implícita con alcance](/docs/%7B%7Bversion%7D%7D/routing#implicit-model-binding-scoping) de Laravel puede limitar automáticamente los vínculos anidados de manera que se confirme que el modelo hijo resuelto pertenece al modelo padre. Al usar el método `scoped` al definir tu recurso anidado, puedes habilitar el alcance automático y además indicarle a Laravel por qué campo se debe recuperar el recurso hijo:


```php
use App\Http\Controllers\PhotoCommentController;

Route::resource('photos.comments', PhotoCommentController::class)->scoped([
    'comment' => 'slug',
]);
```
Esta ruta registrará un recurso anidado con alcance que puede ser accedido con URIs como las siguientes:


```php
/photos/{photo}/comments/{comment:slug}
```
Al usar un enlace implícito con clave personalizada como un parámetro de ruta anidado, Laravel automáticamente limitará la consulta para recuperar el modelo anidado por su padre utilizando convenciones para adivinar el nombre de la relación en el padre. En este caso, se asumirá que el modelo `Photo` tiene una relación llamada `comments` (el plural del nombre del parámetro de ruta) que se puede usar para recuperar el modelo `Comment`.

<a name="restful-localizing-resource-uris"></a>
### Localizando URIs de Recursos

Por defecto, `Route::resource` creará URIs de recursos utilizando verbos en inglés y reglas plurales. Si necesitas localizar los verbos de acción `create` y `edit`, puedes usar el método `Route::resourceVerbs`. Esto se puede hacer al inicio del método `boot` dentro del `App\Providers\AppServiceProvider` de tu aplicación:


```php
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
```
El pluralizador de Laravel admite [varias lenguas diferentes que puedes configurar según tus necesidades](/docs/%7B%7Bversion%7D%7D/localization#pluralization-language). Una vez que se hayan personalizado los verbos y el idioma de pluralización, un registro de ruta de recurso como `Route::resource('publicacion', PublicacionController::class)` producirá las siguientes URI:


```php
/publicacion/crear

/publicacion/{publicaciones}/editar
```

<a name="restful-supplementing-resource-controllers"></a>
### Complementando Controladores de Recursos

Si necesitas añadir rutas adicionales a un controlador de recursos más allá del conjunto de rutas de recursos predeterminadas, debes definir esas rutas antes de tu llamada al método `Route::resource`; de lo contrario, las rutas definidas por el método `resource` pueden tomar precedencia sobre tus rutas suplementarias de manera no intencionada:


```php
use App\Http\Controller\PhotoController;

Route::get('/photos/popular', [PhotoController::class, 'popular']);
Route::resource('photos', PhotoController::class);
```
> [!NOTA]
Recuerda mantener tus controladores enfocados. Si te encuentras necesitando rutinariamente métodos fuera del conjunto típico de acciones de recursos, considera dividir tu controlador en dos controladores más pequeños.

<a name="singleton-resource-controllers"></a>
### Controladores de Recursos Singleton

A veces, tu aplicación tendrá recursos que pueden tener solo una instancia. Por ejemplo, el "perfil" de un usuario se puede editar o actualizar, pero un usuario no puede tener más de un "perfil". Del mismo modo, una imagen puede tener un solo "thumbnail". Estos recursos se llaman "recursos singleton", lo que significa que puede existir una y solo una instancia del recurso. En estos escenarios, puedes registrar un controlador de recursos "singleton":


```php
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::singleton('profile', ProfileController::class);

```
La definición de recurso singleton anterior registrará las siguientes rutas. Como puedes ver, las rutas de "creación" no se registran para recursos singleton, y las rutas registradas no aceptan un identificador ya que solo puede existir una instancia del recurso:
<div class="overflow-auto">

| Verbo     | URI              | Acción | Nombre de Ruta  |
| --------- | ---------------- | ------ | --------------- |
| GET       | `/profile`       | mostrar| profile.show    |
| GET       | `/profile/edit`  | editar | profile.edit    |
| PUT/PATCH | `/profile`       | actualizar | profile.update |
</div>
Los recursos singleton también pueden estar anidados dentro de un recurso estándar:


```php
Route::singleton('photos.thumbnail', ThumbnailController::class);

```
En este ejemplo, el recurso `photos` recibiría todas las [rutas de recursos estándar](#actions-handled-by-resource-controllers); sin embargo, el recurso `thumbnail` sería un recurso singleton con las siguientes rutas:
<div class="overflow-auto">

| Verbo      | URI                               | Acción | Nombre de la Ruta       |
| ---------- | --------------------------------- | ------ | ----------------------- |
| GET        | `/photos/{photo}/thumbnail`       | mostrar| photos.thumbnail.show   |
| GET        | `/photos/{photo}/thumbnail/edit`  | editar | photos.thumbnail.edit   |
| PUT/PATCH  | `/photos/{photo}/thumbnail`       | actualizar | photos.thumbnail.update |
</div>

<a name="creatable-singleton-resources"></a>
#### Recursos Singleton Creables

Ocasionalmente, es posible que desees definir rutas de creación y almacenamiento para un recurso singleton. Para lograr esto, puedes invocar el método `creatable` al registrar la ruta del recurso singleton:


```php
Route::singleton('photos.thumbnail', ThumbnailController::class)->creatable();

```
En este ejemplo, se registrarán las siguientes rutas. Como puedes ver, también se registrará una ruta `DELETE` para recursos singleton creatables:
<div class="overflow-auto">

| Verbo     | URI                                 | Acción  | Nombre de Ruta            |
|-----------|-------------------------------------|---------|---------------------------|
| GET       | `/photos/{photo}/thumbnail/create`  | crear   | photos.thumbnail.create    |
| POST      | `/photos/{photo}/thumbnail`         | almacenar| photos.thumbnail.store     |
| GET       | `/photos/{photo}/thumbnail`         | mostrar  | photos.thumbnail.show      |
| GET       | `/photos/{photo}/thumbnail/edit`    | editar   | photos.thumbnail.edit      |
| PUT/PATCH | `/photos/{photo}/thumbnail`         | actualizar| photos.thumbnail.update    |
| DELETE    | `/photos/{photo}/thumbnail`         | destruir | photos.thumbnail.destroy   |
</div>
Si deseas que Laravel registre la ruta `DELETE` para un recurso singleton pero no registre las rutas de creación o almacenamiento, puedes utilizar el método `destroyable`:


```php
Route::singleton(...)->destroyable();

```

<a name="api-singleton-resources"></a>
#### Recursos de Singleton de API

El método `apiSingleton` se puede utilizar para registrar un recurso singleton que será manipulado a través de una API, lo que hace que las rutas `create` y `edit` sean innecesarias:


```php
Route::apiSingleton('profile', ProfileController::class);

```
Por supuesto, los recursos singleton de la API también pueden ser `creatable`, lo que registrará las rutas `store` y `destroy` para el recurso:


```php
Route::apiSingleton('photos.thumbnail', ProfileController::class)->creatable();

```

<a name="dependency-injection-and-controllers"></a>
## Inyección de Dependencias y Controladores


<a name="constructor-injection"></a>
#### Inyección de Constructor

El [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel se utiliza para resolver todos los controladores de Laravel. Como resultado, puedes indicar cualquier dependencia que tu controlador pueda necesitar en su constructor. Las dependencias declaradas se resolverán automáticamente e inyectarán en la instancia del controlador:


```php
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
```

<a name="method-injection"></a>
#### Inyección de Métodos

Además de la inyección por constructor, también puedes indicar dependencias en los métodos de tu controlador. Un caso de uso común para la inyección de métodos es inyectar la instancia de `Illuminate\Http\Request` en los métodos de tu controlador:


```php
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
```
Si el método de tu controlador también está esperando entrada de un parámetro de ruta, lista tus argumentos de ruta después de tus otras dependencias. Por ejemplo, si tu ruta está definida de la siguiente manera:


```php
use App\Http\Controllers\UserController;

Route::put('/user/{id}', [UserController::class, 'update']);
```
Puedes seguir usando hint de tipo en `Illuminate\Http\Request` y acceder a tu parámetro `id` definiendo tu método de controlador de la siguiente manera:


```php
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