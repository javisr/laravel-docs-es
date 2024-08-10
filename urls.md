# Generación de URL

- [Introducción](#introducción)
- [Lo Básico](#lo-básico)
    - [Generando URLs](#generando-urls)
    - [Accediendo a la URL Actual](#accediendo-a-la-url-actual)
- [URLs para Rutas Nombradas](#urls-para-rutas-nombradas)
    - [URLs Firmadas](#urls-firmadas)
- [URLs para Acciones de Controlador](#urls-para-acciones-de-controlador)
- [Valores Predeterminados](#valores-predeterminados)

<a name="introducción"></a>
## Introducción

Laravel proporciona varios helpers para ayudarte a generar URLs para tu aplicación. Estos helpers son principalmente útiles al construir enlaces en tus plantillas y respuestas de API, o al generar respuestas de redirección a otra parte de tu aplicación.

<a name="lo-básico"></a>
## Lo Básico

<a name="generando-urls"></a>
### Generando URLs

El helper `url` puede ser utilizado para generar URLs arbitrarias para tu aplicación. La URL generada utilizará automáticamente el esquema (HTTP o HTTPS) y el host de la solicitud actual que está siendo manejada por la aplicación:

    $post = App\Models\Post::find(1);

    echo url("/posts/{$post->id}");

    // http://example.com/posts/1

Para generar una URL con parámetros de cadena de consulta, puedes usar el método `query`:

    echo url()->query('/posts', ['search' => 'Laravel']);

    // https://example.com/posts?search=Laravel

    echo url()->query('/posts?sort=latest', ['search' => 'Laravel']);

    // http://example.com/posts?sort=latest&search=Laravel

Proporcionar parámetros de cadena de consulta que ya existen en la ruta sobrescribirá su valor existente:

    echo url()->query('/posts?sort=latest', ['sort' => 'oldest']);

    // http://example.com/posts?sort=oldest

Arrays de valores también pueden ser pasados como parámetros de consulta. Estos valores serán correctamente indexados y codificados en la URL generada:

    echo $url = url()->query('/posts', ['columns' => ['title', 'body']]);

    // http://example.com/posts?columns%5B0%5D=title&columns%5B1%5D=body

    echo urldecode($url);

    // http://example.com/posts?columns[0]=title&columns[1]=body

<a name="accediendo-a-la-url-actual"></a>
### Accediendo a la URL Actual

Si no se proporciona una ruta al helper `url`, se devuelve una instancia de `Illuminate\Routing\UrlGenerator`, lo que te permite acceder a información sobre la URL actual:

    // Obtener la URL actual sin la cadena de consulta...
    echo url()->current();

    // Obtener la URL actual incluyendo la cadena de consulta...
    echo url()->full();

    // Obtener la URL completa para la solicitud anterior...
    echo url()->previous();

Cada uno de estos métodos también puede ser accedido a través de la [facade](/docs/{{version}}/facades) `URL`:

    use Illuminate\Support\Facades\URL;

    echo URL::current();

<a name="urls-para-rutas-nombradas"></a>
## URLs para Rutas Nombradas

El helper `route` puede ser utilizado para generar URLs a [rutas nombradas](/docs/{{version}}/routing#named-routes). Las rutas nombradas te permiten generar URLs sin estar acopladas a la URL real definida en la ruta. Por lo tanto, si la URL de la ruta cambia, no es necesario realizar cambios en tus llamadas a la función `route`. Por ejemplo, imagina que tu aplicación contiene una ruta definida como la siguiente:

    Route::get('/post/{post}', function (Post $post) {
        // ...
    })->name('post.show');

Para generar una URL a esta ruta, puedes usar el helper `route` de la siguiente manera:

    echo route('post.show', ['post' => 1]);

    // http://example.com/post/1

Por supuesto, el helper `route` también puede ser utilizado para generar URLs para rutas con múltiples parámetros:

    Route::get('/post/{post}/comment/{comment}', function (Post $post, Comment $comment) {
        // ...
    })->name('comment.show');

    echo route('comment.show', ['post' => 1, 'comment' => 3]);

    // http://example.com/post/1/comment/3

Cualquier elemento adicional del array que no corresponda a los parámetros de definición de la ruta se añadirá a la cadena de consulta de la URL:

    echo route('post.show', ['post' => 1, 'search' => 'rocket']);

    // http://example.com/post/1?search=rocket

<a name="eloquent-models"></a>
#### Modelos Eloquent

A menudo estarás generando URLs utilizando la clave de ruta (típicamente la clave primaria) de [modelos Eloquent](/docs/{{version}}/eloquent). Por esta razón, puedes pasar modelos Eloquent como valores de parámetro. El helper `route` extraerá automáticamente la clave de ruta del modelo:

    echo route('post.show', ['post' => $post]);

<a name="urls-firmadas"></a>
### URLs Firmadas

Laravel te permite crear fácilmente URLs "firmadas" a rutas nombradas. Estas URLs tienen un hash de "firma" añadido a la cadena de consulta que permite a Laravel verificar que la URL no ha sido modificada desde que fue creada. Las URLs firmadas son especialmente útiles para rutas que son accesibles públicamente pero que necesitan una capa de protección contra la manipulación de URLs.

Por ejemplo, podrías usar URLs firmadas para implementar un enlace público de "cancelar suscripción" que se envía por correo electrónico a tus clientes. Para crear una URL firmada a una ruta nombrada, usa el método `signedRoute` de la facade `URL`:

    use Illuminate\Support\Facades\URL;

    return URL::signedRoute('unsubscribe', ['user' => 1]);

Puedes excluir el dominio del hash de la URL firmada proporcionando el argumento `absolute` al método `signedRoute`:

    return URL::signedRoute('unsubscribe', ['user' => 1], absolute: false);

Si deseas generar una URL de ruta firmada temporal que expire después de un tiempo especificado, puedes usar el método `temporarySignedRoute`. Cuando Laravel valida una URL de ruta firmada temporal, se asegurará de que la marca de tiempo de expiración que está codificada en la URL firmada no haya expirado:

    use Illuminate\Support\Facades\URL;

    return URL::temporarySignedRoute(
        'unsubscribe', now()->addMinutes(30), ['user' => 1]
    );

<a name="validando-firmas-de-ruta"></a>
#### Validando Firmas de Ruta Firmadas

Para verificar que una solicitud entrante tiene una firma válida, debes llamar al método `hasValidSignature` en la instancia de `Illuminate\Http\Request` entrante:

    use Illuminate\Http\Request;

    Route::get('/unsubscribe/{user}', function (Request $request) {
        if (! $request->hasValidSignature()) {
            abort(401);
        }

        // ...
    })->name('unsubscribe');

A veces, puede que necesites permitir que el frontend de tu aplicación añada datos a una URL firmada, como cuando realizas paginación del lado del cliente. Por lo tanto, puedes especificar parámetros de consulta de solicitud que deben ser ignorados al validar una URL firmada utilizando el método `hasValidSignatureWhileIgnoring`. Recuerda, ignorar parámetros permite que cualquiera modifique esos parámetros en la solicitud:

    if (! $request->hasValidSignatureWhileIgnoring(['page', 'order'])) {
        abort(401);
    }

En lugar de validar URLs firmadas utilizando la instancia de solicitud entrante, puedes asignar el `signed` (`Illuminate\Routing\Middleware\ValidateSignature`) [middleware](/docs/{{version}}/middleware) a la ruta. Si la solicitud entrante no tiene una firma válida, el middleware devolverá automáticamente una respuesta HTTP `403`:

    Route::post('/unsubscribe/{user}', function (Request $request) {
        // ...
    })->name('unsubscribe')->middleware('signed');

Si tus URLs firmadas no incluyen el dominio en el hash de la URL, debes proporcionar el argumento `relative` al middleware:

    Route::post('/unsubscribe/{user}', function (Request $request) {
        // ...
    })->name('unsubscribe')->middleware('signed:relative');

<a name="respondiendo-a-rutas-firmadas-inválidas"></a>
#### Respondiendo a Rutas Firmadas Inválidas

Cuando alguien visita una URL firmada que ha expirado, recibirá una página de error genérica para el código de estado HTTP `403`. Sin embargo, puedes personalizar este comportamiento definiendo una función de "render" personalizada para la excepción `InvalidSignatureException` en el archivo `bootstrap/app.php` de tu aplicación:

    use Illuminate\Routing\Exceptions\InvalidSignatureException;

    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (InvalidSignatureException $e) {
            return response()->view('errors.link-expired', status: 403);
        });
    })

<a name="urls-para-acciones-de-controlador"></a>
## URLs para Acciones de Controlador

La función `action` genera una URL para la acción de controlador dada:

    use App\Http\Controllers\HomeController;

    $url = action([HomeController::class, 'index']);

Si el método del controlador acepta parámetros de ruta, puedes pasar un array asociativo de parámetros de ruta como el segundo argumento a la función:

    $url = action([UserController::class, 'profile'], ['id' => 1]);

<a name="valores-predeterminados"></a>
## Valores Predeterminados

Para algunas aplicaciones, puede que desees especificar valores predeterminados a nivel de solicitud para ciertos parámetros de URL. Por ejemplo, imagina que muchas de tus rutas definen un parámetro `{locale}`:

    Route::get('/{locale}/posts', function () {
        // ...
    })->name('post.index');

Es engorroso tener que pasar siempre el `locale` cada vez que llamas al helper `route`. Por lo tanto, puedes usar el método `URL::defaults` para definir un valor predeterminado para este parámetro que siempre se aplicará durante la solicitud actual. Puede que desees llamar a este método desde un [middleware de ruta](/docs/{{version}}/middleware#assigning-middleware-to-routes) para que tengas acceso a la solicitud actual:

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\URL;
    use Symfony\Component\HttpFoundation\Response;

    class SetDefaultLocaleForUrls
    {
        /**
         * Manejar una solicitud entrante.
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            URL::defaults(['locale' => $request->user()->locale]);

            return $next($request);
        }
    }

Una vez que se ha establecido el valor predeterminado para el parámetro `locale`, ya no se requiere pasar su valor al generar URLs a través del helper `route`.

<a name="url-defaults-middleware-priority"></a>
#### Valores Predeterminados de URL y Prioridad de Middleware

Establecer valores predeterminados de URL puede interferir con el manejo de Laravel de los enlaces de modelo implícitos. Por lo tanto, debes [priorizar tu middleware](/docs/{{version}}/middleware#sorting-middleware) que establece valores predeterminados de URL para que se ejecute antes del propio middleware `SubstituteBindings` de Laravel. Puedes lograr esto utilizando el método de middleware `priority` en el archivo `bootstrap/app.php` de tu aplicación:

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
