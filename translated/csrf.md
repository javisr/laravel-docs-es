# Protección CSRF

- [Introducción](#csrf-introduction)
- [Prevención de Solicitudes CSRF](#preventing-csrf-requests)
    - [Exclusión de URIs](#csrf-excluding-uris)
- [X-CSRF-Token](#csrf-x-csrf-token)
- [X-XSRF-Token](#csrf-x-xsrf-token)

<a name="csrf-introduction"></a>
## Introducción

Las falsificaciones de solicitudes entre sitios son un tipo de explotación maliciosa mediante la cual se realizan comandos no autorizados en nombre de un usuario autenticado. Afortunadamente, Laravel facilita la protección de tu aplicación contra ataques de [falsificación de solicitudes entre sitios](https://en.wikipedia.org/wiki/Cross-site_request_forgery) (CSRF).

<a name="csrf-explanation"></a>
#### Una Explicación de la Vulnerabilidad

En caso de que no estés familiarizado con las falsificaciones de solicitudes entre sitios, discutamos un ejemplo de cómo se puede explotar esta vulnerabilidad. Imagina que tu aplicación tiene una ruta `/user/email` que acepta una solicitud `POST` para cambiar la dirección de correo electrónico del usuario autenticado. Lo más probable es que esta ruta espere que un campo de entrada `email` contenga la dirección de correo electrónico que el usuario desea comenzar a usar.

Sin protección CSRF, un sitio web malicioso podría crear un formulario HTML que apunte a la ruta `/user/email` de tu aplicación y envíe la propia dirección de correo electrónico del usuario malicioso:

```blade
<form action="https://your-application.com/user/email" method="POST">
    <input type="email" value="malicious-email@example.com">
</form>

<script>
    document.forms[0].submit();
</script>
```

Si el sitio web malicioso envía automáticamente el formulario cuando se carga la página, el usuario malicioso solo necesita atraer a un usuario desprevenido de tu aplicación para que visite su sitio web y su dirección de correo electrónico será cambiada en tu aplicación.

Para prevenir esta vulnerabilidad, necesitamos inspeccionar cada solicitud entrante `POST`, `PUT`, `PATCH` o `DELETE` en busca de un valor de sesión secreto al que la aplicación maliciosa no pueda acceder.

<a name="preventing-csrf-requests"></a>
## Prevención de Solicitudes CSRF

Laravel genera automáticamente un "token" CSRF para cada [sesión de usuario](/docs/{{version}}/session) activa gestionada por la aplicación. Este token se utiliza para verificar que el usuario autenticado es la persona que realmente está realizando las solicitudes a la aplicación. Dado que este token se almacena en la sesión del usuario y cambia cada vez que se regenera la sesión, una aplicación maliciosa no puede acceder a él.

El token CSRF de la sesión actual se puede acceder a través de la sesión de la solicitud o mediante la función auxiliar `csrf_token`:

    use Illuminate\Http\Request;

    Route::get('/token', function (Request $request) {
        $token = $request->session()->token();

        $token = csrf_token();

        // ...
    });

Cada vez que defines un formulario HTML "POST", "PUT", "PATCH" o "DELETE" en tu aplicación, debes incluir un campo oculto CSRF `_token` en el formulario para que el middleware de protección CSRF pueda validar la solicitud. Para mayor comodidad, puedes usar la directiva Blade `@csrf` para generar el campo de entrada del token oculto:

```blade
<form method="POST" action="/profile">
    @csrf

    <!-- Equivalent to... -->
    <input type="hidden" name="_token" value="{{ csrf_token() }}" />
</form>
```

El `Illuminate\Foundation\Http\Middleware\ValidateCsrfToken` [middleware](/docs/{{version}}/middleware), que se incluye en el grupo de middleware `web` por defecto, verificará automáticamente que el token en la entrada de la solicitud coincida con el token almacenado en la sesión. Cuando estos dos tokens coinciden, sabemos que el usuario autenticado es quien está iniciando la solicitud.

<a name="csrf-tokens-and-spas"></a>
### Tokens CSRF y SPAs

Si estás construyendo una SPA que utiliza Laravel como backend API, debes consultar la [documentación de Laravel Sanctum](/docs/{{version}}/sanctum) para obtener información sobre la autenticación con tu API y la protección contra vulnerabilidades CSRF.

<a name="csrf-excluding-uris"></a>
### Exclusión de URIs de la Protección CSRF

A veces, es posible que desees excluir un conjunto de URIs de la protección CSRF. Por ejemplo, si estás utilizando [Stripe](https://stripe.com) para procesar pagos y estás utilizando su sistema de webhook, necesitarás excluir tu ruta de controlador de webhook de Stripe de la protección CSRF, ya que Stripe no sabrá qué token CSRF enviar a tus rutas.

Típicamente, deberías colocar este tipo de rutas fuera del grupo de middleware `web` que Laravel aplica a todas las rutas en el archivo `routes/web.php`. Sin embargo, también puedes excluir rutas específicas proporcionando sus URIs al método `validateCsrfTokens` en el archivo `bootstrap/app.php` de tu aplicación:

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->validateCsrfTokens(except: [
            'stripe/*',
            'http://example.com/foo/bar',
            'http://example.com/foo/*',
        ]);
    })

> [!NOTE]  
> Para mayor comodidad, el middleware CSRF está automáticamente deshabilitado para todas las rutas al [realizar pruebas](/docs/{{version}}/testing).

<a name="csrf-x-csrf-token"></a>
## X-CSRF-TOKEN

Además de verificar el token CSRF como un parámetro POST, el middleware `Illuminate\Foundation\Http\Middleware\ValidateCsrfToken`, que se incluye en el grupo de middleware `web` por defecto, también verificará el encabezado de solicitud `X-CSRF-TOKEN`. Podrías, por ejemplo, almacenar el token en una etiqueta `meta` HTML:

```blade
<meta name="csrf-token" content="{{ csrf_token() }}">
```

Luego, puedes instruir a una biblioteca como jQuery para que agregue automáticamente el token a todos los encabezados de solicitud. Esto proporciona una protección CSRF simple y conveniente para tus aplicaciones basadas en AJAX utilizando tecnología JavaScript heredada:

```js
$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});
```

<a name="csrf-x-xsrf-token"></a>
## X-XSRF-TOKEN

Laravel almacena el token CSRF actual en una cookie `XSRF-TOKEN` encriptada que se incluye con cada respuesta generada por el framework. Puedes usar el valor de la cookie para establecer el encabezado de solicitud `X-XSRF-TOKEN`.

Esta cookie se envía principalmente como una conveniencia para el desarrollador, ya que algunos frameworks y bibliotecas de JavaScript, como Angular y Axios, colocan automáticamente su valor en el encabezado `X-XSRF-TOKEN` en solicitudes de mismo origen.

> [!NOTE]  
> Por defecto, el archivo `resources/js/bootstrap.js` incluye la biblioteca HTTP Axios que enviará automáticamente el encabezado `X-XSRF-TOKEN` por ti.
