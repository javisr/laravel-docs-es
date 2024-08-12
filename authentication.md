# Autenticación

- [Introducción](#introduction)
  - [Kits de inicio](#starter-kits)
  - [Consideraciones sobre la base de datos](#introduction-database-considerations)
  - [Visión general del ecosistema](#ecosystem-overview)
- [Autenticación](#authentication-quickstart)
  - [Instalar un kit de inicio](#install-a-starter-kit)
  - [Recuperación del usuario autenticado](#retrieving-the-authenticated-user)
  - [Protección de rutas](#protecting-routes)
  - [Limitación del inicio de sesión](#login-throttling)
- [Autenticación manual de usuarios](#authenticating-users)
  - [Recordar usuarios](#remembering-users)
  - [Otros métodos de autenticación](#other-authentication-methods)
- [Autenticación básica HTTP](#http-basic-authentication)
  - [Autenticación básica HTTP sin estado](#stateless-http-basic-authentication)
- [Cierre de sesión](#logging-out)
  - [Invalidación de sesiones en otros dispositivos](#invalidating-sessions-on-other-devices)
- [Confirmación de contraseña](#password-confirmation)
  - [Configuración](#password-confirmation-configuration)
  - [Enrutamiento](#password-confirmation-routing)
  - [Protección de rutas](#password-confirmation-protecting-routes)
- [Adición de guardas personalizadas](#adding-custom-guards)
  - [Closure Request Guards](#closure-request-guards)
- [Adición de proveedores de usuario personalizados](#adding-custom-user-providers)
  - [El contrato de proveedor de usuario](#the-user-provider-contract)
  - [El contrato autenticable](#the-authenticatable-contract)
- [Autenticación Social](/docs/{{version}}/socialite)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción


Muchas aplicaciones web proporcionan una forma para que sus usuarios se autentiquen con la aplicación e "inicien sesión". Implementar esta característica en aplicaciones web puede ser una tarea compleja y potencialmente arriesgada. Por esta razón, Laravel se esfuerza por darte las herramientas que necesitas para implementar la autenticación de forma rápida, segura y sencilla.

Laravel, en su núcleo, utiliza dos estructuras para la autenticación: las "guardas" y los "proveedores". Los guardas definen cómo los usuarios son autenticados para cada solicitud. Por ejemplo, Laravel incluye una guarda de `session` que mantiene el estado utilizando almacenamiento de sesión y cookies.

Los proveedores definen cómo los usuarios son recuperados del almacenamiento persistente. Laravel incluye soporte para recuperar usuarios usando [Eloquent](/docs/{{version}}/eloquent) y el constructor de consultas de base de datos (`query builder`). Sin embargo, eres libre de definir proveedores adicionales según sea necesario para tu aplicación.

El fichero de configuración de autenticación de tu aplicación se encuentra en `config/auth.php`. Este archivo contiene varias opciones bien documentadas para ajustar el comportamiento de los servicios de autenticación de Laravel.

> **Nota**  
> No hay que confundir guardas y proveedores con "roles" y "permisos". Para obtener más información sobre la autorización de acciones de usuario mediante permisos, consulte la documentación sobre [autorización](/docs/{{version}}/authorization).

<a name="starter-kits"></a>
### Kits de inicio

¿Quieres empezar rápido? Instala un [kit de inicio](/docs/{{version}}/starter-kits) en una aplicación Laravel nueva. Después de migrar tu base de datos, navega por tu navegador hasta `/register` o cualquier otra URL que esté asignada a tu aplicación. Los kits de inicio se encargarán de montar todo tu sistema de autenticación.

**Incluso si decides no utilizar un kit de inicio en tu aplicación Laravel, instalar el kit de inicio Laravel [Breeze](/docs/{{version}}/starter-kits#laravel-breeze) puede ser una buena oportunidad para aprender a implementar toda la funcionalidad de autenticación de Laravel en un proyecto Laravel real.** Dado que Laravel Breeze crea controladores de autenticación, rutas y vistas para ti, puedes examinar el código dentro de estos archivos para aprender cómo se pueden implementar las características de autenticación de Laravel.

<a name="introduction-database-considerations"></a>
### Consideraciones sobre la base de datos

Por defecto, Laravel incluye un [modelo](/docs/{{version}}/eloquent) `App\Models\User` [Eloquent](/docs/{{version}}/eloquent) en tu directorio `app/Models`. Este modelo se puede utilizar con el controlador de autenticación Eloquent por defecto. Si tu aplicación no utiliza Eloquent, puedes utilizar el proveedor de autenticación de `base de datos` que utiliza el constructor de consultas de Laravel.

Al construir el esquema de base de datos para el modelo `App\Models\User`, asegúrese de que la columna de contraseña tiene al menos 60 caracteres de longitud. Por supuesto, la migración de la tabla `users` que se incluye en las nuevas aplicaciones Laravel ya crea una columna que supera esta longitud.

Además, debes comprobar que tu tabla `users` (o equivalente) contiene una columna `remember_token` nulable, de tipo `string`, de 100 caracteres. Esta columna se utilizará para almacenar un token para los usuarios que seleccionen la opción "recuérdame" al iniciar sesión en tu aplicación. De nuevo, la migración de la tabla `users` por defecto que se incluye en las nuevas aplicaciones Laravel ya contiene esta columna.

<a name="ecosystem-overview"></a>
### Visión general del ecosistema

Laravel ofrece varios paquetes relacionados con la autenticación. Antes de continuar, revisaremos el ecosistema general de autenticación en Laravel y discutiremos el propósito de cada paquete.

En primer lugar, considere cómo funciona la autenticación. Cuando se utiliza un navegador web, un usuario proporcionará su nombre de usuario y contraseña a través de un formulario de inicio de sesión. Si estas credenciales son correctas, la aplicación almacenará información sobre el usuario autenticado en la [session](/docs/{{version}}/session) del usuario. Una cookie enviada al navegador contiene el identificador de sesión para que las siguientes peticiones a la aplicación puedan asociar al usuario con la sesión correcta. Una vez recibida la cookie de sesión, la aplicación recuperará los datos de la sesión basándose en el ID de sesión, observará que la información de autenticación se ha almacenado en la sesión y considerará al usuario como "autenticado".

Cuando un servicio remoto necesita autenticarse para acceder a una API, no se suelen utilizar cookies para la autenticación porque no hay navegador web. En su lugar, el servicio remoto envía un token de API a la API en cada solicitud. La aplicación puede validar el token entrante contra una tabla de tokens de API válidos y "autenticar" la solicitud como realizada por el usuario asociado con ese token de API.

<a name="laravels-built-in-browser-authentication-services"></a>
#### Servicios de autenticación del navegador incorporados en Laravel

Laravel incluye servicios integrados de autenticación y sesión a los que se accede normalmente a través de las facades `Auth` y `Session`. Dichos servicios proporcionan autenticación basada en cookies para las peticiones que se inician desde los navegadores web. Tambien proporcionan métodos que permiten verificar las credenciales de un usuario y autenticarlo. Además, estos servicios almacenarán automáticamente los datos de autenticación adecuados en la sesión del usuario y emitirán la cookie de sesión del usuario. En esta documentación se explica cómo utilizar estos servicios.

**Kits de inicio de aplicaciones**

Como se discute en esta documentación, puedes interactuar con estos servicios de autenticación manualmente para construir la propia capa de autenticación de tu aplicación. Sin embargo, para ayudarte a empezar más rápidamente, hemos publicado [paquetes gratuitos](/docs/{{version}}/starter-kits) que proporcionan una estructura robusta y moderna de toda la capa de autenticación. Estos paquetes son Laravel [Breeze](/docs/{{version}}/starter-kits#laravel-breeze), [Laravel Jetstream](/docs/{{version}}/starter-kits#laravel-jetstream) y [Laravel Fortify](/docs/{{version}}/fortify).

_Laravel Breeze_ es una implementación simple y mínima de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de email y confirmación de contraseña. La capa de vista de Laravel Breeze se compone de simples [plantillas Blade](/docs/{{version}}/blade) estilizadas con [CSS Tailwind](https://tailwindcss.com). Para empezar, consulta la documentación sobre los [kits de inicio de aplicaciones](/docs/{{version}}/starter-kits) de Laravel.

_Laravel Fortify_ es un backend de autenticación headless para Laravel que implementa muchas de las características que se encuentran en esta documentación, incluyendo la autenticación basada en cookies, así como otras características como la autenticación de dos factores y la verificación de email. Fortify proporciona el backend de autenticación para Laravel Jetstream o se puede utilizar de forma independiente en combinación con [Laravel Sanctum](/docs/{{version}}/sanctum) para proporcionar autenticación para una SPA que necesite autenticarse con Laravel.

_[Laravel Jetstream](https://jetstream.laravel.com)_ es un kit de inicio de aplicación robusto que consume y expone los servicios de autenticación de Laravel Fortify con una hermosa y moderna interfaz de usuario impulsada por [Tailwind CSS](https://tailwindcss.com), [Livewire](https://laravel-livewire.com), y / o [Inertia](https://inertiajs.com). Laravel Jetstream incluye soporte opcional para la autenticación de dos factores, soporte de equipo, gestión de sesiones de navegador, gestión de perfiles, e integración incorporada con [Laravel Sanctum](/docs/{{version}}/sanctum) para ofrecer autenticación de token de API. De la autenticación de API de Laravel se hablará a continuación.

<a name="laravels-api-authentication-services"></a>
#### Servicios de autenticación de la API de Laravel

Laravel proporciona dos paquetes opcionales para ayudarle a gestionar los tokens de API y autenticar las solicitudes realizadas con tokens de API: [Passport](/docs/{{version}}/passport) y [Sanctum](/docs/{{version}}/sanctum). Ten en cuenta que estas librerías y las librerías de autenticación basadas en cookies incorporadas en Laravel no son mutuamente excluyentes. Estas librerías se centran principalmente en la autenticación de tokens de API mientras que los servicios de autenticación incorporados se centran en la autenticación del navegador basada en cookies. Muchas aplicaciones utilizarán tanto los servicios de autenticación basados en cookies incorporados en Laravel como uno de los paquetes de autenticación de API de Laravel.

**Pasaporte**

Passport es un proveedor de autenticación OAuth2, que ofrece una variedad de "tipos de concesión" OAuth2 que le permiten emitir varios tipos de tokens. En general, se trata de un paquete robusto y complejo para la autenticación de API. Sin embargo, la mayoría de las aplicaciones no requieren las complejas características que ofrece la especificación OAuth2, lo que puede resultar confuso tanto para los usuarios como para los desarrolladores. Además, históricamente, ha habido confusión entre los los desarrolladores sobre cómo autenticar aplicaciones SPA o aplicaciones móviles utilizando proveedores de autenticación OAuth2 como Passport.

**Sanctum**

En respuesta a la complejidad de OAuth2 y a la confusión de los desarrolladores, nos propusimos crear un paquete de autenticación más sencillo y racionalizado que pudiera gestionar tanto las solicitudes web de origen desde un navegador web como las solicitudes API a través de tokens. Este objetivo se hizo realidad con el lanzamiento de Laravel [Sanctum](/docs/{{version}}/sanctum). `Sanctum` debe ser considerado como el paquete de autenticación preferido y recomendado para las aplicaciones que ofrecen una interfaz de usuario web además de una API, tambien  para aquellas que consistan en una aplicación de una sola página (SPA) más el backend Laravel por separado, o aplicaciones que ofrecen un cliente móvil.

Laravel Sanctum es un paquete híbrido de autenticación web / API que puede gestionar todo el proceso de autenticación de su aplicación. Esto es posible porque cuando las aplicaciones basadas en Sanctum reciben una petición, Sanctum determinará primero si la petición incluye una cookie de sesión que haga referencia a una sesión autenticada. Sanctum logra esto llamando a los servicios de autenticación incorporados en Laravel que discutimos anteriormente. Si la petición no está siendo autenticada a través de una cookie de sesión, Sanctum inspeccionará la petición en busca de un token de API. Si hay un token de API presente, Sanctum autenticará la petición usando ese token. Para obtener más información sobre este proceso, consulte la documentación ["cómo funciona"](/docs/{{version}}/sanctum#how-it-works) de Sanctum.

Laravel Sanctum es el paquete de API que hemos decidido incluir con el kit de inicio de la aplicación [Laravel Jetstream](https://jetstream.laravel.com) porque creemos que es el que mejor se adapta a la mayoría de las necesidades de autenticación de las aplicaciones web.

<a name="summary-choosing-your-stack"></a>
#### Resumen y elección de la pila

En resumen, si tu aplicación va a ser usada a través de un navegador y estás construyendo una aplicación Laravel monolítica, tu aplicación usará los servicios de autenticación incorporados de Laravel.

A continuación, si tu aplicación ofrece una API que será consumida por terceros, deberás elegir entre [Passport](/docs/{{version}}/passport) o [Sanctum](/docs/{{version}}/sanctum) para proporcionar autenticación de token de API para tu aplicación. En general, se debe preferir Sanctum siempre que sea posible, ya que es una solución sencilla y completa para la autenticación de API, autenticación de SPA y autenticación móvil, incluido el soporte para "ámbitos" o "habilidades".

Si está construyendo una aplicación de una sola página (SPA) alimentada por un backend Laravel, debe utilizar [Laravel Sanctum](/docs/{{version}}/sanctum). Al utilizar Sanctum, tendrás que [implementar manualmente tus propias rutas de autenticación de backend](#authenticating-users) o utilizar [Laravel Fortify](/docs/{{version}}/fortify) como servicio de autenticación de backend sin cabeceras que proporcione rutas y controladores para características tales como el registro, restablecimiento de contraseña, verificación de email, y mucho más.

Passport puede ser elegido cuando tu aplicación necesite absolutamente todas las características proporcionadas por la especificación OAuth2.

Si deseas comenzar forma rápida, le recomendamos el uso de [Laravel Breeze](/docs/{{version}}/starter-kits#laravel-breeze) para iniciar una nueva aplicación que utilice el stack recomendado por Laravel de autenticación y que incluye los servicios de autenticación integrados en Laravel y Laravel Sanctum.

<a name="authentication-quickstart"></a>
## Inicio rápido de la autenticación

> **Advertencia**  
> Esta parte de la documentación trata sobre la autenticación de usuarios a través de los [kits de inicio de aplicaciones](/docs/{{version}}/starter-kits) Laravel, que incluyen una de interfaz de usuario para ayudarte a empezar rápidamente. Si quieres integrar manualmente con los sistemas de autenticación de Laravel, consulta la documentación sobre [autenticación manual de usuarios](#authenticating-users).

<a name="install-a-starter-kit"></a>
### Instalar un kit de inicio

En primer lugar, debe [instalar un kit de inicio de aplicaciones Larvel](/docs/{{version}}/starter-kits). Nuestros kits de inicio actuales, Laravel Breeze y Laravel Jetstream, ofrecen puntos de partida muy bien diseñados para incorporar la autenticación en tu nueva aplicación Laravel.

Laravel Breeze es una implementación mínima y sencilla de todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de email y confirmación de contraseña. La capa de vista de Laravel Breeze se compone de simples [plantillas Blade](/docs/{{version}}/blade) estilizadas con [CSS Tailwind](https://tailwindcss.com). Breeze también ofrece una opción de  basada en [Inertia](https://inertiajs.com) utilizando Vue o React.

[Laravel Jetstream](https://jetstream.laravel.com) es un kit de inicio de aplicación más robusto que incluye soporte para su aplicación con [Livewire](https://laravel-livewire.com) o [Inertia y Vue](https://inertiajs.com). Además, Jetstream cuenta con soporte opcional para la autenticación de dos factores, equipos, gestión de perfiles, gestión de sesiones de navegador, soporte de API a través de [Laravel Sanctum](/docs/{{version}}/sanctum), eliminación de cuentas y más.

<a name="retrieving-the-authenticated-user"></a>
### Recuperación del usuario autenticado

Después de instalar un kit de inicio de autenticación y permitir a los usuarios registrarse y autenticarse con tu aplicación, a menudo necesitarás interactuar con el usuario autenticado. Mientras manejas una solicitud entrante, puedes acceder al usuario autenticado a través del método `user` de la facade `Auth`:

    use Illuminate\Support\Facades\Auth;

    // Retrieve the currently authenticated user...
    $user = Auth::user();

    // Retrieve the currently authenticated user's ID...
    $id = Auth::id();

De manera alternativa, una vez autenticado un usuario, puede acceder al usuario autenticado a través de una instancia `Illuminate\Http\Request`. Recuerde, las clases tipadas se inyectarán automáticamente en los métodos de su controlador. Mediante el tipado del objeto `Illuminate\Http\Request`, podrá acceder cómodamente al usuario autenticado desde cualquier método controlador de su aplicación a través del método `user` de la petición:

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\Request;

    class FlightController extends Controller
    {
        /**
         * Update the flight information for an existing flight.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function update(Request $request)
        {
            // $request->user()
        }
    }

<a name="determining-if-the-current-user-is-authenticated"></a>
#### Determinar si el usuario actual está autenticado

Para determinar si el usuario que realiza la solicitud HTTP entrante está autenticado, puede utilizar el método `check` de la facade `Auth`. Este método devolverá `true` si el usuario está autenticado:

    use Illuminate\Support\Facades\Auth;

    if (Auth::check()) {
        // The user is logged in...
    }

> **Nota**  
> Aunque es posible determinar si un usuario está autenticado utilizando el método `check`, normalmente utilizará un middleware para verificar que el usuario está autenticado antes de permitirle el acceso a ciertas rutas / controladores. Para aprender más sobre esto, consulta la documentación sobre [protección](/docs/{{version}}/authentication#protecting-routes) de rutas.

<a name="protecting-routes"></a>
### Protección de rutas

El [middleware de ruta](/docs/{{version}}/middleware) se puede utilizar para permitir que sólo los usuarios autenticados accedan a una ruta determinada. Laravel viene con un middleware `auth`, que hace referencia a la clase `Illuminate\Auth\Middleware\Authenticate`. Dado que este middleware ya está registrado en el núcleo HTTP de tu aplicación, todo lo que necesitas hacer es adjuntar el middleware a una definición de ruta:

    Route::get('/flights', function () {
        // Only authenticated users may access this route...
    })->middleware('auth');

<a name="redirecting-unauthenticated-users"></a>
#### Redireccionamiento de usuarios no autenticados

Cuando el middleware `auth` detecta un usuario no autenticado, lo redirige a la ruta  de login de usuario. Puedes modificar este comportamiento actualizando la función `redirectTo` en el archivo `app/Http/Middleware/Authenticate.` php de tu aplicación:

    /**
     * Get the path the user should be redirected to.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string
     */
    protected function redirectTo($request)
    {
        return route('login');
    }

<a name="specifying-a-guard"></a>
#### Especificación de una Guarda

Al adjuntar el middleware `auth` a una ruta, también puede especificar qué "guarda" debe utilizarse para autenticar al usuario. La guarda especificada debe corresponder a una de las claves del array `guards` de tu fichero de configuración `auth.php`:

    Route::get('/flights', function () {
        // Only authenticated users may access this route...
    })->middleware('auth:admin');

<a name="login-throttling"></a>
### Limitación del inicio de sesión

Si está utilizando los [kits de inicio](/docs/{{version}}/starter-kits) Laravel Breeze o Laravel Jetstream, la limitación de velocidad se aplicará automáticamente a los intentos de inicio de sesión. Por defecto, el usuario no podrá iniciar sesión durante un minuto si no proporciona las credenciales correctas tras varios intentos. La limitación es única para el nombre de usuario / dirección de email del usuario y su dirección IP.

> **Nota**  
> Si desea limitar el número de accesos de otras rutas en su aplicación, consulte la [documentación de límite de accesos a rutas](/docs/{{version}}/routing#rate-limiting).

<a name="authenticating-users"></a>
## Autenticación manual de usuarios

No estás obligado a utilizar el código pre-generado de autenticación incluido en los [kits de inicio de Laravel](/docs/{{version}}/starter-kits). Si decides no utilizarlo, tendrás que gestionar la autenticación de usuarios utilizando directamente las clases de autenticación de Laravel. No te preocupes, ¡es pan comido!

Accederemos a los servicios de autenticación de Laravel a través de la [facade](/docs/{{version}}/facades) `Auth`, por lo que tendremos que asegurarnos de importar la facade `Auth` en la parte superior de la clase. A continuación, vamos a ver el método `attempt`. El método `attempt` se utiliza normalmente para manejar los intentos de autenticación desde el formulario de "login" de tu aplicación. Si la autenticación tiene éxito, debes regenerar la [session](/docs/{{version}}/session) del usuario para evitar ataques de [session fixation](https://en.wikipedia.org/wiki/Session_fixation):

    <?php

    namespace App\Http\Controllers;

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

    class LoginController extends Controller
    {
        /**
         * Handle an authentication attempt.
         *
         * @param  \Illuminate\Http\Request  $request
         * @return \Illuminate\Http\Response
         */
        public function authenticate(Request $request)
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

El método `attempt` acepta un array de pares clave / valor como primer argumento. Los valores del array se utilizarán para encontrar al usuario en la tabla de la base de datos. Así, en el ejemplo anterior, el usuario será recuperado por el valor de la columna `email`. Si el usuario es encontrado, la contraseña hash almacenada en la base de datos será comparada con el valor de la `contraseña` pasado al método a través del array. No se debe aplicar hash al valor de la `contraseña` de la petición entrante, ya que el framework automáticamente aplicará hash al valor antes de compararlo con la contraseña hash de la base de datos. Se iniciará una sesión autenticada para el usuario si las dos contraseñas coinciden.

Recuerda que los servicios de autenticación de Laravel recuperarán los usuarios de tu base de datos basándose en la configuración del "proveedor" de tu guarda de autenticación. En el fichero de configuración por defecto `config/auth.php`, se especifica el proveedor de usuarios Eloquent y se le indica que utilice el modelo `App\Models\User` cuando recupere usuarios. Usted puede cambiar estos valores dentro de su archivo de configuración en función en las necesidades de su aplicación.

El método `attempt` devolverá `true` si la autenticación se ha realizado correctamente. En caso contrario, devolverá `false`.

El método `intended` proporcionado por el redirector de Laravel redirigirá al usuario a la URL a la que estaba intentando acceder antes de ser interceptado por el middleware de autenticación. En caso de que el destino previsto no esté disponible, se puede proporcionar una URI de reserva a este método.

<a name="specifying-additional-conditions"></a>
#### Especificación de condiciones adicionales

Si lo desea, también puede añadir condiciones de consulta adicionales a la consulta de autenticación, además del email y la contraseña del usuario. Para lograrlo, podemos simplemente añadir las condiciones de consulta al array pasado al método `attempt`. Por ejemplo, podemos verificar que el usuario está marcado como "activo":

    if (Auth::attempt(['email' => $email, 'password' => $password, 'active' => 1])) {
        // Authentication was successful...
    }

Para condiciones de consulta complejas, puede proporcionar un closure en su array de credenciales. Este closure se invocará con la instancia de consulta, lo que le permitirá personalizar la consulta en función de las necesidades de su aplicación:

    if (Auth::attempt([
        'email' => $email, 
        'password' => $password, 
        fn ($query) => $query->has('activeSubscription'),
    ])) {
        // Authentication was successful...
    }

> **Advertencia**  
> En estos ejemplos, `email` no es una opción obligatoria, sólo se utiliza como ejemplo. Debe utilizar cualquier nombre de columna que corresponda a un "nombre de usuario" en su tabla de base de datos.

El método `attemptWhen`, que recibe un closure como segundo argumento, puede utilizarse para realizar una inspección más exhaustiva del usuario potencial antes de autenticarlo. El closure recibe el usuario potencial y debe devolver `true` o `false` para indicar si el usuario puede ser autenticado:

    if (Auth::attemptWhen([
        'email' => $email,
        'password' => $password,
    ], function ($user) {
        return $user->isNotBanned();
    })) {
        // Authentication was successful...
    }

<a name="accessing-specific-guard-instances"></a>
#### Acceso a instancias de guarda específicas

A través del método `guard` de la facade `Auth`, puede especificar qué instancia de guarda desea utilizar al autenticar al usuario. Esto te permite gestionar la autenticación para partes separadas de tu aplicación usando modelos autenticables o tablas de usuarios completamente separadas.

El nombre del guard pasado al método `guard` debe corresponder a uno de los guardas configuradas en tu fichero de configuración `auth.php`:

    if (Auth::guard('admin')->attempt($credentials)) {
        // ...
    }

<a name="remembering-users"></a>
### Recordar usuarios

Muchas aplicaciones web proporcionan una casilla de verificación "recuérdame" en su formulario de inicio de sesión. Si quieres proporcionar la funcionalidad "recuérdame" en tu aplicación, puedes pasar un valor booleano como segundo argumento al método `attempt`.

Cuando este valor es `true`, Laravel mantendrá al usuario autenticado indefinidamente o hasta que se desconecte manualmente. Tu tabla `users` debe incluir la columna string `remember_token`, que se utilizará para almacenar el token "remember me". La migración de la tabla `users` incluida con las nuevas aplicaciones Laravel ya incluye esta columna:

    use Illuminate\Support\Facades\Auth;

    if (Auth::attempt(['email' => $email, 'password' => $password], $remember)) {
        // The user is being remembered...
    }

Si tu aplicación ofrece la funcionalidad "remember me", puedes utilizar el método `viaRemember` para determinar si el usuario autenticado actualmente se autenticó utilizando la cookie "remember me":

    use Illuminate\Support\Facades\Auth;

    if (Auth::viaRemember()) {
        // ...
    }

<a name="other-authentication-methods"></a>
### Otros métodos de autenticación

<a name="authenticate-a-user-instance"></a>
#### Autenticar una instancia de usuario

Si necesita establecer una instancia de usuario existente como el usuario autenticado actualmente, puede pasar la instancia de usuario al método de `inicio de sesión` de la facade `Auth`. La instancia de usuario dada debe ser una implementación del [contrato](/docs/{{version}}/contracts) `Illuminate\Contracts\Auth\Authenticatable`. El modelo `App\Models\User` incluido con Laravel ya implementa esta interfaz. Este método de autenticación es útil cuando ya tienes una instancia de usuario válida, como por ejemplo directamente después de que un usuario se registre en tu aplicación:

    use Illuminate\Support\Facades\Auth;

    Auth::login($user);

Puedes pasar un valor booleano como segundo argumento al método de `login`. Este valor indica si se desea la funcionalidad "recuérdame" para la sesión autenticada. Recuerde, esto significa que la sesión será autenticada indefinidamente o hasta que el usuario salga manualmente de la aplicación:

    Auth::login($user, $remember = true);

Si es necesario, puede especificar una guard de autenticación antes de llamar al método `login`:

    Auth::guard('admin')->login($user);

<a name="authenticate-a-user-by-id"></a>
#### Autenticar un usuario por ID

Para autenticar un usuario usando la clave primaria de su registro de base de datos, puede usar el método `loginUsingId`. Este método acepta la clave principal del usuario que desea autenticar:

    Auth::loginUsingId(1);

Puede pasar un valor booleano como segundo argumento al método `loginUsingId`. Este valor indica si se desea la funcionalidad "recuérdame" para la sesión autenticada. Recuerde, esto significa que la sesión será autenticada indefinidamente o hasta que el usuario salga manualmente de la aplicación:

    Auth::loginUsingId(1, $remember = true);

<a name="authenticate-a-user-once"></a>
#### Autenticar un usuario una vez

Puede utilizar el método `once` para autenticar un usuario con la aplicación para una única petición. No se utilizarán sesiones ni cookies al llamar a este método:

    if (Auth::once($credentials)) {
        //
    }

<a name="http-basic-authentication"></a>
## Autenticación básica HTTP

[La autenticación básica HTTP](https://en.wikipedia.org/wiki/Basic_access_authentication) proporciona una forma rápida de autenticar a los usuarios de tu aplicación sin necesidad de configurar una página de "login" dedicada. Para empezar, adjunta el [middleware](/docs/{{version}}/middleware) auth. `basic` a una ruta. El middleware auth. `basic` se incluye con el framework Laravel, por lo que no es necesario definirlo:

    Route::get('/profile', function () {
        // Only authenticated users may access this route...
    })->middleware('auth.basic');

Una vez que el middleware se ha adjuntado a la ruta, se le pedirá automáticamente las credenciales al acceder a la ruta en su navegador. Por defecto, el middleware `auth.` basic asumirá que la columna `email` de tu tabla de base de datos de `usuarios` es el "nombre de usuario" del usuario.

<a name="a-note-on-fastcgi"></a>
#### Nota sobre FastCGI

Si está utilizando PHP FastCGI y Apache para servir su aplicación Laravel, la autenticación HTTP Basic puede no funcionar correctamente. Para corregir estos problemas, puede añadir las siguientes líneas al archivo `.htaccess` de su aplicación:

```apache
RewriteCond %{HTTP:Authorization} ^(.+)$
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
```

<a name="stateless-http-basic-authentication"></a>
### Autenticación básica HTTP sin estado

También puede utilizar la autenticación básica HTTP sin establecer una cookie de identificador de usuario en la sesión. Esto es útil principalmente si eliges utilizar la autenticación HTTP para autenticar las peticiones a la API de tu aplicación. Para ello, defina [un middleware](/docs/{{version}}/middleware) que llame al método `onceBasic`. Si el método `onceBasic` no devuelve ninguna respuesta, la solicitud se puede seguir pasando a la aplicación:

    <?php

    namespace App\Http\Middleware;

    use Illuminate\Support\Facades\Auth;

    class AuthenticateOnceWithBasicAuth
    {
        /**
         * Handle an incoming request.
         *
         * @param  \Illuminate\Http\Request  $request
         * @param  \Closure  $next
         * @return mixed
         */
        public function handle($request, $next)
        {
            return Auth::onceBasic() ?: $next($request);
        }

    }

A continuación, [registra el middleware de ruta](/docs/{{version}}/middleware#registering-middleware) y adjúntalo a una ruta:

    Route::get('/api/user', function () {
        // Only authenticated users may access this route...
    })->middleware('auth.basic.once');

<a name="logging-out"></a>
## Cierre de sesión

Para cerrar manualmente la sesión de los usuarios de su aplicación, puede utilizar el método de `cierre de sesión` proporcionado por la facade `Auth`. Esto eliminará la información de autenticación de la sesión del usuario para que las peticiones posteriores no sean autenticadas.

Además de llamar al método de cierre de `session`, se recomienda invalidar la sesión del usuario y regenerar su [token CSRF](/docs/{{version}}/csrf). Después de cerrar la sesión del usuario, normalmente redirigirás al usuario a la raíz de tu aplicación:

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

    /**
     * Log the user out of the application.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect('/');
    }

<a name="invalidating-sessions-on-other-devices"></a>
### Invalidación de sesiones en otros dispositivos

Laravel también proporciona un mecanismo para invalidar y "cerrar" las sesiones de un usuario que están activas en otros dispositivos sin invalidar la sesión en su dispositivo actual. Esta característica se utiliza normalmente cuando un usuario está cambiando o actualizando su contraseña y desea invalidar las sesiones en otros dispositivos, manteniendo el dispositivo actual autenticado.

Antes de empezar, debe asegurarse de que el middleware `Illuminate\Session\Middleware\AuthenticateSession` está incluido en las rutas que deben recibir la autenticación de sesión. Normalmente, debe colocar este middleware en una definición de grupo de rutas para que pueda aplicarse a la mayoría de las rutas de su aplicación. Por defecto, el middleware `AuthenticateSession` puede adjuntarse a una ruta utilizando la clave de middleware de ruta `auth.session` definida en el kernel HTTP de tu aplicación:

    Route::middleware(['auth', 'auth.session'])->group(function () {
        Route::get('/', function () {
            // ...
        });
    });

A continuación, puede utilizar el método `logoutOtherDevices` proporcionado por la facade `Auth`. Este método requiere que el usuario confirme su contraseña actual, que tu aplicación debería aceptar a través de un formulario de entrada:

    use Illuminate\Support\Facades\Auth;

    Auth::logoutOtherDevices($currentPassword);

Cuando el método `logoutOtherDevices` es invocado, las otras sesiones del usuario serán invalidadas por completo, lo que significa que serán "desconectados" de todos ls guardas en los que fueron autenticados previamente.

<a name="password-confirmation"></a>
## Confirmación de contraseña

Mientras construyes tu aplicación, puede que ocasionalmente tengas acciones que requieran que el usuario confirme su contraseña antes de que se realice la acción o antes de que el usuario sea redirigido a un área sensible de la aplicación. Laravel incluye un middleware integrado que facilita este proceso. Implementar esta funcionalidad requerirá definir dos rutas: una ruta para mostrar una vista pidiendo al usuario que confirme su contraseña y otra ruta para confirmar que la contraseña es válida y redirigir al usuario a su destino.

> **Nota**  
> La siguiente documentación enseña cómo integrar las características de confirmación de contraseña de Laravel directamente; sin embargo, si deseas comenzar más rápidamente, ¡los [kits de inicio de aplicaciones Laravel](/docs/{{version}}/starter-kits) incluyen soporte para esta característica!

<a name="password-confirmation-configuration"></a>
### Configuración

Después de confirmar su contraseña, no se volverá a pedir al usuario que confirme su contraseña durante tres horas. Sin embargo, puede configurar el tiempo que transcurrirá antes de que se le vuelva a pedir la contraseña al usuario cambiando el valor de configuración `password_timeout` en el archivo de configuración `config/auth.php` de su aplicación.

<a name="password-confirmation-routing"></a>
### Enrutamiento

<a name="the-password-confirmation-form"></a>
#### El formulario de confirmación de contraseña

En primer lugar, definiremos una ruta para mostrar una vista que solicite al usuario que confirme su contraseña:

    Route::get('/confirm-password', function () {
        return view('auth.confirm-password');
    })->middleware('auth')->name('password.confirm');

Como es de esperar, la vista devuelta por esta ruta debe tener un formulario que contenga un campo de `contraseña`. Además, no dude en incluir texto dentro de la vista que explique que el usuario está entrando en un área protegida de la aplicación y debe confirmar su contraseña.

<a name="confirming-the-password"></a>
#### Confirmación de la contraseña

A continuación, definiremos una ruta que gestionará la petición del formulario desde la vista "confirmar contraseña". Esta ruta será responsable de validar la contraseña y redirigir al usuario a su destino:

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

Antes de continuar, examinemos esta ruta con más detalle. En primer lugar, se determina si el campo de `contraseña` de la solicitud coincide realmente con la contraseña del usuario autenticado. Si la contraseña es válida, necesitamos informar a la sesión de Laravel que el usuario ha confirmado su contraseña. El método `passwordConfirmed` establecerá una marca de tiempo en la sesión del usuario que Laravel puede utilizar para determinar cuándo fue la última vez que el usuario confirmó su contraseña. Finalmente, podemos redirigir al usuario a su destino.

<a name="password-confirmation-protecting-routes"></a>
### Protección de rutas

Debes asegurarte de que cualquier ruta que realice una acción que requiera la confirmación reciente de la contraseña tenga asignado el middleware `password.confirm`. Este middleware se incluye con la instalación por defecto de Laravel y almacenará automáticamente el destino previsto del usuario en la sesión para que el usuario pueda ser redirigido a esa ubicación después de confirmar su contraseña. Después de almacenar el destino previsto del usuario en la sesión, el middleware redirigirá al usuario a la [ruta con nombre](/docs/{{version}}/routing#named-routes) `password.confirm`:

    Route::get('/settings', function () {
        // ...
    })->middleware(['password.confirm']);

    Route::post('/settings', function () {
        // ...
    })->middleware(['password.confirm']);

<a name="adding-custom-guards"></a>
## Adición de guardas personalizadas

Puedes definir tus propias guardas de autenticación utilizando el método `extend` de la facade `Auth`. Deberías colocar tu llamada al método `extend` dentro de un [proveedor de servicios](/docs/{{version}}/providers). Como Laravel ya incluye un `AuthServiceProvider`, podemos colocar el código en ese proveedor:

    <?php

    namespace App\Providers;

    use App\Services\Auth\JwtGuard;
    use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
    use Illuminate\Support\Facades\Auth;

    class AuthServiceProvider extends ServiceProvider
    {
        /**
         * Register any application authentication / authorization services.
         *
         * @return void
         */
        public function boot()
        {
            $this->registerPolicies();

            Auth::extend('jwt', function ($app, $name, array $config) {
                // Return an instance of Illuminate\Contracts\Auth\Guard...

                return new JwtGuard(Auth::createUserProvider($config['provider']));
            });
        }
    }

Como puedes ver en el ejemplo anterior, la llamada de retorno pasada al método `extend` debería devolver una implementación de `Illuminate\Contracts\Auth\Guard`. Esta interfaz contiene algunos métodos que deberá implementar para definir una guarda personalizada. Una vez definida su guarda personalizada, puede hacer referencia a la guarda en la configuración de `guards` de su archivo de configuración `auth.php`:

    'guards' => [
        'api' => [
            'driver' => 'jwt',
            'provider' => 'users',
        ],
    ],

<a name="closure-request-guards"></a>
### Closure Request Guards

La forma más sencilla de implementar un sistema de autenticación personalizado basado en peticiones HTTP es utilizando el método `Auth::viaRequest`. Este método te permite definir rápidamente tu proceso de autenticación utilizando un único closure.

Para empezar, llame al método `Auth::viaRequest` dentro del método `boot` de su `AuthServiceProvider`. El método `viaRequest` acepta un nombre de controlador de autenticación como primer argumento. Este nombre puede ser cualquier string que describa tu guarda personalizada. El segundo argumento pasado al método debe ser un closure que reciba la petición HTTP entrante y devuelva una instancia de usuario o, si la autenticación falla, `null`:

    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;

    /**
     * Register any application authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Auth::viaRequest('custom-token', function (Request $request) {
            return User::where('token', $request->token)->first();
        });
    }

Una vez que su controlador de autenticación personalizado ha sido definido, puede configurarlo como un controlador dentro de la configuración de `guardas` de su archivo de configuración `auth.php`:

    'guards' => [
        'api' => [
            'driver' => 'custom-token',
        ],
    ],

<a name="adding-custom-user-providers"></a>
## Adición de proveedores de usuario personalizados

Si no estás usando una base de datos relacional tradicional para almacenar tus usuarios, necesitarás extender Laravel con tu propio proveedor de autenticación de usuarios. Utilizaremos el método `provider` de la facade `Auth` para definir un proveedor de usuarios personalizado. El resolver del proveedor de usuarios debe devolver una implementación de `Illuminate\Contracts\Auth\UserProvider`:

    <?php

    namespace App\Providers;

    use App\Extensions\MongoUserProvider;
    use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
    use Illuminate\Support\Facades\Auth;

    class AuthServiceProvider extends ServiceProvider
    {
        /**
         * Register any application authentication / authorization services.
         *
         * @return void
         */
        public function boot()
        {
            $this->registerPolicies();

            Auth::provider('mongo', function ($app, array $config) {
                // Return an instance of Illuminate\Contracts\Auth\UserProvider...

                return new MongoUserProvider($app->make('mongo.connection'));
            });
        }
    }

Después de haber registrado el proveedor usando el método `provider`, puede cambiar al nuevo proveedor de usuario en su archivo de configuración `auth.php`. En primer lugar, defina un `provider` que utilice su nuevo controlador:

    'providers' => [
        'users' => [
            'driver' => 'mongo',
        ],
    ],

Por último, puede hacer referencia a este proveedor en la configuración de sus `guards`:

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],
    ],

<a name="the-user-provider-contract"></a>
### El contrato de proveedor de usuario

Las implementaciones de `Illuminate\Contracts\Auth\UserProvider` son responsables de obtener una implementación `Illuminate\Contracts\Auth\Authenticatable` de un sistema de almacenamiento persistente, como MySQL, MongoDB, etc. Estas dos interfaces permiten que los mecanismos de autenticación de Laravel sigan funcionando independientemente de cómo se almacenen los datos del usuario o qué tipo de clase se utilice para representar al usuario autenticado:

Echemos un vistazo al contrato `Illuminate\Contracts\Auth\UserProvider`:

    <?php

    namespace Illuminate\Contracts\Auth;

    interface UserProvider
    {
        public function retrieveById($identifier);
        public function retrieveByToken($identifier, $token);
        public function updateRememberToken(Authenticatable $user, $token);
        public function retrieveByCredentials(array $credentials);
        public function validateCredentials(Authenticatable $user, array $credentials);
    }

La función `retrieveById` suele recibir una clave que representa al usuario, como un ID autoincrementado de una base de datos MySQL. El método debe recuperar y devolver la implementación de `Authenticatable` que coincida con el ID.

La función `retrieveByToken` recupera un usuario por su `$identifier` único y `$token`"recuérdame", normalmente almacenado en una columna de base de datos como `remember_token`. Al igual que con el método anterior, este método debe devolver la implementación de `Authenticatable` que coincida con el valor del token.

El método `updateRememberToken` actualiza el `remember_token` de la instancia `$user` con el nuevo `$token`. Se asigna un nuevo token a los usuarios en un intento exitoso de autenticación "remember me" o cuando el usuario cierra la sesión.

El método `retrieveByCredentials` recibe la array de credenciales pasada al método `Auth::attempt` cuando se intenta autenticar con una aplicación. A continuación, el método debe "consultar" el almacenamiento persistente subyacente en busca del usuario que coincida con esas credenciales. Normalmente, este método ejecutará una consulta con una condición "where" que busque un registro de usuario con un "nombre de usuario" que coincida con el valor de `$credentials['nombredeusuario']`. El método debe devolver una implementación de `Authenticatable`. **Este método no debe intentar realizar ninguna validación de contraseña o autenticación.**

El método `validateCredentials` debe comparar `$user` con `$credentials` para autenticar al usuario. Por ejemplo, este método suele utilizar el método `Hash::check` para comparar el valor de `$user->getAuthPassword()` con el valor de `$credentials['password']`. Este método debería devolver `true` o `false` indicando si la contraseña es válida.

<a name="the-authenticatable-contract"></a>
### El Contrato Autenticable

Ahora que hemos explorado cada uno de los métodos del `UserProvider`, echemos un vistazo al contrato `Authenticatable`. Recuerda que los proveedores de usuarios deben devolver implementaciones de esta interfaz desde los métodos `retrieveById`, `retrieveByToken` y `retrieveByCredentials`:

    <?php

    namespace Illuminate\Contracts\Auth;

    interface Authenticatable
    {
        public function getAuthIdentifierName();
        public function getAuthIdentifier();
        public function getAuthPassword();
        public function getRememberToken();
        public function setRememberToken($value);
        public function getRememberTokenName();
    }

Esta interfaz es sencilla. El método `getAuthIdentifierName` debe devolver el nombre del campo "clave primaria" del usuario y el método `getAuthIdentifier` debe devolver la "clave primaria" del usuario. Cuando se utiliza un back-end MySQL, esta sería probablemente la clave primaria auto-incrementable asignada al registro de usuario. El método `getAuthPassword` debe devolver la contraseña hash del usuario.

Esta interfaz permite que el sistema de autenticación funcione con cualquier clase de "usuario", independientemente del ORM o de la capa de abstracción de almacenamiento que se esté utilizando. Por defecto, Laravel incluye una clase `App\Models\User` en el directorio `app/Models` que implementa esta interfaz.

<a name="events"></a>
## Eventos

Laravel envía una serie de [eventos](/docs/{{version}}/events) durante el proceso de autenticación. Puedes adjuntar oyentes a estos eventos en tu `EventServiceProvider`:

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        'Illuminate\Auth\Events\Registered' => [
            'App\Listeners\LogRegisteredUser',
        ],

        'Illuminate\Auth\Events\Attempting' => [
            'App\Listeners\LogAuthenticationAttempt',
        ],

        'Illuminate\Auth\Events\Authenticated' => [
            'App\Listeners\LogAuthenticated',
        ],

        'Illuminate\Auth\Events\Login' => [
            'App\Listeners\LogSuccessfulLogin',
        ],

        'Illuminate\Auth\Events\Failed' => [
            'App\Listeners\LogFailedLogin',
        ],

        'Illuminate\Auth\Events\Validated' => [
            'App\Listeners\LogValidated',
        ],

        'Illuminate\Auth\Events\Verified' => [
            'App\Listeners\LogVerified',
        ],

        'Illuminate\Auth\Events\Logout' => [
            'App\Listeners\LogSuccessfulLogout',
        ],

        'Illuminate\Auth\Events\CurrentDeviceLogout' => [
            'App\Listeners\LogCurrentDeviceLogout',
        ],

        'Illuminate\Auth\Events\OtherDeviceLogout' => [
            'App\Listeners\LogOtherDeviceLogout',
        ],

        'Illuminate\Auth\Events\Lockout' => [
            'App\Listeners\LogLockout',
        ],

        'Illuminate\Auth\Events\PasswordReset' => [
            'App\Listeners\LogPasswordReset',
        ],
    ];
