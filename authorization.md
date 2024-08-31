# Autorización

- [Introducción](#introduction)
- [Gates](#gates)
  - [Escribiendo Gates](#writing-gates)
  - [Autorizando Acciones](#authorizing-actions-via-gates)
  - [Respuestas de Gate](#gate-responses)
  - [Interceptando Comprobaciones de Gate](#intercepting-gate-checks)
  - [Autorización en Línea](#inline-authorization)
- [Creando Políticas](#creating-policies)
  - [Generando Políticas](#generating-policies)
  - [Registrando Políticas](#registering-policies)
- [Escribiendo Políticas](#writing-policies)
  - [Métodos de Política](#policy-methods)
  - [Respuestas de Política](#policy-responses)
  - [Métodos Sin Modelos](#methods-without-models)
  - [Usuarios Invitados](#guest-users)
  - [Filtros de Política](#policy-filters)
- [Autorizando Acciones Usando Políticas](#authorizing-actions-using-policies)
  - [A través del Modelo de Usuario](#via-the-user-model)
  - [A través de la Facade de Gate](#via-the-gate-facade)
  - [A través de Middleware](#via-middleware)
  - [A través de Plantillas Blade](#via-blade-templates)
  - [Suministrando Contexto Adicional](#supplying-additional-context)
- [Autorización e Inertia](#authorization-and-inertia)

<a name="introduction"></a>
## Introducción

Además de proporcionar servicios de [autenticación](/docs/%7B%7Bversion%7D%7D/authentication) integrados, Laravel también ofrece una forma sencilla de autorizar acciones de usuario contra un recurso dado. Por ejemplo, aunque un usuario esté autenticado, es posible que no esté autorizado para actualizar o eliminar ciertos modelos Eloquent o registros de base de datos gestionados por su aplicación. Las características de autorización de Laravel proporcionan una manera fácil y organizada de gestionar este tipo de verificaciones de autorización.
Laravel ofrece dos formas principales de autorizar acciones: [gates](#gates) y [policies](#creating-policies). Piensa en los gates y policies como en rutas y controladores. Los gates proporcionan un enfoque simple basado en funciones anónimas para la autorización, mientras que los policies, al igual que los controladores, agrupan la lógica en torno a un modelo o recurso en particular. En esta documentación, exploraremos primero los gates y luego examinaremos los policies.
No necesitas elegir entre utilizar exclusivamente gates o exclusivamente policies al construir una aplicación. La mayoría de las aplicaciones probablemente contengan alguna mezcla de gates y policies, ¡y eso está perfectamente bien! Los gates son más aplicables a acciones que no están relacionadas con ningún modelo o recurso, como ver un panel de administración. En contraste, las policies deben usarse cuando deseas autorizar una acción para un modelo o recurso en particular.

<a name="gates"></a>
## Puertas


<a name="writing-gates"></a>
### Escribiendo Gates

> [!WARNING]
Las Gates son una excelente manera de aprender lo básico de las características de autorización de Laravel; sin embargo, al construir aplicaciones robustas en Laravel, deberías considerar usar [políticas](#creating-policies) para organizar tus reglas de autorización.
Las puertas son simplemente `funciones anónimas` que determinan si un usuario está autorizado para realizar una acción dada. Típicamente, las puertas se definen dentro del método `boot` de la clase `App\Providers\AppServiceProvider` utilizando la fachada `Gate`. Las puertas siempre reciben una instancia de usuario como su primer argumento y pueden opcionalmente recibir argumentos adicionales, como un modelo Eloquent relevante.
En este ejemplo, definiremos un gate para determinar si un usuario puede actualizar un modelo `App\Models\Post` dado. El gate logrará esto comparando el `id` del usuario con el `user_id` del usuario que creó la publicación:


```php
use App\Models\Post;
use App\Models\User;
use Illuminate\Support\Facades\Gate;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Gate::define('update-post', function (User $user, Post $post) {
        return $user->id === $post->user_id;
    });
}
```
Al igual que los controladores, los gates también se pueden definir utilizando un array de callbacks de clase:


```php
use App\Policies\PostPolicy;
use Illuminate\Support\Facades\Gate;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Gate::define('update-post', [PostPolicy::class, 'update']);
}
```

<a name="authorizing-actions-via-gates"></a>
### Autorizando Acciones

Para autorizar una acción utilizando puertas, deberías usar los métodos `allows` o `denies` proporcionados por la fachada `Gate`. Ten en cuenta que no es necesario pasar el usuario autenticado actualmente a estos métodos. Laravel se encargará automáticamente de pasar el usuario a la `función anónima` de la puerta. Es típico llamar a los métodos de autorización de la puerta dentro de los controladores de tu aplicación antes de realizar una acción que requiere autorización:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class PostController extends Controller
{
    /**
     * Update the given post.
     */
    public function update(Request $request, Post $post): RedirectResponse
    {
        if (! Gate::allows('update-post', $post)) {
            abort(403);
        }

        // Update the post...

        return redirect('/posts');
    }
}
```
Si deseas determinar si un usuario que no sea el usuario autenticado actualmente está autorizado para realizar una acción, puedes usar el método `forUser` en la fachada `Gate`:


```php
if (Gate::forUser($user)->allows('update-post', $post)) {
    // The user can update the post...
}

if (Gate::forUser($user)->denies('update-post', $post)) {
    // The user can't update the post...
}
```
Puedes autorizar múltiples acciones a la vez utilizando los métodos `any` o `none`:


```php
if (Gate::any(['update-post', 'delete-post'], $post)) {
    // The user can update or delete the post...
}

if (Gate::none(['update-post', 'delete-post'], $post)) {
    // The user can't update or delete the post...
}
```

<a name="authorizing-or-throwing-exceptions"></a>
#### Autorizando o Lanzando Excepciones

Si deseas intentar autorizar una acción y lanzar automáticamente una `Illuminate\Auth\Access\AuthorizationException` si el usuario no tiene permitido realizar la acción dada, puedes usar el método `authorize` de la fachada `Gate`. Las instancias de `AuthorizationException` son automáticamente convertidas a una respuesta HTTP 403 por Laravel:


```php
Gate::authorize('update-post', $post);

// The action is authorized...
```

<a name="gates-supplying-additional-context"></a>
#### Proporcionando Contexto Adicional

Los métodos de la puerta para autorizar habilidades (`allows`, `denies`, `check`, `any`, `none`, `authorize`, `can`, `cannot`) y las [directivas Blade de autorización](#via-blade-templates) (`@can`, `@cannot`, `@canany`) pueden recibir un array como su segundo argumento. Estos elementos del array se pasan como parámetros a la `función anónima` de la puerta, y se pueden usar para contexto adicional al tomar decisiones de autorización:


```php
use App\Models\Category;
use App\Models\User;
use Illuminate\Support\Facades\Gate;

Gate::define('create-post', function (User $user, Category $category, bool $pinned) {
    if (! $user->canPublishToGroup($category->group)) {
        return false;
    } elseif ($pinned && ! $user->canPinPosts()) {
        return false;
    }

    return true;
});

if (Gate::check('create-post', [$category, $pinned])) {
    // The user can create the post...
}
```

<a name="gate-responses"></a>
### Respuestas de Puerta

Hasta ahora, solo hemos examinado puertas que devuelven valores booleanos simples. Sin embargo, a veces es posible que desees devolver una respuesta más detallada, incluyendo un mensaje de error. Para hacerlo, puedes devolver una `Illuminate\Auth\Access\Response` desde tu puerta:


```php
use App\Models\User;
use Illuminate\Auth\Access\Response;
use Illuminate\Support\Facades\Gate;

Gate::define('edit-settings', function (User $user) {
    return $user->isAdmin
                ? Response::allow()
                : Response::deny('You must be an administrator.');
});
```
Incluso cuando devuelvas una respuesta de autorización desde tu gate, el método `Gate::allows` seguirá devolviendo un simple valor booleano; sin embargo, puedes usar el método `Gate::inspect` para obtener la respuesta de autorización completa devuelta por el gate:


```php
$response = Gate::inspect('edit-settings');

if ($response->allowed()) {
    // The action is authorized...
} else {
    echo $response->message();
}
```


```php
Gate::authorize('edit-settings');

// The action is authorized...
```

<a name="customizing-gate-response-status"></a>
#### Personalizando el Estado de Respuesta HTTP

Cuando se deniega una acción a través de un Gate, se devuelve una respuesta HTTP `403`; sin embargo, a veces puede ser útil devolver un código de estado HTTP alternativo. Puedes personalizar el código de estado HTTP devuelto para una verificación de autorización fallida utilizando el constructor estático `denyWithStatus` en la clase `Illuminate\Auth\Access\Response`:


```php
use App\Models\User;
use Illuminate\Auth\Access\Response;
use Illuminate\Support\Facades\Gate;

Gate::define('edit-settings', function (User $user) {
    return $user->isAdmin
                ? Response::allow()
                : Response::denyWithStatus(404);
});
```


```php
use App\Models\User;
use Illuminate\Auth\Access\Response;
use Illuminate\Support\Facades\Gate;

Gate::define('edit-settings', function (User $user) {
    return $user->isAdmin
                ? Response::allow()
                : Response::denyAsNotFound();
});
```

<a name="intercepting-gate-checks"></a>
### Interceptando Comprobaciones de Puerta

A veces, es posible que desees otorgar todas las habilidades a un usuario específico. Puedes usar el método `before` para definir una función anónima que se ejecute antes de todas las demás verificaciones de autorización:


```php
use App\Models\User;
use Illuminate\Support\Facades\Gate;

Gate::before(function (User $user, string $ability) {
    if ($user->isAdministrator()) {
        return true;
    }
});
```
Si la `función anónima` `before` devuelve un resultado no nulo, ese resultado se considerará el resultado de la verificación de autorización.
Puedes usar el método `after` para definir una función anónima que se ejecutará después de todas las demás verificaciones de autorización:


```php
use App\Models\User;

Gate::after(function (User $user, string $ability, bool|null $result, mixed $arguments) {
    if ($user->isAdministrator()) {
        return true;
    }
});
```
Similar al método `before`, si el resultado de la `after` función anónima es no nulo, ese resultado se considerará el resultado de la verificación de autorización.

<a name="inline-authorization"></a>
### Autorización en línea

Ocasionalmente, es posible que desees determinar si el usuario autenticado actualmente está autorizado para realizar una acción dada sin escribir una puerta dedicada que corresponda a la acción. Laravel te permite realizar este tipo de verificaciones de autorización "en línea" a través de los métodos `Gate::allowIf` y `Gate::denyIf`. La autorización en línea no ejecuta ningún gancho de autorización definidos como ["before" o "after"](#intercepting-gate-checks):


```php
use App\Models\User;
use Illuminate\Support\Facades\Gate;

Gate::allowIf(fn (User $user) => $user->isAdministrator());

Gate::denyIf(fn (User $user) => $user->banned());

```
Si la acción no está autorizada o si ningún usuario está actualmente autenticado, Laravel lanzará automáticamente una excepción `Illuminate\Auth\Access\AuthorizationException`. Las instancias de `AuthorizationException` son convertidas automáticamente en una respuesta HTTP 403 por el manejador de excepciones de Laravel.

<a name="creating-policies"></a>
## Creando Políticas


<a name="generating-policies"></a>
### Generando Políticas

Las políticas son clases que organizan la lógica de autorización en torno a un modelo o recurso particular. Por ejemplo, si tu aplicación es un blog, es posible que tengas un modelo `App\Models\Post` y una `App\Policies\PostPolicy` correspondiente para autorizar acciones de usuario como crear o actualizar publicaciones.
Puedes generar una política utilizando el comando Artisan `make:policy`. La política generada se colocará en el directorio `app/Policies`. Si este directorio no existe en tu aplicación, Laravel lo creará por ti:


```shell
php artisan make:policy PostPolicy

```
El comando `make:policy` generará una clase de política vacía. Si deseas generar una clase con métodos de política de ejemplo relacionados con la visualización, creación, actualización y eliminación del recurso, puedes proporcionar una opción `--model` al ejecutar el comando:


```shell
php artisan make:policy PostPolicy --model=Post

```

<a name="registering-policies"></a>
### Registrando Políticas


<a name="policy-discovery"></a>
#### Descubrimiento de Políticas

Por defecto, Laravel descubre automáticamente las políticas siempre que el modelo y la política sigan las convenciones de nomenclatura estándar de Laravel. Específicamente, las políticas deben estar en un directorio `Policies` en o por encima del directorio que contiene tus modelos. Así que, por ejemplo, los modelos pueden colocarse en el directorio `app/Models` mientras que las políticas pueden colocarse en el directorio `app/Policies`. En esta situación, Laravel buscará políticas en `app/Models/Policies` y luego en `app/Policies`. Además, el nombre de la política debe coincidir con el nombre del modelo y tener un sufijo `Policy`. Así que, un modelo `User` correspondería a una clase de política `UserPolicy`.
Si deseas definir tu propia lógica de descubrimiento de políticas, puedes registrar un callback de descubrimiento de políticas personalizado utilizando el método `Gate::guessPolicyNamesUsing`. Típicamente, este método debería ser llamado desde el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Gate;

Gate::guessPolicyNamesUsing(function (string $modelClass) {
    // Return the name of the policy class for the given model...
});
```

<a name="manually-registering-policies"></a>
#### Registrando Políticas Manualmente

Usando la facade `Gate`, puedes registrar manualmente políticas y sus modelos correspondientes dentro del método `boot` del `AppServiceProvider` de tu aplicación:


```php
use App\Models\Order;
use App\Policies\OrderPolicy;
use Illuminate\Support\Facades\Gate;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Gate::policy(Order::class, OrderPolicy::class);
}
```

<a name="writing-policies"></a>
## Escritura de Políticas


<a name="policy-methods"></a>
### Métodos de Políticas

Una vez que la clase de política ha sido registrada, puedes añadir métodos para cada acción que autoriza. Por ejemplo, definamos un método `update` en nuestra `PostPolicy` que determina si un `App\Models\User` dado puede actualizar una instancia dada de `App\Models\Post`.
El método `update` recibirá una instancia de `User` y una instancia de `Post` como sus argumentos, y debe devolver `true` o `false` indicando si el usuario está autorizado para actualizar el `Post` dado. Así que, en este ejemplo, verificaremos que el `id` del usuario coincida con el `user_id` en la publicación:


```php
<?php

namespace App\Policies;

use App\Models\Post;
use App\Models\User;

class PostPolicy
{
    /**
     * Determine if the given post can be updated by the user.
     */
    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }
}
```
Puedes continuar definiendo métodos adicionales en la política según sea necesario para las diversas acciones que autoriza. Por ejemplo, podrías definir métodos `view` o `delete` para autorizar varias acciones relacionadas con `Post`, pero recuerda que puedes darle a los métodos de tu política cualquier nombre que desees.
Si utilizaste la opción `--model` al generar tu política a través de la consola de Artisan, ya contendrá métodos para las acciones `viewAny`, `view`, `create`, `update`, `delete`, `restore` y `forceDelete`.
> [!NOTE]
Todas las políticas se resuelven a través del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel, lo que te permite indicar cualquier dependencia necesaria en el constructor de la política para que se inyecten automáticamente.

<a name="policy-responses"></a>
### Respuestas de Política

Hasta ahora, solo hemos examinado métodos de políticas que devuelven simples valores booleanos. Sin embargo, a veces es posible que desees devolver una respuesta más detallada, incluyendo un mensaje de error. Para hacerlo, puedes devolver una instancia de `Illuminate\Auth\Access\Response` desde tu método de política:


```php
use App\Models\Post;
use App\Models\User;
use Illuminate\Auth\Access\Response;

/**
 * Determine if the given post can be updated by the user.
 */
public function update(User $user, Post $post): Response
{
    return $user->id === $post->user_id
                ? Response::allow()
                : Response::deny('You do not own this post.');
}
```
Al devolver una respuesta de autorización de tu política, el método `Gate::allows` seguirá devolviendo un valor booleano simple; sin embargo, puedes usar el método `Gate::inspect` para obtener la respuesta de autorización completa devuelta por el gate:


```php
use Illuminate\Support\Facades\Gate;

$response = Gate::inspect('update', $post);

if ($response->allowed()) {
    // The action is authorized...
} else {
    echo $response->message();
}
```
Al utilizar el método `Gate::authorize`, que lanza una `AuthorizationException` si la acción no está autorizada, el mensaje de error proporcionado por la respuesta de autorización se propagará a la respuesta HTTP:


```php
Gate::authorize('update', $post);

// The action is authorized...
```

<a name="customizing-policy-response-status"></a>
#### Personalizando el estado de respuesta HTTP

Cuando se deniega una acción a través de un método de política, se devuelve una respuesta HTTP `403`; sin embargo, a veces puede ser útil devolver un código de estado HTTP alternativo. Puedes personalizar el código de estado HTTP devuelto para un chequeo de autorización fallido utilizando el constructor estático `denyWithStatus` en la clase `Illuminate\Auth\Access\Response`:


```php
use App\Models\Post;
use App\Models\User;
use Illuminate\Auth\Access\Response;

/**
 * Determine if the given post can be updated by the user.
 */
public function update(User $user, Post $post): Response
{
    return $user->id === $post->user_id
                ? Response::allow()
                : Response::denyWithStatus(404);
}
```
Debido a que ocultar recursos a través de una respuesta `404` es un patrón tan común en aplicaciones web, se ofrece el método `denyAsNotFound` por conveniencia:


```php
use App\Models\Post;
use App\Models\User;
use Illuminate\Auth\Access\Response;

/**
 * Determine if the given post can be updated by the user.
 */
public function update(User $user, Post $post): Response
{
    return $user->id === $post->user_id
                ? Response::allow()
                : Response::denyAsNotFound();
}
```

<a name="methods-without-models"></a>
### Métodos Sin Modelos

Algunos métodos de política solo reciben una instancia del usuario actualmente autenticado. Esta situación es más común al autorizar acciones `create`. Por ejemplo, si estás creando un blog, es posible que desees determinar si un usuario está autorizado para crear cualquier publicación. En estas situaciones, tu método de política solo debe esperar recibir una instancia de usuario:


```php
/**
 * Determine if the given user can create posts.
 */
public function create(User $user): bool
{
    return $user->role == 'writer';
}
```

<a name="guest-users"></a>
### Usuarios Invitados

Por defecto, todas las puertas de acceso y políticas devuelven automáticamente `false` si la solicitud HTTP entrante no fue iniciada por un usuario autenticado. Sin embargo, puedes permitir que estas verificaciones de autorización pasen a través de tus puertas de acceso y políticas declarando un tipo de indicación "opcional" o suministrando un valor predeterminado `null` para la definición del argumento de usuario:


```php
<?php

namespace App\Policies;

use App\Models\Post;
use App\Models\User;

class PostPolicy
{
    /**
     * Determine if the given post can be updated by the user.
     */
    public function update(?User $user, Post $post): bool
    {
        return $user?->id === $post->user_id;
    }
}
```

<a name="policy-filters"></a>
### Filtros de Política

Para ciertos usuarios, es posible que desees autorizar todas las acciones dentro de una política dada. Para lograr esto, define un método `before` en la política. El método `before` se ejecutará antes que cualquier otro método en la política, dándote la oportunidad de autorizar la acción antes de que se llame al método de política destinado. Esta función se utiliza más comúnmente para autorizar a los administradores de la aplicación a realizar cualquier acción:


```php
use App\Models\User;

/**
 * Perform pre-authorization checks.
 */
public function before(User $user, string $ability): bool|null
{
    if ($user->isAdministrator()) {
        return true;
    }

    return null;
}
```
Si deseas denegar todas las verificaciones de autorización para un tipo particular de usuario, puedes devolver `false` desde el método `before`. Si se devuelve `null`, la verificación de autorización pasará al método de política.
> [!WARNING]
El método `before` de una clase de política no se llamará si la clase no contiene un método con un nombre que coincida con el nombre de la habilidad que se está verificando.

<a name="authorizing-actions-using-policies"></a>
## Autorizando Acciones Usando Políticas


<a name="via-the-user-model"></a>
### A través del modelo de usuario

El modelo `App\Models\User` que se incluye con tu aplicación Laravel incluye dos métodos útiles para autorizar acciones: `can` y `cannot`. Los métodos `can` y `cannot` reciben el nombre de la acción que deseas autorizar y el modelo relevante. Por ejemplo, determinemos si un usuario está autorizado para actualizar un modelo `App\Models\Post` dado. Típicamente, esto se hará dentro de un método del controlador:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PostController extends Controller
{
    /**
     * Update the given post.
     */
    public function update(Request $request, Post $post): RedirectResponse
    {
        if ($request->user()->cannot('update', $post)) {
            abort(403);
        }

        // Update the post...

        return redirect('/posts');
    }
}
```
Si se [registra una política](#registering-policies) para el modelo dado, el método `can` llamará automáticamente a la política apropiada y devolverá el resultado booleano. Si no se registra ninguna política para el modelo, el método `can` intentará llamar a la Puerta basada en funciones anónimas que coincida con el nombre de acción dado.

<a name="user-model-actions-that-dont-require-models"></a>
Recuerda que algunas acciones pueden corresponder a métodos de política como `create` que no requieren una instancia de modelo. En estas situaciones, puedes pasar un nombre de clase al método `can`. El nombre de clase se utilizará para determinar qué política usar al autorizar la acción:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class PostController extends Controller
{
    /**
     * Create a post.
     */
    public function store(Request $request): RedirectResponse
    {
        if ($request->user()->cannot('create', Post::class)) {
            abort(403);
        }

        // Create the post...

        return redirect('/posts');
    }
}
```

<a name="via-the-gate-facade"></a>
### A través de la Facade `Gate`

Además de los métodos útiles proporcionados al modelo `App\Models\User`, siempre puedes autorizar acciones a través del método `authorize` de la fachada `Gate`.
Al igual que el método `can`, este método acepta el nombre de la acción que deseas autorizar y el modelo relevante. Si la acción no está autorizada, el método `authorize` lanzará una excepción `Illuminate\Auth\Access\AuthorizationException`, que el manejador de excepciones de Laravel convertirá automáticamente en una respuesta HTTP con un código de estado 403:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class PostController extends Controller
{
    /**
     * Update the given blog post.
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function update(Request $request, Post $post): RedirectResponse
    {
        Gate::authorize('update', $post);

        // The current user can update the blog post...

        return redirect('/posts');
    }
}
```

<a name="controller-actions-that-dont-require-models"></a>
Como se ha discutido anteriormente, algunos métodos de política como `create` no requieren una instancia de modelo. En estas situaciones, debes pasar un nombre de clase al método `authorize`. El nombre de la clase se utilizará para determinar qué política usar al autorizar la acción:


```php
use App\Models\Post;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

/**
 * Create a new blog post.
 *
 * @throws \Illuminate\Auth\Access\AuthorizationException
 */
public function create(Request $request): RedirectResponse
{
    Gate::authorize('create', Post::class);

    // The current user can create blog posts...

    return redirect('/posts');
}
```

<a name="via-middleware"></a>
### A través de Middleware

Laravel incluye un middleware que puede autorizar acciones antes de que la solicitud entrante llegue incluso a tus rutas o controladores. Por defecto, el middleware `Illuminate\Auth\Middleware\Authorize` puede estar adjunto a una ruta utilizando el alias de middleware `can` [middleware alias](/docs/%7B%7Bversion%7D%7D/middleware#middleware-aliases), que es registrado automáticamente por Laravel. Vamos a explorar un ejemplo de cómo usar el middleware `can` para autorizar que un usuario pueda actualizar una publicación:


```php
use App\Models\Post;

Route::put('/post/{post}', function (Post $post) {
    // The current user may update the post...
})->middleware('can:update,post');
```
En este ejemplo, estamos pasando al middleware `can` dos argumentos. El primero es el nombre de la acción que deseamos autorizar y el segundo es el parámetro de ruta que deseamos pasar al método de la política. En este caso, dado que estamos usando [vinculación de modelo implícita](/docs/%7B%7Bversion%7D%7D/routing#implicit-binding), se pasará un modelo `App\Models\Post` al método de la política. Si el usuario no está autorizado para realizar la acción dada, el middleware devolverá una respuesta HTTP con un código de estado 403.
Para mayor comodidad, también puedes adjuntar el middleware `can` a tu ruta utilizando el método `can`:


```php
use App\Models\Post;

Route::put('/post/{post}', function (Post $post) {
    // The current user may update the post...
})->can('update', 'post');
```

<a name="middleware-actions-that-dont-require-models"></a>
Nuevamente, algunos métodos de política como `create` no requieren una instancia del modelo. En estas situaciones, puedes pasar un nombre de clase al middleware. El nombre de la clase se utilizará para determinar qué política usar al autorizar la acción:


```php
Route::post('/post', function () {
    // The current user may create posts...
})->middleware('can:create,App\Models\Post');
```
Especificar el nombre completo de la clase dentro de una definición de middleware en una cadena puede volverse engorroso. Por esa razón, puedes optar por adjuntar el middleware `can` a tu ruta utilizando el método `can`:


```php
use App\Models\Post;

Route::post('/post', function () {
    // The current user may create posts...
})->can('create', Post::class);
```

<a name="via-blade-templates"></a>
### A través de plantillas Blade

Al escribir plantillas Blade, es posible que desees mostrar una porción de la página solo si el usuario está autorizado a realizar una acción dada. Por ejemplo, es posible que desees mostrar un formulario de actualización para una publicación de blog solo si el usuario puede actualizar realmente la publicación. En esta situación, puedes usar las directivas `@can` y `@cannot`:


```blade
@can('update', $post)
    <!-- The current user can update the post... -->
@elsecan('create', App\Models\Post::class)
    <!-- The current user can create new posts... -->
@else
    <!-- ... -->
@endcan

@cannot('update', $post)
    <!-- The current user cannot update the post... -->
@elsecannot('create', App\Models\Post::class)
    <!-- The current user cannot create new posts... -->
@endcannot

```
Estas directivas son atajos convenientes para escribir declaraciones `@if` y `@unless`. Las declaraciones `@can` y `@cannot` arriba son equivalentes a las siguientes declaraciones:


```blade
@if (Auth::user()->can('update', $post))
    <!-- The current user can update the post... -->
@endif

@unless (Auth::user()->can('update', $post))
    <!-- The current user cannot update the post... -->
@endunless

```
También puedes determinar si un usuario está autorizado para realizar cualquier acción de un array dado de acciones. Para lograr esto, utiliza la directiva `@canany`:


```blade
@canany(['update', 'view', 'delete'], $post)
    <!-- The current user can update, view, or delete the post... -->
@elsecanany(['create'], \App\Models\Post::class)
    <!-- The current user can create a post... -->
@endcanany

```

<a name="blade-actions-that-dont-require-models"></a>
#### Acciones que no requieren modelos

Como la mayoría de los otros métodos de autorización, puedes pasar un nombre de clase a los directivos `@can` y `@cannot` si la acción no requiere una instancia del modelo:


```blade
@can('create', App\Models\Post::class)
    <!-- The current user can create posts... -->
@endcan

@cannot('create', App\Models\Post::class)
    <!-- The current user can't create posts... -->
@endcannot

```

<a name="supplying-additional-context"></a>
### Proporcionando Contexto Adicional

Al autorizar acciones utilizando políticas, puedes pasar un array como segundo argumento a las diversas funciones y ayudantes de autorización. El primer elemento del array se utilizará para determinar qué política debe invocarse, mientras que el resto de los elementos del array se pasan como parámetros al método de la política y se pueden usar para contexto adicional al tomar decisiones de autorización. Por ejemplo, considera la siguiente definición del método `PostPolicy` que contiene un parámetro adicional `$category`:


```php
/**
 * Determine if the given post can be updated by the user.
 */
public function update(User $user, Post $post, int $category): bool
{
    return $user->id === $post->user_id &&
           $user->canUpdateCategory($category);
}
```
Al intentar determinar si el usuario autenticado puede actualizar una publicación dada, podemos invocar este método de política de la siguiente manera:


```php
/**
 * Update the given blog post.
 *
 * @throws \Illuminate\Auth\Access\AuthorizationException
 */
public function update(Request $request, Post $post): RedirectResponse
{
    Gate::authorize('update', [$post, $request->category]);

    // The current user can update the blog post...

    return redirect('/posts');
}
```

<a name="authorization-and-inertia"></a>
## Autorización y Inertia

Aunque la autorización siempre debe manejarse en el servidor, a menudo puede ser conveniente proporcionar a tu aplicación frontend datos de autorización para renderizar correctamente la UI de tu aplicación. Laravel no define una convención requerida para exponer información de autorización a un frontend impulsado por Inertia.
Sin embargo, si estás utilizando uno de los [kits de inicio](/docs/%7B%7Bversion%7D%7D/starter-kits) basados en Inertia de Laravel, tu aplicación ya contiene un middleware `HandleInertiaRequests`. Dentro del método `share` de este middleware, puedes devolver datos compartidos que se proporcionarán a todas las páginas de Inertia en tu aplicación. Estos datos compartidos pueden servir como un lugar conveniente para definir la información de autorización del usuario:


```php
<?php

namespace App\Http\Middleware;

use App\Models\Post;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    // ...

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request)
    {
        return [
            ...parent::share($request),
            'auth' => [
                'user' => $request->user(),
                'permissions' => [
                    'post' => [
                        'create' => $request->user()->can('create', Post::class),
                    ],
                ],
            ],
        ];
    }
}

```