# Generación de URL

- [Introducción](#introduction)
- [Los Fundamentos](#the-basics)
  - [Generando URL](#generating-urls)
  - [Accediendo a la URL Actual](#accessing-the-current-url)
- [URLs para Rutas Nombradas](#urls-for-named-routes)
  - [URLs Firmadas](#signed-urls)
- [URLs para Acciones de Controlador](#urls-for-controller-actions)
- [Valores Predeterminados](#default-values)

<a name="introduction"></a>
## Introducción

Laravel ofrece varios helpers para ayudarte a generar URL para tu aplicación. Estos helpers son especialmente útiles al construir enlaces en tus plantillas y respuestas de API, o al generar respuestas de redirección a otra parte de tu aplicación.

<a name="the-basics"></a>
## Lo Básico


<a name="generating-urls"></a>
### Generando URL

El helper `url` se puede utilizar para generar URL arbitrarias para tu aplicación. La URL generada utilizará automáticamente el esquema (HTTP o HTTPS) y el host de la solicitud actual que está siendo manejada por la aplicación:


```php
$post = App\Models\Post::find(1);

echo url("/posts/{$post->id}");

// http://example.com/posts/1
```
Para generar una URL con parámetros de cadena de consulta, puedes usar el método `query`:


```php
echo url()->query('/posts', ['search' => 'Laravel']);

// https://example.com/posts?search=Laravel

echo url()->query('/posts?sort=latest', ['search' => 'Laravel']);

// http://example.com/posts?sort=latest&search=Laravel
```
Proporcionar parámetros de cadena de consulta que ya existen en la ruta sobrescribirá su valor existente:


```php
echo url()->query('/posts?sort=latest', ['sort' => 'oldest']);

// http://example.com/posts?sort=oldest
```
También se pueden pasar arreglos de valores como parámetros de consulta. Estos valores estarán correctamente indexados y codificados en la URL generada:


```php
echo $url = url()->query('/posts', ['columns' => ['title', 'body']]);

// http://example.com/posts?columns%5B0%5D=title&columns%5B1%5D=body

echo urldecode($url);

// http://example.com/posts?columns[0]=title&columns[1]=body
```

<a name="accessing-the-current-url"></a>
### Accediendo a la URL Actual

Si no se proporciona ninguna ruta al helper `url`, se devuelve una instancia de `Illuminate\Routing\UrlGenerator`, lo que te permite acceder a información sobre la URL actual:


```php
// Get the current URL without the query string...
echo url()->current();

// Get the current URL including the query string...
echo url()->full();

// Get the full URL for the previous request...
echo url()->previous();
```
Cada uno de estos métodos también puede accederse a través de la `URL` [facade](/docs/%7B%7Bversion%7D%7D/facades):


```php
use Illuminate\Support\Facades\URL;

echo URL::current();
```

<a name="urls-for-named-routes"></a>
## URLs para Rutas Nombradas

El helper `route` puede utilizarse para generar URL a [rutas nombradas](/docs/%7B%7Bversion%7D%7D/routing#named-routes). Las rutas nombradas te permiten generar URL sin estar acoplado a la URL real definida en la ruta. Por lo tanto, si la URL de la ruta cambia, no es necesario hacer cambios en tus llamadas a la función `route`. Por ejemplo, imagina que tu aplicación contiene una ruta definida como la siguiente:


```php
Route::get('/post/{post}', function (Post $post) {
    // ...
})->name('post.show');
```
Para generar una URL a esta ruta, puedes usar el helper `route` de la siguiente manera:


```php
echo route('post.show', ['post' => 1]);

// http://example.com/post/1
```
Por supuesto, el helper `route` también se puede utilizar para generar URLs para rutas con múltiples parámetros:


```php
Route::get('/post/{post}/comment/{comment}', function (Post $post, Comment $comment) {
    // ...
})->name('comment.show');

echo route('comment.show', ['post' => 1, 'comment' => 3]);

// http://example.com/post/1/comment/3
```
Cualquier elemento adicional del array que no corresponda a los parámetros de definición de la ruta se añadirá a la cadena de consulta de la URL:


```php
echo route('post.show', ['post' => 1, 'search' => 'rocket']);

// http://example.com/post/1?search=rocket
```

<a name="eloquent-models"></a>
#### Modelos Eloquent

A menudo estarás generando URLs utilizando la clave de ruta (típicamente la clave primaria) de [modelos de Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). Por esta razón, puedes pasar modelos de Eloquent como valores de parámetro. El helper `route` extraerá automáticamente la clave de ruta del modelo:


```php
echo route('post.show', ['post' => $post]);
```

<a name="signed-urls"></a>
### URLs Firmadas

Laravel te permite crear fácilmente URL "firmadas" para rutas nombradas. Estas URL tienen un hash de "firma" añadido a la cadena de consulta, lo que permite que Laravel verifique que la URL no ha sido modificada desde que fue creada. Las URL firmadas son especialmente útiles para rutas que son accesibles públicamente pero que necesitan una capa de protección contra la manipulación de URL.
Por ejemplo, podrías usar URL firmadas para implementar un enlace público de "desuscribirse" que se envía por correo electrónico a tus clientes. Para crear una URL firmada a una ruta nombrada, utiliza el método `signedRoute` de la fachada `URL`:


```php
use Illuminate\Support\Facades\URL;

return URL::signedRoute('unsubscribe', ['user' => 1]);
```
Puedes excluir el dominio del hash de la URL firmada proporcionando el argumento `absolute` al método `signedRoute`:


```php
return URL::signedRoute('unsubscribe', ['user' => 1], absolute: false);
```
Si deseas generar una URL de ruta firmada temporal que expire después de un período de tiempo específico, puedes usar el método `temporarySignedRoute`. Cuando Laravel valida una URL de ruta firmada temporal, se asegurará de que la marca de tiempo de expiración que está codificada en la URL firmada no haya expirado:


```php
use Illuminate\Support\Facades\URL;

return URL::temporarySignedRoute(
    'unsubscribe', now()->addMinutes(30), ['user' => 1]
);
```

<a name="validating-signed-route-requests"></a>
#### Validando Solicitudes de Rutas Firmadas

Para verificar que una solicitud entrante tiene una firma válida, debes llamar al método `hasValidSignature` en la instancia de `Illuminate\Http\Request` entrante:


```php
use Illuminate\Http\Request;

Route::get('/unsubscribe/{user}', function (Request $request) {
    if (! $request->hasValidSignature()) {
        abort(401);
    }

    // ...
})->name('unsubscribe');
```
A veces, es posible que necesites permitir que el frontend de tu aplicación añada datos a una URL firmada, como al realizar paginación del lado del cliente. Por lo tanto, puedes especificar parámetros de consulta de solicitud que deben ser ignorados al validar una URL firmada utilizando el método `hasValidSignatureWhileIgnoring`. Recuerda que ignorar parámetros permite que cualquiera modifique esos parámetros en la solicitud:


```php
if (! $request->hasValidSignatureWhileIgnoring(['page', 'order'])) {
    abort(401);
}
```
En lugar de validar las URL firmadas utilizando la instancia de la solicitud entrante, puedes asignar el middleware `signed` (`Illuminate\Routing\Middleware\ValidateSignature`) a la ruta. Si la solicitud entrante no tiene una firma válida, el middleware devolverá automáticamente una respuesta HTTP `403`:


```php
Route::post('/unsubscribe/{user}', function (Request $request) {
    // ...
})->name('unsubscribe')->middleware('signed');
```
Si tus URL firmadas no incluyen el dominio en el hash de la URL, debes proporcionar el argumento `relative` al middleware:


```php
Route::post('/unsubscribe/{user}', function (Request $request) {
    // ...
})->name('unsubscribe')->middleware('signed:relative');
```

<a name="responding-to-invalid-signed-routes"></a>
#### Respondiendo a Rutas Firmadas Inválidas

Cuando alguien visita una URL firmada que ha expirado, recibirá una página de error genérica para el código de estado HTTP `403`. Sin embargo, puedes personalizar este comportamiento definiendo una "función anónima" de renderizado personalizada para la excepción `InvalidSignatureException` en el archivo `bootstrap/app.php` de tu aplicación:


```php
use Illuminate\Routing\Exceptions\InvalidSignatureException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (InvalidSignatureException $e) {
        return response()->view('errors.link-expired', status: 403);
    });
})
```

<a name="urls-for-controller-actions"></a>
## URLs para Acciones del Controlador

La función `action` genera una URL para la acción del controlador dada:


```php
use App\Http\Controllers\HomeController;

$url = action([HomeController::class, 'index']);
```
Si el método del controlador acepta parámetros de ruta, puedes pasar un array asociativo de parámetros de ruta como segundo argumento a la función:


```php
$url = action([UserController::class, 'profile'], ['id' => 1]);
```

<a name="default-values"></a>
## Valores Predeterminados

Para algunas aplicaciones, es posible que desees especificar valores predeterminados a nivel de solicitud para ciertos parámetros de URL. Por ejemplo, imagina que muchas de tus rutas definen un parámetro `{locale}`:


```php
Route::get('/{locale}/posts', function () {
    // ...
})->name('post.index');
```
Es engorroso tener que pasar el `locale` cada vez que llamas al helper `route`. Así que puedes usar el método `URL::defaults` para definir un valor por defecto para este parámetro que se aplicará siempre durante la solicitud actual. Puede que desees llamar a este método desde un [middleware de ruta](/docs/%7B%7Bversion%7D%7D/middleware#assigning-middleware-to-routes) para que tengas acceso a la solicitud actual:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Symfony\Component\HttpFoundation\Response;

class SetDefaultLocaleForUrls
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        URL::defaults(['locale' => $request->user()->locale]);

        return $next($request);
    }
}
```
Una vez que se ha establecido el valor predeterminado para el parámetro `locale`, ya no es necesario pasar su valor al generar URL a través del helper `route`.

<a name="url-defaults-middleware-priority"></a>
#### Valores predeterminados de URL y prioridad de middleware

Establecer valores predeterminados de URL puede interferir con el manejo de las vinculaciones de modelo implícitas por parte de Laravel. Por lo tanto, debes [priorizar tu middleware](/docs/%7B%7Bversion%7D%7D/middleware#sorting-middleware) que establece los predeterminados de URL para que se ejecuten antes del middleware `SubstituteBindings` de Laravel. Puedes lograr esto utilizando el método de middleware `priority` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->priority([
        \Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests::class,
        \Illuminate\Cookie\Middleware\EncryptCookies::class,
        \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
        \Illuminate\Contracts\Auth\Middleware\AuthenticatesRequests::class,
        \Illuminate\Routing\Middleware\ThrottleRequests::class,
        \Illuminate\Routing\Middleware\ThrottleRequestsWithRedis::class,
        \Illuminate\Session\Middleware\AuthenticateSession::class,
        \App\Http\Middleware\SetDefaultLocaleForUrls::class, // [tl! add]
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        \Illuminate\Auth\Middleware\Authorize::class,
    ]);
})

```