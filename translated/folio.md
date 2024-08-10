# Laravel Folio

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Rutas de Página / URIs](#page-paths-uris)
    - [Enrutamiento de Subdominio](#subdomain-routing)
- [Creando Rutas](#creating-routes)
    - [Rutas Anidadas](#nested-routes)
    - [Rutas de Índice](#index-routes)
- [Parámetros de Ruta](#route-parameters)
- [Vinculación de Modelo de Ruta](#route-model-binding)
    - [Modelos Suavemente Eliminados](#soft-deleted-models)
- [Ganchos de Renderizado](#render-hooks)
- [Rutas Nombradas](#named-routes)
- [Middleware](#middleware)
- [Caché de Rutas](#route-caching)

<a name="introduction"></a>
## Introducción

[Laravel Folio](https://github.com/laravel/folio) es un potente enrutador basado en páginas diseñado para simplificar el enrutamiento en aplicaciones Laravel. Con Laravel Folio, generar una ruta se convierte en algo tan sencillo como crear una plantilla Blade dentro del directorio `resources/views/pages` de tu aplicación.

Por ejemplo, para crear una página que sea accesible en la URL `/greeting`, solo crea un archivo `greeting.blade.php` en el directorio `resources/views/pages` de tu aplicación:

```php
<div>
    Hello World
</div>
```

<a name="installation"></a>
## Instalación

Para comenzar, instala Folio en tu proyecto utilizando el gestor de paquetes Composer:

```bash
composer require laravel/folio
```

Después de instalar Folio, puedes ejecutar el comando Artisan `folio:install`, que instalará el proveedor de servicios de Folio en tu aplicación. Este proveedor de servicios registra el directorio donde Folio buscará rutas / páginas:

```bash
php artisan folio:install
```

<a name="page-paths-uris"></a>
### Rutas de Página / URIs

Por defecto, Folio sirve páginas desde el directorio `resources/views/pages` de tu aplicación, pero puedes personalizar estos directorios en el método `boot` del proveedor de servicios de Folio.

Por ejemplo, a veces puede ser conveniente especificar múltiples rutas de Folio en la misma aplicación Laravel. Puede que desees tener un directorio separado de páginas de Folio para el área "admin" de tu aplicación, mientras usas otro directorio para el resto de las páginas de tu aplicación.

Puedes lograr esto utilizando los métodos `Folio::path` y `Folio::uri`. El método `path` registra un directorio que Folio escaneará en busca de páginas al enrutar solicitudes HTTP entrantes, mientras que el método `uri` especifica la "URI base" para ese directorio de páginas:

```php
use Laravel\Folio\Folio;

Folio::path(resource_path('views/pages/guest'))->uri('/');

Folio::path(resource_path('views/pages/admin'))
    ->uri('/admin')
    ->middleware([
        '*' => [
            'auth',
            'verified',

            // ...
        ],
    ]);
```

<a name="subdomain-routing"></a>
### Enrutamiento de Subdominio

También puedes enrutar a páginas basadas en el subdominio de la solicitud entrante. Por ejemplo, puede que desees enrutar solicitudes de `admin.example.com` a un directorio de página diferente al resto de tus páginas de Folio. Puedes lograr esto invocando el método `domain` después de invocar el método `Folio::path`:

```php
use Laravel\Folio\Folio;

Folio::domain('admin.example.com')
    ->path(resource_path('views/pages/admin'));
```

El método `domain` también te permite capturar partes del dominio o subdominio como parámetros. Estos parámetros se inyectarán en tu plantilla de página:

```php
use Laravel\Folio\Folio;

Folio::domain('{account}.example.com')
    ->path(resource_path('views/pages/admin'));
```

<a name="creating-routes"></a>
## Creando Rutas

Puedes crear una ruta de Folio colocando una plantilla Blade en cualquiera de tus directorios montados de Folio. Por defecto, Folio monta el directorio `resources/views/pages`, pero puedes personalizar estos directorios en el método `boot` del proveedor de servicios de Folio.

Una vez que se ha colocado una plantilla Blade en un directorio montado de Folio, puedes acceder a ella de inmediato a través de tu navegador. Por ejemplo, una página colocada en `pages/schedule.blade.php` puede ser accedida en tu navegador en `http://example.com/schedule`.

Para ver rápidamente una lista de todas tus páginas / rutas de Folio, puedes invocar el comando Artisan `folio:list`:

```bash
php artisan folio:list
```

<a name="nested-routes"></a>
### Rutas Anidadas

Puedes crear una ruta anidada creando uno o más directorios dentro de uno de los directorios de Folio. Por ejemplo, para crear una página que sea accesible a través de `/user/profile`, crea una plantilla `profile.blade.php` dentro del directorio `pages/user`:

```bash
php artisan folio:page user/profile

# pages/user/profile.blade.php → /user/profile
```

<a name="index-routes"></a>
### Rutas de Índice

A veces, puede que desees hacer que una página dada sea el "índice" de un directorio. Al colocar una plantilla `index.blade.php` dentro de un directorio de Folio, cualquier solicitud a la raíz de ese directorio será enrutada a esa página:

```bash
php artisan folio:page index
# pages/index.blade.php → /

php artisan folio:page users/index
# pages/users/index.blade.php → /users
```

<a name="route-parameters"></a>
## Parámetros de Ruta

A menudo, necesitarás tener segmentos de la URL de la solicitud entrante inyectados en tu página para que puedas interactuar con ellos. Por ejemplo, puede que necesites acceder al "ID" del usuario cuyo perfil se está mostrando. Para lograr esto, puedes encapsular un segmento del nombre de archivo de la página entre corchetes:

```bash
php artisan folio:page "users/[id]"

# pages/users/[id].blade.php → /users/1
```

Los segmentos capturados se pueden acceder como variables dentro de tu plantilla Blade:

```html
<div>
    User {{ $id }}
</div>
```

Para capturar múltiples segmentos, puedes prefijar el segmento encapsulado con tres puntos `...`:

```bash
php artisan folio:page "users/[...ids]"

# pages/users/[...ids].blade.php → /users/1/2/3
```

Al capturar múltiples segmentos, los segmentos capturados se inyectarán en la página como un array:

```html
<ul>
    @foreach ($ids as $id)
        <li>User {{ $id }}</li>
    @endforeach
</ul>
```

<a name="route-model-binding"></a>
## Vinculación de Modelo de Ruta

Si un segmento comodín del nombre de archivo de tu plantilla de página corresponde a uno de los modelos Eloquent de tu aplicación, Folio aprovechará automáticamente las capacidades de vinculación de modelo de ruta de Laravel e intentará inyectar la instancia del modelo resuelto en tu página:

```bash
php artisan folio:page "users/[User]"

# pages/users/[User].blade.php → /users/1
```

Los modelos capturados se pueden acceder como variables dentro de tu plantilla Blade. El nombre de la variable del modelo se convertirá a "camel case":

```html
<div>
    User {{ $user->id }}
</div>
```

#### Personalizando la Clave

A veces puede que desees resolver modelos Eloquent vinculados utilizando una columna diferente a `id`. Para hacerlo, puedes especificar la columna en el nombre de archivo de la página. Por ejemplo, una página con el nombre de archivo `[Post:slug].blade.php` intentará resolver el modelo vinculado a través de la columna `slug` en lugar de la columna `id`.

En Windows, debes usar `-` para separar el nombre del modelo de la clave: `[Post-slug].blade.php`.

#### Ubicación del Modelo

Por defecto, Folio buscará tu modelo dentro del directorio `app/Models` de tu aplicación. Sin embargo, si es necesario, puedes especificar el nombre de clase de modelo completamente calificado en el nombre de archivo de tu plantilla:

```bash
php artisan folio:page "users/[.App.Models.User]"

# pages/users/[.App.Models.User].blade.php → /users/1
```

<a name="soft-deleted-models"></a>
### Modelos Suavemente Eliminados

Por defecto, los modelos que han sido suavemente eliminados no se recuperan al resolver vinculaciones de modelo implícitas. Sin embargo, si lo deseas, puedes instruir a Folio para que recupere modelos suavemente eliminados invocando la función `withTrashed` dentro de la plantilla de la página:

```php
<?php

use function Laravel\Folio\{withTrashed};

withTrashed();

?>

<div>
    User {{ $user->id }}
</div>
```

<a name="render-hooks"></a>
## Ganchos de Renderizado

Por defecto, Folio devolverá el contenido de la plantilla Blade de la página como la respuesta a la solicitud entrante. Sin embargo, puedes personalizar la respuesta invocando la función `render` dentro de la plantilla de la página.

La función `render` acepta una función anónima que recibirá la instancia de `View` que está siendo renderizada por Folio, lo que te permite agregar datos adicionales a la vista o personalizar toda la respuesta. Además de recibir la instancia de `View`, cualquier parámetro de ruta adicional o vinculaciones de modelo también se proporcionarán a la función anónima `render`:

```php
<?php

use App\Models\Post;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

use function Laravel\Folio\render;

render(function (View $view, Post $post) {
    if (! Auth::user()->can('view', $post)) {
        return response('Unauthorized', 403);
    }

    return $view->with('photos', $post->author->photos);
}); ?>

<div>
    {{ $post->content }}
</div>

<div>
    This author has also taken {{ count($photos) }} photos.
</div>
```

<a name="named-routes"></a>
## Rutas Nombradas

Puedes especificar un nombre para la ruta de una página dada utilizando la función `name`:

```php
<?php

use function Laravel\Folio\name;

name('users.index');
```

Al igual que las rutas nombradas de Laravel, puedes usar la función `route` para generar URLs a páginas de Folio que se les ha asignado un nombre:

```php
<a href="{{ route('users.index') }}">
    All Users
</a>
```

Si la página tiene parámetros, simplemente puedes pasar sus valores a la función `route`:

```php
route('users.show', ['user' => $user]);
```

<a name="middleware"></a>
## Middleware

Puedes aplicar middleware a una página específica invocando la función `middleware` dentro de la plantilla de la página:

```php
<?php

use function Laravel\Folio\{middleware};

middleware(['auth', 'verified']);

?>

<div>
    Dashboard
</div>
```

O, para asignar middleware a un grupo de páginas, puedes encadenar el método `middleware` después de invocar el método `Folio::path`.

Para especificar a qué páginas se debe aplicar el middleware, el array de middleware puede ser indexado utilizando los patrones de URL correspondientes de las páginas a las que se debe aplicar. El carácter `*` puede ser utilizado como un carácter comodín:

```php
use Laravel\Folio\Folio;

Folio::path(resource_path('views/pages'))->middleware([
    'admin/*' => [
        'auth',
        'verified',

        // ...
    ],
]);
```

Puedes incluir funciones anónimas en el array de middleware para definir middleware en línea:

```php
use Closure;
use Illuminate\Http\Request;
use Laravel\Folio\Folio;

Folio::path(resource_path('views/pages'))->middleware([
    'admin/*' => [
        'auth',
        'verified',

        function (Request $request, Closure $next) {
            // ...

            return $next($request);
        },
    ],
]);
```

<a name="route-caching"></a>
## Caché de Rutas

Al usar Folio, siempre debes aprovechar las [capacidades de caché de rutas de Laravel](/docs/{{version}}/routing#route-caching). Folio escucha el comando Artisan `route:cache` para asegurarse de que las definiciones de páginas de Folio y los nombres de ruta estén correctamente almacenados en caché para un rendimiento máximo.
