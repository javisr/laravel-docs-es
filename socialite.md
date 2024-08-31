# Laravel Socialite

- [Introducción](#introduction)
- [Instalación](#installation)
- [Actualizando Socialite](#upgrading-socialite)
- [Configuración](#configuration)
- [Autenticación](#authentication)
  - [Enrutamiento](#routing)
  - [Autenticación y Almacenamiento](#authentication-and-storage)
  - [Ámbitos de Acceso](#access-scopes)
  - [Ámbitos de Bot de Slack](#slack-bot-scopes)
  - [Parámetros Opcionales](#optional-parameters)
- [Recuperando Detalles del Usuario](#retrieving-user-details)

<a name="introduction"></a>
## Introducción

Además de la autenticación típica basada en formularios, Laravel también ofrece una manera simple y conveniente de autenticarse con proveedores OAuth utilizando [Laravel Socialite](https://github.com/laravel/socialite). Socialite actualmente admite la autenticación a través de Facebook, Twitter, LinkedIn, Google, GitHub, GitLab, Bitbucket y Slack.
> [!NOTA]
Los adaptadores para otras plataformas están disponibles a través del sitio web [Socialite Providers](https://socialiteproviders.com/) impulsado por la comunidad.

<a name="installation"></a>
## Instalación

Para comenzar con Socialite, utiliza el gestor de paquetes Composer para añadir el paquete a las dependencias de tu proyecto:


```shell
composer require laravel/socialite

```

<a name="upgrading-socialite"></a>
## Actualizando Socialite

Al actualizar a una nueva versión principal de Socialite, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/socialite/blob/master/UPGRADE.md).

<a name="configuration"></a>
## Configuración

Antes de usar Socialite, necesitarás añadir credenciales para los proveedores OAuth que utiliza tu aplicación. Típicamente, estas credenciales se pueden obtener creando una "aplicación de desarrollador" dentro del panel de control del servicio con el que te autenticarás.
Estas credenciales deben colocarse en el archivo de configuración `config/services.php` de tu aplicación y deben usar la clave `facebook`, `twitter` (OAuth 1.0), `twitter-oauth-2` (OAuth 2.0), `linkedin-openid`, `google`, `github`, `gitlab`, `bitbucket`, `slack` o `slack-openid`, dependiendo de los proveedores que requiera tu aplicación:


```php
'github' => [
    'client_id' => env('GITHUB_CLIENT_ID'),
    'client_secret' => env('GITHUB_CLIENT_SECRET'),
    'redirect' => 'http://example.com/callback-url',
],
```
> [!NOTE]
Si la opción `redirect` contiene una ruta relativa, se resolverá automáticamente a una URL completamente calificada.

<a name="authentication"></a>
## Autenticación


<a name="routing"></a>
### Enrutamiento

Para autenticar usuarios utilizando un proveedor OAuth, necesitarás dos rutas: una para redirigir al usuario al proveedor OAuth y otra para recibir la callback del proveedor después de la autenticación. Las rutas de ejemplo a continuación demuestran la implementación de ambas rutas:


```php
use Laravel\Socialite\Facades\Socialite;

Route::get('/auth/redirect', function () {
    return Socialite::driver('github')->redirect();
});

Route::get('/auth/callback', function () {
    $user = Socialite::driver('github')->user();

    // $user->token
});
```
El método `redirect` proporcionado por la fachada `Socialite` se encarga de redirigir al usuario al proveedor de OAuth, mientras que el método `user` examinará la solicitud entrante y recuperará la información del usuario del proveedor después de que hayan aprobado la solicitud de autenticación.

<a name="authentication-and-storage"></a>
### Autenticación y Almacenamiento

Una vez que el usuario ha sido recuperado del proveedor OAuth, puedes determinar si el usuario existe en la base de datos de tu aplicación y [autenticar al usuario](/docs/%7B%7Bversion%7D%7D/authentication#authenticate-a-user-instance). Si el usuario no existe en la base de datos de tu aplicación, típicamente crearás un nuevo registro en tu base de datos para representar al usuario:


```php
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
```
> [!NOTE]
Para obtener más información sobre qué información del usuario está disponible de proveedores OAuth específicos, consulta la documentación sobre [recuperar detalles del usuario](#retrieving-user-details).

<a name="access-scopes"></a>
### Alcances de Acceso

Antes de redirigir al usuario, puedes usar el método `scopes` para especificar los "alcances" que se deben incluir en la solicitud de autenticación. Este método combinará todos los alcances especificados anteriormente con los alcances que especifiques:


```php
use Laravel\Socialite\Facades\Socialite;

return Socialite::driver('github')
    ->scopes(['read:user', 'public_repo'])
    ->redirect();
```
Puedes sobrescribir todos los ámbitos existentes en la solicitud de autenticación utilizando el método `setScopes`:


```php
return Socialite::driver('github')
    ->setScopes(['read:user', 'public_repo'])
    ->redirect();
```

<a name="slack-bot-scopes"></a>
### Alcances de Bot de Slack

La API de Slack proporciona [diferentes tipos de tokens de acceso](https://api.slack.com/authentication/token-types), cada uno con su propio conjunto de [alcances de permiso](https://api.slack.com/scopes). Socialite es compatible con ambos tipos de tokens de acceso de Slack:
<div class="content-list" markdown="1">

- Bot (prefixed with `xoxb-`)
- User (prefixed with `xoxp-`)
</div>
Por defecto, el driver `slack` generará un token de `usuario` y invocar el método `user` del driver devolverá los detalles del usuario.
Los tokens de bot son principalmente útiles si tu aplicación va a enviar notificaciones a espacios de trabajo de Slack externos que son propiedad de los usuarios de tu aplicación. Para generar un token de bot, invoca el método `asBotUser` antes de redirigir al usuario a Slack para la autenticación:


```php
return Socialite::driver('slack')
    ->asBotUser()
    ->setScopes(['chat:write', 'chat:write.public', 'chat:write.customize'])
    ->redirect();
```
Además, debes invocar el método `asBotUser` antes de invocar el método `user` después de que Slack redirija al usuario de vuelta a tu aplicación tras la autenticación:


```php
$user = Socialite::driver('slack')->asBotUser()->user();
```
Al generar un token para el bot, el método `user` seguirá devolviendo una instancia de `Laravel\Socialite\Two\User`; sin embargo, solo se llenará la propiedad `token`. Este token puede almacenarse para [enviar notificaciones a los espacios de trabajo de Slack del usuario autenticado](/docs/%7B%7Bversion%7D%7D/notifications#notifying-external-slack-workspaces).

<a name="optional-parameters"></a>
### Parámetros Opcionales

Varios proveedores de OAuth admiten otros parámetros opcionales en la solicitud de redirección. Para incluir cualquier parámetro opcional en la solicitud, llama al método `with` con un array asociativo:


```php
use Laravel\Socialite\Facades\Socialite;

return Socialite::driver('google')
    ->with(['hd' => 'example.com'])
    ->redirect();
```
> [!WARNING]
Al utilizar el método `with`, ten cuidado de no pasar ninguna palabra clave reservada como `state` o `response_type`.

<a name="retrieving-user-details"></a>
## Recuperando Detalles del Usuario

Después de que el usuario sea redirigido de vuelta a la ruta de callback de autenticación de tu aplicación, puedes recuperar los detalles del usuario utilizando el método `user` de Socialite. El objeto de usuario devuelto por el método `user` proporciona una variedad de propiedades y métodos que puedes usar para almacenar información sobre el usuario en tu propia base de datos.
Pueden estar disponibles diferentes propiedades y métodos en este objeto dependiendo de si el proveedor de OAuth con el que te estás autenticando admite OAuth 1.0 o OAuth 2.0:


```php
use Laravel\Socialite\Facades\Socialite;

Route::get('/auth/callback', function () {
    $user = Socialite::driver('github')->user();

    // OAuth 2.0 providers...
    $token = $user->token;
    $refreshToken = $user->refreshToken;
    $expiresIn = $user->expiresIn;

    // OAuth 1.0 providers...
    $token = $user->token;
    $tokenSecret = $user->tokenSecret;

    // All providers...
    $user->getId();
    $user->getNickname();
    $user->getName();
    $user->getEmail();
    $user->getAvatar();
});
```

<a name="retrieving-user-details-from-a-token-oauth2"></a>
#### Recuperando Detalles del Usuario a partir de un Token (OAuth2)

Si ya tienes un token de acceso válido para un usuario, puedes recuperar sus detalles de usuario utilizando el método `userFromToken` de Socialite:


```php
use Laravel\Socialite\Facades\Socialite;

$user = Socialite::driver('github')->userFromToken($token);
```
Si estás utilizando Facebook Limited Login a través de una aplicación iOS, Facebook devolverá un token OIDC en lugar de un token de acceso. Al igual que un token de acceso, el token OIDC se puede proporcionar al método `userFromToken` para recuperar detalles del usuario.

<a name="retrieving-user-details-from-a-token-and-secret-oauth1"></a>
#### Recuperando Detalles del Usuario a partir de un Token y Secreto (OAuth1)

Si ya tienes un token y secreto válidos para un usuario, puedes recuperar los detalles del usuario utilizando el método `userFromTokenAndSecret` de Socialite:


```php
use Laravel\Socialite\Facades\Socialite;

$user = Socialite::driver('twitter')->userFromTokenAndSecret($token, $secret);
```

<a name="stateless-authentication"></a>
#### Autenticación Sin Estado

El método `stateless` se puede usar para deshabilitar la verificación del estado de la sesión. Esto es útil al agregar autenticación social a una API sin estado que no utiliza sesiones basadas en cookies:


```php
use Laravel\Socialite\Facades\Socialite;

return Socialite::driver('google')->stateless()->user();
```
> [!WARNING]
La autenticación sin estado no está disponible para el driver OAuth 1.0 de Twitter.