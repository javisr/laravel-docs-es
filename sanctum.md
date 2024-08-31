# Laravel Sanctum

- [Introducción](#introduction)
  - [Cómo Funciona](#how-it-works)
- [Instalación](#installation)
- [Configuración](#configuration)
  - [Sobrescribir Modelos Predeterminados](#overriding-default-models)
- [Autenticación con Token API](#api-token-authentication)
  - [Emisión de Tokens API](#issuing-api-tokens)
  - [Habilidades del Token](#token-abilities)
  - [Protegiendo Rutas](#protecting-routes)
  - [Revocando Tokens](#revoking-tokens)
  - [Expiración del Token](#token-expiration)
- [Autenticación SPA](#spa-authentication)
  - [Configuración](#spa-configuration)
  - [Autenticación](#spa-authenticating)
  - [Protegiendo Rutas](#protecting-spa-routes)
  - [Autorizando Canales de Transmisión Privados](#authorizing-private-broadcast-channels)
- [Autenticación de Aplicaciones Móviles](#mobile-application-authentication)
  - [Emisión de Tokens API](#issuing-mobile-api-tokens)
  - [Protegiendo Rutas](#protecting-mobile-api-routes)
  - [Revocando Tokens](#revoking-mobile-api-tokens)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Sanctum](https://github.com/laravel/sanctum) ofrece un sistema de autenticación ligero para SPA (aplicaciones de una sola página), aplicaciones móviles y API basadas en tokens simples. Sanctum permite a cada usuario de tu aplicación generar múltiples tokens de API para su cuenta. Estos tokens pueden recibir habilidades / scopes que especifican qué acciones se les permite realizar.

<a name="how-it-works"></a>
### Cómo Funciona

Laravel Sanctum existe para resolver dos problemas separados. Discutamos cada uno antes de profundizar en la biblioteca.

<a name="how-it-works-api-tokens"></a>
#### Tokens de API

Primero, Sanctum es un paquete simple que puedes usar para emitir tokens API a tus usuarios sin la complicación de OAuth. Esta función está inspirada en GitHub y otras aplicaciones que emiten "tokens de acceso personal". Por ejemplo, imagina que la "configuración de la cuenta" de tu aplicación tiene una pantalla donde un usuario puede generar un token API para su cuenta. Puedes usar Sanctum para generar y gestionar esos tokens. Estos tokens típicamente tienen un tiempo de expiración muy largo (años), pero pueden ser revocados manualmente por el usuario en cualquier momento.
Laravel Sanctum ofrece esta función almacenando los tokens API de los usuarios en una sola tabla de base de datos y autenticando las solicitudes HTTP entrantes a través del encabezado `Authorization`, que debe contener un token API válido.

<a name="how-it-works-spa-authentication"></a>
#### Autenticación de SPA

En segundo lugar, Sanctum existe para ofrecer una manera simple de autenticar aplicaciones de una sola página (SPAs) que necesitan comunicarse con una API impulsada por Laravel. Estas SPAs pueden existir en el mismo repositorio que tu aplicación Laravel o pueden ser un repositorio completamente separado, como una SPA creada con Next.js o Nuxt.
Para esta función, Sanctum no utiliza tokens de ningún tipo. En su lugar, Sanctum utiliza los servicios de autenticación de sesión basados en cookies integrados en Laravel. Típicamente, Sanctum utiliza el guardia de autenticación `web` de Laravel para lograr esto. Esto proporciona los beneficios de protección CSRF, autenticación de sesión, así como proteger contra la filtración de las credenciales de autenticación a través de XSS.
Sanctum solo intentará autenticar utilizando cookies cuando la solicitud entrante origine desde tu propio frontend SPA. Cuando Sanctum examina una solicitud HTTP entrante, primero verificará si hay una cookie de autenticación y, si no está presente, Sanctum luego examinará el encabezado `Authorization` en busca de un token API válido.
> [!NOTA]
Está completamente bien usar Sanctum solo para la autenticación de tokens de API o solo para la autenticación de SPA. Solo porque uses Sanctum no significa que estés obligado a utilizar ambas funciones que ofrece.

<a name="installation"></a>
## Instalación

Puedes instalar Laravel Sanctum a través del comando Artisan `install:api`:


```shell
php artisan install:api

```
A continuación, si planeas utilizar Sanctum para autenticar una SPA, consulta la sección de [Autenticación de SPA](#spa-authentication) de esta documentación.

<a name="configuration"></a>
## Configuración


<a name="overriding-default-models"></a>
### Sobrescribiendo Modelos Predeterminados

Aunque no es típico que se requiera, puedes extender el modelo `PersonalAccessToken` utilizado internamente por Sanctum:


```php
use Laravel\Sanctum\PersonalAccessToken as SanctumPersonalAccessToken;

class PersonalAccessToken extends SanctumPersonalAccessToken
{
    // ...
}
```
Entonces, puedes instruir a Sanctum para que utilice tu modelo personalizado a través del método `usePersonalAccessTokenModel` proporcionado por Sanctum. Típicamente, debes llamar a este método en el método `boot` del archivo `AppServiceProvider` de tu aplicación:


```php
use App\Models\Sanctum\PersonalAccessToken;
use Laravel\Sanctum\Sanctum;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);
}
```

<a name="api-token-authentication"></a>
## Autenticación de Token API

> [!NOTE]
No debes usar tokens API para autenticar tu propia SPA de primer nivel. En su lugar, utiliza las [funciones de autenticación de SPA](#spa-authentication) integradas de Sanctum.

<a name="issuing-api-tokens"></a>
Sanctum te permite emitir tokens API / tokens de acceso personal que se pueden usar para autenticar solicitudes API a tu aplicación. Al hacer solicitudes utilizando tokens API, el token debe incluirse en el encabezado `Authorization` como un token `Bearer`.
Para comenzar a emitir tokens para los usuarios, tu modelo User debe usar el trait `Laravel\Sanctum\HasApiTokens`:


```php
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;
}
```
Para emitir un token, puedes usar el método `createToken`. El método `createToken` devuelve una instancia de `Laravel\Sanctum\NewAccessToken`. Los tokens API se hash utilizando hashing SHA-256 antes de ser almacenados en tu base de datos, pero puedes acceder al valor en texto plano del token utilizando la propiedad `plainTextToken` de la instancia `NewAccessToken`. Debes mostrar este valor al usuario inmediatamente después de que se haya creado el token:


```php
use Illuminate\Http\Request;

Route::post('/tokens/create', function (Request $request) {
    $token = $request->user()->createToken($request->token_name);

    return ['token' => $token->plainTextToken];
});
```
Puedes acceder a todos los tokens del usuario utilizando la relación Eloquent `tokens` proporcionada por el trait `HasApiTokens`:


```php
foreach ($user->tokens as $token) {
    // ...
}
```

<a name="token-abilities"></a>
### Capacidades de Token

Sanctum te permite asignar "capacidades" a los tokens. Las capacidades cumplen un propósito similar a los "alcances" de OAuth. Puedes pasar un array de capacidades en forma de cadena como segundo argumento al método `createToken`:


```php
return $user->createToken('token-name', ['server:update'])->plainTextToken;
```
Al manejar una solicitud entrante autenticada por Sanctum, puedes determinar si el token tiene una habilidad dada utilizando el método `tokenCan`:


```php
if ($user->tokenCan('server:update')) {
    // ...
}
```

<a name="token-ability-middleware"></a>
#### Middleware de Habilidad de Token

Sanctum también incluye dos middleware que se pueden utilizar para verificar que una solicitud entrante esté autenticada con un token que ha sido otorgado una habilidad dada. Para comenzar, define los siguientes alias de middleware en el archivo `bootstrap/app.php` de tu aplicación:


```php
use Laravel\Sanctum\Http\Middleware\CheckAbilities;
use Laravel\Sanctum\Http\Middleware\CheckForAnyAbility;

->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'abilities' => CheckAbilities::class,
        'ability' => CheckForAnyAbility::class,
    ]);
})
```
El middleware `abilities` puede asignarse a una ruta para verificar que el token de la solicitud entrante tenga todas las habilidades listadas:


```php
Route::get('/orders', function () {
    // Token has both "check-status" and "place-orders" abilities...
})->middleware(['auth:sanctum', 'abilities:check-status,place-orders']);
```
El middleware `ability` puede asignarse a una ruta para verificar que el token de la solicitud entrante tenga *al menos una* de las habilidades listadas:


```php
Route::get('/orders', function () {
    // Token has the "check-status" or "place-orders" ability...
})->middleware(['auth:sanctum', 'ability:check-status,place-orders']);
```

<a name="first-party-ui-initiated-requests"></a>
#### Solicitudes Iniciadas por la Interfaz de Usuario de Primer Partido

Para mayor comodidad, el método `tokenCan` siempre devolverá `true` si la solicitud autenticada entrante fue de tu SPA de primera parte y estás utilizando la [autenticación SPA](#spa-authentication) incorporada de Sanctum.
Sin embargo, esto no significa necesariamente que tu aplicación deba permitir al usuario realizar la acción. Típicamente, las [políticas de autorización](/docs/%7B%7Bversion%7D%7D/authorization#creating-policies) de tu aplicación determinarán si el token ha recibido el permiso para realizar las habilidades, así como verificar que la instancia del usuario mismo deba tener permitido realizar la acción.
Por ejemplo, si imaginamos una aplicación que gestiona servidores, esto podría significar verificar que el token esté autorizado para actualizar servidores **y** que el servidor pertenezca al usuario:


```php
return $request->user()->id === $server->user_id &&
       $request->user()->tokenCan('server:update')

```
Al principio, permitir que se llame al método `tokenCan` y que siempre devuelva `true` para las solicitudes iniciadas por la UI de primera parte puede parecer extraño; sin embargo, es conveniente poder asumir que un token de API está siempre disponible y se puede inspeccionar a través del método `tokenCan`. Al tomar este enfoque, puedes llamar siempre al método `tokenCan` dentro de las políticas de autorización de tu aplicación sin preocuparte de si la solicitud fue activada desde la UI de tu aplicación o fue iniciada por uno de los consumidores de terceros de tu API.

<a name="protecting-routes"></a>
Para proteger rutas de modo que todas las solicitudes entrantes deben estar autenticadas, debes adjuntar el guardia de autenticación `sanctum` a tus rutas protegidas dentro de tus archivos de rutas `routes/web.php` y `routes/api.php`. Este guardia asegurará que las solicitudes entrantes estén autenticadas como solicitudes con estado, autenticadas por cookie, o contengan un encabezado de token de API válido si la solicitud es de un tercero.
Es posible que te estés preguntando por qué sugerimos que autentiques las rutas dentro del archivo `routes/web.php` de tu aplicación utilizando el guardia `sanctum`. Recuerda que Sanctum intentará primero autenticar las solicitudes entrantes utilizando la cookie de autenticación de sesión típica de Laravel. Si esa cookie no está presente, entonces Sanctum intentará autenticar la solicitud utilizando un token en el encabezado `Authorization` de la solicitud. Además, autenticar todas las solicitudes utilizando Sanctum asegura que siempre podamos llamar al método `tokenCan` en la instancia del usuario actualmente autenticado:

<a name="revoking-tokens"></a>
Puedes "revocar" tokens eliminándolos de tu base de datos utilizando la relación `tokens` que proporciona el rasgo `Laravel\Sanctum\HasApiTokens`:


```php
// Revoke all tokens...
$user->tokens()->delete();

// Revoke the token that was used to authenticate the current request...
$request->user()->currentAccessToken()->delete();

// Revoke a specific token...
$user->tokens()->where('id', $tokenId)->delete();
```

<a name="token-expiration"></a>
### Expiración del Token

Por defecto, los tokens de Sanctum nunca expiran y solo pueden ser invalidados mediante [la revocación del token](#revoking-tokens). Sin embargo, si deseas configurar un tiempo de expiración para los tokens API de tu aplicación, puedes hacerlo a través de la opción de configuración `expiration` definida en el archivo de configuración `sanctum` de tu aplicación. Esta opción de configuración define el número de minutos hasta que un token emitido se considerará expirado:


```php
'expiration' => 525600,

```
Si deseas especificar el tiempo de expiración de cada token de forma independiente, puedes hacerlo proporcionando el tiempo de expiración como el tercer argumento al método `createToken`:


```php
return $user->createToken(
    'token-name', ['*'], now()->addWeek()
)->plainTextToken;

```
Si has configurado un tiempo de expiración de token para tu aplicación, es posible que también desees [programar una tarea](/docs/%7B%7Bversion%7D%7D/scheduling) para eliminar los tokens expirados de tu aplicación. Afortunadamente, Sanctum incluye un comando Artisan `sanctum:prune-expired` que puedes usar para lograr esto. Por ejemplo, puedes configurar una tarea programada para eliminar todos los registros de base de datos de tokens expirados que hayan estado expirados durante al menos 24 horas:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('sanctum:prune-expired --hours=24')->daily();

```

<a name="spa-authentication"></a>
## Autenticación de SPA

Sanctum también existe para proporcionar un método simple de autenticación para aplicaciones de una sola página (SPAs) que necesitan comunicarse con una API impulsada por Laravel. Estas SPAs pueden existir en el mismo repositorio que tu aplicación Laravel o pueden ser un repositorio completamente separado.
Para esta función, Sanctum no utiliza tokens de ningún tipo. En su lugar, Sanctum utiliza los servicios de autenticación de sesión basados en cookies integrados en Laravel. Este enfoque de autenticación ofrece los beneficios de protección CSRF, autenticación de sesión, así como protección contra la filtración de las credenciales de autenticación a través de XSS.
> [!WARNING]
Para autenticarte, tu SPA y API deben compartir el mismo dominio de nivel superior. Sin embargo, pueden estar ubicados en diferentes subdominios. Además, debes asegurarte de enviar el encabezado `Accept: application/json` y el encabezado `Referer` o `Origin` con tu solicitud.

<a name="spa-configuration"></a>
### Configuración


<a name="configuring-your-first-party-domains"></a>
#### Configurando tus dominios de primera parte

Primero, debes configurar desde qué dominios tu SPA realizará solicitudes. Puedes configurar estos dominios utilizando la opción de configuración `stateful` en tu archivo de configuración `sanctum`. Esta configuración determina qué dominios mantendrán la autenticación "stateful" utilizando cookies de sesión de Laravel al realizar solicitudes a tu API.
> [!WARNING]
Si estás accediendo a tu aplicación a través de una URL que incluye un puerto (`127.0.0.1:8000`), debes asegurarte de que incluyas el número de puerto junto con el dominio.

<a name="sanctum-middleware"></a>
#### Middleware de Sanctum

A continuación, debes instruir a Laravel para que las solicitudes entrantes de tu SPA puedan autenticarse utilizando las cookies de sesión de Laravel, mientras que aún se permiten las solicitudes de terceros o aplicaciones móviles para autenticarse usando tokens API. Esto se puede lograr fácilmente invocando el método `statefulApi` de middleware en el archivo `bootstrap/app.php` de tu aplicación:


```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->statefulApi();
})
```

<a name="cors-and-cookies"></a>
#### CORS y Cookies

Si tienes problemas para autenticarte con tu aplicación desde una SPA que se ejecuta en un subdominio separado, es probable que hayas configurado incorrectamente tu CORS (Intercambio de Recursos de Origen Cruzado) o la configuración de cookies de sesión.
El archivo de configuración `config/cors.php` no se publica por defecto. Si necesitas personalizar las opciones de CORS de Laravel, debes publicar el archivo de configuración `cors` completo utilizando el comando Artisan `config:publish`:


```bash
php artisan config:publish cors

```
A continuación, debes asegurarte de que la configuración CORS de tu aplicación esté devolviendo el encabezado `Access-Control-Allow-Credentials` con un valor de `True`. Esto se puede lograr configurando la opción `supports_credentials` dentro del archivo de configuración `config/cors.php` de tu aplicación a `true`.
Además, deberías habilitar las opciones `withCredentials` y `withXSRFToken` en la instancia global `axios` de tu aplicación. Típicamente, esto debería realizarse en tu archivo `resources/js/bootstrap.js`. Si no estás utilizando Axios para realizar solicitudes HTTP desde tu frontend, deberías realizar la configuración equivalente en tu propio cliente HTTP:


```js
axios.defaults.withCredentials = true;
axios.defaults.withXSRFToken = true;

```
Finalmente, debes asegurarte de que la configuración del dominio de la cookie de sesión de tu aplicación admita cualquier subdominio de tu dominio raíz. Puedes lograr esto prefijando el dominio con un `.` al inicio dentro del archivo de configuración `config/session.php` de tu aplicación:


```php
'domain' => '.domain.com',
```

<a name="spa-authenticating"></a>
### Autenticación


<a name="csrf-protection"></a>
#### Protección CSRF

Para autenticar tu SPA, la página de "inicio de sesión" de tu SPA debe primero hacer una solicitud al endpoint `/sanctum/csrf-cookie` para inicializar la protección CSRF para la aplicación:


```js
axios.get('/sanctum/csrf-cookie').then(response => {
    // Login...
});

```
Durante esta solicitud, Laravel establecerá una cookie `XSRF-TOKEN` que contiene el token CSRF actual. Este token debe ser pasado en un encabezado `X-XSRF-TOKEN` en solicitudes posteriores, lo cual algunas bibliotecas de clientes HTTP como Axios y el HttpClient de Angular harán automáticamente por ti. Si tu biblioteca HTTP de JavaScript no establece el valor por ti, necesitarás configurar manualmente el encabezado `X-XSRF-TOKEN` para que coincida con el valor de la cookie `XSRF-TOKEN` que se establece en esta ruta.

<a name="logging-in"></a>
#### Iniciando Sesión

Una vez que se haya inicializado la protección CSRF, debes hacer una solicitud `POST` a la ruta `/login` de tu aplicación Laravel. Esta ruta `/login` puede ser [implementada manualmente](/docs/%7B%7Bversion%7D%7D/authentication#authenticating-users) o utilizando un paquete de autenticación headless como [Laravel Fortify](/docs/%7B%7Bversion%7D%7D/fortify).
Si la solicitud de inicio de sesión es exitosa, estarás autenticado y las solicitudes posteriores a las rutas de tu aplicación se autenticarán automáticamente a través de la cookie de sesión que la aplicación Laravel emitió a tu cliente. Además, dado que tu aplicación ya realizó una solicitud a la ruta `/sanctum/csrf-cookie`, las solicitudes posteriores deberían recibir automáticamente protección CSRF siempre que tu cliente HTTP de JavaScript envíe el valor de la cookie `XSRF-TOKEN` en el encabezado `X-XSRF-TOKEN`.
Por supuesto, si la sesión de tu usuario expira debido a la falta de actividad, las solicitudes posteriores a la aplicación Laravel pueden recibir una respuesta de error HTTP 401 o 419. En este caso, debes redirigir al usuario a la página de inicio de sesión de tu SPA.
> [!WARNING]
Puedes escribir tu propio endpoint `/login`; sin embargo, debes asegurarte de que autentique al usuario utilizando los servicios de autenticación basados en [sesiones que proporciona Laravel](/docs/%7B%7Bversion%7D%7D/authentication#authenticating-users). Típicamente, esto significa usar el guardia de autenticación `web`.

<a name="protecting-spa-routes"></a>
Para proteger rutas de modo que todas las solicitudes entrantes deben estar autenticadas, debes adjuntar el guardia de autenticación `sanctum` a tus rutas API dentro de tu archivo `routes/api.php`. Este guardia asegurará que las solicitudes entrantes estén autenticadas como solicitudes autenticadas con estado de tu SPA o contengan un encabezado de token API válido si la solicitud es de un tercero:


```php
use Illuminate\Http\Request;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
```

<a name="authorizing-private-broadcast-channels"></a>
### Autorizando Canales de Difusión Privados

Si tu SPA necesita autenticarse con [canales de difusión privados / de presencia](/docs/%7B%7Bversion%7D%7D/broadcasting#authorizing-channels), deberías eliminar la entrada `channels` del método `withRouting` contenido en el archivo `bootstrap/app.php` de tu aplicación. En su lugar, debes invocar el método `withBroadcasting` para que puedas especificar el middleware correcto para las rutas de difusión de tu aplicación:


```php
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        // ...
    )
    ->withBroadcasting(
        __DIR__.'/../routes/channels.php',
        ['prefix' => 'api', 'middleware' => ['api', 'auth:sanctum']],
    )
```
A continuación, para que las solicitudes de autorización de Pusher tengan éxito, necesitarás proporcionar un `authorizer` personalizado de Pusher al inicializar [Laravel Echo](/docs/%7B%7Bversion%7D%7D/broadcasting#client-side-installation). Esto permite que tu aplicación configure Pusher para usar la instancia de `axios` que está [correctamente configurada para solicitudes entre dominios](#cors-and-cookies):


```js
window.Echo = new Echo({
    broadcaster: "pusher",
    cluster: import.meta.env.VITE_PUSHER_APP_CLUSTER,
    encrypted: true,
    key: import.meta.env.VITE_PUSHER_APP_KEY,
    authorizer: (channel, options) => {
        return {
            authorize: (socketId, callback) => {
                axios.post('/api/broadcasting/auth', {
                    socket_id: socketId,
                    channel_name: channel.name
                })
                .then(response => {
                    callback(false, response.data);
                })
                .catch(error => {
                    callback(true, error);
                });
            }
        };
    },
})

```

<a name="mobile-application-authentication"></a>
## Autenticación de Aplicaciones Móviles

También puedes usar tokens de Sanctum para autenticar las solicitudes de la aplicación móvil a tu API. El proceso para autenticar las solicitudes de la aplicación móvil es similar al de autenticar solicitudes de API de terceros; sin embargo, hay pequeñas diferencias en cómo emitirás los tokens de API.

<a name="issuing-mobile-api-tokens"></a>
### Emisión de Tokens de API

Para comenzar, crea una ruta que acepte el correo electrónico / nombre de usuario del usuario, la contraseña y el nombre del dispositivo, y luego intercambia esas credenciales por un nuevo token de Sanctum. El "nombre del dispositivo" dado a este endpoint es solo para fines informativos y puede ser cualquier valor que desees. En general, el valor del nombre del dispositivo debe ser un nombre que el usuario reconozca, como "iPhone 12 de Nuno".
Típicamente, realizarás una solicitud al endpoint de token desde la pantalla de "inicio de sesión" de tu aplicación móvil. El endpoint devolverá el token API en texto plano, que luego puede ser almacenado en el dispositivo móvil y utilizado para hacer solicitudes API adicionales:


```php
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

Route::post('/sanctum/token', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
        'device_name' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();

    if (! $user || ! Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages([
            'email' => ['The provided credentials are incorrect.'],
        ]);
    }

    return $user->createToken($request->device_name)->plainTextToken;
});
```
Cuando la aplicación móvil utiliza el token para hacer una solicitud API a tu aplicación, debe pasar el token en el encabezado `Authorization` como un token `Bearer`.
> [!NOTA]
Al emitir tokens para una aplicación móvil, también puedes especificar [habilidades del token](#token-abilities).

<a name="protecting-mobile-api-routes"></a>
### Protegiendo Rutas

Como se documentó anteriormente, puedes proteger rutas para que todas las solicitudes entrantes deben estar autenticadas adjuntando el guardia de autenticación `sanctum` a las rutas:


```php
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
```

<a name="revoking-mobile-api-tokens"></a>
### Revocar Tokens

Para permitir que los usuarios revoquen los tokens de API emitidos a dispositivos móviles, puedes listarlos por nombre, junto con un botón de "Revocar", dentro de una sección de "configuración de cuenta" en la interfaz de usuario de tu aplicación web. Cuando el usuario haga clic en el botón de "Revocar", puedes eliminar el token de la base de datos. Recuerda que puedes acceder a los tokens de API de un usuario a través de la relación `tokens` proporcionada por el rasgo `Laravel\Sanctum\HasApiTokens`:


```php
// Revoke all tokens...
$user->tokens()->delete();

// Revoke a specific token...
$user->tokens()->where('id', $tokenId)->delete();
```

<a name="testing"></a>
## Pruebas

Mientras se prueba, se puede usar el método `Sanctum::actingAs` para autenticar a un usuario y especificar qué habilidades se deben otorgar a su token:


```php
use App\Models\User;
use Laravel\Sanctum\Sanctum;

test('task list can be retrieved', function () {
    Sanctum::actingAs(
        User::factory()->create(),
        ['view-tasks']
    );

    $response = $this->get('/api/task');

    $response->assertOk();
});

```


```php
use App\Models\User;
use Laravel\Sanctum\Sanctum;

public function test_task_list_can_be_retrieved(): void
{
    Sanctum::actingAs(
        User::factory()->create(),
        ['view-tasks']
    );

    $response = $this->get('/api/task');

    $response->assertOk();
}

```
Si deseas otorgar todas las habilidades al token, deberías incluir `*` en la lista de habilidades proporcionada al método `actingAs`:


```php
Sanctum::actingAs(
    User::factory()->create(),
    ['*']
);
```