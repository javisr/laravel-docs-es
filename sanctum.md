# Laravel Sanctum

- [Introducción](#introduction)
  - [Funcionamiento](#how-it-works)
- [Instalación](#installation)
- [Configuración](#configuration)
  - [Sustitución de modelos predeterminados](#overriding-default-models)
- [Autenticación de tokens de API](#api-token-authentication)
  - [Emisión de tokens de API](#issuing-api-tokens)
  - [Habilidades de los tokens](#token-abilities)
  - [Protección de rutas](#protecting-routes)
  - [Revocación de tokens](#revoking-tokens)
  - [Expiración de tokens](#token-expiration)
- [Autenticación SPA](#spa-authentication)
  - [Configuración](#spa-configuration)
  - [Autenticación](#spa-authenticating)
  - [Protección de rutas](#protecting-spa-routes)
  - [Autorización de canales de difusión privados](#authorizing-private-broadcast-channels)
- [Autenticación de aplicaciones móviles](#mobile-application-authentication)
  - [Emisión de tokens de API](#issuing-mobile-api-tokens)
  - [Protección de rutas](#protecting-mobile-api-routes)
  - [Revocación de tokens](#revoking-mobile-api-tokens)
- [Probando](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Sanctum](https://github.com/laravel/sanctum) proporciona un sistema de autenticación de ligero para SPAs (aplicaciones de página única), aplicaciones móviles y APIs simples basadas en tokens. Sanctum permite a cada usuario de tu aplicación generar múltiples tokens API para su cuenta. A estos tokens se les pueden otorgar habilidades / ámbitos que especifican qué acciones pueden realizar los tokens.

<a name="how-it-works"></a>
### Cómo funciona

Laravel Sanctum se puede usar para resolver dos problemas distintos. Vamos a discutir cada uno antes de profundizar en la biblioteca.

<a name="how-it-works-api-tokens"></a>
#### Tokens de API

En primer lugar, Sanctum es un paquete simple que puede utilizar para emitir tokens de API a sus usuarios sin la complicación de OAuth. Esta característica está inspirada en GitHub y otras aplicaciones que emiten "tokens de acceso personal". Por ejemplo, imagina que la "configuración de cuenta" de tu aplicación tiene una pantalla donde un usuario puede generar un token de API para su cuenta. Puedes utilizar Sanctum para generar y gestionar esos tokens. Estos tokens suelen tener un tiempo de caducidad muy largo (años), pero pueden ser revocados manualmente por el usuario en cualquier momento.

Laravel Sanctum ofrece esta característica mediante el almacenamiento de tokens de API de usuario en una sola tabla de base de datos y la autenticación de las solicitudes HTTP entrantes a través de la cabecera `Authorization` que debe contener un token de API válido.

<a name="how-it-works-spa-authentication"></a>
#### Autenticación de SPA

En segundo lugar, Sanctum existe para ofrecer una forma sencilla de autenticar aplicaciones de página única (SPA) que necesitan comunicarse con una API de Laravel. Estas SPAs pueden existir en el mismo repositorio que tu aplicación Laravel o pueden ser un repositorio completamente separado, como una SPA creada usando Vue CLI o una aplicación Next.js.

Para esta función, Sanctum no utiliza tokens de ningún tipo. En su lugar, Sanctum utiliza los servicios de autenticación de sesión basados en cookies incorporados en Laravel. Típicamente, Sanctum utiliza la guarda de autenticación `web` de Laravel para lograr esto. Esto proporciona los beneficios de la protección CSRF, autenticación de sesión, así como protege contra la fuga de las credenciales de autenticación a través de XSS.

Sanctum solo intentará autenticar usando cookies cuando la petición entrante se origine desde tu propio frontend SPA. Cuando Sanctum examina una petición HTTP entrante, primero comprobará si hay una cookie de autenticación y, si no hay ninguna presente, Sanctum examinará la cabecera de `Autorización` en busca de un token de API válido.

> **Nota**  
> Es perfectamente correcto utilizar Sanctum sólo para la autenticación de token de API o sólo para la autenticación de SPA. El hecho de utilizar Sanctum no significa que esté obligado a utilizar las dos funciones que ofrece.

<a name="installation"></a>
## Instalación

> **Nota**  
> Las versiones más recientes de Laravel ya incluyen Laravel Sanctum. Sin embargo, si el archivo `composer.json` de tu aplicación no incluye `laravel/sanctum`, puedes seguir las instrucciones de instalación que se indican a continuación.

Puedes instalar Laravel Sanctum a través del gestor de paquetes Composer:

```shell
composer require laravel/sanctum
```

A continuación, debes publicar los archivos de configuración y migración de Sanctum utilizando el comando `vendor:publish` Artisan. El archivo de configuración de `Sanctum` será colocado en el directorio `config` de tu aplicación:

```shell
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

Por último, debes ejecutar las migraciones de tu base de datos. Sanctum creará una tabla de base de datos en la que almacenar los tokens de la API:

```shell
php artisan migrate
```

A continuación, si planeas utilizar Sanctum para autenticar una SPA, deberías añadir el middleware de Sanctum a tu grupo middleware `api` dentro del archivo `app/Http/Kernel.php` de tu aplicación:

    'api' => [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],

<a name="migration-customization"></a>
#### Personalización de la migración

Si no vas a utilizar las migraciones por defecto de Sanctum, debes llamar al método `Sanctum::ignoreMigrations` en el método `register` de tu clase `AppProviders\AppServiceProvider`. Puede exportar las migraciones por defecto ejecutando el siguiente comando: `php artisan vendor:publish --tag=sanctum-migrations`

<a name="configuration"></a>
## Configuración

<a name="overriding-default-models"></a>
### Modificación de modelos predeterminados

Aunque no es necesario, puedes extender el modelo `PersonalAccessToken` usado internamente por Sanctum:

    use Laravel\Sanctum\PersonalAccessToken as SanctumPersonalAccessToken;

    class PersonalAccessToken extends SanctumPersonalAccessToken
    {
        // ...
    }

A continuación, puede indicar a Sanctum que utilice su modelo personalizado mediante el método `usePersonalAccessTokenModel` proporcionado por Sanctum. Normalmente, deberías llamar a este método en el método de `boot` de uno de los proveedores de servicios de tu aplicación:

    use App\Models\Sanctum\PersonalAccessToken;
    use Laravel\Sanctum\Sanctum;

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Sanctum::usePersonalAccessTokenModel(PersonalAccessToken::class);
    }

<a name="api-token-authentication"></a>
## Autenticación de tokens de API

> **Nota**  
> No debe utilizar tokens de API para autenticar su propio SPA de origen. En su lugar, utilice las [funciones de autenticación](#spa-authentication) de SPA integradas en Sanctum.

<a name="issuing-api-tokens"></a>
### Emisión de tokens de API

Sanctum le permite emitir tokens de API / tokens de acceso personal que se pueden utilizar para autenticar las solicitudes de API a su aplicación. Al realizar solicitudes utilizando tokens de API, el token debe incluirse en la cabecera `Authorization` como token `Bearer`.

Para empezar a emitir tokens para los usuarios, su modelo de usuario debe utilizar el trait `LaravelSanctum\HasApiTokens`:

    use Laravel\Sanctum\HasApiTokens;

    class User extends Authenticatable
    {
        use HasApiTokens, HasFactory, Notifiable;
    }

Para emitir un token, puede utilizar el método `createToken`. El método `createToken` devuelve una instancia `Laravel\Sanctum\NewAccessToken`. Los tokens de la API se cifran utilizando el hash SHA-256 antes de ser almacenados en la base de datos, pero se puede acceder al valor en texto plano del token utilizando la propiedad `plainTextToken` de la instancia `NewAccessToken`. Debe mostrar este valor al usuario inmediatamente después de que se haya creado el token:

    use Illuminate\Http\Request;

    Route::post('/tokens/create', function (Request $request) {
        $token = $request->user()->createToken($request->token_name);

        return ['token' => $token->plainTextToken];
    });

Puede acceder a todos los tokens del usuario utilizando la relación `tokens` Eloquent proporcionada por el trait `HasApiTokens`:

    foreach ($user->tokens as $token) {
        //
    }

<a name="token-abilities"></a>
### Habilidades de los tokens

Sanctum permite asignar "habilidades" a los tokens. Las habilidades tienen un propósito similar a los "ámbitos" de OAuth. Puede pasar una array de habilidades de cadena como segundo argumento al método `createToken`:

    return $user->createToken('token-name', ['server:update'])->plainTextToken;

Al gestionar una solicitud entrante autenticada por Sanctum, puedes determinar si el token tiene una habilidad determinada utilizando el método `tokenCan`:

    if ($user->tokenCan('server:update')) {
        //
    }

<a name="token-ability-middleware"></a>
#### Middleware de habilidad de token

Sanctum también incluye dos middleware que se pueden utilizar para verificar que una solicitud entrante está autenticada con un token al que se le ha concedido una habilidad determinada. Para empezar, añade el siguiente middleware a la propiedad `$routeMiddleware` del archivo `app/Http/Kernel.` php de tu aplicación:

    'abilities' => \Laravel\Sanctum\Http\Middleware\CheckAbilities::class,
    'ability' => \Laravel\Sanctum\Http\Middleware\CheckForAnyAbility::class,

El middleware de `abilities` puede ser asignado a una ruta para verificar que el token de la petición entrante tiene todas las habilidades listadas:

    Route::get('/orders', function () {
        // Token has both "check-status" and "place-orders" abilities...
    })->middleware(['auth:sanctum', 'abilities:check-status,place-orders']);

El middleware de `ability` puede ser asignado a una ruta para verificar que el token de la petición entrante tiene *al menos una* de las habilidades listadas:

    Route::get('/orders', function () {
        // Token has the "check-status" or "place-orders" ability...
    })->middleware(['auth:sanctum', 'ability:check-status,place-orders']);

<a name="first-party-ui-initiated-requests"></a>
#### Solicitudes iniciadas por la propia interfaz (First-Party UI)

Por conveniencia, el método `tokenCan` siempre devolverá `true` si la solicitud autenticada entrante proviene de su SPA de origen y está utilizando la [autenticación SPA](#spa-authentication) incorporada de Sanctum.

Sin embargo, esto no significa necesariamente que su aplicación tenga que permitir al usuario realizar la acción. Normalmente, las [policies de autorización](/docs/{{version}}/authorization#creating-policies) de su aplicación determinarán si se ha concedido al token el permiso para realizar las habilidades, así como comprobar que la propia instancia de usuario debe tener permiso para realizar la acción.

Por ejemplo, si imaginamos una aplicación que gestiona servidores, esto podría significar comprobar que el token está autorizado a actualizar servidores **y** que el servidor pertenece al usuario:

```php
return $request->user()->id === $server->user_id &&
       $request->user()->tokenCan('server:update')
```

Al principio, permitir que el método `tokenCan` sea llamado y siempre devuelva `true` para peticiones iniciadas por la propia interfaz de usuario puede parecer extraño; sin embargo, es conveniente poder asumir siempre que un token de API está disponible y puede ser inspeccionado a través del método `tokenCan`. Adoptando este enfoque, usted siempre puede llamar al método `tokenCan` dentro de las policies autorización de su aplicación sin preocuparse de si la solicitud fue lanzada desde la interfaz de usuario de su aplicación o fue iniciada por uno de los consumidores de terceros de su API.

<a name="protecting-routes"></a>
### Protección de rutas

Para proteger las rutas de forma que todas las peticiones entrantes deban autenticarse, debe adjuntar la guarda de autenticación `sanctum` a sus rutas protegidas dentro de sus archivos de ruta `routes/web.php` y `routes/api.php`. Esta guarda asegurará que las peticiones entrantes sean autenticadas como peticiones con estado, autenticadas por cookie o que contengan una cabecera de token de API válida si la petición es de un tercero.

Te estarás preguntando por qué sugerimos que autentiques las rutas dentro del archivo `routes/web.php`  de tu aplicación usando la guarda `sanctum`. Recuerda, Sanctum primero intentará autenticar las peticiones entrantes usando la típica cookie de autenticación de sesión de Laravel. Si esa cookie no está presente entonces Sanctum intentará autenticar la petición usando un token en la cabecera `Authorization` de la petición. Además, autenticar todas las peticiones usando Sanctum asegura que siempre podamos llamar al método `tokenCan` en la instancia de usuario autenticada actualmente:

    use Illuminate\Http\Request;

    Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
        return $request->user();
    });

<a name="revoking-tokens"></a>s
### Revocación de tokens

Puedes "revocar" tokens borrándolos de tu base de datos usando la relación `tokens` que proporciona el trait `Laravel\Sanctum\HasApiTokens`:

    // Revoke all tokens...
    $user->tokens()->delete();

    // Revoke the token that was used to authenticate the current request...
    $request->user()->currentAccessToken()->delete();

    // Revoke a specific token...
    $user->tokens()->where('id', $tokenId)->delete();

<a name="token-expiration"></a>
### Caducidad de tokens

Por defecto, los tokens de Sanctum nunca caducan y sólo pueden ser invalidados [revocando el token](#revoking-tokens). Sin embargo, si desea configurar un tiempo de caducidad para los tokens API de su aplicación, puede hacerlo a través de la opción de configuración `expiration` definida en el archivo de configuración de `sanctum` de su aplicación. Esta opción de configuración define el número de minutos hasta que un token emitido se considerará caducado:

```php
'expiration' => 525600,
```

Si ha configurado un tiempo de expiración de token para su aplicación, puede que también desee [programar una tarea](/docs/{{version}}/scheduling) para eliminar los tokens expirados de su aplicación. Afortunadamente, Sanctum incluye un comando Artisan `sanctum:prune-expired` que puedes utilizar para lograr esto. Por ejemplo, puedes configurar una tarea programada para eliminar todos los registros caducados de la base de datos de tokens que lleven caducados al menos 24 horas:

```php
$schedule->command('sanctum:prune-expired --hours=24')->daily();
```

<a name="spa-authentication"></a>
## Autenticación de SPA

Sanctum también sirve para proporcionar un método simple de autenticación de aplicaciones de página única (SPA) que necesitan comunicarse con una API de Laravel. Estas SPAs pueden existir en el mismo repositorio que su aplicación Laravel o puede ser un repositorio totalmente independiente.

Para esta función, Sanctum no utiliza tokens de ningún tipo. En su lugar, Sanctum utiliza los servicios de autenticación de sesión basados en cookies incorporados en Laravel. Este enfoque de la autenticación proporciona los beneficios de la protección CSRF, autenticación de sesión, así como protege contra la fuga de las credenciales de autenticación a través de XSS.

> **Advertencia**  
> Con el fin de autenticar, su SPA y API deben compartir el mismo dominio de nivel superior. Sin embargo, pueden situarse en subdominios diferentes. Además, debe asegurarse de enviar el encabezado `Accept: application/json` con su solicitud.


<a name="spa-configuration"></a>
### Configuración

<a name="configuring-your-first-party-domains"></a>
#### Configuración de los dominios de origen

En primer lugar, debe configurar los dominios desde los que su SPA realizará solicitudes. Puede configurar estos dominios utilizando la opción de configuración `stateful` en su archivo de configuración `de sanctum`. Este ajuste de configuración determina qué dominios mantendrán la autenticación "stateful" utilizando las cookies de sesión de Laravel al hacer peticiones a su API.

> **Advertencia**  
> Si accede a su aplicación a través de una URL que incluye un puerto`(127.0.0.1:8000`), debe asegurarse de incluir el número de puerto con el dominio.

<a name="sanctum-middleware"></a>
#### Middleware Sanctum

A continuación, debes añadir el middleware de Sanctum a tu grupo de middleware `api` dentro de tu archivo `app/Http/Kernel.php`. Este middleware es responsable de garantizar que las solicitudes entrantes de tu SPA puedan autenticarse utilizando las cookies de sesión de Laravel, al tiempo que permite que las solicitudes de terceros o aplicaciones móviles se autentiquen utilizando tokens de API:

    'api' => [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],

<a name="cors-and-cookies"></a>
#### CORS y Cookies

Si tiene problemas para autenticarse con su aplicación desde un SPA que se ejecuta en un subdominio separado, es probable que haya configurado mal su CORS (Cross-Origin Resource Sharing) o la configuración de las cookies de sesión.

Debe asegurarse de que la configuración CORS de su aplicación está devolviendo el encabezado `Access-Control-Allow-Credentials` con un valor de `True`. Esto se puede lograr estableciendo la opción `supports_credentials` dentro del archivo de configuración `config/cors.php` de su aplicación a `true`.

Además, debes habilitar la opción `withCredentials` en la instancia `axios` global de tu aplicación. Normalmente, esto debería realizarse en el archivo `resources/js/bootstrap.js`. Si no estás usando Axios para hacer peticiones HTTP desde tu frontend, deberías realizar la configuración equivalente en tu propio cliente HTTP:

```js
axios.defaults.withCredentials = true;
```

Finalmente, deberías asegurarte de que la configuración del dominio de la cookie de sesión de tu aplicación soporta cualquier subdominio de tu dominio raíz. Esto se consigue anteponiendo un `.` al dominio en el fichero de configuración `config/session.php` de la aplicación:

    'domain' => '.domain.com',

<a name="spa-authenticating"></a>
### Autenticación

<a name="csrf-protection"></a>
#### Protección CSRF

Para autenticar su SPA, la página de "login" de su SPA debe hacer primero una petición al endpoint `/sanctum/csrf-cookie` para inicializar la protección CSRF para la aplicación:

```js
axios.get('/sanctum/csrf-cookie').then(response => {
    // Login...
});
```

Durante esta petición, Laravel establecerá una cookie `XSRF-TOKEN` que contendrá el token CSRF actual. Este token debe ser pasado en una cabecera `X-XSRF-TOKEN` en peticiones posteriores, lo que algunas librerías cliente HTTP como Axios y Angular HttpClient harán automáticamente por ti. Si su biblioteca JavaScript HTTP no establece el valor por usted, tendrá que establecer manualmente la cabecera `X-XSRF-TOKEN` para que coincida con el valor de la cookie `XSRF-TOKEN` que se establece por esta ruta.

<a name="logging-in"></a>
#### Inicio de sesión

Una vez inicializada la protección CSRF, debe realizar una petición `POST` a la ruta `/login` de su aplicación Laravel. Esta ruta `/login` puede [implementarse manualmente](/docs/{{version}}/authentication#authenticating-users) o utilizando un paquete de autenticación headless como [Laravel Fortify](/docs/{{version}}/fortify).

Si la solicitud de inicio de sesión tiene éxito, serás autenticado y las solicitudes posteriores a las rutas de tu aplicación serán autenticadas automáticamente a través de la cookie de sesión que la aplicación Laravel emitió a tu cliente. Además, dado que tu aplicación ya ha realizado una petición a la ruta `/sanctum/csrf-cookie`, las peticiones posteriores deberían recibir automáticamente protección CSRF siempre y cuando tu cliente JavaScript HTTP envíe el valor de la cookie `XSRF-TOKEN` en la cabecera `X-XSRF-TOKEN`.

Por supuesto, si la sesión de tu usuario expira por falta de actividad, las peticiones posteriores a la aplicación Laravel pueden recibir una respuesta de error 401 o 419 HTTP. En este caso, deberías redirigir al usuario a la página de login de tu SPA.

> **Advertencia**  
> Eres libre de escribir tu propio endpoint `/login`; sin embargo, deberías asegurarte de que autentica al usuario usando [los servicios estándar de autenticación basados en sesión que Laravel proporciona](/docs/{{version}}/authentication#authenticating-users). Típicamente, esto significa usar la guarda de autenticación `web`.

<a name="protecting-spa-routes"></a>
### Protección de rutas

Para proteger las rutas de forma que todas las peticiones entrantes deban ser autenticadas, debes adjuntar la guarda de autenticación `sanctum` a tus rutas API dentro de tu fichero `routes/api.php` . Este guarda se asegurará de que las peticiones entrantes se autentiquen como peticiones autenticadas con estado desde su SPA o contengan una cabecera de token de API válida si la petición procede de un tercero:

    use Illuminate\Http\Request;

    Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
        return $request->user();
    });

<a name="authorizing-private-broadcast-channels"></a>
### Autorización de canales de difusión privados

Si tu SPA necesita autenticarse con [canales de difusión privados o "de presencia"](/docs/{{version}}/broadcasting#authorizing-channels), debes colocar la llamada al método `Broadcast::routes` dentro de tu archivo `routes/api.php`:

    Broadcast::routes(['middleware' => ['auth:sanctum']]);

A continuación, para que las solicitudes de autorización de Pusher tengan éxito, deberá proporcionar un "autorizador" de Pusher personalizado al inicializar [Laravel Echo](/docs/{{version}}/broadcasting#client-side-installation). Esto permite que su aplicación configure Pusher para usar la instancia `axios` que está [configurada correctamente para solicitudes entre dominios](#cors-and-cookies)::

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

También puede utilizar tokens de Sanctum para autenticar las solicitudes de su aplicación móvil a su API. El proceso de autenticación de solicitudes de aplicaciones móviles es similar al de autenticación de solicitudes de API de terceros; sin embargo, hay pequeñas diferencias en cómo emitirá los tokens de API.

<a name="issuing-mobile-api-tokens"></a>
### Emisión de tokens de API

Para empezar, crear una ruta que acepta el correo electrónico del usuario / nombre de usuario, contraseña y nombre del dispositivo, a continuación, intercambia esas credenciales para un nuevo token Sanctum. El "nombre del dispositivo" dado a este endpoint es para fines informativos y puede ser cualquier valor que desee. En general, el valor del nombre del dispositivo debe ser un nombre que el usuario reconozca, como "iPhone 12 de Nuno".

Generalmente, usted hará una solicitud al endpoint token  desde la pantalla de "login" de su aplicación móvil. El endpoint devolverá el token de la API en texto plano, que podrá almacenarse en el dispositivo móvil y utilizarse para realizar otras solicitudes a la API:

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

Cuando la aplicación móvil utiliza el token para realizar una solicitud de API a su aplicación, debe pasar el token en el encabezado `Authorization` como token `Bearer`.

> **Nota**  
> Al emitir tokens para una aplicación móvil, también puede especificar [las habilidades de los tokens](#token-abilities).

<a name="protecting-mobile-api-routes"></a>
### Protección de rutas

Como se ha documentado previamente, puedes proteger las rutas para que todas las peticiones entrantes deban ser autenticadas adjuntando la guarda de autenticación `Sanctum` a las rutas:

    Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
        return $request->user();
    });

<a name="revoking-mobile-api-tokens"></a>
### Revocación de tokens

Para permitir a los usuarios revocar los tokens de API emitidos para dispositivos móviles, puede listarlos por nombre, junto con un botón "Revocar", dentro de una parte de "ajustes de cuenta" de la interfaz de usuario de su aplicación web. Cuando el usuario haga clic en el botón "Revocar", podrá eliminar el token de la base de datos. Recuerda que puedes acceder a los tokens de API de un usuario a través de la relación `tokens` proporcionada por el trait `Laravel\Sanctum\HasApiTokens`:

    // Revoke all tokens...
    $user->tokens()->delete();

    // Revoke a specific token...
    $user->tokens()->where('id', $tokenId)->delete();

<a name="testing"></a>
## Testing

Durante los tests, se puede utilizar el método `Sanctum::actingAs` para autenticar a un usuario y especificar qué habilidades se deben conceder a su token:

    use App\Models\User;
    use Laravel\Sanctum\Sanctum;

    public function test_task_list_can_be_retrieved()
    {
        Sanctum::actingAs(
            User::factory()->create(),
            ['view-tasks']
        );

        $response = $this->get('/api/task');

        $response->assertOk();
    }

Si deseas conceder todas las habilidades al token, debes incluir `*` en la lista de habilidades proporcionada al método `actingAs`:

    Sanctum::actingAs(
        User::factory()->create(),
        ['*']
    );
