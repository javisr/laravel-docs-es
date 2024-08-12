# Protección CSRF

- [Introducción](#csrf-introduction)
- [Prevención de solicitudes CSRF](#preventing-csrf-requests)
  - [Excluir URIs](#csrf-excluding-uris)
- [X-CSRF-Token](#csrf-x-csrf-token)
- [X-XSRF-Token](#csrf-x-xsrf-token)

<a name="csrf-introduction"></a>
## Introducción

Las falsificaciones de peticiones entre sitios son un tipo de exploit malicioso mediante el cual se ejecutan comandos no autorizados en nombre de un usuario autenticado. Afortunadamente, Laravel hace que sea fácil de proteger su aplicación contra ataques de [falsificación de petición de sitio cruzado](https://en.wikipedia.org/wiki/Cross-site_request_forgery) (CSRF).

<a name="csrf-explanation"></a>
#### Explicación de la vulnerabilidad

En caso de que no estés familiarizado con las falsificaciones de peticiones entre sitios, vamos a exponer un ejemplo de cómo esta vulnerabilidad puede ser explotada. Imagina que tu aplicación tiene una ruta `/user/email` que acepta una petición `POST` para cambiar la dirección de correo electrónico del usuario autenticado. Lo más probable es que esta ruta espere que un campo de entrada de `email` contenga la dirección de correo electrónico que al usuario le gustaría empezar a utilizar.

Sin protección CSRF, un sitio web malicioso podría crear un formulario HTML que apunte a la ruta `/user/email` de su aplicación y envíe la propia dirección de correo electrónico del usuario malicioso:

```blade
<form action="https://your-application.com/user/email" method="POST">
    <input type="email" value="malicious-email@example.com">
</form>

<script>
    document.forms[0].submit();
</script>
```

Si el sitio web malicioso envía automáticamente el formulario cuando se carga la página, el usuario malicioso sólo tiene que atraer a un usuario desprevenido de tu aplicación para que visite su sitio web y su dirección de correo electrónico se cambiará en la aplicación.

Para prevenir esta vulnerabilidad, necesitamos inspeccionar cada petición `POST`, `PUT`, `PATCH`, o `DELETE` entrante en busca de un valor de sesión secreto al que la aplicación maliciosa no pueda acceder.

<a name="preventing-csrf-requests"></a>
## Prevención de solicitudes CSRF

Laravel genera automáticamente un "token" CSRF para cada [sesión de usuario](/docs/{{version}}/session) activa gestionada por la aplicación. Este token se utiliza para verificar que el usuario autenticado es la persona que realmente realiza las peticiones a la aplicación. Como este token se almacena en la sesión del usuario y cambia cada vez que se regenera la sesión, una aplicación maliciosa no puede acceder a él.

Se puede acceder al token CSRF de la sesión actual a través de la sesión de la petición o a través de la función de ayuda `csrf_token`:

    use Illuminate\Http\Request;

    Route::get('/token', function (Request $request) {
        $token = $request->session()->token();

        $token = csrf_token();

        // ...
    });

Cada vez que defina un formulario HTML "POST", "PUT", "PATCH" o "DELETE" en su aplicación, debe incluir un campo oculto CSRF `_token` en el formulario para que el middleware protección CSRF pueda validar la solicitud. Para mayor comodidad, puede utilizar la directiva `@csrf` Blade para generar el campo de entrada de token oculto:

```blade
<form method="POST" action="/profile">
    @csrf

    <!-- Equivalent to... -->
    <input type="hidden" name="_token" value="{{ csrf_token() }}" />
</form>
```

El [middleware](/docs/{{version}}/middleware) `App\Http\middleware\VerifyCsrfToken`, que está incluido en el grupo de middleware `web` por defecto, verificará automáticamente que el token en la entrada de la petición coincide con el token almacenado en la sesión. Cuando estos dos tokens coinciden, sabemos que el usuario autenticado es el que inicia la petición.

<a name="csrf-tokens-and-spas"></a>
### Tokens CSRF y SPAs

Si estás construyendo una SPA que utiliza Laravel como API backend, deberías consultar la [documentación de Laravel Sanctum](/docs/{{version}}/sanctum) para obtener información sobre la autenticación con tu API y la protección contra vulnerabilidades CSRF.

<a name="csrf-excluding-uris"></a>
### Excluir URIs de la protección CSRF

A veces puede que desee excluir un conjunto de URIs de la protección CSRF. Por ejemplo, si está utilizando [Stripe](https://stripe.com) para procesar pagos y está utilizando su sistema de webhooks, necesitará excluir su ruta de gestión de webhooks de Stripe de la protección CSRF ya que Stripe no sabrá qué token CSRF enviar a sus rutas.

Normalmente, debe colocar este tipo de rutas fuera del grupo de middleware `web` que `App\Providers\RouteServiceProvider` aplica a todas las rutas en el archivo `routes/web.php`. Sin embargo, también puede excluir las rutas añadiendo sus URIs a la propiedad `$except` del middleware `VerifyCsrfToken`:

    <?php

    namespace App\Http\Middleware;

    use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

    class VerifyCsrfToken extends Middleware
    {
        /**
         * The URIs that should be excluded from CSRF verification.
         *
         * @var array
         */
        protected $except = [
            'stripe/*',
            'http://example.com/foo/bar',
            'http://example.com/foo/*',
        ];
    }

> **Nota**  
> Para mayor comodidad, el middleware CSRF se desactiva automáticamente para todas las rutas cuando [se ejecutan tests](/docs/{{version}}/testing).

<a name="csrf-x-csrf-token"></a>
## X-CSRF-TOKEN

Además de comprobar el token CSRF como parámetro POST, el middleware `App\Http\Middleware\VerifyCsrfToken` también comprobará la cabecera de petición `X-CSRF-TOKEN`. Podría, por ejemplo, almacenar el token en una etiqueta `meta` de HTML:

```blade
<meta name="csrf-token" content="{{ csrf_token() }}">
```

A continuación, puede indicar a una biblioteca como jQuery que añada automáticamente el token a todas las cabeceras de solicitud. Esto proporciona una protección CSRF simple y conveniente para sus aplicaciones basadas en AJAX que utilizan tecnología JavaScript heredada:

```js
$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});
```

<a name="csrf-x-xsrf-token"></a>
## X-XSRF-TOKEN

Laravel almacena el token CSRF actual en una cookie `XSRF-TOKEN` cifrada que se incluye en cada respuesta generada por el framework. Puedes utilizar el valor de la cookie para establecer la cabecera de petición `X-XSRF-TOKEN`.

Esta cookie se envía principalmente para comodidad del desarrollador, ya que algunos frameworks y bibliotecas JavaScript, como Angular y Axios, colocan automáticamente su valor en la cabecera `X-XSRF-TOKEN` en las solicitudes con el mismo origen.

> **Nota**  
> Por defecto, el archivo `resources/js/bootstrap.js` incluye la librería HTTP Axios que enviará automáticamente la cabecera `X-XSRF-TOKEN` por ti.
