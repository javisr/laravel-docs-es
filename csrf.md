# Protección CSRF

- [Introducción](#csrf-introduction)
- [Prevención de Solicitudes CSRF](#preventing-csrf-requests)
  - [Excluyendo URIs](#csrf-excluding-uris)
- [X-CSRF-Token](#csrf-x-csrf-token)
- [X-XSRF-Token](#csrf-x-xsrf-token)

<a name="csrf-introduction"></a>
## Introducción

Los ataques de falsificación de solicitudes entre sitios son un tipo de explotación maliciosa mediante la cual se realizan comandos no autorizados en nombre de un usuario autenticado. Afortunadamente, Laravel facilita la protección de tu aplicación contra ataques de [falsificación de solicitudes entre sitios](https://es.wikipedia.org/wiki/Falsificaci%C3%B3n_de_solicitudes_de_sitio_cruzado) (CSRF).

<a name="csrf-explanation"></a>
#### Una Explicación de la Vulnerabilidad

En caso de que no estés familiarizado con las falsificaciones de solicitudes entre sitios, discutamos un ejemplo de cómo se puede explotar esta vulnerabilidad. Imagina que tu aplicación tiene una ruta `/user/email` que acepta una solicitud `POST` para cambiar la dirección de correo electrónico del usuario autenticado. Lo más probable es que esta ruta espere que un campo de entrada `email` contenga la dirección de correo electrónico que el usuario desee comenzar a usar.
Sin protección CSRF, un sitio web malicioso podría crear un formulario HTML que apunte a la ruta `/user/email` de tu aplicación y envíe la dirección de correo electrónico del propio usuario malicioso:


```blade
<form action="https://your-application.com/user/email" method="POST">
    <input type="email" value="malicious-email@example.com">
</form>

<script>
    document.forms[0].submit();
</script>

```
Si el sitio web malicioso envía automáticamente el formulario cuando se carga la página, el usuario malicioso solo necesita atraer a un usuario desprevenido de tu aplicación para que visite su sitio web y su dirección de correo electrónico será cambiada en tu aplicación.
Para prevenir esta vulnerabilidad, necesitamos inspeccionar cada solicitud `POST`, `PUT`, `PATCH` o `DELETE` entrante en busca de un valor de sesión secreto que la aplicación maliciosa no pueda acceder.

<a name="preventing-csrf-requests"></a>
## Previniendo Solicitudes CSRF

Laravel genera automáticamente un "token" CSRF para cada [sesión de usuario](/docs/%7B%7Bversion%7D%7D/session) activa gestionada por la aplicación. Este token se utiliza para verificar que el usuario autenticado es la persona que realmente está haciendo las solicitudes a la aplicación. Dado que este token se almacena en la sesión del usuario y cambia cada vez que se regenera la sesión, una aplicación maliciosa no puede acceder a él.
El token CSRF de la sesión actual se puede acceder a través de la sesión de la solicitud o a través de la función auxiliar `csrf_token`:


```php
use Illuminate\Http\Request;

Route::get('/token', function (Request $request) {
    $token = $request->session()->token();

    $token = csrf_token();

    // ...
});
```
Cada vez que definas un formulario HTML "POST", "PUT", "PATCH" o "DELETE" en tu aplicación, debes incluir un campo oculto CSRF `_token` en el formulario para que el middleware de protección CSRF pueda validar la solicitud. Para mayor comodidad, puedes usar la directiva `@csrf` de Blade para generar el campo de entrada del token oculto:


```blade
<form method="POST" action="/profile">
    @csrf

    <!-- Equivalent to... -->
    <input type="hidden" name="_token" value="{{ csrf_token() }}" />
</form>

```
El middleware `Illuminate\Foundation\Http\Middleware\ValidateCsrfToken` [middleware](/docs/%7B%7Bversion%7D%7D/middleware), que se incluye en el grupo de middleware `web` por defecto, verificará automáticamente que el token en la entrada de la solicitud coincida con el token almacenado en la sesión. Cuando estos dos tokens coinciden, sabemos que el usuario autenticado es quien está iniciando la solicitud.

<a name="csrf-tokens-and-spas"></a>
### Tokens CSRF y SPAs

Si estás construyendo una SPA que utiliza Laravel como backend API, debes consultar la [documentación de Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) para obtener información sobre la autenticación con tu API y la protección contra vulnerabilidades CSRF.

<a name="csrf-excluding-uris"></a>
### Excluyendo URI de la Protección CSRF

A veces es posible que desees excluir un conjunto de URIs de la protección CSRF. Por ejemplo, si estás utilizando [Stripe](https://stripe.com) para procesar pagos y estás utilizando su sistema de webhook, necesitarás excluir tu ruta del controlador de webhook de Stripe de la protección CSRF, ya que Stripe no sabrá qué token CSRF enviar a tus rutas.
Típicamente, deberías colocar este tipo de rutas fuera del grupo de middleware `web` que Laravel aplica a todas las rutas en el archivo `routes/web.php`. Sin embargo, también puedes excluir rutas específicas proporcionando sus URIs al método `validateCsrfTokens` en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->validateCsrfTokens(except: [
        'stripe/*',
        'http://example.com/foo/bar',
        'http://example.com/foo/*',
    ]);
})
```
> [!NOTA]
Para mayor comodidad, el middleware CSRF se desactiva automáticamente para todas las rutas al [realizar pruebas](/docs/%7B%7Bversion%7D%7D/testing).

<a name="csrf-x-csrf-token"></a>
## X-CSRF-TOKEN

Además de verificar el token CSRF como un parámetro POST, el middleware `Illuminate\Foundation\Http\Middleware\ValidateCsrfToken`, que se incluye en el grupo de middleware `web` por defecto, también verificará el encabezado de solicitud `X-CSRF-TOKEN`. Podrías, por ejemplo, almacenar el token en una etiqueta `meta` HTML:


```blade
<meta name="csrf-token" content="{{ csrf_token() }}">

```
Entonces, puedes instruir a una biblioteca como jQuery para que añada automáticamente el token a todos los encabezados de la solicitud. Esto proporciona una protección CSRF simple y conveniente para tus aplicaciones basadas en AJAX utilizando tecnología JavaScript legada:


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
Esta cookie se envía principalmente como una conveniencia para desarrolladores, ya que algunos frameworks y bibliotecas de JavaScript, como Angular y Axios, colocan automáticamente su valor en el encabezado `X-XSRF-TOKEN` en solicitudes de mismo origen.
> [!NOTA]
Por defecto, el archivo `resources/js/bootstrap.js` incluye la biblioteca HTTP Axios, que enviará automáticamente el encabezado `X-XSRF-TOKEN` por ti.