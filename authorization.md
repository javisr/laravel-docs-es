# Autorización

- [Introducción](#introduction)
- [Gates](#gates)
  - [Escritura de Gates](#writing-gates)
  - [Autorización de acciones](#authorizing-actions-via-gates)
  - [Gates con Respuestas](#gate-responses)
  - [Interceptación de comprobaciones Gate](#intercepting-gate-checks)
  - [Autorización Inline](#inline-authorization)
- [Creación de policies](#creating-policies)
  - [Generación de policies](#generating-policies)
  - [Registro de policies](#registering-policies)
- [Escritura de policies](#writing-policies)
    - [Métodos de una Policy](#policy-methods)
    - [Policies con Respuestas](#policy-responses)
    - [Métodos sin modelos](#methods-without-models)
    - [Usuarios invitados](#guest-users)
    - [Filtros](#policy-filters)
- [Autorización de acciones mediante policies](#authorizing-actions-using-policies)
  - [A través del modelo de usuario](#via-the-user-model)
  - [Mediante Controller Helpers](#via-controller-helpers)
  - [Mediante middleware](#via-middleware)
  - [Mediante plantillas Blade](#via-blade-templates)
  - [Suministrando Contexto Adicional](#supplying-additional-context)

<a name="introduction"></a>
## Introducción

Además de proporcionar servicios de [autenticación](/docs/{{version}}/authentication) incorporados, Laravel también proporciona una forma sencilla de autorizar las acciones del usuario contra un recurso determinado. Por ejemplo, aunque un usuario esté autenticado, puede que no esté autorizado a actualizar o borrar ciertos modelos de Eloquent o registros de bases de datos gestionados por tu aplicación. Las características de autorización de Laravel proporcionan una forma fácil y organizada de gestionar este tipo de comprobaciones de autorización.

Laravel proporciona dos formas principales de autorizar acciones: [gates](#gates) y [policies](#creating-policies). Piensa en las gates y las policies como rutas y controladores. Las gates proporcionan un enfoque simple, con una autorización basada en un closure, mientras que policies, como los controladores, agrupan la lógica en torno a un modelo o recurso en particular. En esta sección, exploraremos primero las `gates` y luego examinaremos las `policies`.

A la hora de crear una aplicación, no es necesario elegir entre el uso exclusivo de gates o el uso exclusivo de policies. Lo más probable es que la mayoría de las aplicaciones contengan una mezcla de gates y policies, ¡y eso está perfectamente bien! Las gates son más aplicables a acciones que no están relacionadas con ningún modelo o recurso, como ver un panel de control del administrador. Por el contrario, las policies deben utilizarse cuando se desea autorizar una acción para un modelo o recurso en particular.

<a name="gates"></a>
## Gates

<a name="writing-gates"></a>
### Escritura de Gates

> **Advertencia**  
> Las gates son una buena forma de aprender los fundamentos de autorización de Laravel, sin embargo, cuando se esta construyendo una applicación robusta, debe considerar el uso de [policies](#creating-policies) para organizar sus reglas de autorización.

Las gates son simples closures que determinan si un usuario está autorizado a realizar una acción determinada. Típicamente, las gates se definen dentro del método `boot` de la clase `App\Providers\AuthServiceProvider` usando la facade `Gate`. Las gates siempre reciben una instancia de usuario como su primer argumento y, de manera opcional, pueden recibir argumentos adicionales como un modelo de Eloquent.

En este ejemplo, definiremos una gate para determinar si un usuario puede actualizar un modelo `App\Models\Post` dado. La gate logrará esto comparando el `id` del usuario con el `user_id` del usuario que creó el post:

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Support\Facades\Gate;

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Gate::define('update-post', function (User $user, Post $post) {
            return $user->id === $post->user_id;
        });
    }

Al igual que los controladores, las gates también pueden definirse utilizando un "array callback" con una clase y uno de sus métodos públicos:

    use App\Policies\PostPolicy;
    use Illuminate\Support\Facades\Gate;

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Gate::define('update-post', [PostPolicy::class, 'update']);
    }

<a name="authorizing-actions-via-gates"></a>
### Autorización de acciones

Para autorizar una acción usando gates, deberías usar los métodos `allows` o `denies` proporcionados por la facade la `Gate`. Ten en cuenta que no es necesario que pases el usuario autenticado a estos métodos. Laravel se encargará automáticamente de pasar el usuario al closure del gate. Es típico llamar a los métodos de autorización de gate dentro de los controladores de tu aplicación antes de realizar una acción que requiera autorización:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Post;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Gate;

    class PostController extends Controller
    {
        /**
         * Update the given post.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \App\Models\Post  $post
         * @return \Illuminate\Http\Response
         */
        public function update(Request $request, Post $post)
        {
            if (! Gate::allows('update-post', $post)) {
                abort(403);
            }

            // Update the post...
        }
    }

Si desea determinar si un usuario distinto del usuario autenticado actualmente está autorizado a realizar una acción, puede utilizar el método `forUser` en la facade de la `gate`:

    if (Gate::forUser($user)->allows('update-post', $post)) {
        // The user can update the post...
    }

    if (Gate::forUser($user)->denies('update-post', $post)) {
        // The user can't update the post...
    }

Puede autorizar múltiples acciones a la vez utilizando los métodos `any` o `none`:

    if (Gate::any(['update-post', 'delete-post'], $post)) {
        // The user can update or delete the post...
    }

    if (Gate::none(['update-post', 'delete-post'], $post)) {
        // The user can't update or delete the post...
    }

<a name="authorizing-or-throwing-exceptions"></a>
#### Autorizar o lanzar excepciones

Si desea intentar autorizar una acción y lanzar automáticamente una `Illuminate\Auth\Access\AuthorizationException` si el usuario no está autorizado a realizar la acción dada, puede utilizar el método `authorize` de la facade la `gate`. Las instancias de `AuthorizationException` se convierten automáticamente en una respuesta HTTP 403 por el gestor de excepciones de Laravel:

    Gate::authorize('update-post', $post);

    // The action is authorized...

<a name="gates-supplying-additional-context"></a>
#### Suministro de contexto adicional

Los métodos gate para autorizar habilidades `(allows`, `denies`, `check`, `any`, `none`, `authorize`, `can`, `cannot`) y las [directivas Blade de autorización](#via-blade-templates) `(@can`, `@cannot`, `@canany`) pueden recibir un array como segundo argumento. Los elementos del array se pasan como parámetros al closure la gate y se pueden utilizar como contexto adicional al tomar decisiones de autorización:

    use App\Models\Category;
    use App\Models\User;
    use Illuminate\Support\Facades\Gate;

    Gate::define('create-post', function (User $user, Category $category, $pinned) {
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

<a name="gate-responses"></a>
### Gates con Respuestas

Hasta ahora, sólo hemos examinado gates que devuelven valores booleanos simples. Sin embargo, a veces puede que desee devolver una respuesta más detallada, incluyendo un mensaje de error. Para ello, puede devolver una `Illuminate\Auth\Access\Response` desde su gate:

    use App\Models\User;
    use Illuminate\Auth\Access\Response;
    use Illuminate\Support\Facades\Gate;

    Gate::define('edit-settings', function (User $user) {
        return $user->isAdmin
                    ? Response::allow()
                    : Response::deny('You must be an administrator.');
    });

Incluso cuando devuelve una respuesta de autorización desde su gate, el método `Gate::allows` devolverá un simple valor booleano; sin embargo, puede usar el método `Gate::inspect` para obtener la respuesta de autorización completa devuelta por la gate:

    $response = Gate::inspect('edit-settings');

    if ($response->allowed()) {
        // The action is authorized...
    } else {
        echo $response->message();
    }

Cuando se utiliza el método `Gate::authorize`, el cual lanza una `AuthorizationException` si la acción no está autorizada, el mensaje de error proporcionado por la respuesta de autorización se propagará a la respuesta HTTP:

    Gate::authorize('edit-settings');

    // The action is authorized...

<a name="customising-gate-response-status"></a>
#### Personalizando el Estado de la Respuesta HTTP

Cuando se deniega una acción a través de una gate, se devuelve una respuesta HTTP `403`; sin embargo, a veces puede ser útil devolver un código de estado HTTP alternativo. Puede personalizar el código de estado HTTP devuelto por una comprobación de autorización fallida utilizando el constructor estático `denyWithStatus` en la clase `Illuminate\Auth\Access\Response`:

    use App\Models\User;
    use Illuminate\Auth\Access\Response;
    use Illuminate\Support\Facades\Gate;

    Gate::define('edit-settings', function (User $user) {
        return $user->isAdmin
                    ? Response::allow()
                    : Response::denyWithStatus(404);
    });

Dado que ocultar recursos mediante una respuesta `404` es un patrón muy común en las aplicaciones web, el método `denyAsNotFound` se ofrece para más comodidad:

    use App\Models\User;
    use Illuminate\Auth\Access\Response;
    use Illuminate\Support\Facades\Gate;

    Gate::define('edit-settings', function (User $user) {
        return $user->isAdmin
                    ? Response::allow()
                    : Response::denyAsNotFound();
    });

<a name="intercepting-gate-checks"></a>
### Interceptación de comprobaciones Gate

A veces, es posible que desee conceder todas las capacidades a un usuario específico. Puede utilizar el método `before` para definir un closure que se ejecute antes de todas las demás comprobaciones de autorización:

    use Illuminate\Support\Facades\Gate;

    Gate::before(function ($user, $ability) {
        if ($user->isAdministrator()) {
            return true;
        }
    });

Si el closure `before` devuelve un resultado no nulo, ese resultado se considerará el resultado de la comprobación de autorización.

Puede utilizar el método `after` para definir un closure que se ejecute después de todas las demás comprobaciones de autorización:

    Gate::after(function ($user, $ability, $result, $arguments) {
        if ($user->isAdministrator()) {
            return true;
        }
    });

De forma similar al método `before`, si el closure `after` devuelve un resultado no nulo, ese resultado se considerará el resultado de la comprobación de autorización.

<a name="inline-authorization"></a>
### Autorización Inline

Ocasionalmente, es posible que desee determinar si el usuario autenticado actualmente está autorizado a realizar una acción determinada sin escribir una gate dedicada que corresponda a la acción. Laravel permite realizar este tipo de comprobaciones de autorización "inline" mediante los métodos `gate::allowIf` y `gate::denyIf`:

```php
use Illuminate\Support\Facades\Gate;

Gate::allowIf(fn ($user) => $user->isAdministrator());

Gate::denyIf(fn ($user) => $user->banned());
```

Si la acción no está autorizada o si no hay ningún usuario autenticado, Laravel lanzará automáticamente una excepción `Illuminate\Auth\Access\AuthorizationException`. Las instancias de `AuthorizationException` se convierten automáticamente en una respuesta HTTP 403 por el gestor de excepciones de Laravel.

<a name="creating-policies"></a>
## Creación de Policies

<a name="generating-policies"></a>
### Generación de Policies

Las Policies son clases que organizan la lógica de autorización en torno a un modelo o recurso en particular. Por ejemplo, si su aplicación es un blog, puede tener un modelo `App\Models\Post` y una correspondiente `App\Policies\PostPolicy` para autorizar acciones de usuario como crear o actualizar posts.

Puede generar una policy utilizando el comando `make:policy` de Artisan. La policy generada será colocada en el directorio `app/Policies`. Si este directorio no existe en tu aplicación, Laravel lo creará por ti:

```shell
php artisan make:policy PostPolicy
```

El comando `make:policy` generará una clase de policy vacía. Si deseas generar una clase con métodos de policy de ejemplo relacionados con la visualización, creación, actualización y eliminación del recurso, puedes proporcionar una opción `--model` al ejecutar el comando:

```shell
php artisan make:policy PostPolicy --model=Post
```

<a name="registering-policies"></a>
### Registro de Policies

Una vez creada la clase de policy, es necesario registrarla. Registrando policies es como podemos informar a Laravel qué policy usar cuando autoriza acciones contra un tipo de modelo dado.

El `App\Providers\AuthServiceProvider` incluido con las nuevas aplicaciones Laravel contiene una propiedad `policies` que mapea tus modelos Eloquent a sus correspondientes policies. El registro de una policy le indicará a Laravel qué policy utilizar cuando autorice acciones contra un modelo Eloquent dado:

    <?php

    namespace App\Providers;

    use App\Models\Post;
    use App\Policies\PostPolicy;
    use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
    use Illuminate\Support\Facades\Gate;

    class AuthServiceProvider extends ServiceProvider
    {
        /**
         * The policy mappings for the application.
         *
         * @var array
         */
        protected $policies = [
            Post::class => PostPolicy::class,
        ];

        /**
         * Register any application authentication / authorization services.
         *
         * @return void
         */
        public function boot()
        {
            $this->registerPolicies();

            //
        }
    }

<a name="policy-auto-discovery"></a>
#### Policy Auto-Discovery

En lugar de registrar manualmente policies, éstas pueden ser registradas automáticamente  siempre que el modelo y la policy sigan las convenciones de nomenclatura estándar de Laravel. En concreto, las policies deben estar en un directorio llamado `Policies` situado en el mismo nivel o uno por encima del directorio que contiene sus modelos. Así, por ejemplo, los modelos pueden colocarse en el directorio `app/Models` mientras que las policies pueden colocarse en el directorio `app/Policies`. En esta situación, Laravel buscará las policies en `app/Models/Policies` y luego en `app/Policies`. Además, el nombre de policy debe coincidir con el nombre del modelo y tener el sufijo `Policy`. Así, un modelo `User` correspondería a una clase de policy `UserPolicy`.

Si desea definir su propia lógica de descubrimiento de policy, puede registrar un callback de descubrimiento de policy personalizado utilizando el método `Gate::guessPolicyNamesUsing`. Normalmente, este método debería llamarse desde el método de `boot` del `AuthServiceProvider` de su aplicación:

    use Illuminate\Support\Facades\Gate;

    Gate::guessPolicyNamesUsing(function ($modelClass) {
        // Return the name of the policy class for the given model...
    });

> **Advertencia**  
> Cualquier policy que esté explícitamente asignada en el `AuthServiceProvider` tendrá prioridad sobre cualquier policy potencialmente autodescubierta.

<a name="writing-policies"></a>
## Escritura de policies

<a name="policy-methods"></a>
### Métodos de una Policy

Una vez registrada la clase policy, puedes añadir métodos para cada acción que autorice. Por ejemplo, definamos un método `update` en nuestro `PostPolicy` que determine si una instancia de `App\Models\User` dada puede actualizar una instancia de `App\Models\Post`.

El método `update` recibirá como argumentos una instancia de `User` y una instancia de `Post`, y debería devolver `true` o `false` indicando si el usuario está autorizado a actualizar el `Post` dado. Así, en este ejemplo, verificaremos que el `id` del usuario coincide con el `user_id` de la entrada:

    <?php

    namespace App\Policies;

    use App\Models\Post;
    use App\Models\User;

    class PostPolicy
    {
        /**
         * Determine if the given post can be updated by the user.
         *
         * @param  \App\Models\User  $user
         * @param  \App\Models\Post  $post
         * @return bool
         */
        public function update(User $user, Post $post)
        {
            return $user->id === $post->user_id;
        }
    }

Puede continuar definiendo métodos adicionales en la policy según sea necesario para las diversas acciones que autoriza. Por ejemplo, puede definir métodos `view` o `delete` para autorizar varias acciones relacionadas con `Post`, pero recuerde que es libre de dar a los métodos de su policy el nombre que desee.

Si usted utilizó la opción `--model` cuando generó su policy a través de la consola Artisan, ésta ya contendrá métodos para las acciones `viewAny`, `view`, `create`, `update`, `delete`, `restore`, y `forceDelete`.

> **Nota**  
> Todas las policies se resuelven a través del [contenedor de servicios](/docs/{{version}}/container) de Laravel, lo que le permite escribir cualquier dependencia necesaria en el constructor de la policy para que se inyecten automáticamente.

<a name="policy-responses"></a>
### Policies con Respuestas

Hasta ahora, sólo hemos examinado los métodos de policy que devuelven valores booleanos simples. Sin embargo, a veces puede que desee devolver una respuesta más detallada, incluyendo un mensaje de error. Para ello, puede devolver una instancia `Illuminate\Auth\Access\Response` desde el método de su policy:

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Auth\Access\Response;

    /**
     * Determine if the given post can be updated by the user.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Auth\Access\Response
     */
    public function update(User $user, Post $post)
    {
        return $user->id === $post->user_id
                    ? Response::allow()
                    : Response::deny('You do not own this post.');
    }

Cuando devuelva una respuesta de autorización de su policy, el método `Gate::allows` seguirá devolviendo un simple valor booleano; sin embargo, puede utilizar el método `Gate::inspect` para obtener la respuesta de autorización completa devuelta por la gate:

    use Illuminate\Support\Facades\Gate;

    $response = Gate::inspect('update', $post);

    if ($response->allowed()) {
        // The action is authorized...
    } else {
        echo $response->message();
    }

Cuando se utiliza el método `Gate::authorize`, que lanza una `AuthorizationException` si la acción no está autorizada, el mensaje de error proporcionado por la respuesta de autorización se propagará a la respuesta HTTP:

    Gate::authorize('update', $post);

    // The action is authorized...

<a name="customising-policy-response-status"></a>
#### Personalización del estado de la respuesta HTTP

Cuando se deniega una acción a través de un método de policy, se devuelve una respuesta HTTP `403`; sin embargo, a veces puede ser útil devolver un código de estado HTTP alternativo. Puede personalizar el código de estado HTTP devuelto para una comprobación de autorización fallida utilizando el constructor estático `denyWithStatus` de la clase `Illuminate\Auth\Access\Response`:

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Auth\Access\Response;

    /**
     * Determine if the given post can be updated by the user.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Auth\Access\Response
     */
    public function update(User $user, Post $post)
    {
        return $user->id === $post->user_id
                    ? Response::allow()
                    : Response::denyWithStatus(404);
    }

Debido a que ocultar recursos a través de una respuesta `404` es un patrón muy común en las aplicaciones web, el método `denyAsNotFound` se ofrece para más comodidad:

    use App\Models\Post;
    use App\Models\User;
    use Illuminate\Auth\Access\Response;

    /**
     * Determine if the given post can be updated by the user.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Auth\Access\Response
     */
    public function update(User $user, Post $post)
    {
        return $user->id === $post->user_id
                    ? Response::allow()
                    : Response::denyAsNotFound();
    }

<a name="methods-without-models"></a>
### Métodos sin modelos

Algunos métodos de policy sólo reciben una instancia del usuario autenticado en ese momento. Esta situación es más común cuando se autorizan acciones de `creación`. Por ejemplo, si está creando un blog, puede que desee determinar si un usuario está autorizado a crear alguna entrada. En estas situaciones, el método de su policy sólo debería esperar recibir una instancia de usuario:

    /**
     * Determine if the given user can create posts.
     *
     * @param  \App\Models\User  $user
     * @return bool
     */
    public function create(User $user)
    {
        return $user->role == 'writer';
    }

<a name="guest-users"></a>
### Usuarios invitados

De forma predeterminada, todas las gates y policies devuelven automáticamente `false` si la solicitud HTTP entrante no fue iniciada por un usuario autenticado. Sin embargo, puede permitir que estas comprobaciones de autorización pasen a través de sus gates y policies declarando una sugerencia de tipo "opcional" o proporcionando un valor predeterminado `nulo` para la definición del argumento de usuario:

    <?php

    namespace App\Policies;

    use App\Models\Post;
    use App\Models\User;

    class PostPolicy
    {
        /**
         * Determine if the given post can be updated by the user.
         *
         * @param  \App\Models\User  $user
         * @param  \App\Models\Post  $post
         * @return bool
         */
        public function update(?User $user, Post $post)
        {
            return optional($user)->id === $post->user_id;
        }
    }

<a name="policy-filters"></a>
### Filtros 

Para ciertos usuarios, es posible que desee autorizar todas las acciones dentro de una policy determinada. Para ello, defina un método `before` en la policy. El método `before` se ejecutará antes que cualquier otro método de la policy, dándole la oportunidad de autorizar la acción antes de que el método de policy sea llamado. Esta función se utiliza normalmente para autorizar a los administradores de aplicaciones a realizar cualquier acción:

    use App\Models\User;

    /**
     * Perform pre-authorization checks.
     *
     * @param  \App\Models\User  $user
     * @param  string  $ability
     * @return void|bool
     */
    public function before(User $user, $ability)
    {
        if ($user->isAdministrator()) {
            return true;
        }
    }

Si desea denegar todas las comprobaciones de autorización para un tipo concreto de usuario, puede devolver `false` en el método `before`. Si se devuelve `null`, la comprobación de autorización pasará al método de policy.

> **Advertencia**  
> El método `before` de una clase de policy no será llamado si la clase no contiene un método con un nombre que coincida con el nombre de la acción que se está comprobando.

<a name="authorizing-actions-using-policies"></a>
## Autorización de acciones mediante policies

<a name="via-the-user-model"></a>
### A través del modelo de usuario

El modelo `App\Models\User` que se incluye con su aplicación Laravel incluye dos métodos útiles para autorizar acciones: `can` y `cannot`. Los métodos `can` y `cannot` reciben el nombre de la acción que deseas autorizar y el modelo relevante. Por ejemplo, vamos a determinar si un usuario está autorizado a actualizar un determinado modelo `App\Models\Post`. Típicamente, esto se hará dentro de un método controlador:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Post;
    use Illuminate\Http\Request;

    class PostController extends Controller
    {
        /**
         * Update the given post.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \App\Models\Post  $post
         * @return \Illuminate\Http\Response
         */
        public function update(Request $request, Post $post)
        {
            if ($request->user()->cannot('update', $post)) {
                abort(403);
            }

            // Update the post...
        }
    }

Si hay una [policy está registrada](#registering-policies) para el modelo dado, el método `can` llamará automáticamente a la policy apropiada y devolverá el resultado booleano. Si no hay ninguna policy registrada para el modelo, el método `can` intentará llamar a la gate que coincida con el nombre de la acción dada.

<a name="user-model-actions-that-dont-require-models"></a>
#### Acciones que no requieren modelos

Recuerde que algunas acciones pueden corresponder a métodos de policy como `create` que no requieren una instancia de modelo. En estas situaciones, puede pasar un nombre de clase al método `can`. El nombre de la clase se utilizará para determinar qué policy utilizar al autorizar la acción:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Post;
    use Illuminate\Http\Request;

    class PostController extends Controller
    {
        /**
         * Create a post.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function store(Request $request)
        {
            if ($request->user()->cannot('create', Post::class)) {
                abort(403);
            }

            // Create the post...
        }
    }

<a name="via-controller-helpers"></a>
### Autorizacion Mediante Controller Helpers

Además de los métodos de ayuda proporcionados al modelo `App\Models\User`, Laravel proporciona un método `authorize` a cualquiera de sus controladores que extiendan la clase base `App\Http\Controllers\Controller`.

Al igual que el método `can`, este método acepta el nombre de la acción que desea autorizar y el modelo correspondiente. Si la acción no está autorizada, el método `authorize` lanzará una excepción `Illuminate\Auth\Access\AuthorizationException` que el gestor de excepciones de Laravel convertirá automáticamente en una respuesta HTTP con un código de estado 403:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Post;
    use Illuminate\Http\Request;

    class PostController extends Controller
    {
        /**
         * Update the given blog post.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \App\Models\Post  $post
         * @return \Illuminate\Http\Response
         *
         * @throws \Illuminate\Auth\Access\AuthorizationException
         */
        public function update(Request $request, Post $post)
        {
            $this->authorize('update', $post);

            // The current user can update the blog post...
        }
    }

<a name="controller-actions-that-dont-require-models"></a>
#### Acciones que no requieren modelos

Como se ha comentado anteriormente, algunos métodos de policy como `create` no requieren una instancia de modelo. En estas situaciones, debes pasar un nombre de clase al método `authorize`. El nombre de la clase se utilizará para determinar qué policy utilizar al autorizar la acción:

    use App\Models\Post;
    use Illuminate\Http\Request;

    /**
     * Create a new blog post.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function create(Request $request)
    {
        $this->authorize('create', Post::class);

        // The current user can create blog posts...
    }

<a name="authorizing-resource-controllers"></a>
#### Autorización de controladores de recursos

Si está utilizando [controladores de recursos](/docs/{{version}}/controllers#resource-controllers), puede hacer uso del método `authorizeResource` en el constructor de su controlador. Este método adjuntará las definiciones de middleware `can` apropiadas a los métodos del controlador de recursos.

El método `authorizeResource` acepta el nombre de la clase del modelo como primer argumento, y el nombre del parámetro de ruta/solicitud que contendrá el ID del modelo como segundo argumento. Debes asegurarte de que tu [controlador de recursos](/docs/{{version}}/controllers#resource-controllers) se crea utilizando el flag `--model` para que tenga las definiciones de método y las sugerencias de tipo necesarias:

    <?php

    namespace App\Http\Controllers;

    use App\Http\Controllers\Controller;
    use App\Models\Post;
    use Illuminate\Http\Request;

    class PostController extends Controller
    {
        /**
         * Create the controller instance.
         *
         * @return void
         */
        public function __construct()
        {
            $this->authorizeResource(Post::class, 'post');
        }
    }

Los siguientes métodos de controlador se asignarán a su correspondiente método de policy. Cuando las peticiones se dirijan al método de controlador dado, el método de policy correspondiente se invocará automáticamente antes de que se ejecute el método de controlador:

| Método de Controlador | Método de Policy |
| --- | --- |
| index | viewAny |
| show | view |
| create | create |
| store | create |
| edit | update |
| update | update |
| destroy | delete |

> **Nota**  
> Puede utilizar el comando `make:policy` con la opción `--model` para generar rápidamente una clase de policy para un modelo dado: `php artisan make:policy PostPolicy --model=Post`.

<a name="via-middleware"></a>
### Autorización Mediante Middleware

Laravel incluye un middleware que puede autorizar acciones incluso antes de que la solicitud entrante llegue a tus rutas o controladores. Por defecto, el middleware `Illuminate\Auth\Authorize` tiene asignada la clave `can` en la clase `App\Http\Kernel`. Exploremos un ejemplo de uso del middleware `can` para autorizar que un usuario pueda actualizar un post:

    use App\Models\Post;

    Route::put('/post/{post}', function (Post $post) {
        // The current user may update the post...
    })->middleware('can:update,post');

En este ejemplo, estamos pasando dos argumentos al middleware `can`. El primero es el nombre de la acción que deseamos autorizar y el segundo es el parámetro de ruta que deseamos pasar al método de policy. En este caso, dado que estamos utilizando [la vinculación implícita de modelos](/docs/{{version}}/routing#implicit-binding), se pasará un modelo `App\Models\Post` al método de policy. Si el usuario no está autorizado a realizar la acción dada, una respuesta HTTP con un código de estado 403 será devuelta por el middleware.

Por conveniencia, también puede adjuntar el middleware `can` a su ruta usando el método `can`:

    use App\Models\Post;

    Route::put('/post/{post}', function (Post $post) {
        // The current user may update the post...
    })->can('update', 'post');

<a name="middleware-actions-that-dont-require-models"></a>
#### Acciones que no requieren modelos

De nuevo, algunos métodos de policy como `create` no requieren una instancia de modelo. En estas situaciones, puede pasar un nombre de clase al middleware. El nombre de la clase se utilizará para determinar qué policy utilizar al autorizar la acción:

    Route::post('/post', function () {
        // The current user may create posts...
    })->middleware('can:create,App\Models\Post');

Especificar el nombre completo de la clase dentro de una cadena de definición de middleware puede llegar a ser engorroso. Por esta razón, puede elegir adjuntar middleware middleware `can` a su ruta utilizando el método `can`:

    use App\Models\Post;

    Route::post('/post', function () {
        // The current user may create posts...
    })->can('create', Post::class);

<a name="via-blade-templates"></a>
### Autorización Mediante plantillas Blade

Al escribir plantillas Blade, puede que desee mostrar una parte de la página sólo si el usuario está autorizado a realizar una acción determinada. Por ejemplo, puede que desee mostrar un formulario de actualización para una entrada de blog sólo si el usuario puede realmente actualizar la entrada. En este caso, puede utilizar las directivas `@can` y `@cannot`:

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

Estas directivas son atajos prácticos para escribir sentencias `@if` y `@unless`. Las sentencias `@can` y `@cannot` anteriores son equivalentes a las siguientes sentencias:

```blade
@if (Auth::user()->can('update', $post))
    <!-- The current user can update the post... -->
@endif

@unless (Auth::user()->can('update', $post))
    <!-- The current user cannot update the post... -->
@endunless
```

También puede determinar si un usuario está autorizado a realizar cualquier acción de un array dado de acciones. Para ello, utilice la directiva `@canany`:

```blade
@canany(['update', 'view', 'delete'], $post)
    <!-- The current user can update, view, or delete the post... -->
@elsecanany(['create'], \App\Models\Post::class)
    <!-- The current user can create a post... -->
@endcanany
```

<a name="blade-actions-that-dont-require-models"></a>
#### Acciones que no requieren modelos

Como la mayoría de los otros métodos de autorización, puede pasar un nombre de clase a las directivas `@can` y `@cannot` si la acción no requiere una instancia de modelo:

```blade
@can('create', App\Models\Post::class)
    <!-- The current user can create posts... -->
@endcan

@cannot('create', App\Models\Post::class)
    <!-- The current user can't create posts... -->
@endcannot
```

<a name="supplying-additional-context"></a>
### Suministro de contexto adicional

Al autorizar acciones mediante policies, puede pasar una array como segundo argumento a las distintas funciones y helpers de autorización. El primer elemento del array se utilizará para determinar qué policy debe invocarse, mientras que el resto de los elementos del array se pasan como parámetros al método de policy y pueden utilizarse como contexto adicional al tomar decisiones de autorización. Por ejemplo, considere la siguiente definición del método `PostPolicy` que contiene un parámetro adicional `$category`:

    /**
     * Determine if the given post can be updated by the user.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Post  $post
     * @param  int  $category
     * @return bool
     */
    public function update(User $user, Post $post, int $category)
    {
        return $user->id === $post->user_id &&
               $user->canUpdateCategory($category);
    }

Cuando intentamos determinar si el usuario autenticado puede actualizar un post dado, podemos invocar este método de policy así:

    /**
     * Update the given blog post.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Post  $post
     * @return \Illuminate\Http\Response
     *
     * @throws \Illuminate\Auth\Access\AuthorizationException
     */
    public function update(Request $request, Post $post)
    {
        $this->authorize('update', [$post, $request->category]);

        // The current user can update the blog post...
    }
