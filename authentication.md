# Autenticación

- [Introducción](#introduction)
    - [Kits de Inicio](#starter-kits)
    - [Consideraciones de Base de Datos](#introduction-database-considerations)
    - [Descripción General del Ecosistema](#ecosystem-overview)
- [Guía Rápida de Autenticación](#authentication-quickstart)
    - [Instalar un Kit de Inicio](#install-a-starter-kit)
    - [Recuperar el Usuario Autenticado](#retrieving-the-authenticated-user)
    - [Proteger Rutas](#protecting-routes)
    - [Limitación de Inicios de Sesión](#login-throttling)
- [Autenticación Manual de Usuarios](#authenticating-users)
    - [Recordar Usuarios](#remembering-users)
    - [Otros Métodos de Autenticación](#other-authentication-methods)
- [Autenticación Básica HTTP](#http-basic-authentication)
    - [Autenticación Básica HTTP Sin Estado](#stateless-http-basic-authentication)
- [Cerrar Sesión](#logging-out)
    - [Invalidar Sesiones en Otros Dispositivos](#invalidating-sessions-on-other-devices)
- [Confirmación de Contraseña](#password-confirmation)
    - [Configuración](#password-confirmation-configuration)
    - [Enrutamiento](#password-confirmation-routing)
    - [Proteger Rutas](#password-confirmation-protecting-routes)
- [Agregar Guardias Personalizados](#adding-custom-guards)
    - [Guardias de Solicitud de Función Anónima](#closure-request-guards)
- [Agregar Proveedores de Usuario Personalizados](#adding-custom-user-providers)
    - [El Contrato del Proveedor de Usuario](#the-user-provider-contract)
    - [El Contrato Autenticable](#the-authenticatable-contract)
- [Rehashing Automático de Contraseña](#automatic-password-rehashing)
- [Autenticación Social](/docs/{{version}}/socialite)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Muchas aplicaciones web proporcionan una forma para que sus usuarios se autentiquen con la aplicación y "inicien sesión". Implementar esta función en aplicaciones web puede ser un esfuerzo complejo y potencialmente arriesgado. Por esta razón, Laravel se esfuerza por brindarte las herramientas que necesitas para implementar la autenticación de manera rápida, segura y sencilla.

En su núcleo, las facilidades de autenticación de Laravel están compuestas por "guardias" y "proveedores". Las guardias definen cómo se autentican los usuarios para cada solicitud. Por ejemplo, Laravel incluye una guardia de `session` que mantiene el estado utilizando almacenamiento de sesión y cookies.

Los proveedores definen cómo se recuperan los usuarios de tu almacenamiento persistente. Laravel incluye soporte para recuperar usuarios utilizando [Eloquent](/docs/{{version}}/eloquent) y el constructor de consultas de base de datos. Sin embargo, eres libre de definir proveedores adicionales según sea necesario para tu aplicación.

El archivo de configuración de autenticación de tu aplicación se encuentra en `config/auth.php`. Este archivo contiene varias opciones bien documentadas para ajustar el comportamiento de los servicios de autenticación de Laravel.

> [!NOTE]  
> Las guardias y los proveedores no deben confundirse con "roles" y "permisos". Para aprender más sobre cómo autorizar acciones de usuario a través de permisos, consulta la documentación sobre [autorización](/docs/{{version}}/authorization).

<a name="starter-kits"></a>
### Kits de Inicio

¿Quieres empezar rápido? Instala un [kit de inicio de aplicación Laravel](/docs/{{version}}/starter-kits) en una nueva aplicación Laravel. Después de migrar tu base de datos, navega en tu navegador a `/register` o cualquier otra URL que esté asignada a tu aplicación. ¡Los kits de inicio se encargarán de estructurar todo tu sistema de autenticación!

**Incluso si decides no usar un kit de inicio en tu aplicación Laravel final, instalar el kit de inicio [Laravel Breeze](/docs/{{version}}/starter-kits#laravel-breeze) puede ser una maravillosa oportunidad para aprender cómo implementar toda la funcionalidad de autenticación de Laravel en un proyecto Laravel real.** Dado que Laravel Breeze crea controladores de autenticación, rutas y vistas para ti, puedes examinar el código dentro de estos archivos para aprender cómo se pueden implementar las características de autenticación de Laravel.

<a name="introduction-database-considerations"></a>
### Consideraciones de Base de Datos

Por defecto, Laravel incluye un modelo [Eloquent](/docs/{{version}}/eloquent) `App\Models\User` en tu directorio `app/Models`. Este modelo puede ser utilizado con el controlador de autenticación Eloquent predeterminado. Si tu aplicación no está utilizando Eloquent, puedes usar el proveedor de autenticación `database` que utiliza el constructor de consultas de Laravel.

Al construir el esquema de base de datos para el modelo `App\Models\User`, asegúrate de que la columna de contraseña tenga al menos 60 caracteres de longitud. Por supuesto, la migración de la tabla `users` que se incluye en nuevas aplicaciones Laravel ya crea una columna que excede esta longitud.

Además, debes verificar que tu tabla `users` (o equivalente) contenga una columna `remember_token` de tipo string y nullable de 100 caracteres. Esta columna se utilizará para almacenar un token para los usuarios que seleccionen la opción "recordarme" al iniciar sesión en tu aplicación. Nuevamente, la migración de la tabla `users` que se incluye en nuevas aplicaciones Laravel ya contiene esta columna.

<a name="ecosystem-overview"></a>
### Descripción General del Ecosistema

Laravel ofrece varios paquetes relacionados con la autenticación. Antes de continuar, revisaremos el ecosistema general de autenticación en Laravel y discutiremos el propósito de cada paquete.

Primero, considera cómo funciona la autenticación. Al usar un navegador web, un usuario proporcionará su nombre de usuario y contraseña a través de un formulario de inicio de sesión. Si estas credenciales son correctas, la aplicación almacenará información sobre el usuario autenticado en la [sesión](/docs/{{version}}/session) del usuario. Una cookie emitida al navegador contiene el ID de sesión para que las solicitudes posteriores a la aplicación puedan asociar al usuario con la sesión correcta. Después de que se recibe la cookie de sesión, la aplicación recuperará los datos de la sesión basándose en el ID de sesión, notará que la información de autenticación se ha almacenado en la sesión y considerará al usuario como "autenticado".

Cuando un servicio remoto necesita autenticarse para acceder a una API, las cookies no se utilizan típicamente para la autenticación porque no hay un navegador web. En su lugar, el servicio remoto envía un token de API a la API en cada solicitud. La aplicación puede validar el token entrante contra una tabla de tokens de API válidos y "autenticar" la solicitud como realizada por el usuario asociado con ese token de API.

<a name="laravels-built-in-browser-authentication-services"></a>
#### Servicios de Autenticación de Navegador Integrados de Laravel

Laravel incluye servicios de autenticación y sesión integrados que generalmente se acceden a través de los facades `Auth` y `Session`. Estas características proporcionan autenticación basada en cookies para solicitudes que se inician desde navegadores web. Proporcionan métodos que te permiten verificar las credenciales de un usuario y autenticar al usuario. Además, estos servicios almacenarán automáticamente los datos de autenticación adecuados en la sesión del usuario y emitirán la cookie de sesión del usuario. Una discusión sobre cómo usar estos servicios se encuentra en esta documentación.

**Kits de Inicio de Aplicaciones**

Como se discutió en esta documentación, puedes interactuar manualmente con estos servicios de autenticación para construir tu propia capa de autenticación de la aplicación. Sin embargo, para ayudarte a comenzar más rápido, hemos lanzado [paquetes gratuitos](/docs/{{version}}/starter-kits) que proporcionan una estructura robusta y moderna de toda la capa de autenticación. Estos paquetes son [Laravel Breeze](/docs/{{version}}/starter-kits#laravel-breeze), [Laravel Jetstream](/docs/{{version}}/starter-kits#laravel-jetstream) y [Laravel Fortify](/docs/{{version}}/fortify).

_Laravel Breeze_ es una implementación simple y mínima de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. La capa de vista de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/{{version}}/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Para comenzar, consulta la documentación sobre los [kits de inicio de aplicación de Laravel](/docs/{{version}}/starter-kits).

_Laravel Fortify_ es un backend de autenticación headless para Laravel que implementa muchas de las características que se encuentran en esta documentación, incluyendo autenticación basada en cookies, así como otras características como autenticación de dos factores y verificación de correo electrónico. Fortify proporciona el backend de autenticación para Laravel Jetstream o puede ser utilizado de forma independiente en combinación con [Laravel Sanctum](/docs/{{version}}/sanctum) para proporcionar autenticación para una SPA que necesita autenticarse con Laravel.

_[Laravel Jetstream](https://jetstream.laravel.com)_ es un robusto kit de inicio de aplicación que consume y expone los servicios de autenticación de Laravel Fortify con una hermosa y moderna interfaz de usuario impulsada por [Tailwind CSS](https://tailwindcss.com), [Livewire](https://livewire.laravel.com) y / o [Inertia](https://inertiajs.com). Laravel Jetstream incluye soporte opcional para autenticación de dos factores, soporte para equipos, gestión de sesiones de navegador, gestión de perfiles e integración incorporada con [Laravel Sanctum](/docs/{{version}}/sanctum) para ofrecer autenticación de tokens de API. Las ofertas de autenticación de API de Laravel se discuten a continuación.

<a name="laravels-api-authentication-services"></a>
#### Servicios de Autenticación de API de Laravel

Laravel proporciona dos paquetes opcionales para ayudarte a gestionar tokens de API y autenticar solicitudes realizadas con tokens de API: [Passport](/docs/{{version}}/passport) y [Sanctum](/docs/{{version}}/sanctum). Ten en cuenta que estas bibliotecas y las bibliotecas de autenticación basadas en cookies integradas de Laravel no son mutuamente excluyentes. Estas bibliotecas se centran principalmente en la autenticación de tokens de API, mientras que los servicios de autenticación integrados se centran en la autenticación basada en cookies para navegadores. Muchas aplicaciones utilizarán tanto los servicios de autenticación basados en cookies integrados de Laravel como uno de los paquetes de autenticación de API de Laravel.

**Passport**

Passport es un proveedor de autenticación OAuth2, que ofrece una variedad de "tipos de concesión" de OAuth2 que te permiten emitir varios tipos de tokens. En general, este es un paquete robusto y complejo para la autenticación de API. Sin embargo, la mayoría de las aplicaciones no requieren las características complejas que ofrece la especificación OAuth2, que pueden ser confusas tanto para los usuarios como para los desarrolladores. Además, los desarrolladores históricamente se han confundido sobre cómo autenticar aplicaciones SPA o aplicaciones móviles utilizando proveedores de autenticación OAuth2 como Passport.

**Sanctum**

En respuesta a la complejidad de OAuth2 y la confusión de los desarrolladores, nos propusimos construir un paquete de autenticación más simple y optimizado que pudiera manejar tanto solicitudes web de primera parte desde un navegador como solicitudes de API a través de tokens. Este objetivo se realizó con el lanzamiento de [Laravel Sanctum](/docs/{{version}}/sanctum), que debe considerarse el paquete de autenticación preferido y recomendado para aplicaciones que ofrecerán una interfaz web de primera parte además de una API, o que serán impulsadas por una aplicación de una sola página (SPA) que existe por separado de la aplicación backend de Laravel, o aplicaciones que ofrecen un cliente móvil.

Laravel Sanctum es un paquete de autenticación híbrido web / API que puede gestionar todo el proceso de autenticación de tu aplicación. Esto es posible porque cuando las aplicaciones basadas en Sanctum reciben una solicitud, Sanctum primero determinará si la solicitud incluye una cookie de sesión que hace referencia a una sesión autenticada. Sanctum logra esto llamando a los servicios de autenticación integrados de Laravel que discutimos anteriormente. Si la solicitud no se está autenticando a través de una cookie de sesión, Sanctum inspeccionará la solicitud en busca de un token de API. Si hay un token de API presente, Sanctum autentificará la solicitud utilizando ese token. Para aprender más sobre este proceso, consulta la documentación de Sanctum sobre ["cómo funciona"](/docs/{{version}}/sanctum#how-it-works).

Laravel Sanctum es el paquete de API que hemos elegido incluir con el kit de inicio de aplicación [Laravel Jetstream](https://jetstream.laravel.com) porque creemos que es el más adecuado para las necesidades de autenticación de la mayoría de las aplicaciones web.

<a name="summary-choosing-your-stack"></a>
#### Resumen y Elección de tu Stack

En resumen, si tu aplicación será accesible utilizando un navegador y estás construyendo una aplicación Laravel monolítica, tu aplicación utilizará los servicios de autenticación integrados de Laravel.

A continuación, si tu aplicación ofrece una API que será consumida por terceros, deberás elegir entre [Passport](/docs/{{version}}/passport) o [Sanctum](/docs/{{version}}/sanctum) para proporcionar autenticación de tokens de API para tu aplicación. En general, Sanctum debe ser preferido cuando sea posible, ya que es una solución simple y completa para la autenticación de API, autenticación de SPA y autenticación móvil, incluyendo soporte para "scopes" o "abilities".

Si estás construyendo una aplicación de una sola página (SPA) que será impulsada por un backend de Laravel, deberías usar [Laravel Sanctum](/docs/{{version}}/sanctum). Al usar Sanctum, necesitarás [implementar manualmente tus propias rutas de autenticación de backend](#authenticating-users) o utilizar [Laravel Fortify](/docs/{{version}}/fortify) como un servicio de backend de autenticación headless que proporciona rutas y controladores para características como registro, restablecimiento de contraseña, verificación de correo electrónico y más.

Passport puede ser elegido cuando tu aplicación necesita absolutamente todas las características proporcionadas por la especificación OAuth2.

Y, si deseas comenzar rápidamente, nos complace recomendar [Laravel Breeze](/docs/{{version}}/starter-kits#laravel-breeze) como una forma rápida de iniciar una nueva aplicación Laravel que ya utiliza nuestra pila de autenticación preferida de los servicios de autenticación integrados de Laravel y Laravel Sanctum.

<a name="authentication-quickstart"></a>
## Guía Rápida de Autenticación

> [!WARNING]  
> Esta parte de la documentación discute la autenticación de usuarios a través de los [kits de inicio de aplicación Laravel](/docs/{{version}}/starter-kits), que incluyen una estructura de interfaz de usuario para ayudarte a comenzar rápidamente. Si deseas integrarte directamente con los sistemas de autenticación de Laravel, consulta la documentación sobre [autenticación manual de usuarios](#authenticating-users).

<a name="install-a-starter-kit"></a>
### Instalar un Kit de Inicio

Primero, debes [instalar un kit de inicio de aplicación Laravel](/docs/{{version}}/starter-kits). Nuestros actuales kits de inicio, Laravel Breeze y Laravel Jetstream, ofrecen puntos de partida bellamente diseñados para incorporar la autenticación en tu nueva aplicación Laravel.

Laravel Breeze es una implementación mínima y simple de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. La capa de vista de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/{{version}}/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Además, Breeze proporciona opciones de estructura basadas en [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com), con la opción de usar Vue o React para la estructura basada en Inertia.

[Laravel Jetstream](https://jetstream.laravel.com) es un kit de inicio de aplicación más robusto que incluye soporte para estructurar tu aplicación con [Livewire](https://livewire.laravel.com) o [Inertia y Vue](https://inertiajs.com). Además, Jetstream cuenta con soporte opcional para autenticación de dos factores, equipos, gestión de perfiles, gestión de sesiones de navegador, soporte de API a través de [Laravel Sanctum](/docs/{{version}}/sanctum), eliminación de cuentas y más.

<a name="retrieving-the-authenticated-user"></a>
### Recuperando el Usuario Autenticado

Después de instalar un kit de inicio de autenticación y permitir que los usuarios se registren y autentiquen con tu aplicación, a menudo necesitarás interactuar con el usuario actualmente autenticado. Al manejar una solicitud entrante, puedes acceder al usuario autenticado a través del método `user` de la fachada `Auth`:

    use Illuminate\Support\Facades\Auth;

    // Recuperar el usuario actualmente autenticado...
    $user = Auth::user();

    // Recuperar el ID del usuario actualmente autenticado...
    $id = Auth::id();

Alternativamente, una vez que un usuario está autenticado, puedes acceder al usuario autenticado a través de una instancia de `Illuminate\Http\Request`. Recuerda que las clases con tipo se inyectarán automáticamente en los métodos de tu controlador. Al usar la clase `Illuminate\Http\Request`, puedes obtener acceso conveniente al usuario autenticado desde cualquier método de controlador en tu aplicación a través del método `user` de la solicitud:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\RedirectResponse;
    use Illuminate\Http\Request;

    class FlightController extends Controller
    {
        /**
         * Actualizar la información del vuelo para un vuelo existente.
         */
        public function update(Request $request): RedirectResponse
        {
            $user = $request->user();

            // ...

            return redirect('/flights');
        }
    }

<a name="determining-if-the-current-user-is-authenticated"></a>
#### Determinando si el Usuario Actual está Autenticado

Para determinar si el usuario que realiza la solicitud HTTP entrante está autenticado, puedes usar el método `check` en la fachada `Auth`. Este método devolverá `true` si el usuario está autenticado:

    use Illuminate\Support\Facades\Auth;

    if (Auth::check()) {
        // El usuario ha iniciado sesión...
    }

> [!NOTE]  
> Aunque es posible determinar si un usuario está autenticado usando el método `check`, normalmente usarás un middleware para verificar que el usuario esté autenticado antes de permitirle el acceso a ciertas rutas / controladores. Para aprender más sobre esto, consulta la documentación sobre [proteger rutas](/docs/{{version}}/authentication#protecting-routes).

<a name="protecting-routes"></a>
### Protegiendo Rutas

[El middleware de ruta](/docs/{{version}}/middleware) se puede usar para permitir solo a los usuarios autenticados acceder a una ruta determinada. Laravel incluye un middleware `auth`, que es un [alias de middleware](/docs/{{version}}/middleware#middleware-alias) para la clase `Illuminate\Auth\Middleware\Authenticate`. Dado que este middleware ya está aliasado internamente por Laravel, todo lo que necesitas hacer es adjuntar el middleware a una definición de ruta:

    Route::get('/flights', function () {
        // Solo los usuarios autenticados pueden acceder a esta ruta...
    })->middleware('auth');

<a name="redirecting-unauthenticated-users"></a>
#### Redirigiendo Usuarios No Autenticados

Cuando el middleware `auth` detecta un usuario no autenticado, redirigirá al usuario a la ruta nombrada `login` [ruta nombrada](/docs/{{version}}/routing#named-routes). Puedes modificar este comportamiento usando el método `redirectGuestsTo` en el archivo `bootstrap/app.php` de tu aplicación:

    use Illuminate\Http\Request;

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->redirectGuestsTo('/login');

        // Usando una función anónima...
        $middleware->redirectGuestsTo(fn (Request $request) => route('login'));
    })

<a name="specifying-a-guard"></a>
#### Especificando un Guard

Al adjuntar el middleware `auth` a una ruta, también puedes especificar qué "guard" debe usarse para autenticar al usuario. El guard especificado debe corresponder a una de las claves en el array `guards` de tu archivo de configuración `auth.php`:

    Route::get('/flights', function () {
        // Solo los usuarios autenticados pueden acceder a esta ruta...
    })->middleware('auth:admin');

<a name="login-throttling"></a>
### Limitación de Intentos de Inicio de Sesión

Si estás utilizando los kits de inicio de Laravel Breeze o Laravel Jetstream [kits de inicio](/docs/{{version}}/starter-kits), la limitación de tasa se aplicará automáticamente a los intentos de inicio de sesión. Por defecto, el usuario no podrá iniciar sesión durante un minuto si no proporciona las credenciales correctas después de varios intentos. La limitación es única para el nombre de usuario / dirección de correo electrónico del usuario y su dirección IP.

> [!NOTE]  
> Si deseas limitar la tasa de otras rutas en tu aplicación, consulta la [documentación sobre limitación de tasa](/docs/{{version}}/routing#rate-limiting).

<a name="authenticating-users"></a>
## Autenticando Usuarios Manualmente

No estás obligado a usar la estructura de autenticación incluida con los [kits de inicio de aplicación](/docs/{{version}}/starter-kits) de Laravel. Si decides no usar esta estructura, necesitarás gestionar la autenticación de usuarios utilizando directamente las clases de autenticación de Laravel. ¡No te preocupes, es muy fácil!

Accederemos a los servicios de autenticación de Laravel a través de la [fachada](/docs/{{version}}/facades) `Auth`, así que necesitaremos asegurarnos de importar la fachada `Auth` en la parte superior de la clase. A continuación, veamos el método `attempt`. El método `attempt` se utiliza normalmente para manejar los intentos de autenticación desde el formulario de "inicio de sesión" de tu aplicación. Si la autenticación es exitosa, deberías regenerar la [sesión](/docs/{{version}}/session) del usuario para prevenir [fijación de sesión](https://en.wikipedia.org/wiki/Session_fixation):

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\Request;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Support\Facades\Auth;

    class LoginController extends Controller
    {
        /**
         * Manejar un intento de autenticación.
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
                'email' => 'Las credenciales proporcionadas no coinciden con nuestros registros.',
            ])->onlyInput('email');
        }
    }

El método `attempt` acepta un array de pares clave / valor como su primer argumento. Los valores en el array se utilizarán para encontrar al usuario en tu tabla de base de datos. Así que, en el ejemplo anterior, el usuario se recuperará por el valor de la columna `email`. Si se encuentra al usuario, la contraseña hasheada almacenada en la base de datos se comparará con el valor de `password` pasado al método a través del array. No debes hashear el valor de `password` de la solicitud entrante, ya que el framework hasheará automáticamente el valor antes de compararlo con la contraseña hasheada en la base de datos. Se iniciará una sesión autenticada para el usuario si las dos contraseñas hasheadas coinciden.

Recuerda, los servicios de autenticación de Laravel recuperarán usuarios de tu base de datos según la configuración del "proveedor" de tu guard de autenticación. En el archivo de configuración `config/auth.php` por defecto, se especifica el proveedor de usuario Eloquent y se le indica que use el modelo `App\Models\User` al recuperar usuarios. Puedes cambiar estos valores dentro de tu archivo de configuración según las necesidades de tu aplicación.

El método `attempt` devolverá `true` si la autenticación fue exitosa. De lo contrario, se devolverá `false`.

El método `intended` proporcionado por el redireccionador de Laravel redirigirá al usuario a la URL que intentaba acceder antes de ser interceptado por el middleware de autenticación. Se puede proporcionar una URI de respaldo a este método en caso de que el destino previsto no esté disponible.

<a name="specifying-additional-conditions"></a>
#### Especificando Condiciones Adicionales

Si lo deseas, también puedes agregar condiciones de consulta adicionales a la consulta de autenticación además del correo electrónico y la contraseña del usuario. Para lograr esto, simplemente podemos agregar las condiciones de consulta al array pasado al método `attempt`. Por ejemplo, podemos verificar que el usuario esté marcado como "activo":

    if (Auth::attempt(['email' => $email, 'password' => $password, 'active' => 1])) {
        // La autenticación fue exitosa...
    }

Para condiciones de consulta complejas, puedes proporcionar una función anónima en tu array de credenciales. Esta función anónima se invocará con la instancia de consulta, lo que te permitirá personalizar la consulta según las necesidades de tu aplicación:

    use Illuminate\Database\Eloquent\Builder;

    if (Auth::attempt([
        'email' => $email,
        'password' => $password,
        fn (Builder $query) => $query->has('activeSubscription'),
    ])) {
        // La autenticación fue exitosa...
    }

> [!WARNING]  
> En estos ejemplos, `email` no es una opción requerida, simplemente se utiliza como ejemplo. Debes usar el nombre de columna que corresponda a un "nombre de usuario" en tu tabla de base de datos.

El método `attemptWhen`, que recibe una función anónima como su segundo argumento, se puede usar para realizar una inspección más extensa del usuario potencial antes de autenticarlo realmente. La función anónima recibe al usuario potencial y debe devolver `true` o `false` para indicar si el usuario puede ser autenticado:

    if (Auth::attemptWhen([
        'email' => $email,
        'password' => $password,
    ], function (User $user) {
        return $user->isNotBanned();
    })) {
        // La autenticación fue exitosa...
    }

<a name="accessing-specific-guard-instances"></a>
#### Accediendo a Instancias de Guard Específicas

A través del método `guard` de la fachada `Auth`, puedes especificar qué instancia de guard te gustaría utilizar al autenticar al usuario. Esto te permite gestionar la autenticación para partes separadas de tu aplicación utilizando modelos o tablas de usuario completamente separados.

El nombre del guard pasado al método `guard` debe corresponder a uno de los guards configurados en tu archivo de configuración `auth.php`:

    if (Auth::guard('admin')->attempt($credentials)) {
        // ...
    }

<a name="remembering-users"></a>
### Recordando Usuarios

Muchas aplicaciones web ofrecen una casilla de verificación "recordarme" en su formulario de inicio de sesión. Si deseas proporcionar funcionalidad de "recordarme" en tu aplicación, puedes pasar un valor booleano como segundo argumento al método `attempt`.

Cuando este valor es `true`, Laravel mantendrá al usuario autenticado indefinidamente o hasta que cierre sesión manualmente. Tu tabla `users` debe incluir la columna de cadena `remember_token`, que se utilizará para almacenar el token de "recordarme". La migración de la tabla `users` incluida con nuevas aplicaciones de Laravel ya incluye esta columna:

    use Illuminate\Support\Facades\Auth;

    if (Auth::attempt(['email' => $email, 'password' => $password], $remember)) {
        // El usuario está siendo recordado...
    }

Si tu aplicación ofrece funcionalidad de "recordarme", puedes usar el método `viaRemember` para determinar si el usuario actualmente autenticado fue autenticado utilizando la cookie de "recordarme":

    use Illuminate\Support\Facades\Auth;

    if (Auth::viaRemember()) {
        // ...
    }

<a name="other-authentication-methods"></a>
### Otros Métodos de Autenticación

<a name="authenticate-a-user-instance"></a>
#### Autenticar una Instancia de Usuario

Si necesitas establecer una instancia de usuario existente como el usuario actualmente autenticado, puedes pasar la instancia de usuario al método `login` de la fachada `Auth`. La instancia de usuario dada debe ser una implementación del [contrato](/docs/{{version}}/contracts) `Illuminate\Contracts\Auth\Authenticatable`. El modelo `App\Models\User` incluido con Laravel ya implementa esta interfaz. Este método de autenticación es útil cuando ya tienes una instancia de usuario válida, como directamente después de que un usuario se registra en tu aplicación:

    use Illuminate\Support\Facades\Auth;

    Auth::login($user);

Puedes pasar un valor booleano como segundo argumento al método `login`. Este valor indica si se desea la funcionalidad de "recordarme" para la sesión autenticada. Recuerda, esto significa que la sesión estará autenticada indefinidamente o hasta que el usuario cierre sesión manualmente de la aplicación:

    Auth::login($user, $remember = true);

Si es necesario, puedes especificar un guard de autenticación antes de llamar al método `login`:

    Auth::guard('admin')->login($user);

<a name="authenticate-a-user-by-id"></a>
#### Autenticar un Usuario por ID

Para autenticar a un usuario utilizando la clave primaria de su registro en la base de datos, puedes usar el método `loginUsingId`. Este método acepta la clave primaria del usuario que deseas autenticar:

    Auth::loginUsingId(1);

Puedes pasar un valor booleano como segundo argumento al método `loginUsingId`. Este valor indica si se desea la funcionalidad de "recordarme" para la sesión autenticada. Recuerda, esto significa que la sesión estará autenticada indefinidamente o hasta que el usuario cierre sesión manualmente de la aplicación:

    Auth::loginUsingId(1, $remember = true);

<a name="authenticate-a-user-once"></a>
#### Autenticar un Usuario Una Vez

Puedes usar el método `once` para autenticar a un usuario con la aplicación para una sola solicitud. No se utilizarán sesiones ni cookies al llamar a este método:

    if (Auth::once($credentials)) {
        // ...
    }

<a name="http-basic-authentication"></a>
## Autenticación HTTP Básica

[La Autenticación HTTP Básica](https://en.wikipedia.org/wiki/Basic_access_authentication) proporciona una forma rápida de autenticar a los usuarios de tu aplicación sin configurar una página de "inicio de sesión" dedicada. Para comenzar, adjunta el middleware `auth.basic` [middleware](/docs/{{version}}/middleware) a una ruta. El middleware `auth.basic` está incluido con el framework Laravel, por lo que no necesitas definirlo:

    Route::get('/profile', function () {
        // Solo los usuarios autenticados pueden acceder a esta ruta...
    })->middleware('auth.basic');

Una vez que el middleware ha sido adjuntado a la ruta, se te pedirá automáticamente que ingreses las credenciales al acceder a la ruta en tu navegador. Por defecto, el middleware `auth.basic` asumirá que la columna `email` en tu tabla de base de datos `users` es el "nombre de usuario" del usuario.

<a name="a-note-on-fastcgi"></a>
#### Una Nota sobre FastCGI

Si estás utilizando PHP FastCGI y Apache para servir tu aplicación Laravel, la autenticación HTTP Básica puede no funcionar correctamente. Para corregir estos problemas, se pueden agregar las siguientes líneas al archivo `.htaccess` de tu aplicación:

```apache
RewriteCond %{HTTP:Authorization} ^(.+)$
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
```

<a name="stateless-http-basic-authentication"></a>
### Autenticación HTTP Básica Sin Estado

También puedes usar la Autenticación HTTP Básica sin establecer una cookie de identificador de usuario en la sesión. Esto es principalmente útil si decides usar la Autenticación HTTP para autenticar solicitudes a la API de tu aplicación. Para lograr esto, [define un middleware](/docs/{{version}}/middleware) que llame al método `onceBasic`. Si no se devuelve ninguna respuesta del método `onceBasic`, la solicitud puede ser pasada más allá en la aplicación:

    <?php

    namespace App\Http\Middleware;

    use Closure;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;
    use Symfony\Component\HttpFoundation\Response;

    class AuthenticateOnceWithBasicAuth
    {
        /**
         * Manejar una solicitud entrante.
         *
         * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
         */
        public function handle(Request $request, Closure $next): Response
        {
            return Auth::onceBasic() ?: $next($request);
        }

    }

A continuación, adjunte el middleware a una ruta:

    Route::get('/api/user', function () {
        // Solo los usuarios autenticados pueden acceder a esta ruta...
    })->middleware(AuthenticateOnceWithBasicAuth::class);

<a name="logging-out"></a>
## Cierre de Sesión

Para cerrar manualmente la sesión de los usuarios en su aplicación, puede usar el método `logout` proporcionado por el `Auth` facade. Esto eliminará la información de autenticación de la sesión del usuario para que las solicitudes posteriores no estén autenticadas.

Además de llamar al método `logout`, se recomienda que invalide la sesión del usuario y regenere su [token CSRF](/docs/{{version}}/csrf). Después de cerrar la sesión del usuario, normalmente redirigiría al usuario a la raíz de su aplicación:

    use Illuminate\Http\Request;
    use Illuminate\Http\RedirectResponse;
    use Illuminate\Support\Facades\Auth;

    /**
     * Cerrar la sesión del usuario en la aplicación.
     */
    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect('/');
    }

<a name="invalidating-sessions-on-other-devices"></a>
### Invalidando Sesiones en Otros Dispositivos

Laravel también proporciona un mecanismo para invalidar y "cerrar sesión" de las sesiones de un usuario que están activas en otros dispositivos sin invalidar la sesión en su dispositivo actual. Esta función se utiliza típicamente cuando un usuario está cambiando o actualizando su contraseña y desea invalidar las sesiones en otros dispositivos mientras mantiene el dispositivo actual autenticado.

Antes de comenzar, debe asegurarse de que el middleware `Illuminate\Session\Middleware\AuthenticateSession` esté incluido en las rutas que deben recibir autenticación de sesión. Normalmente, debe colocar este middleware en una definición de grupo de rutas para que se pueda aplicar a la mayoría de las rutas de su aplicación. Por defecto, el middleware `AuthenticateSession` puede ser adjuntado a una ruta usando el alias de middleware `auth.session` [middleware alias](/docs/{{version}}/middleware#middleware-alias):

    Route::middleware(['auth', 'auth.session'])->group(function () {
        Route::get('/', function () {
            // ...
        });
    });

Luego, puede usar el método `logoutOtherDevices` proporcionado por el `Auth` facade. Este método requiere que el usuario confirme su contraseña actual, que su aplicación debe aceptar a través de un formulario de entrada:

    use Illuminate\Support\Facades\Auth;

    Auth::logoutOtherDevices($currentPassword);

Cuando se invoca el método `logoutOtherDevices`, las otras sesiones del usuario serán invalidadas por completo, lo que significa que serán "cerradas" de todos los guards por los que estaban autenticados anteriormente.

<a name="password-confirmation"></a>
## Confirmación de Contraseña

Mientras construye su aplicación, ocasionalmente puede tener acciones que requieran que el usuario confirme su contraseña antes de que se realice la acción o antes de que el usuario sea redirigido a un área sensible de la aplicación. Laravel incluye middleware incorporado para facilitar este proceso. Implementar esta función requerirá que defina dos rutas: una ruta para mostrar una vista que pida al usuario que confirme su contraseña y otra ruta para confirmar que la contraseña es válida y redirigir al usuario a su destino previsto.

> [!NOTE]  
> La siguiente documentación discute cómo integrarse con las funciones de confirmación de contraseña de Laravel directamente; sin embargo, si desea comenzar más rápidamente, los [kits de inicio de aplicación de Laravel](/docs/{{version}}/starter-kits) incluyen soporte para esta función.

<a name="password-confirmation-configuration"></a>
### Configuración

Después de confirmar su contraseña, a un usuario no se le pedirá que confirme su contraseña nuevamente durante tres horas. Sin embargo, puede configurar la duración del tiempo antes de que se le vuelva a solicitar la contraseña al usuario cambiando el valor de la configuración `password_timeout` dentro del archivo de configuración `config/auth.php` de su aplicación.

<a name="password-confirmation-routing"></a>
### Enrutamiento

<a name="the-password-confirmation-form"></a>
#### El Formulario de Confirmación de Contraseña

Primero, definiremos una ruta para mostrar una vista que solicite al usuario que confirme su contraseña:

    Route::get('/confirm-password', function () {
        return view('auth.confirm-password');
    })->middleware('auth')->name('password.confirm');

Como puede esperar, la vista que se devuelve desde esta ruta debe tener un formulario que contenga un campo `password`. Además, siéntase libre de incluir texto dentro de la vista que explique que el usuario está ingresando a un área protegida de la aplicación y debe confirmar su contraseña.

<a name="confirming-the-password"></a>
#### Confirmando la Contraseña

A continuación, definiremos una ruta que manejará la solicitud del formulario desde la vista "confirmar contraseña". Esta ruta será responsable de validar la contraseña y redirigir al usuario a su destino previsto:

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Hash;
    use Illuminate\Support\Facades\Redirect;

    Route::post('/confirm-password', function (Request $request) {
        if (! Hash::check($request->password, $request->user()->password)) {
            return back()->withErrors([
                'password' => ['La contraseña proporcionada no coincide con nuestros registros.']
            ]);
        }

        $request->session()->passwordConfirmed();

        return redirect()->intended();
    })->middleware(['auth', 'throttle:6,1']);

Antes de continuar, examinemos esta ruta con más detalle. Primero, se determina que el campo `password` de la solicitud coincide con la contraseña del usuario autenticado. Si la contraseña es válida, necesitamos informar a la sesión de Laravel que el usuario ha confirmado su contraseña. El método `passwordConfirmed` establecerá una marca de tiempo en la sesión del usuario que Laravel puede usar para determinar cuándo fue la última vez que el usuario confirmó su contraseña. Finalmente, podemos redirigir al usuario a su destino previsto.

<a name="password-confirmation-protecting-routes"></a>
### Protegiendo Rutas

Debe asegurarse de que cualquier ruta que realice una acción que requiera confirmación reciente de contraseña esté asignada al middleware `password.confirm`. Este middleware está incluido con la instalación predeterminada de Laravel y almacenará automáticamente el destino previsto del usuario en la sesión para que el usuario pueda ser redirigido a esa ubicación después de confirmar su contraseña. Después de almacenar el destino previsto del usuario en la sesión, el middleware redirigirá al usuario a la ruta nombrada `password.confirm` [named route](/docs/{{version}}/routing#named-routes):

    Route::get('/settings', function () {
        // ...
    })->middleware(['password.confirm']);

    Route::post('/settings', function () {
        // ...
    })->middleware(['password.confirm']);

<a name="adding-custom-guards"></a>
## Agregando Guards Personalizados

Puede definir sus propios guards de autenticación utilizando el método `extend` en el `Auth` facade. Debe colocar su llamada al método `extend` dentro de un [proveedor de servicios](/docs/{{version}}/providers). Dado que Laravel ya incluye un `AppServiceProvider`, podemos colocar el código en ese proveedor:

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
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            Auth::extend('jwt', function (Application $app, string $name, array $config) {
                // Devuelve una instancia de Illuminate\Contracts\Auth\Guard...

                return new JwtGuard(Auth::createUserProvider($config['provider']));
            });
        }
    }

Como puede ver en el ejemplo anterior, el callback pasado al método `extend` debe devolver una implementación de `Illuminate\Contracts\Auth\Guard`. Esta interfaz contiene algunos métodos que deberá implementar para definir un guard personalizado. Una vez que su guard personalizado ha sido definido, puede hacer referencia al guard en la configuración `guards` de su archivo de configuración `auth.php`:

    'guards' => [
        'api' => [
            'driver' => 'jwt',
            'provider' => 'users',
        ],
    ],

<a name="closure-request-guards"></a>
### Guards de Solicitud con Funciones Anónimas

La forma más sencilla de implementar un sistema de autenticación basado en solicitudes HTTP personalizado es utilizando el método `Auth::viaRequest`. Este método le permite definir rápidamente su proceso de autenticación utilizando una sola función anónima.

Para comenzar, llame al método `Auth::viaRequest` dentro del método `boot` de su `AppServiceProvider` de la aplicación. El método `viaRequest` acepta un nombre de controlador de autenticación como su primer argumento. Este nombre puede ser cualquier cadena que describa su guard personalizado. El segundo argumento pasado al método debe ser una función anónima que reciba la solicitud HTTP entrante y devuelva una instancia de usuario o, si la autenticación falla, `null`:

    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Auth::viaRequest('custom-token', function (Request $request) {
            return User::where('token', (string) $request->token)->first();
        });
    }

Una vez que su controlador de autenticación personalizado ha sido definido, puede configurarlo como un controlador dentro de la configuración `guards` de su archivo de configuración `auth.php`:

    'guards' => [
        'api' => [
            'driver' => 'custom-token',
        ],
    ],

Finalmente, puede hacer referencia al guard al asignar el middleware de autenticación a una ruta:

    Route::middleware('auth:api')->group(function () {
        // ...
    });

<a name="adding-custom-user-providers"></a>
## Agregando Proveedores de Usuarios Personalizados

Si no está utilizando una base de datos relacional tradicional para almacenar sus usuarios, necesitará extender Laravel con su propio proveedor de usuarios de autenticación. Usaremos el método `provider` en el `Auth` facade para definir un proveedor de usuarios personalizado. El resolutor de proveedores de usuarios debe devolver una implementación de `Illuminate\Contracts\Auth\UserProvider`:

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
         * Inicializar cualquier servicio de la aplicación.
         */
        public function boot(): void
        {
            Auth::provider('mongo', function (Application $app, array $config) {
                // Devuelve una instancia de Illuminate\Contracts\Auth\UserProvider...

                return new MongoUserProvider($app->make('mongo.connection'));
            });
        }
    }

Después de haber registrado el proveedor utilizando el método `provider`, puede cambiar al nuevo proveedor de usuarios en su archivo de configuración `auth.php`. Primero, defina un `provider` que use su nuevo controlador:

    'providers' => [
        'users' => [
            'driver' => 'mongo',
        ],
    ],

Finalmente, puede hacer referencia a este proveedor en su configuración `guards`:

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],
    ],

<a name="the-user-provider-contract"></a>
### El Contrato del Proveedor de Usuarios

Las implementaciones de `Illuminate\Contracts\Auth\UserProvider` son responsables de obtener una implementación de `Illuminate\Contracts\Auth\Authenticatable` de un sistema de almacenamiento persistente, como MySQL, MongoDB, etc. Estas dos interfaces permiten que los mecanismos de autenticación de Laravel continúen funcionando independientemente de cómo se almacenen los datos del usuario o qué tipo de clase se utilice para representar al usuario autenticado:

Veamos el contrato `Illuminate\Contracts\Auth\UserProvider`:

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

La función `retrieveById` generalmente recibe una clave que representa al usuario, como un ID autoincremental de una base de datos MySQL. La implementación `Authenticatable` que coincide con el ID debe ser recuperada y devuelta por el método.

La función `retrieveByToken` recupera un usuario por su `$identifier` único y su `$token` de "recuerdame", que generalmente se almacena en una columna de base de datos como `remember_token`. Al igual que con el método anterior, la implementación `Authenticatable` con un valor de token coincidente debe ser devuelta por este método.

El método `updateRememberToken` actualiza el `remember_token` de la instancia `$user` con el nuevo `$token`. Se asigna un nuevo token a los usuarios en un intento de autenticación "recuerdame" exitoso o cuando el usuario cierra sesión.

El método `retrieveByCredentials` recibe el array de credenciales pasadas al método `Auth::attempt` al intentar autenticarse con una aplicación. El método debe "consultar" el almacenamiento persistente subyacente para el usuario que coincide con esas credenciales. Normalmente, este método ejecutará una consulta con una condición "where" que busca un registro de usuario con un "nombre de usuario" que coincida con el valor de `$credentials['username']`. El método debe devolver una implementación de `Authenticatable`. **Este método no debe intentar realizar ninguna validación de contraseña o autenticación.**

El método `validateCredentials` debe comparar el `$user` dado con las `$credentials` para autenticar al usuario. Por ejemplo, este método normalmente utilizará el método `Hash::check` para comparar el valor de `$user->getAuthPassword()` con el valor de `$credentials['password']`. Este método debe devolver `true` o `false` indicando si la contraseña es válida.

El método `rehashPasswordIfRequired` debe volver a hashear la contraseña del `$user` dado si es necesario y está soportado. Por ejemplo, este método normalmente utilizará el método `Hash::needsRehash` para determinar si el valor de `$credentials['password']` necesita ser rehasheado. Si la contraseña necesita ser rehasheada, el método debe usar el método `Hash::make` para volver a hashear la contraseña y actualizar el registro del usuario en el almacenamiento persistente subyacente.

<a name="the-authenticatable-contract"></a>
### El Contrato Authenticatable

Ahora que hemos explorado cada uno de los métodos en el `UserProvider`, echemos un vistazo al contrato `Authenticatable`. Recuerde, los proveedores de usuarios deben devolver implementaciones de esta interfaz desde los métodos `retrieveById`, `retrieveByToken` y `retrieveByCredentials`:

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

Esta interfaz es simple. El método `getAuthIdentifierName` debe devolver el nombre de la columna de "clave primaria" para el usuario y el método `getAuthIdentifier` debe devolver la "clave primaria" del usuario. Al usar un back-end de MySQL, esto probablemente sería la clave primaria autoincremental asignada al registro del usuario. El método `getAuthPasswordName` debe devolver el nombre de la columna de contraseña del usuario. El método `getAuthPassword` debe devolver la contraseña hasheada del usuario.

Esta interfaz permite que el sistema de autenticación funcione con cualquier clase de "usuario", independientemente de qué ORM o capa de abstracción de almacenamiento estés utilizando. Por defecto, Laravel incluye una clase `App\Models\User` en el directorio `app/Models` que implementa esta interfaz.

<a name="automatic-password-rehashing"></a>
## Rehashing Automático de Contraseñas

El algoritmo de hashing de contraseñas por defecto de Laravel es bcrypt. El "factor de trabajo" para los hashes bcrypt se puede ajustar a través del archivo de configuración `config/hashing.php` de tu aplicación o la variable de entorno `BCRYPT_ROUNDS`.

Típicamente, el factor de trabajo de bcrypt debería aumentarse con el tiempo a medida que aumenta la potencia de procesamiento de la CPU / GPU. Si aumentas el factor de trabajo de bcrypt para tu aplicación, Laravel volverá a hashear las contraseñas de los usuarios de manera elegante y automática a medida que los usuarios se autentiquen con tu aplicación a través de los kits de inicio de Laravel o cuando [autenticues manualmente a los usuarios](#authenticating-users) a través del método `attempt`.

Típicamente, el rehashing automático de contraseñas no debería interrumpir tu aplicación; sin embargo, puedes desactivar este comportamiento publicando el archivo de configuración `hashing`:

```shell
php artisan config:publish hashing
```

Una vez que se ha publicado el archivo de configuración, puedes establecer el valor de configuración `rehash_on_login` en `false`:

```php
'rehash_on_login' => false,
```

<a name="events"></a>
## Eventos

Laravel despacha una variedad de [eventos](/docs/{{version}}/events) durante el proceso de autenticación. Puedes [definir oyentes](/docs/{{version}}/events) para cualquiera de los siguientes eventos:

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
