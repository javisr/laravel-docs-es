# Autenticación

- [Introducción](#introduction)
  - [Kits de Inicio](#starter-kits)
  - [Consideraciones de Base de Datos](#introduction-database-considerations)
  - [Visión General del Ecosistema](#ecosystem-overview)
- [Inicio Rápido de Autenticación](#authentication-quickstart)
  - [Instalar un Kit de Inicio](#install-a-starter-kit)
  - [Recuperar el Usuario Autenticado](#retrieving-the-authenticated-user)
  - [Proteger Rutas](#protecting-routes)
  - [Limitación de Intentos de Inicio de Sesión](#login-throttling)
- [Autenticación Manual de Usuarios](#authenticating-users)
  - [Recordar Usuarios](#remembering-users)
  - [Otros Métodos de Autenticación](#other-authentication-methods)
- [Autenticación HTTP Básica](#http-basic-authentication)
  - [Autenticación HTTP Básica Sin Estado](#stateless-http-basic-authentication)
- [Cerrar Sesión](#logging-out)
  - [Invalidar Sesiones en Otros Dispositivos](#invalidating-sessions-on-other-devices)
- [Confirmación de Contraseña](#password-confirmation)
  - [Configuración](#password-confirmation-configuration)
  - [Enrutamiento](#password-confirmation-routing)
  - [Proteger Rutas](#password-confirmation-protecting-routes)
- [Agregar Guardias Personalizados](#adding-custom-guards)
  - [Modos de Solicitud de Función Anónima](#closure-request-guards)
- [Agregar Proveedores de Usuario Personalizados](#adding-custom-user-providers)
  - [El Contrato del Proveedor de Usuario](#the-user-provider-contract)
  - [El Contrato Autenticable](#the-authenticatable-contract)
- [Rehashing Automático de Contraseñas](#automatic-password-rehashing)
- [Autenticación Social](/docs/%7B%7Bversion%7D%7D/socialite)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Muchas aplicaciones web ofrecen a sus usuarios una forma de autenticarse en la aplicación y "iniciar sesión". Implementar esta función en aplicaciones web puede ser un esfuerzo complejo y potencialmente arriesgado. Por esta razón, Laravel se esfuerza por proporcionarte las herramientas que necesitas para implementar la autenticación de manera rápida, segura y sencilla.
En su esencia, las instalaciones de autenticación de Laravel están compuestas por "guards" y "providers". Los guards definen cómo se autentican los usuarios para cada solicitud. Por ejemplo, Laravel viene con un guard `session` que mantiene el estado utilizando almacenamiento de sesión y cookies.
Los proveedores definen cómo se recuperan los usuarios de tu almacenamiento persistente. Laravel viene con soporte para recuperar usuarios utilizando [Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) y el constructor de consultas de la base de datos. Sin embargo, puedes definir proveedores adicionales según sea necesario para tu aplicación.
El archivo de configuración de autenticación de tu aplicación se encuentra en `config/auth.php`. Este archivo contiene varias opciones bien documentadas para ajustar el comportamiento de los servicios de autenticación de Laravel.
> [!NOTA]
Los guards y providers no deben confundirse con "roles" y "permisos". Para aprender más sobre cómo autorizar acciones de usuario a través de permisos, consulta la documentación de [autorización](/docs/%7B%7Bversion%7D%7D/authorization).

<a name="starter-kits"></a>
### Kits de Inicio

¿Quieres empezar rápido? Instala un [kit de inicio de aplicación Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits) en una aplicación Laravel nueva. Después de migrar tu base de datos, navega en tu navegador a `/register` o cualquier otra URL que esté asignada a tu aplicación. ¡Los kits de inicio se encargarán de la estructura de todo tu sistema de autenticación!
**Incluso si decides no usar un kit de inicio en tu aplicación Laravel final, instalar el kit de inicio [Laravel Breeze](/docs/%7B%7Bversion%7D%7D/starter-kits#laravel-breeze) puede ser una excelente oportunidad para aprender cómo implementar toda la funcionalidad de autenticación de Laravel en un proyecto Laravel real.** Dado que Laravel Breeze crea controladores de autenticación, rutas y vistas por ti, puedes examinar el código dentro de estos archivos para aprender cómo se pueden implementar las características de autenticación de Laravel.

<a name="introduction-database-considerations"></a>
### Consideraciones de Base de Datos

Por defecto, Laravel incluye un modelo [Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent) `App\Models\User` en tu directorio `app/Models`. Este modelo puede ser utilizado con el driver de autenticación Eloquent predeterminado. Si tu aplicación no está utilizando Eloquent, puedes usar el proveedor de autenticación `database` que utiliza el constructor de consultas de Laravel.
Al construir el esquema de la base de datos para el modelo `App\Models\User`, asegúrate de que la columna de contraseña tenga al menos 60 caracteres de longitud. Por supuesto, la migración de la tabla `users` que se incluye en las nuevas aplicaciones Laravel ya crea una columna que excede esta longitud.
Además, debes verificar que tu tabla `users` (o equivalente) contenga una columna `remember_token` de tipo cadena y nullable de 100 caracteres. Esta columna se utilizará para almacenar un token para los usuarios que seleccionan la opción "recordarme" al iniciar sesión en tu aplicación. Nuevamente, la migración predeterminada de la tabla `users` que se incluye en las nuevas aplicaciones Laravel ya contiene esta columna.

<a name="ecosystem-overview"></a>
### Resumen del Ecosistema

Laravel ofrece varios paquetes relacionados con la autenticación. Antes de continuar, revisaremos el ecosistema general de autenticación en Laravel y discutiremos el propósito de cada paquete.
Primero, considera cómo funciona la autenticación. Al usar un navegador web, un usuario proporcionará su nombre de usuario y contraseña a través de un formulario de inicio de sesión. Si estas credenciales son correctas, la aplicación almacenará información sobre el usuario autenticado en la [sesión](/docs/%7B%7Bversion%7D%7D/session) del usuario. Una cookie emitida al navegador contiene el ID de sesión para que las solicitudes subsiguientes a la aplicación puedan asociar al usuario con la sesión correcta. Después de que se reciba la cookie de sesión, la aplicación recuperará los datos de la sesión según el ID de sesión, notará que la información de autenticación se ha almacenado en la sesión y considerará al usuario como "autenticado".
Cuando un servicio remoto necesita autenticarse para acceder a una API, normalmente no se utilizan cookies para la autenticación porque no hay un navegador web. En su lugar, el servicio remoto envía un token de API a la API en cada solicitud. La aplicación puede validar el token entrante contra una tabla de tokens de API válidos y "autenticar" la solicitud como si fuera realizada por el usuario asociado con ese token de API.

<a name="laravels-built-in-browser-authentication-services"></a>
#### Servicios de Autenticación en el Navegador Integrados de Laravel

Laravel incluye servicios de autenticación y sesión integrados que generalmente se acceden a través de las fachadas `Auth` y `Session`. Estas características proporcionan autenticación basada en cookies para las solicitudes que se inician desde navegadores web. Proporcionan métodos que te permiten verificar las credenciales de un usuario y autenticar al usuario. Además, estos servicios almacenarán automáticamente los datos de autenticación adecuados en la sesión del usuario y emitirán la cookie de sesión del usuario. Una discusión sobre cómo usar estos servicios se encuentra dentro de esta documentación.
**Kits de Inicio para Aplicaciones**
Como se discutió en esta documentación, puedes interactuar manualmente con estos servicios de autenticación para construir la capa de autenticación de tu aplicación. Sin embargo, para ayudarte a comenzar más rápidamente, hemos lanzado [paquetes gratuitos](/docs/%7B%7Bversion%7D%7D/starter-kits) que proporcionan un andamiaje robusto y moderno de toda la capa de autenticación. Estos paquetes son [Laravel Breeze](/docs/%7B%7Bversion%7D%7D/starter-kits#laravel-breeze), [Laravel Jetstream](/docs/%7B%7Bversion%7D%7D/starter-kits#laravel-jetstream) y [Laravel Fortify](/docs/%7B%7Bversion%7D%7D/fortify).
*Laravel Breeze* es una implementación simple y mínima de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. La capa de vista de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/%7B%7Bversion%7D%7D/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Para comenzar, consulta la documentación sobre los [kits de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits) de Laravel.
*Laravel Fortify* es un backend de autenticación sin cabeza para Laravel que implementa muchas de las funcionalidades que se encuentran en esta documentación, incluyendo la autenticación basada en cookies, así como otras características como la autenticación de dos factores y la verificación por correo electrónico. Fortify proporciona el backend de autenticación para Laravel Jetstream o puede usarse de manera independiente en combinación con [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) para proporcionar autenticación para una SPA que necesita autenticarse con Laravel.
*[Laravel Jetstream](https://jetstream.laravel.com)* es un sólido kit de inicio para aplicaciones que consume y expone los servicios de autenticación de Laravel Fortify con una hermosa interfaz moderna impulsada por [Tailwind CSS](https://tailwindcss.com), [Livewire](https://livewire.laravel.com) y / o [Inertia](https://inertiajs.com). Laravel Jetstream incluye soporte opcional para autenticación de dos factores, soporte para equipos, gestión de sesiones del navegador, gestión de perfiles e integración incorporada con [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) para ofrecer autenticación con tokens API. Las ofertas de autenticación API de Laravel se discuten a continuación.

<a name="laravels-api-authentication-services"></a>
#### Servicios de Autenticación API de Laravel

Laravel ofrece dos paquetes opcionales para ayudarte a gestionar tokens API y autenticar solicitudes realizadas con tokens API: [Passport](/docs/%7B%7Bversion%7D%7D/passport) y [Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum). Ten en cuenta que estas bibliotecas y las bibliotecas de autenticación basadas en cookies integradas de Laravel no son mutuamente excluyentes. Estas bibliotecas se centran principalmente en la autenticación con tokens API, mientras que los servicios de autenticación integrados se centran en la autenticación basada en cookies en el navegador. Muchas aplicaciones utilizarán tanto los servicios de autenticación basados en cookies integrados de Laravel como uno de los paquetes de autenticación API de Laravel.
**Passport**
Passport es un proveedor de autenticación OAuth2, que ofrece una variedad de "tipos de concesión" OAuth2 que te permiten emitir varios tipos de tokens. En general, este es un paquete robusto y complejo para la autenticación de API. Sin embargo, la mayoría de las aplicaciones no requieren las características complejas ofrecidas por la especificación OAuth2, que pueden ser confusas tanto para los usuarios como para los desarrolladores. Además, los desarrolladores históricamente han estado confundidos sobre cómo autenticar aplicaciones SPA o aplicaciones móviles utilizando proveedores de autenticación OAuth2 como Passport.
**Sanctum**
En respuesta a la complejidad de OAuth2 y la confusión de los desarrolladores, nos propusimos crear un paquete de autenticación más simple y eficiente que pudiera manejar tanto las solicitudes web de primera parte desde un navegador web como las solicitudes API a través de tokens. Este objetivo se realizó con el lanzamiento de [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum), que debe considerarse el paquete de autenticación preferido y recomendado para aplicaciones que ofrecerán una interfaz web de primera parte además de una API, o que estarán impulsadas por una aplicación de una sola página (SPA) que existe de forma independiente de la aplicación backend de Laravel, o aplicaciones que ofrezcan un cliente móvil.
Laravel Sanctum es un paquete de autenticación híbrido web / API que puede gestionar todo el proceso de autenticación de tu aplicación. Esto es posible porque, cuando las aplicaciones basadas en Sanctum reciben una solicitud, Sanctum primero determinará si la solicitud incluye una cookie de sesión que hace referencia a una sesión autenticada. Sanctum logra esto llamando a los servicios de autenticación incorporados de Laravel, los cuales discutimos anteriormente. Si la solicitud no se está autenticando a través de una cookie de sesión, Sanctum inspeccionará la solicitud en busca de un token API. Si un token API está presente, Sanctum autenticará la solicitud utilizando ese token. Para obtener más información sobre este proceso, consulta la documentación de cómo funciona Sanctum.
Laravel Sanctum es el paquete API que hemos elegido incluir con el kit de inicio de la aplicación [Laravel Jetstream](https://jetstream.laravel.com) porque creemos que es el que mejor se adapta a las necesidades de autenticación de la mayoría de las aplicaciones web.

<a name="summary-choosing-your-stack"></a>
#### Resumen y Elección de Tu Stack

En resumen, si tu aplicación será accedida utilizando un navegador y estás construyendo una aplicación Laravel monolítica, tu aplicación utilizará los servicios de autenticación integrados de Laravel.
A continuación, si tu aplicación ofrece una API que será consumida por terceros, elegirás entre [Passport](/docs/%7B%7Bversion%7D%7D/passport) o [Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) para proporcionar autenticación de tokens API para tu aplicación. En general, se debe preferir Sanctum cuando sea posible, ya que es una solución simple y completa para la autenticación de API, autenticación SPA y autenticación móvil, incluyendo soporte para "scopes" o "abilities".
Si estás construyendo una aplicación de una sola página (SPA) que será impulsada por un backend de Laravel, deberías usar [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum). Al usar Sanctum, necesitarás [implementar manualmente tus propias rutas de autenticación en el backend](#authenticating-users) o utilizar [Laravel Fortify](/docs/%7B%7Bversion%7D%7D/fortify) como un servicio de autenticación headless que proporciona rutas y controladores para funciones como registro, restablecimiento de contraseña, verificación de correo electrónico y más.
Passport puede ser elegido cuando tu aplicación necesita absolutamente todas las características proporcionadas por la especificación OAuth2.
Y, si deseas comenzar rápidamente, nos complace recomendar [Laravel Breeze](/docs/%7B%7Bversion%7D%7D/starter-kits#laravel-breeze) como una forma rápida de iniciar una nueva aplicación Laravel que ya utiliza nuestra pila de autenticación preferida de los servicios de autenticación integrados de Laravel y Laravel Sanctum.

<a name="authentication-quickstart"></a>
## Autenticación Rápida

> [!WARNING]
Esta porción de la documentación trata sobre la autenticación de usuarios a través de los [kits de inicio de aplicación Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits), que incluyen una estructura de UI para ayudarte a comenzar rápidamente. Si deseas integrarte directamente con los sistemas de autenticación de Laravel, consulta la documentación sobre [autenticación manual de usuarios](#authenticating-users).

<a name="install-a-starter-kit"></a>
### Instalar un Kit de Inicio

Primero, debes [instalar un kit de inicio de aplicación Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits). Nuestros kits de inicio actuales, Laravel Breeze y Laravel Jetstream, ofrecen puntos de partida bellamente diseñados para incorporar autenticación en tu nueva aplicación Laravel.
Laravel Breeze es una implementación mínima y simple de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. La capa de vista de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/%7B%7Bversion%7D%7D/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Además, Breeze ofrece opciones de scaffolding basadas en [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com), con la opción de usar Vue o React para el scaffolding basado en Inertia.
[Laravel Jetstream](https://jetstream.laravel.com) es un kit de inicio de aplicaciones más robusto que incluye soporte para escalar tu aplicación con [Livewire](https://livewire.laravel.com) o [Inertia y Vue](https://inertiajs.com). Además, Jetstream cuenta con un soporte opcional para la autenticación de dos factores, equipos, gestión de perfiles, gestión de sesiones de navegador, soporte de API a través de [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum), eliminación de cuentas y más.

<a name="retrieving-the-authenticated-user"></a>
### Recuperando el Usuario Autenticado

Después de instalar un kit de inicio de autenticación y permitir que los usuarios se registren y se autentiquen con tu aplicación, a menudo necesitarás interactuar con el usuario autenticado actualmente. Al manejar una solicitud entrante, puedes acceder al usuario autenticado a través del método `user` de la fachada `Auth`:


```php
use Illuminate\Support\Facades\Auth;

// Retrieve the currently authenticated user...
$user = Auth::user();

// Retrieve the currently authenticated user's ID...
$id = Auth::id();
```
Alternativamente, una vez que un usuario esté autenticado, puedes acceder al usuario autenticado a través de una instancia de `Illuminate\Http\Request`. Recuerda que las clases con tipo indicado se inyectarán automáticamente en los métodos de tu controlador. Al indicar el tipo del objeto `Illuminate\Http\Request`, puedes acceder de manera conveniente al usuario autenticado desde cualquier método del controlador en tu aplicación a través del método `user` de la solicitud:


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class FlightController extends Controller
{
    /**
     * Update the flight information for an existing flight.
     */
    public function update(Request $request): RedirectResponse
    {
        $user = $request->user();

        // ...

        return redirect('/flights');
    }
}
```

<a name="determining-if-the-current-user-is-authenticated"></a>
#### Determinando si el Usuario Actual está Autenticado

Para determinar si el usuario que realiza la solicitud HTTP entrante está autenticado, puedes usar el método `check` en la fachada `Auth`. Este método devolverá `true` si el usuario está autenticado:


```php
use Illuminate\Support\Facades\Auth;

if (Auth::check()) {
    // The user is logged in...
}
```
> [!NOTA]
Aunque es posible determinar si un usuario está autenticado utilizando el método `check`, típicamente usarás un middleware para verificar que el usuario esté autenticado antes de permitir el acceso del usuario a ciertas rutas / controladores. Para obtener más información sobre esto, consulta la documentación sobre [proteger rutas](/docs/%7B%7Bversion%7D%7D/authentication#protecting-routes).

<a name="protecting-routes"></a>
[El middleware de ruta](/docs/%7B%7Bversion%7D%7D/middleware) se puede usar para permitir solo a usuarios autenticados acceder a una ruta dada. Laravel incluye un middleware `auth`, que es un [alias de middleware](/docs/%7B%7Bversion%7D%7D/middleware#middleware-aliases) para la clase `Illuminate\Auth\Middleware\Authenticate`. Dado que este middleware ya está aliased internamente por Laravel, todo lo que necesitas hacer es adjuntar el middleware a una definición de ruta:


```php
Route::get('/flights', function () {
    // Only authenticated users may access this route...
})->middleware('auth');
```

<a name="redirecting-unauthenticated-users"></a>
#### Redirigiendo Usuarios No Autenticados

Cuando el middleware `auth` detecta un usuario no autenticado, redirigirá al usuario a la ruta nombrada `login` [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes). Puedes modificar este comportamiento utilizando el método `redirectGuestsTo` del archivo `bootstrap/app.php` de tu aplicación:


```php
use Illuminate\Http\Request;

->withMiddleware(function (Middleware $middleware) {
    $middleware->redirectGuestsTo('/login');

    // Using a closure...
    $middleware->redirectGuestsTo(fn (Request $request) => route('login'));
})
```

<a name="specifying-a-guard"></a>
#### Especificando un Guard



Al adjuntar el middleware `auth` a una ruta, también puedes especificar qué "guardia" se debe usar para autenticar al usuario. La guardia especificada debe corresponder a una de las claves en el array `guards` de tu archivo de configuración `auth.php`:


```php
Route::get('/flights', function () {
    // Only authenticated users may access this route...
})->middleware('auth:admin');
```

<a name="login-throttling"></a>
### Limitación de Inicio de Sesión

Si estás utilizando los [kits de inicio](/docs/%7B%7Bversion%7D%7D/starter-kits) Laravel Breeze o Laravel Jetstream, se aplicará automáticamente un límite de tasa a los intentos de inicio de sesión. Por defecto, el usuario no podrá iniciar sesión durante un minuto si no proporciona las credenciales correctas después de varios intentos. La limitación es única para el nombre de usuario / dirección de correo electrónico del usuario y su dirección IP.
> [!NOTA]
Si deseas limitar la tasa de otras rutas en tu aplicación, consulta la [documentación de limitación de tasa](/docs/%7B%7Bversion%7D%7D/routing#rate-limiting).

<a name="authenticating-users"></a>
## Autenticando Usuarios Manualmente

No se requiere que utilices el andamiaje de autenticación incluido con los [kits de inicio de la aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits) de Laravel. Si decides no usar este andamiaje, necesitarás gestionar la autenticación de usuarios utilizando directamente las clases de autenticación de Laravel. ¡No te preocupes, es muy fácil!
Accederemos a los servicios de autenticación de Laravel a través de la `facade` [Auth](/docs/%7B%7Bversion%7D%7D/facades), así que necesitaremos asegurarnos de importar la `facade` `Auth` en la parte superior de la clase. A continuación, revisemos el método `attempt`. El método `attempt` se utiliza normalmente para manejar intentos de autenticación desde el formulario de "login" de tu aplicación. Si la autenticación es exitosa, deberías regenerar la [sesión](/docs/%7B%7Bversion%7D%7D/session) del usuario para prevenir la [fijación de sesión](https://en.wikipedia.org/wiki/Session_fixation):


```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /**
     * Handle an authentication attempt.
     */
    public function authenticate(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            return redirect()->intended('dashboard');
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }
}
```
El método `attempt` acepta un array de pares clave / valor como su primer argumento. Los valores en el array se utilizarán para encontrar al usuario en tu tabla de base de datos. Así que, en el ejemplo anterior, el usuario será recuperado por el valor de la columna `email`. Si se encuentra al usuario, la contraseña hash almacenada en la base de datos se comparará con el valor `password` pasado al método a través del array. No debes hash el valor `password` de la solicitud entrante, ya que el framework automáticamente will hash el valor antes de compararlo con la contraseña hash en la base de datos. Se iniciará una sesión autenticada para el usuario si las dos contraseñas hash coinciden.
Recuerda que los servicios de autenticación de Laravel recuperarán usuarios de tu base de datos según la configuración "provider" de tu guardia de autenticación. En el archivo de configuración predeterminado `config/auth.php`, se especifica el proveedor de usuarios Eloquent y se le indica utilizar el modelo `App\Models\User` al recuperar usuarios. Puedes cambiar estos valores dentro de tu archivo de configuración según las necesidades de tu aplicación.
El método `attempt` devolverá `true` si la autenticación fue exitosa. De lo contrario, se devolverá `false`.
El método `intended` proporcionado por el redirigidor de Laravel redirigirá al usuario a la URL a la que intentaba acceder antes de ser interceptado por el middleware de autenticación. Se puede dar una URI de respaldo a este método en caso de que el destino previsto no esté disponible.

<a name="specifying-additional-conditions"></a>
#### Especificando Condiciones Adicionales

Si lo deseas, también puedes agregar condiciones de consulta adicionales a la consulta de autenticación además del correo electrónico y la contraseña del usuario. Para lograr esto, simplemente podemos añadir las condiciones de consulta al array que se pasa al método `attempt`. Por ejemplo, podemos verificar que el usuario esté marcado como "activo":


```php
if (Auth::attempt(['email' => $email, 'password' => $password, 'active' => 1])) {
    // Authentication was successful...
}
```
Para condiciones de consulta complejas, puedes proporcionar una función anónima en tu array de credenciales. Esta función anónima se invocará con la instancia de la consulta, lo que te permitirá personalizar la consulta según las necesidades de tu aplicación:


```php
use Illuminate\Database\Eloquent\Builder;

if (Auth::attempt([
    'email' => $email,
    'password' => $password,
    fn (Builder $query) => $query->has('activeSubscription'),
])) {
    // Authentication was successful...
}
```
> [!WARNING]
En estos ejemplos, `email` no es una opción requerida, simplemente se usa como ejemplo. Debes usar cualquier nombre de columna que corresponda a un "nombre de usuario" en tu tabla de base de datos.
El método `attemptWhen`, que recibe una `función anónima` como su segundo argumento, se puede usar para realizar una inspección más exhaustiva del usuario potencial antes de autenticar realmente al usuario. La `función anónima` recibe al usuario potencial y debe devolver `true` o `false` para indicar si el usuario puede ser autenticado:


```php
if (Auth::attemptWhen([
    'email' => $email,
    'password' => $password,
], function (User $user) {
    return $user->isNotBanned();
})) {
    // Authentication was successful...
}
```

<a name="accessing-specific-guard-instances"></a>
#### Accediendo a Instancias de Guard específico

A través del método `guard` de la fachada `Auth`, puedes especificar qué instancia de guardia te gustaría utilizar al autenticar al usuario. Esto te permite gestionar la autenticación para partes separadas de tu aplicación utilizando modelos o tablas de usuario completamente separados.
El nombre del guardia pasado al método `guard` debe corresponder a uno de los guardias configurados en tu archivo de configuración `auth.php`:


```php
if (Auth::guard('admin')->attempt($credentials)) {
    // ...
}
```

<a name="remembering-users"></a>
### Recordando Usuarios

Muchas aplicaciones web ofrecen una casilla de verificación de "recuérdame" en su formulario de inicio de sesión. Si deseas proporcionar funcionalidad de "recuérdame" en tu aplicación, puedes pasar un valor booleano como segundo argumento al método `attempt`.
Cuando este valor es `true`, Laravel mantendrá al usuario autenticado indefinidamente o hasta que cierre sesión manualmente. La tabla `users` debe incluir la columna de cadena `remember_token`, que se utilizará para almacenar el token de "recuerdame". La migración de la tabla `users` incluida con las nuevas aplicaciones Laravel ya incluye esta columna:


```php
use Illuminate\Support\Facades\Auth;

if (Auth::attempt(['email' => $email, 'password' => $password], $remember)) {
    // The user is being remembered...
}
```
Si tu aplicación ofrece funcionalidad de "recordarme", puedes usar el método `viaRemember` para determinar si el usuario actualmente autenticado fue autenticado utilizando la cookie de "recordarme":


```php
use Illuminate\Support\Facades\Auth;

if (Auth::viaRemember()) {
    // ...
}
```

<a name="other-authentication-methods"></a>
### Otros Métodos de Autenticación


<a name="authenticate-a-user-instance"></a>
#### Autenticar una Instancia de Usuario

Si necesitas establecer una instancia de usuario existente como el usuario autenticado actualmente, puedes pasar la instancia del usuario al método `login` de la fachada `Auth`. La instancia de usuario dada debe ser una implementación del contrato `Illuminate\Contracts\Auth\Authenticatable` [contract](/docs/%7B%7Bversion%7D%7D/contracts). El modelo `App\Models\User` incluido con Laravel ya implementa esta interfaz. Este método de autenticación es útil cuando ya tienes una instancia de usuario válida, como directamente después de que un usuario se registre en tu aplicación:


```php
use Illuminate\Support\Facades\Auth;

Auth::login($user);
```
Puedes pasar un valor booleano como segundo argumento al método `login`. Este valor indica si se desea la funcionalidad de "recordarme" para la sesión autenticada. Recuerda, esto significa que la sesión estará autenticada indefinidamente o hasta que el usuario cierre sesión manualmente de la aplicación:


```php
Auth::login($user, $remember = true);
```
Si es necesario, puedes especificar un guard de autenticación antes de llamar al método `login`:


```php
Auth::guard('admin')->login($user);
```

<a name="authenticate-a-user-by-id"></a>
#### Autenticar un usuario por ID

Para autenticar a un usuario utilizando la clave primaria del registro de su base de datos, puedes usar el método `loginUsingId`. Este método acepta la clave primaria del usuario que deseas autenticar:


```php
Auth::loginUsingId(1);
```
Puedes pasar un valor booleano al argumento `remember` del método `loginUsingId`. Este valor indica si se desea la funcionalidad de "recordarme" para la sesión autenticada. Recuerda, esto significa que la sesión estará autenticada de manera indefinida o hasta que el usuario cierre sesión manualmente en la aplicación:


```php
Auth::loginUsingId(1, remember: true);
```

<a name="authenticate-a-user-once"></a>
#### Autenticar a un Usuario Una vez

Puedes usar el método `once` para autenticar a un usuario con la aplicación para una sola solicitud. No se utilizarán sesiones ni cookies al llamar a este método:


```php
if (Auth::once($credentials)) {
    // ...
}
```

<a name="http-basic-authentication"></a>
## Autenticación Básica HTTP

[HTTP Basic Authentication](https://es.wikipedia.org/wiki/Autenticaci%C3%B3n_basica) proporciona una forma rápida de autenticar a los usuarios de tu aplicación sin configurar una página de "inicio de sesión" dedicada. Para comenzar, adjunta el middleware `auth.basic` a una ruta. El middleware `auth.basic` está incluido con el framework Laravel, por lo que no necesitas definirlo:


```php
Route::get('/profile', function () {
    // Only authenticated users may access this route...
})->middleware('auth.basic');
```
Una vez que el middleware se ha adjuntado a la ruta, se te pedirá automáticamente que ingreses credenciales al acceder a la ruta en tu navegador. Por defecto, el middleware `auth.basic` asumirá que la columna `email` en tu tabla `users` de la base de datos es el "nombre de usuario" del usuario.

<a name="a-note-on-fastcgi"></a>
#### Una Nota sobre FastCGI

Si estás utilizando PHP FastCGI y Apache para servir tu aplicación Laravel, la autenticación HTTP Basic puede no funcionar correctamente. Para corregir estos problemas, se pueden añadir las siguientes líneas al archivo `.htaccess` de tu aplicación:


```apache
RewriteCond %{HTTP:Authorization} ^(.+)$
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

```

<a name="stateless-http-basic-authentication"></a>
### Autenticación Básica HTTP Sin Estado

También puedes usar la Autenticación Básica HTTP sin configurar una cookie de identificador de usuario en la sesión. Esto es principalmente útil si eliges usar la Autenticación HTTP para autenticar solicitudes a la API de tu aplicación. Para lograr esto, [define un middleware](/docs/%7B%7Bversion%7D%7D/middleware) que llame al método `onceBasic`. Si no se devuelve ninguna respuesta por parte del método `onceBasic`, la solicitud puede ser pasada más adelante en la aplicación:


```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AuthenticateOnceWithBasicAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        return Auth::onceBasic() ?: $next($request);
    }

}
```
A continuación, adjunta el middleware a una ruta:


```php
Route::get('/api/user', function () {
    // Only authenticated users may access this route...
})->middleware(AuthenticateOnceWithBasicAuth::class);
```

<a name="logging-out"></a>
## Cierre de Sesión

Para cerrar sesión manualmente a los usuarios de tu aplicación, puedes usar el método `logout` proporcionado por la fachada `Auth`. Esto eliminará la información de autenticación de la sesión del usuario para que las solicitudes posteriores no estén autenticadas.
Además de llamar al método `logout`, se recomienda que invalide la sesión del usuario y regenere su [token CSRF](/docs/%7B%7Bversion%7D%7D/csrf). Después de cerrar la sesión del usuario, típicamente redirigirías al usuario a la raíz de tu aplicación:


```php
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

/**
 * Log the user out of the application.
 */
public function logout(Request $request): RedirectResponse
{
    Auth::logout();

    $request->session()->invalidate();

    $request->session()->regenerateToken();

    return redirect('/');
}
```

<a name="invalidating-sessions-on-other-devices"></a>
### Invalidando Sesiones en Otros Dispositivos

Laravel también proporciona un mecanismo para invalidar y "cerrar sesión" en las sesiones de un usuario que están activas en otros dispositivos sin invalidar la sesión en su dispositivo actual. Esta función se utiliza típicamente cuando un usuario está cambiando o actualizando su contraseña y deseas invalidar las sesiones en otros dispositivos mientras mantienes el dispositivo actual autenticado.
Antes de comenzar, debes asegurarte de que el middleware `Illuminate\Session\Middleware\AuthenticateSession` esté incluido en las rutas que deben recibir autenticación de sesión. Típicamente, debes colocar este middleware en una definición de grupo de rutas para que se aplique a la mayoría de las rutas de tu aplicación. Por defecto, el middleware `AuthenticateSession` puede ser adjuntado a una ruta utilizando el alias de middleware `auth.session` [middleware alias](/docs/%7B%7Bversion%7D%7D/middleware#middleware-aliases):


```php
Route::middleware(['auth', 'auth.session'])->group(function () {
    Route::get('/', function () {
        // ...
    });
});
```
Entonces, puedes usar el método `logoutOtherDevices` proporcionado por la fachada `Auth`. Este método requiere que el usuario confirme su contraseña actual, que tu aplicación debe aceptar a través de un formulario de entrada:


```php
use Illuminate\Support\Facades\Auth;

Auth::logoutOtherDevices($currentPassword);
```
Cuando se invoca el método `logoutOtherDevices`, las otras sesiones del usuario se invalidarán por completo, lo que significa que serán "desconectadas" de todos los guards por los que estaban autenticadas previamente.

<a name="password-confirmation"></a>
## Confirmación de Contraseña

Mientras construyes tu aplicación, es posible que ocasionalmente tengas acciones que requieran que el usuario confirme su contraseña antes de que se realice la acción o antes de que el usuario sea redirigido a un área sensible de la aplicación. Laravel incluye middleware incorporado para hacer que este proceso sea muy sencillo. Implementar esta función requerirá que definas dos rutas: una ruta para mostrar una vista pidiendo al usuario que confirme su contraseña y otra ruta para confirmar que la contraseña es válida y redirigir al usuario a su destino previsto.
> [!NOTE]
La siguiente documentación aborda cómo integrarse directamente con las funciones de confirmación de contraseña de Laravel; sin embargo, si deseas comenzar más rápidamente, los [kits de inicio de aplicación de Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits) incluyen soporte para esta función.

<a name="password-confirmation-configuration"></a>
### Configuración

Después de confirmar su contraseña, a un usuario no se le volverá a pedir que confirme su contraseña durante tres horas. Sin embargo, puedes configurar la duración del tiempo antes de que se le pida al usuario que ingrese su contraseña nuevamente cambiando el valor de la configuración `password_timeout` dentro del archivo de configuración `config/auth.php` de tu aplicación.

<a name="password-confirmation-routing"></a>
### Enrutamiento


<a name="the-password-confirmation-form"></a>
#### El Formulario de Confirmación de Contraseña

Primero, definiremos una ruta para mostrar una vista que le pide al usuario que confirme su contraseña:


```php
Route::get('/confirm-password', function () {
    return view('auth.confirm-password');
})->middleware('auth')->name('password.confirm');
```
Como era de esperar, la vista que devuelve esta ruta debería tener un formulario que contenga un campo `password`. Además, siéntete libre de incluir texto dentro de la vista que explique que el usuario está ingresando a un área protegida de la aplicación y debe confirmar su contraseña.

<a name="confirming-the-password"></a>
#### Confirmando la Contraseña

A continuación, definiremos una ruta que manejará la solicitud del formulario desde la vista "confirmar contraseña". Esta ruta será responsable de validar la contraseña y redirigir al usuario a su destino deseado:


```php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Redirect;

Route::post('/confirm-password', function (Request $request) {
    if (! Hash::check($request->password, $request->user()->password)) {
        return back()->withErrors([
            'password' => ['The provided password does not match our records.']
        ]);
    }

    $request->session()->passwordConfirmed();

    return redirect()->intended();
})->middleware(['auth', 'throttle:6,1']);
```
Antes de continuar, examinemos esta ruta con más detalle. Primero, se determina que el campo `password` de la solicitud coincida con la contraseña del usuario autenticado. Si la contraseña es válida, necesitamos informar a la sesión de Laravel que el usuario ha confirmado su contraseña. El método `passwordConfirmed` establecerá un sello de tiempo en la sesión del usuario que Laravel puede usar para determinar cuándo fue la última vez que el usuario confirmó su contraseña. Finalmente, podemos redirigir al usuario a su destino previsto.

<a name="password-confirmation-protecting-routes"></a>
### Protegiendo Rutas

Debes asegurarte de que cualquier ruta que realice una acción que requiera confirmación reciente de contraseña esté asignada al middleware `password.confirm`. Este middleware se incluye con la instalación predeterminada de Laravel y almacenará automáticamente la intención de destino del usuario en la sesión para que el usuario pueda ser redirigido a esa ubicación después de confirmar su contraseña. Después de almacenar la intención de destino del usuario en la sesión, el middleware redirigirá al usuario a la ruta nombrada `password.confirm` [named route](/docs/%7B%7Bversion%7D%7D/routing#named-routes):


```php
Route::get('/settings', function () {
    // ...
})->middleware(['password.confirm']);

Route::post('/settings', function () {
    // ...
})->middleware(['password.confirm']);
```

<a name="adding-custom-guards"></a>
## Agregar Guardias Personalizados

Puedes definir tus propios guards de autenticación utilizando el método `extend` en la fachada `Auth`. Debes colocar tu llamada al método `extend` dentro de un [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers). Dado que Laravel ya incluye un `AppServiceProvider`, podemos colocar el código en ese proveedor:


```php
<?php

namespace App\Providers;

use App\Services\Auth\JwtGuard;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    // ...

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Auth::extend('jwt', function (Application $app, string $name, array $config) {
            // Return an instance of Illuminate\Contracts\Auth\Guard...

            return new JwtGuard(Auth::createUserProvider($config['provider']));
        });
    }
}
```
Como puedes ver en el ejemplo anterior, la devolución de llamada pasada al método `extend` debe devolver una implementación de `Illuminate\Contracts\Auth\Guard`. Esta interfaz contiene algunos métodos que necesitarás implementar para definir un guardia personalizado. Una vez que tu guardia personalizado haya sido definido, puedes hacer referencia al guardia en la configuración `guards` de tu archivo de configuración `auth.php`:


```php
'guards' => [
    'api' => [
        'driver' => 'jwt',
        'provider' => 'users',
    ],
],
```

<a name="closure-request-guards"></a>
### Guardian de Solicitudes de Función Anónima

La forma más sencilla de implementar un sistema de autenticación basado en solicitudes HTTP personalizadas es utilizando el método `Auth::viaRequest`. Este método te permite definir rápidamente tu proceso de autenticación utilizando una sola función anónima.
Para comenzar, llama al método `Auth::viaRequest` dentro del método `boot` del `AppServiceProvider` de tu aplicación. El método `viaRequest` acepta un nombre de driver de autenticación como su primer argumento. Este nombre puede ser cualquier cadena que describa tu guardia personalizada. El segundo argumento pasado al método debe ser una función anónima que reciba la solicitud HTTP entrante y devuelva una instancia de usuario o, si la autenticación falla, `null`:


```php
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Auth::viaRequest('custom-token', function (Request $request) {
        return User::where('token', (string) $request->token)->first();
    });
}
```
Una vez que tu driver de autenticación personalizado ha sido definido, puedes configurarlo como un driver dentro de la configuración `guards` de tu archivo de configuración `auth.php`:


```php
'guards' => [
    'api' => [
        'driver' => 'custom-token',
    ],
],
```
Finalmente, puedes hacer referencia al guardia al asignar el middleware de autenticación a una ruta:


```php
Route::middleware('auth:api')->group(function () {
    // ...
});
```

<a name="adding-custom-user-providers"></a>
## Agregar Proveedores de Usuarios Personalizados

Si no estás utilizando una base de datos relacional tradicional para almacenar a tus usuarios, necesitarás ampliar Laravel con tu propio proveedor de usuarios de autenticación. Usaremos el método `provider` en la fachada `Auth` para definir un proveedor de usuarios personalizado. El resolvedor de proveedores de usuarios debe devolver una implementación de `Illuminate\Contracts\Auth\UserProvider`:


```php
<?php

namespace App\Providers;

use App\Extensions\MongoUserProvider;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    // ...

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Auth::provider('mongo', function (Application $app, array $config) {
            // Return an instance of Illuminate\Contracts\Auth\UserProvider...

            return new MongoUserProvider($app->make('mongo.connection'));
        });
    }
}
```
Después de haber registrado el proveedor utilizando el método `provider`, puedes cambiar al nuevo proveedor de usuarios en tu archivo de configuración `auth.php`. Primero, define un `provider` que use tu nuevo driver:


```php
'providers' => [
    'users' => [
        'driver' => 'mongo',
    ],
],
```
Finalmente, puedes hacer referencia a este proveedor en tu configuración de `guards`:


```php
'guards' => [
    'web' => [
        'driver' => 'session',
        'provider' => 'users',
    ],
],
```

<a name="the-user-provider-contract"></a>
### El Contrato del Proveedor de Usuarios

Las implementaciones de `Illuminate\Contracts\Auth\UserProvider` son responsables de recuperar una implementación de `Illuminate\Contracts\Auth\Authenticatable` de un sistema de almacenamiento persistente, como MySQL, MongoDB, etc. Estas dos interfaces permiten que los mecanismos de autenticación de Laravel continúen funcionando sin importar cómo se almacenen los datos del usuario o qué tipo de clase se utilice para representar al usuario autenticado:
Echemos un vistazo al contrato `Illuminate\Contracts\Auth\UserProvider`:


```php
<?php

namespace Illuminate\Contracts\Auth;

interface UserProvider
{
    public function retrieveById($identifier);
    public function retrieveByToken($identifier, $token);
    public function updateRememberToken(Authenticatable $user, $token);
    public function retrieveByCredentials(array $credentials);
    public function validateCredentials(Authenticatable $user, array $credentials);
    public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false);
}
```
La función `retrieveById` generalmente recibe una clave que representa al usuario, como un ID autoincremental de una base de datos MySQL. La implementación `Authenticatable` que coincide con el ID debe ser recuperada y devuelta por el método.
La función `retrieveByToken` recupera a un usuario por su `$identifier` único y el `$token` de "recuérdame", que generalmente se almacena en una columna de base de datos como `remember_token`. Al igual que con el método anterior, la implementación `Authenticatable` con un valor de token coincidente debe ser devuelta por este método.
El método `updateRememberToken` actualiza el `remember_token` de la instancia `$user` con el nuevo `$token`. Se asigna un nuevo token a los usuarios en un intento de autenticación "recordarme" exitoso o cuando el usuario está cerrando sesión.
El método `retrieveByCredentials` recibe el array de credenciales pasadas al método `Auth::attempt` al intentar autenticarse con una aplicación. El método debe "consultar" el almacenamiento persistente subyacente en busca del usuario que coincida con esas credenciales. Típicamente, este método realizará una consulta con una condición "where" que busca un registro de usuario con un "nombre de usuario" que coincida con el valor de `$credentials['username']`. El método debe devolver una implementación de `Authenticatable`. **Este método no debe intentar realizar ninguna validación de contraseña o autenticación.**
El método `validateCredentials` debe comparar el `$user` dado con las `$credentials` para autenticar al usuario. Por ejemplo, este método típicamente utilizará el método `Hash::check` para comparar el valor de `$user->getAuthPassword()` con el valor de `$credentials['password']`. Este método debería devolver `true` o `false`, indicando si la contraseña es válida.
El método `rehashPasswordIfRequired` debería volver a hashear la contraseña del `$user` dado si es necesario y soportado. Por ejemplo, este método típicamente utilizará el método `Hash::needsRehash` para determinar si el valor de `$credentials['password']` necesita ser rehasheado. Si la contraseña necesita ser rehasheada, el método debería usar el método `Hash::make` para volver a hashear la contraseña y actualizar el registro del usuario en el almacenamiento persistente subyacente.

<a name="the-authenticatable-contract"></a>
### El Contrato Authenticatable

Ahora que hemos explorado cada uno de los métodos en el `UserProvider`, echemos un vistazo al contrato `Authenticatable`. Recuerda que los proveedores de usuarios deben devolver implementaciones de esta interfaz desde los métodos `retrieveById`, `retrieveByToken` y `retrieveByCredentials`:


```php
<?php

namespace Illuminate\Contracts\Auth;

interface Authenticatable
{
    public function getAuthIdentifierName();
    public function getAuthIdentifier();
    public function getAuthPasswordName();
    public function getAuthPassword();
    public function getRememberToken();
    public function setRememberToken($value);
    public function getRememberTokenName();
}
```
Esta interfaz es simple. El método `getAuthIdentifierName` debe devolver el nombre de la columna "clave primaria" para el usuario y el método `getAuthIdentifier` debe devolver la "clave primaria" del usuario. Al usar un backend MySQL, esto probablemente sería la clave primaria autoincremental asignada al registro del usuario. El método `getAuthPasswordName` debe devolver el nombre de la columna de contraseña del usuario. El método `getAuthPassword` debe devolver la contraseña hash del usuario.
Esta interfaz permite que el sistema de autenticación funcione con cualquier clase de "usuario", sin importar qué ORM o capa de abstracción de almacenamiento estés utilizando. Por defecto, Laravel incluye una clase `App\Models\User` en el directorio `app/Models` que implementa esta interfaz.

<a name="automatic-password-rehashing"></a>
## Rehashing Automático de Contraseñas

El algoritmo de hash de contraseñas predeterminado de Laravel es bcrypt. El "factor de trabajo" para los hashes bcrypt se puede ajustar a través del archivo de configuración `config/hashing.php` de tu aplicación o la variable de entorno `BCRYPT_ROUNDS`.
Típicamente, el factor de trabajo de bcrypt debería aumentarse con el tiempo a medida que aumenta la potencia de procesamiento de CPU / GPU. Si aumentas el factor de trabajo de bcrypt para tu aplicación, Laravel volverá a realizar el hash de las contraseñas de los usuarios de manera automática y sin problemas a medida que los usuarios se autentiquen en tu aplicación a través de los kits de inicio de Laravel o cuando [autenticues a usuarios manualmente](#authenticating-users) mediante el método `attempt`.
Típicamente, el rehashing automático de contraseñas no debería interrumpir tu aplicación; sin embargo, puedes desactivar este comportamiento publicando el archivo de configuración `hashing`:


```shell
php artisan config:publish hashing

```
Una vez que se haya publicado el archivo de configuración, puedes establecer el valor de configuración `rehash_on_login` en `false`:


```php
'rehash_on_login' => false,

```

<a name="events"></a>
## Eventos

Laravel despacha una variedad de [eventos](/docs/%7B%7Bversion%7D%7D/events) durante el proceso de autenticación. Puedes [definir oyentes](/docs/%7B%7Bversion%7D%7D/events) para cualquiera de los siguientes eventos:
<div class="overflow-auto">

| Nombre del Evento |
| --- |
| `Illuminate\Auth\Events\Registered` |
| `Illuminate\Auth\Events\Attempting` |
| `Illuminate\Auth\Events\Authenticated` |
| `Illuminate\Auth\Events\Login` |
| `Illuminate\Auth\Events\Failed` |
| `Illuminate\Auth\Events\Validated` |
| `Illuminate\Auth\Events\Verified` |
| `Illuminate\Auth\Events\Logout` |
| `Illuminate\Auth\Events\CurrentDeviceLogout` |
| `Illuminate\Auth\Events\OtherDeviceLogout` |
| `Illuminate\Auth\Events\Lockout` |
| `Illuminate\Auth\Events\PasswordReset` |
</div>