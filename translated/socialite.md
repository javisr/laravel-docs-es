# Laravel Socialite

- [Introducción](#introduction)
- [Instalación](#installation)
- [Actualizando Socialite](#upgrading-socialite)
- [Configuración](#configuration)
- [Autenticación](#authentication)
    - [Enrutamiento](#routing)
    - [Autenticación y Almacenamiento](#authentication-and-storage)
    - [Scopes de Acceso](#access-scopes)
    - [Scopes de Bot de Slack](#slack-bot-scopes)
    - [Parámetros Opcionales](#optional-parameters)
- [Recuperando Detalles del Usuario](#retrieving-user-details)

<a name="introduction"></a>
## Introducción

Además de la autenticación típica basada en formularios, Laravel también proporciona una forma simple y conveniente de autenticar con proveedores de OAuth utilizando [Laravel Socialite](https://github.com/laravel/socialite). Socialite actualmente admite la autenticación a través de Facebook, Twitter, LinkedIn, Google, GitHub, GitLab, Bitbucket y Slack.

> [!NOTE]  
> Los adaptadores para otras plataformas están disponibles a través del sitio web impulsado por la comunidad [Socialite Providers](https://socialiteproviders.com/).

<a name="installation"></a>
## Instalación

Para comenzar con Socialite, utiliza el administrador de paquetes Composer para agregar el paquete a las dependencias de tu proyecto:

```shell
composer require laravel/socialite
```

<a name="upgrading-socialite"></a>
## Actualizando Socialite

Al actualizar a una nueva versión principal de Socialite, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/socialite/blob/master/UPGRADE.md).

<a name="configuration"></a>
## Configuración

Antes de usar Socialite, necesitarás agregar credenciales para los proveedores de OAuth que utiliza tu aplicación. Típicamente, estas credenciales pueden ser recuperadas creando una "aplicación de desarrollador" dentro del panel de control del servicio con el que te autenticarás.

Estas credenciales deben colocarse en el archivo de configuración `config/services.php` de tu aplicación, y deben usar la clave `facebook`, `twitter` (OAuth 1.0), `twitter-oauth-2` (OAuth 2.0), `linkedin-openid`, `google`, `github`, `gitlab`, `bitbucket`, `slack`, o `slack-openid`, dependiendo de los proveedores que tu aplicación requiera:

    'github' => [
        'client_id' => env('GITHUB_CLIENT_ID'),
        'client_secret' => env('GITHUB_CLIENT_SECRET'),
        'redirect' => 'http://example.com/callback-url',
    ],

> [!NOTE]  
> Si la opción `redirect` contiene una ruta relativa, se resolverá automáticamente a una URL completamente calificada.

<a name="authentication"></a>
## Autenticación

<a name="routing"></a>
### Enrutamiento

Para autenticar usuarios utilizando un proveedor de OAuth, necesitarás dos rutas: una para redirigir al usuario al proveedor de OAuth, y otra para recibir la devolución de llamada del proveedor después de la autenticación. Las rutas de ejemplo a continuación demuestran la implementación de ambas rutas:

    use Laravel\Socialite\Facades\Socialite;

    Route::get('/auth/redirect', function () {
        return Socialite::driver('github')->redirect();
    });

    Route::get('/auth/callback', function () {
        $user = Socialite::driver('github')->user();

        // $user->token
    });

El método `redirect` proporcionado por el `Socialite` facade se encarga de redirigir al usuario al proveedor de OAuth, mientras que el método `user` examinará la solicitud entrante y recuperará la información del usuario del proveedor después de que haya aprobado la solicitud de autenticación.

<a name="authentication-and-storage"></a>
### Autenticación y Almacenamiento

Una vez que el usuario ha sido recuperado del proveedor de OAuth, puedes determinar si el usuario existe en la base de datos de tu aplicación y [autenticar al usuario](/docs/{{version}}/authentication#authenticate-a-user-instance). Si el usuario no existe en la base de datos de tu aplicación, típicamente crearás un nuevo registro en tu base de datos para representar al usuario:

    use App\Models\User;
    use Illuminate\Support\Facades\Auth;
    use Laravel\Socialite\Facades\Socialite;

    Route::get('/auth/callback', function () {
        $githubUser = Socialite::driver('github')->user();

        $user = User::updateOrCreate([
            'github_id' => $githubUser->id,
        ], [
            'name' => $githubUser->name,
            'email' => $githubUser->email,
            'github_token' => $githubUser->token,
            'github_refresh_token' => $githubUser->refreshToken,
        ]);

        Auth::login($user);

        return redirect('/dashboard');
    });

> [!NOTE]  
> Para más información sobre qué información del usuario está disponible de proveedores de OAuth específicos, consulta la documentación sobre [recuperar detalles del usuario](#retrieving-user-details).

<a name="access-scopes"></a>
### Scopes de Acceso

Antes de redirigir al usuario, puedes usar el método `scopes` para especificar los "scopes" que deben incluirse en la solicitud de autenticación. Este método fusionará todos los scopes previamente especificados con los scopes que especifiques:

    use Laravel\Socialite\Facades\Socialite;

    return Socialite::driver('github')
        ->scopes(['read:user', 'public_repo'])
        ->redirect();

Puedes sobrescribir todos los scopes existentes en la solicitud de autenticación utilizando el método `setScopes`:

    return Socialite::driver('github')
        ->setScopes(['read:user', 'public_repo'])
        ->redirect();

<a name="slack-bot-scopes"></a>
### Scopes de Bot de Slack

La API de Slack proporciona [diferentes tipos de tokens de acceso](https://api.slack.com/authentication/token-types), cada uno con su propio conjunto de [scopes de permiso](https://api.slack.com/scopes). Socialite es compatible con ambos tipos de tokens de acceso de Slack:

<div class="content-list" markdown="1">

- Bot (prefijado con `xoxb-`)
- Usuario (prefijado con `xoxp-`)

</div>

Por defecto, el driver `slack` generará un token de `usuario` y al invocar el método `user` del driver se devolverán los detalles del usuario.

Los tokens de bot son principalmente útiles si tu aplicación enviará notificaciones a espacios de trabajo de Slack externos que son propiedad de los usuarios de tu aplicación. Para generar un token de bot, invoca el método `asBotUser` antes de redirigir al usuario a Slack para la autenticación:

    return Socialite::driver('slack')
        ->asBotUser()
        ->setScopes(['chat:write', 'chat:write.public', 'chat:write.customize'])
        ->redirect();

Además, debes invocar el método `asBotUser` antes de invocar el método `user` después de que Slack redirija al usuario de vuelta a tu aplicación después de la autenticación:

    $user = Socialite::driver('slack')->asBotUser()->user();

Al generar un token de bot, el método `user` seguirá devolviendo una instancia de `Laravel\Socialite\Two\User`; sin embargo, solo se hidratará la propiedad `token`. Este token puede ser almacenado para [enviar notificaciones a los espacios de trabajo de Slack del usuario autenticado](/docs/{{version}}/notifications#notifying-external-slack-workspaces).

<a name="optional-parameters"></a>
### Parámetros Opcionales

Varios proveedores de OAuth admiten otros parámetros opcionales en la solicitud de redirección. Para incluir cualquier parámetro opcional en la solicitud, llama al método `with` con un array asociativo:

    use Laravel\Socialite\Facades\Socialite;

    return Socialite::driver('google')
        ->with(['hd' => 'example.com'])
        ->redirect();

> [!WARNING]  
> Al usar el método `with`, ten cuidado de no pasar ninguna palabra clave reservada como `state` o `response_type`.

<a name="retrieving-user-details"></a>
## Recuperando Detalles del Usuario

Después de que el usuario es redirigido de vuelta a la ruta de devolución de llamada de autenticación de tu aplicación, puedes recuperar los detalles del usuario utilizando el método `user` de Socialite. El objeto de usuario devuelto por el método `user` proporciona una variedad de propiedades y métodos que puedes usar para almacenar información sobre el usuario en tu propia base de datos.

Diferentes propiedades y métodos pueden estar disponibles en este objeto dependiendo de si el proveedor de OAuth con el que te estás autenticando admite OAuth 1.0 o OAuth 2.0:

    use Laravel\Socialite\Facades\Socialite;

    Route::get('/auth/callback', function () {
        $user = Socialite::driver('github')->user();

        // Proveedores OAuth 2.0...
        $token = $user->token;
        $refreshToken = $user->refreshToken;
        $expiresIn = $user->expiresIn;

        // Proveedores OAuth 1.0...
        $token = $user->token;
        $tokenSecret = $user->tokenSecret;

        // Todos los proveedores...
        $user->getId();
        $user->getNickname();
        $user->getName();
        $user->getEmail();
        $user->getAvatar();
    });

<a name="retrieving-user-details-from-a-token-oauth2"></a>
#### Recuperando Detalles del Usuario Desde un Token (OAuth2)

Si ya tienes un token de acceso válido para un usuario, puedes recuperar sus detalles utilizando el método `userFromToken` de Socialite:

    use Laravel\Socialite\Facades\Socialite;

    $user = Socialite::driver('github')->userFromToken($token);

Si estás utilizando Facebook Limited Login a través de una aplicación iOS, Facebook devolverá un token OIDC en lugar de un token de acceso. Al igual que un token de acceso, el token OIDC puede ser proporcionado al método `userFromToken` para recuperar los detalles del usuario.

<a name="retrieving-user-details-from-a-token-and-secret-oauth1"></a>
#### Recuperando Detalles del Usuario Desde un Token y Secreto (OAuth1)

Si ya tienes un token y secreto válidos para un usuario, puedes recuperar sus detalles utilizando el método `userFromTokenAndSecret` de Socialite:

    use Laravel\Socialite\Facades\Socialite;

    $user = Socialite::driver('twitter')->userFromTokenAndSecret($token, $secret);

<a name="stateless-authentication"></a>
#### Autenticación Sin Estado

El método `stateless` puede ser utilizado para deshabilitar la verificación del estado de la sesión. Esto es útil al agregar autenticación social a una API sin estado que no utiliza sesiones basadas en cookies:

    use Laravel\Socialite\Facades\Socialite;

    return Socialite::driver('google')->stateless()->user();

> [!WARNING]  
> La autenticación sin estado no está disponible para el driver de Twitter OAuth 1.0.
