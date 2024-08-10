# Laravel Passport

- [Introducción](#introduction)
    - [¿Passport o Sanctum?](#passport-or-sanctum)
- [Instalación](#installation)
    - [Desplegando Passport](#deploying-passport)
    - [Actualizando Passport](#upgrading-passport)
- [Configuración](#configuration)
    - [Hashing del Secreto del Cliente](#client-secret-hashing)
    - [Duraciones de los Tokens](#token-lifetimes)
    - [Sobrescribiendo Modelos Predeterminados](#overriding-default-models)
    - [Sobrescribiendo Rutas](#overriding-routes)
- [Emitiendo Tokens de Acceso](#issuing-access-tokens)
    - [Gestionando Clientes](#managing-clients)
    - [Solicitando Tokens](#requesting-tokens)
    - [Refrescando Tokens](#refreshing-tokens)
    - [Revocando Tokens](#revoking-tokens)
    - [Purging Tokens](#purging-tokens)
- [Código de Autorización Grant Con PKCE](#code-grant-pkce)
    - [Creando el Cliente](#creating-a-auth-pkce-grant-client)
    - [Solicitando Tokens](#requesting-auth-pkce-grant-tokens)
- [Tokens de Grant de Contraseña](#password-grant-tokens)
    - [Creando un Cliente de Grant de Contraseña](#creating-a-password-grant-client)
    - [Solicitando Tokens](#requesting-password-grant-tokens)
    - [Solicitando Todos los Scopes](#requesting-all-scopes)
    - [Personalizando el Proveedor de Usuario](#customizing-the-user-provider)
    - [Personalizando el Campo de Nombre de Usuario](#customizing-the-username-field)
    - [Personalizando la Validación de Contraseña](#customizing-the-password-validation)
- [Tokens de Grant Implícitos](#implicit-grant-tokens)
- [Tokens de Grant de Credenciales de Cliente](#client-credentials-grant-tokens)
- [Tokens de Acceso Personal](#personal-access-tokens)
    - [Creando un Cliente de Acceso Personal](#creating-a-personal-access-client)
    - [Gestionando Tokens de Acceso Personal](#managing-personal-access-tokens)
- [Protegiendo Rutas](#protecting-routes)
    - [A través de Middleware](#via-middleware)
    - [Pasando el Token de Acceso](#passing-the-access-token)
- [Scopes de Token](#token-scopes)
    - [Definiendo Scopes](#defining-scopes)
    - [Scope Predeterminado](#default-scope)
    - [Asignando Scopes a Tokens](#assigning-scopes-to-tokens)
    - [Verificando Scopes](#checking-scopes)
- [Consumiendo Tu API Con JavaScript](#consuming-your-api-with-javascript)
- [Eventos](#events)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Passport](https://github.com/laravel/passport) proporciona una implementación completa de servidor OAuth2 para tu aplicación Laravel en cuestión de minutos. Passport está construido sobre el [servidor OAuth2 de League](https://github.com/thephpleague/oauth2-server) que es mantenido por Andy Millington y Simon Hamp.

> [!WARNING]  
> Esta documentación asume que ya estás familiarizado con OAuth2. Si no sabes nada sobre OAuth2, considera familiarizarte con la [terminología](https://oauth2.thephpleague.com/terminology/) y características generales de OAuth2 antes de continuar.

<a name="passport-or-sanctum"></a>
### ¿Passport o Sanctum?

Antes de comenzar, es posible que desees determinar si tu aplicación se beneficiaría más de Laravel Passport o [Laravel Sanctum](/docs/{{version}}/sanctum). Si tu aplicación necesita absolutamente soportar OAuth2, entonces deberías usar Laravel Passport.

Sin embargo, si estás intentando autenticar una aplicación de una sola página, una aplicación móvil, o emitir tokens de API, deberías usar [Laravel Sanctum](/docs/{{version}}/sanctum). Laravel Sanctum no soporta OAuth2; sin embargo, proporciona una experiencia de desarrollo de autenticación API mucho más simple.

<a name="installation"></a>
## Instalación

Puedes instalar Laravel Passport a través del comando Artisan `install:api`:

```shell
php artisan install:api --passport
```

Este comando publicará y ejecutará las migraciones de base de datos necesarias para crear las tablas que tu aplicación necesita para almacenar clientes OAuth2 y tokens de acceso. El comando también creará las claves de cifrado requeridas para generar tokens de acceso seguros.

Además, este comando preguntará si deseas usar UUIDs como el valor de clave primaria del modelo `Client` de Passport en lugar de enteros autoincrementales.

Después de ejecutar el comando `install:api`, agrega el trait `Laravel\Passport\HasApiTokens` a tu modelo `App\Models\User`. Este trait proporcionará algunos métodos auxiliares a tu modelo que te permitirán inspeccionar el token y los scopes del usuario autenticado:

    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Factories\HasFactory;
    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Laravel\Passport\HasApiTokens;

    class User extends Authenticatable
    {
        use HasApiTokens, HasFactory, Notifiable;
    }

Finalmente, en el archivo de configuración `config/auth.php` de tu aplicación, deberías definir un guard de autenticación `api` y establecer la opción `driver` en `passport`. Esto indicará a tu aplicación que use el `TokenGuard` de Passport al autenticar solicitudes API entrantes:

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        'api' => [
            'driver' => 'passport',
            'provider' => 'users',
        ],
    ],

<a name="deploying-passport"></a>
### Desplegando Passport

Al desplegar Passport en los servidores de tu aplicación por primera vez, probablemente necesitarás ejecutar el comando `passport:keys`. Este comando genera las claves de cifrado que Passport necesita para generar tokens de acceso. Las claves generadas no se mantienen típicamente en el control de versiones:

```shell
php artisan passport:keys
```

Si es necesario, puedes definir la ruta desde donde se deben cargar las claves de Passport. Puedes usar el método `Passport::loadKeysFrom` para lograr esto. Típicamente, este método debería ser llamado desde el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Passport::loadKeysFrom(__DIR__.'/../secrets/oauth');
    }

<a name="loading-keys-from-the-environment"></a>
#### Cargando Claves Desde el Entorno

Alternativamente, puedes publicar el archivo de configuración de Passport usando el comando Artisan `vendor:publish`:

```shell
php artisan vendor:publish --tag=passport-config
```

Después de que el archivo de configuración haya sido publicado, puedes cargar las claves de cifrado de tu aplicación definiéndolas como variables de entorno:

```ini
PASSPORT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
<private key here>
-----END RSA PRIVATE KEY-----"

PASSPORT_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
<public key here>
-----END PUBLIC KEY-----"
```

<a name="upgrading-passport"></a>
### Actualizando Passport

Al actualizar a una nueva versión principal de Passport, es importante que revises cuidadosamente [la guía de actualización](https://github.com/laravel/passport/blob/master/UPGRADE.md).

<a name="configuration"></a>
## Configuración

<a name="client-secret-hashing"></a>
### Hashing del Secreto del Cliente

Si deseas que los secretos de tu cliente sean hash cuando se almacenan en tu base de datos, deberías llamar al método `Passport::hashClientSecrets` en el método `boot` de tu clase `App\Providers\AppServiceProvider`:

    use Laravel\Passport\Passport;

    Passport::hashClientSecrets();

Una vez habilitado, todos tus secretos de cliente solo serán visibles para el usuario inmediatamente después de que sean creados. Dado que el valor del secreto del cliente en texto plano nunca se almacena en la base de datos, no es posible recuperar el valor del secreto si se pierde.

<a name="token-lifetimes"></a>
### Duraciones de los Tokens

Por defecto, Passport emite tokens de acceso de larga duración que expiran después de un año. Si deseas configurar una duración de token más larga o más corta, puedes usar los métodos `tokensExpireIn`, `refreshTokensExpireIn`, y `personalAccessTokensExpireIn`. Estos métodos deben ser llamados desde el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Passport::tokensExpireIn(now()->addDays(15));
        Passport::refreshTokensExpireIn(now()->addDays(30));
        Passport::personalAccessTokensExpireIn(now()->addMonths(6));
    }

> [!WARNING]  
> Las columnas `expires_at` en las tablas de base de datos de Passport son de solo lectura y solo para fines de visualización. Al emitir tokens, Passport almacena la información de expiración dentro de los tokens firmados y cifrados. Si necesitas invalidar un token, deberías [revocarlo](#revoking-tokens).

<a name="overriding-default-models"></a>
### Sobrescribiendo Modelos Predeterminados

Eres libre de extender los modelos utilizados internamente por Passport definiendo tu propio modelo y extendiendo el modelo correspondiente de Passport:

    use Laravel\Passport\Client as PassportClient;

    class Client extends PassportClient
    {
        // ...
    }

Después de definir tu modelo, puedes instruir a Passport para que use tu modelo personalizado a través de la clase `Laravel\Passport\Passport`. Típicamente, deberías informar a Passport sobre tus modelos personalizados en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    use App\Models\Passport\AuthCode;
    use App\Models\Passport\Client;
    use App\Models\Passport\PersonalAccessClient;
    use App\Models\Passport\RefreshToken;
    use App\Models\Passport\Token;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Passport::useTokenModel(Token::class);
        Passport::useRefreshTokenModel(RefreshToken::class);
        Passport::useAuthCodeModel(AuthCode::class);
        Passport::useClientModel(Client::class);
        Passport::usePersonalAccessClientModel(PersonalAccessClient::class);
    }

<a name="overriding-routes"></a>
### Sobrescribiendo Rutas

A veces puedes desear personalizar las rutas definidas por Passport. Para lograr esto, primero necesitas ignorar las rutas registradas por Passport agregando `Passport::ignoreRoutes` al método `register` de tu `AppServiceProvider` de la aplicación:

    use Laravel\Passport\Passport;

    /**
     * Register any application services.
     */
    public function register(): void
    {
        Passport::ignoreRoutes();
    }

Luego, puedes copiar las rutas definidas por Passport en [su archivo de rutas](https://github.com/laravel/passport/blob/11.x/routes/web.php) al archivo `routes/web.php` de tu aplicación y modificarlas a tu gusto:

    Route::group([
        'as' => 'passport.',
        'prefix' => config('passport.path', 'oauth'),
        'namespace' => '\Laravel\Passport\Http\Controllers',
    ], function () {
        // Rutas de Passport...
    });

<a name="issuing-access-tokens"></a>
## Emitiendo Tokens de Acceso

Usar OAuth2 a través de códigos de autorización es como la mayoría de los desarrolladores están familiarizados con OAuth2. Al usar códigos de autorización, una aplicación cliente redirigirá a un usuario a tu servidor donde aprobará o denegará la solicitud para emitir un token de acceso al cliente.

<a name="managing-clients"></a>
### Gestionando Clientes

Primero, los desarrolladores que construyen aplicaciones que necesitan interactuar con la API de tu aplicación deberán registrar su aplicación con la tuya creando un "cliente". Típicamente, esto consiste en proporcionar el nombre de su aplicación y una URL a la que tu aplicación puede redirigir después de que los usuarios aprueben su solicitud de autorización.

<a name="the-passportclient-command"></a>
#### El Comando `passport:client`

La forma más simple de crear un cliente es usando el comando Artisan `passport:client`. Este comando puede ser utilizado para crear tus propios clientes para probar la funcionalidad de OAuth2. Cuando ejecutas el comando `client`, Passport te pedirá más información sobre tu cliente y te proporcionará un ID de cliente y un secreto:

```shell
php artisan passport:client
```

**URLs de Redirección**

Si deseas permitir múltiples URLs de redirección para tu cliente, puedes especificarlas usando una lista delimitada por comas cuando se te pida la URL por el comando `passport:client`. Cualquier URL que contenga comas debe estar codificada en URL:

```shell
http://example.com/callback,http://examplefoo.com/callback
```

<a name="clients-json-api"></a>
#### JSON API

Dado que los usuarios de tu aplicación no podrán utilizar el comando `client`, Passport proporciona una API JSON que puedes usar para crear clientes. Esto te ahorra el problema de tener que codificar manualmente controladores para crear, actualizar y eliminar clientes.

Sin embargo, necesitarás emparejar la API JSON de Passport con tu propio frontend para proporcionar un panel de control para que tus usuarios gestionen sus clientes. A continuación, revisaremos todos los puntos finales de la API para gestionar clientes. Para conveniencia, usaremos [Axios](https://github.com/axios/axios) para demostrar cómo hacer solicitudes HTTP a los puntos finales.

La API JSON está protegida por los middlewares `web` y `auth`; por lo tanto, solo puede ser llamada desde tu propia aplicación. No puede ser llamada desde una fuente externa.

<a name="get-oauthclients"></a>
#### `GET /oauth/clients`

Esta ruta devuelve todos los clientes para el usuario autenticado. Esto es principalmente útil para listar todos los clientes del usuario para que puedan editarlos o eliminarlos:

```js
axios.get('/oauth/clients')
    .then(response => {
        console.log(response.data);
    });
```

<a name="post-oauthclients"></a>
#### `POST /oauth/clients`

Esta ruta se utiliza para crear nuevos clientes. Requiere dos piezas de datos: el `name` del cliente y una URL de `redirect`. La URL de `redirect` es donde el usuario será redirigido después de aprobar o denegar una solicitud de autorización.

Cuando se crea un cliente, se le emitirá un ID de cliente y un secreto de cliente. Estos valores se utilizarán al solicitar tokens de acceso desde tu aplicación. La ruta de creación de clientes devolverá la nueva instancia de cliente:

```js
const data = {
    name: 'Client Name',
    redirect: 'http://example.com/callback'
};

axios.post('/oauth/clients', data)
    .then(response => {
        console.log(response.data);
    })
    .catch (response => {
        // List errors on response...
    });
```

<a name="put-oauthclientsclient-id"></a>
#### `PUT /oauth/clients/{client-id}`

Esta ruta se utiliza para actualizar clientes. Requiere dos piezas de datos: el `name` del cliente y una URL de `redirect`. La URL de `redirect` es donde el usuario será redirigido después de aprobar o denegar una solicitud de autorización. La ruta devolverá la instancia de cliente actualizada:

```js
const data = {
    name: 'New Client Name',
    redirect: 'http://example.com/callback'
};

axios.put('/oauth/clients/' + clientId, data)
    .then(response => {
        console.log(response.data);
    })
    .catch (response => {
        // List errors on response...
    });
```

<a name="delete-oauthclientsclient-id"></a>
#### `DELETE /oauth/clients/{client-id}`

Esta ruta se utiliza para eliminar clientes:

```js
axios.delete('/oauth/clients/' + clientId)
    .then(response => {
        // ...
    });
```

<a name="requesting-tokens"></a>
### Solicitando Tokens

<a name="requesting-tokens-redirecting-for-authorization"></a>
#### Redirigiendo para Autorización

Una vez que se ha creado un cliente, los desarrolladores pueden usar su ID de cliente y secreto para solicitar un código de autorización y un token de acceso desde tu aplicación. Primero, la aplicación consumidora debería hacer una solicitud de redirección a la ruta `/oauth/authorize` de tu aplicación de la siguiente manera:

    use Illuminate\Http\Request;
    use Illuminate\Support\Str;

    Route::get('/redirect', function (Request $request) {
        $request->session()->put('state', $state = Str::random(40));

        $query = http_build_query([
            'client_id' => 'client-id',
            'redirect_uri' => 'http://third-party-app.com/callback',
            'response_type' => 'code',
            'scope' => '',
            'state' => $state,
            // 'prompt' => '', // "none", "consent", or "login"
        ]);

        return redirect('http://passport-app.test/oauth/authorize?'.$query);
    });

El parámetro `prompt` puede ser utilizado para especificar el comportamiento de autenticación de la aplicación Passport.

Si el valor de `prompt` es `none`, Passport siempre lanzará un error de autenticación si el usuario no está ya autenticado con la aplicación Passport. Si el valor es `consent`, Passport siempre mostrará la pantalla de aprobación de autorización, incluso si todos los scopes fueron previamente otorgados a la aplicación consumidora. Cuando el valor es `login`, la aplicación Passport siempre pedirá al usuario que vuelva a iniciar sesión en la aplicación, incluso si ya tiene una sesión existente.

Si no se proporciona un valor de `prompt`, se le pedirá al usuario autorización solo si no ha autorizado previamente el acceso a la aplicación consumidora para los alcances solicitados.

> [!NOTE]  
> Recuerda, la ruta `/oauth/authorize` ya está definida por Passport. No necesitas definir manualmente esta ruta.

<a name="approving-the-request"></a>
#### Aprobando la Solicitud

Al recibir solicitudes de autorización, Passport responderá automáticamente según el valor del parámetro `prompt` (si está presente) y puede mostrar una plantilla al usuario que le permita aprobar o denegar la solicitud de autorización. Si aprueban la solicitud, serán redirigidos de vuelta a la `redirect_uri` que fue especificada por la aplicación consumidora. La `redirect_uri` debe coincidir con la URL `redirect` que fue especificada cuando se creó el cliente.

Si deseas personalizar la pantalla de aprobación de autorización, puedes publicar las vistas de Passport utilizando el comando Artisan `vendor:publish`. Las vistas publicadas se colocarán en el directorio `resources/views/vendor/passport`:

```shell
php artisan vendor:publish --tag=passport-views
```

A veces, es posible que desees omitir el aviso de autorización, como cuando autorizas un cliente de primera parte. Puedes lograr esto [extendiendo el modelo `Client`](#overriding-default-models) y definiendo un método `skipsAuthorization`. Si `skipsAuthorization` devuelve `true`, el cliente será aprobado y el usuario será redirigido de vuelta a la `redirect_uri` de inmediato, a menos que la aplicación consumidora haya establecido explícitamente el parámetro `prompt` al redirigir para autorización:

    <?php

    namespace App\Models\Passport;

    use Laravel\Passport\Client as BaseClient;

    class Client extends BaseClient
    {
        /**
         * Determina si el cliente debe omitir el aviso de autorización.
         */
        public function skipsAuthorization(): bool
        {
            return $this->firstParty();
        }
    }

<a name="requesting-tokens-converting-authorization-codes-to-access-tokens"></a>
#### Convirtiendo Códigos de Autorización en Tokens de Acceso

Si el usuario aprueba la solicitud de autorización, será redirigido de vuelta a la aplicación consumidora. El consumidor debe primero verificar el parámetro `state` contra el valor que se almacenó antes de la redirección. Si el parámetro de estado coincide, entonces el consumidor debe emitir una solicitud `POST` a tu aplicación para solicitar un token de acceso. La solicitud debe incluir el código de autorización que fue emitido por tu aplicación cuando el usuario aprobó la solicitud de autorización:

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Http;

    Route::get('/callback', function (Request $request) {
        $state = $request->session()->pull('state');

        throw_unless(
            strlen($state) > 0 && $state === $request->state,
            InvalidArgumentException::class,
            'Valor de estado inválido.'
        );

        $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
            'grant_type' => 'authorization_code',
            'client_id' => 'client-id',
            'client_secret' => 'client-secret',
            'redirect_uri' => 'http://third-party-app.com/callback',
            'code' => $request->code,
        ]);

        return $response->json();
    });

Esta ruta `/oauth/token` devolverá una respuesta JSON que contiene los atributos `access_token`, `refresh_token` y `expires_in`. El atributo `expires_in` contiene el número de segundos hasta que el token de acceso expire.

> [!NOTE]  
> Al igual que la ruta `/oauth/authorize`, la ruta `/oauth/token` está definida para ti por Passport. No hay necesidad de definir manualmente esta ruta.

<a name="tokens-json-api"></a>
#### API JSON

Passport también incluye una API JSON para gestionar tokens de acceso autorizados. Puedes combinar esto con tu propio frontend para ofrecer a tus usuarios un panel de control para gestionar tokens de acceso. Para conveniencia, utilizaremos [Axios](https://github.com/mzabriskie/axios) para demostrar cómo realizar solicitudes HTTP a los puntos finales. La API JSON está protegida por los middlewares `web` y `auth`; por lo tanto, solo puede ser llamada desde tu propia aplicación.

<a name="get-oauthtokens"></a>
#### `GET /oauth/tokens`

Esta ruta devuelve todos los tokens de acceso autorizados que el usuario autenticado ha creado. Esto es principalmente útil para listar todos los tokens del usuario para que puedan revocarlos:

```js
axios.get('/oauth/tokens')
    .then(response => {
        console.log(response.data);
    });
```

<a name="delete-oauthtokenstoken-id"></a>
#### `DELETE /oauth/tokens/{token-id}`

Esta ruta puede ser utilizada para revocar tokens de acceso autorizados y sus tokens de actualización relacionados:

```js
axios.delete('/oauth/tokens/' + tokenId);
```

<a name="refreshing-tokens"></a>
### Refrescando Tokens

Si tu aplicación emite tokens de acceso de corta duración, los usuarios necesitarán refrescar sus tokens de acceso a través del token de actualización que se les proporcionó cuando se emitió el token de acceso:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'refresh_token',
        'refresh_token' => 'el-token-de-actualización',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'scope' => '',
    ]);

    return $response->json();

Esta ruta `/oauth/token` devolverá una respuesta JSON que contiene los atributos `access_token`, `refresh_token` y `expires_in`. El atributo `expires_in` contiene el número de segundos hasta que el token de acceso expire.

<a name="revoking-tokens"></a>
### Revocando Tokens

Puedes revocar un token utilizando el método `revokeAccessToken` en el `Laravel\Passport\TokenRepository`. Puedes revocar los tokens de actualización de un token utilizando el método `revokeRefreshTokensByAccessTokenId` en el `Laravel\Passport\RefreshTokenRepository`. Estas clases pueden ser resueltas utilizando el [contenedor de servicios](/docs/{{version}}/container) de Laravel:

    use Laravel\Passport\TokenRepository;
    use Laravel\Passport\RefreshTokenRepository;

    $tokenRepository = app(TokenRepository::class);
    $refreshTokenRepository = app(RefreshTokenRepository::class);

    // Revocar un token de acceso...
    $tokenRepository->revokeAccessToken($tokenId);

    // Revocar todos los tokens de actualización del token...
    $refreshTokenRepository->revokeRefreshTokensByAccessTokenId($tokenId);

<a name="purging-tokens"></a>
### Purga de Tokens

Cuando los tokens han sido revocados o expirados, es posible que desees purgarlos de la base de datos. El comando Artisan `passport:purge` incluido en Passport puede hacer esto por ti:

```shell
# Purge revoked and expired tokens and auth codes...
php artisan passport:purge

# Only purge tokens expired for more than 6 hours...
php artisan passport:purge --hours=6

# Only purge revoked tokens and auth codes...
php artisan passport:purge --revoked

# Only purge expired tokens and auth codes...
php artisan passport:purge --expired
```

También puedes configurar un [trabajo programado](/docs/{{version}}/scheduling) en el archivo `routes/console.php` de tu aplicación para eliminar automáticamente tus tokens en un horario:

    use Laravel\Support\Facades\Schedule;

    Schedule::command('passport:purge')->hourly();

<a name="code-grant-pkce"></a>
## Autorización de Código Grant con PKCE

La autorización de código grant con "Proof Key for Code Exchange" (PKCE) es una forma segura de autenticar aplicaciones de una sola página o aplicaciones nativas para acceder a tu API. Este grant debe ser utilizado cuando no puedes garantizar que el secreto del cliente se almacenará de forma confidencial o para mitigar la amenaza de que el código de autorización sea interceptado por un atacante. Una combinación de un "verificador de código" y un "reto de código" reemplaza el secreto del cliente al intercambiar el código de autorización por un token de acceso.

<a name="creating-a-auth-pkce-grant-client"></a>
### Creando el Cliente

Antes de que tu aplicación pueda emitir tokens a través de la autorización de código grant con PKCE, necesitarás crear un cliente habilitado para PKCE. Puedes hacer esto utilizando el comando Artisan `passport:client` con la opción `--public`:

```shell
php artisan passport:client --public
```

<a name="requesting-auth-pkce-grant-tokens"></a>
### Solicitando Tokens

<a name="code-verifier-code-challenge"></a>
#### Verificador de Código y Reto de Código

Dado que este grant de autorización no proporciona un secreto de cliente, los desarrolladores necesitarán generar una combinación de un verificador de código y un reto de código para solicitar un token.

El verificador de código debe ser una cadena aleatoria de entre 43 y 128 caracteres que contenga letras, números y caracteres `"-"`, `"."`, `"_"`, `"~"`, como se define en la [especificación RFC 7636](https://tools.ietf.org/html/rfc7636).

El reto de código debe ser una cadena codificada en Base64 con caracteres seguros para URL y nombres de archivo. Los caracteres finales `'='` deben ser eliminados y no debe haber saltos de línea, espacios en blanco u otros caracteres adicionales.

    $encoded = base64_encode(hash('sha256', $code_verifier, true));

    $codeChallenge = strtr(rtrim($encoded, '='), '+/', '-_');

<a name="code-grant-pkce-redirecting-for-authorization"></a>
#### Redirigiendo para Autorización

Una vez que se ha creado un cliente, puedes usar el ID del cliente y el verificador de código y reto de código generados para solicitar un código de autorización y un token de acceso de tu aplicación. Primero, la aplicación consumidora debe hacer una solicitud de redirección a la ruta `/oauth/authorize` de tu aplicación:

    use Illuminate\Http\Request;
    use Illuminate\Support\Str;

    Route::get('/redirect', function (Request $request) {
        $request->session()->put('state', $state = Str::random(40));

        $request->session()->put(
            'code_verifier', $code_verifier = Str::random(128)
        );

        $codeChallenge = strtr(rtrim(
            base64_encode(hash('sha256', $code_verifier, true))
        , '='), '+/', '-_');

        $query = http_build_query([
            'client_id' => 'client-id',
            'redirect_uri' => 'http://third-party-app.com/callback',
            'response_type' => 'code',
            'scope' => '',
            'state' => $state,
            'code_challenge' => $codeChallenge,
            'code_challenge_method' => 'S256',
            // 'prompt' => '', // "none", "consent", or "login"
        ]);

        return redirect('http://passport-app.test/oauth/authorize?'.$query);
    });

<a name="code-grant-pkce-converting-authorization-codes-to-access-tokens"></a>
#### Convirtiendo Códigos de Autorización en Tokens de Acceso

Si el usuario aprueba la solicitud de autorización, será redirigido de vuelta a la aplicación consumidora. El consumidor debe verificar el parámetro `state` contra el valor que se almacenó antes de la redirección, como en el estándar de autorización de código grant.

Si el parámetro de estado coincide, el consumidor debe emitir una solicitud `POST` a tu aplicación para solicitar un token de acceso. La solicitud debe incluir el código de autorización que fue emitido por tu aplicación cuando el usuario aprobó la solicitud de autorización junto con el verificador de código generado originalmente:

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Http;

    Route::get('/callback', function (Request $request) {
        $state = $request->session()->pull('state');

        $codeVerifier = $request->session()->pull('code_verifier');

        throw_unless(
            strlen($state) > 0 && $state === $request->state,
            InvalidArgumentException::class
        );

        $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
            'grant_type' => 'authorization_code',
            'client_id' => 'client-id',
            'redirect_uri' => 'http://third-party-app.com/callback',
            'code_verifier' => $codeVerifier,
            'code' => $request->code,
        ]);

        return $response->json();
    });

<a name="password-grant-tokens"></a>
## Tokens de Grant de Contraseña

> [!WARNING]  
> Ya no recomendamos el uso de tokens de grant de contraseña. En su lugar, deberías elegir [un tipo de grant que actualmente es recomendado por OAuth2 Server](https://oauth2.thephpleague.com/authorization-server/which-grant/).

El grant de contraseña de OAuth2 permite a tus otros clientes de primera parte, como una aplicación móvil, obtener un token de acceso utilizando una dirección de correo electrónico / nombre de usuario y contraseña. Esto te permite emitir tokens de acceso de manera segura a tus clientes de primera parte sin requerir que tus usuarios pasen por todo el flujo de redirección del código de autorización de OAuth2.

Para habilitar el grant de contraseña, llama al método `enablePasswordGrant` en el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    /**
     * Inicializa cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Passport::enablePasswordGrant();
    }

<a name="creating-a-password-grant-client"></a>
### Creando un Cliente de Grant de Contraseña

Antes de que tu aplicación pueda emitir tokens a través del grant de contraseña, necesitarás crear un cliente de grant de contraseña. Puedes hacer esto utilizando el comando Artisan `passport:client` con la opción `--password`. **Si ya has ejecutado el comando `passport:install`, no necesitas ejecutar este comando:**

```shell
php artisan passport:client --password
```

<a name="requesting-password-grant-tokens"></a>
### Solicitando Tokens

Una vez que hayas creado un cliente de grant de contraseña, puedes solicitar un token de acceso emitiendo una solicitud `POST` a la ruta `/oauth/token` con la dirección de correo electrónico y la contraseña del usuario. Recuerda, esta ruta ya está registrada por Passport, por lo que no hay necesidad de definirla manualmente. Si la solicitud es exitosa, recibirás un `access_token` y un `refresh_token` en la respuesta JSON del servidor:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'password',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'username' => 'taylor@laravel.com',
        'password' => 'mi-contraseña',
        'scope' => '',
    ]);

    return $response->json();

> [!NOTE]  
> Recuerda, los tokens de acceso son de larga duración por defecto. Sin embargo, eres libre de [configurar la duración máxima de tu token de acceso](#configuration) si es necesario.

<a name="requesting-all-scopes"></a>
### Solicitando Todos los Alcances

Al usar el grant de contraseña o el grant de credenciales del cliente, es posible que desees autorizar el token para todos los alcances admitidos por tu aplicación. Puedes hacer esto solicitando el alcance `*`. Si solicitas el alcance `*`, el método `can` en la instancia del token siempre devolverá `true`. Este alcance solo puede ser asignado a un token que se emita utilizando el grant de `password` o `client_credentials`:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'password',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'username' => 'taylor@laravel.com',
        'password' => 'mi-contraseña',
        'scope' => '*',
    ]);

<a name="customizing-the-user-provider"></a>
### Personalizando el Proveedor de Usuarios

Si tu aplicación utiliza más de un [proveedor de usuarios de autenticación](/docs/{{version}}/authentication#introduction), puedes especificar qué proveedor de usuarios utiliza el cliente de grant de contraseña proporcionando una opción `--provider` al crear el cliente a través del comando `artisan passport:client --password`. El nombre del proveedor dado debe coincidir con un proveedor válido definido en el archivo de configuración `config/auth.php` de tu aplicación. Luego puedes [proteger tu ruta utilizando middleware](#via-middleware) para asegurarte de que solo los usuarios del proveedor especificado por el guard sean autorizados.

<a name="customizing-the-username-field"></a>
### Personalizando el Campo de Nombre de Usuario

Cuando se autentica utilizando el grant de contraseña, Passport utilizará el atributo `email` de su modelo autenticable como el "nombre de usuario". Sin embargo, puede personalizar este comportamiento definiendo un método `findForPassport` en su modelo:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Laravel\Passport\HasApiTokens;

    class User extends Authenticatable
    {
        use HasApiTokens, Notifiable;

        /**
         * Find the user instance for the given username.
         */
        public function findForPassport(string $username): User
        {
            return $this->where('username', $username)->first();
        }
    }

<a name="customizing-the-password-validation"></a>
### Personalizando la Validación de Contraseña

Cuando se autentica utilizando el grant de contraseña, Passport utilizará el atributo `password` de su modelo para validar la contraseña dada. Si su modelo no tiene un atributo `password` o desea personalizar la lógica de validación de contraseña, puede definir un método `validateForPassportPasswordGrant` en su modelo:

    <?php

    namespace App\Models;

    use Illuminate\Foundation\Auth\User as Authenticatable;
    use Illuminate\Notifications\Notifiable;
    use Illuminate\Support\Facades\Hash;
    use Laravel\Passport\HasApiTokens;

    class User extends Authenticatable
    {
        use HasApiTokens, Notifiable;

        /**
         * Validate the password of the user for the Passport password grant.
         */
        public function validateForPassportPasswordGrant(string $password): bool
        {
            return Hash::check($password, $this->password);
        }
    }

<a name="implicit-grant-tokens"></a>
## Tokens de Grant Implícito

> [!WARNING]  
> Ya no recomendamos usar tokens de grant implícito. En su lugar, debe elegir [un tipo de grant que actualmente sea recomendado por OAuth2 Server](https://oauth2.thephpleague.com/authorization-server/which-grant/).

El grant implícito es similar al grant de código de autorización; sin embargo, el token se devuelve al cliente sin intercambiar un código de autorización. Este grant se utiliza comúnmente para aplicaciones de JavaScript o móviles donde las credenciales del cliente no pueden almacenarse de manera segura. Para habilitar el grant, llame al método `enableImplicitGrant` en el método `boot` de la clase `App\Providers\AppServiceProvider` de su aplicación:

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Passport::enableImplicitGrant();
    }

Una vez que se ha habilitado el grant, los desarrolladores pueden usar su ID de cliente para solicitar un token de acceso de su aplicación. La aplicación consumidora debe hacer una solicitud de redirección a la ruta `/oauth/authorize` de su aplicación de la siguiente manera:

    use Illuminate\Http\Request;

    Route::get('/redirect', function (Request $request) {
        $request->session()->put('state', $state = Str::random(40));

        $query = http_build_query([
            'client_id' => 'client-id',
            'redirect_uri' => 'http://third-party-app.com/callback',
            'response_type' => 'token',
            'scope' => '',
            'state' => $state,
            // 'prompt' => '', // "none", "consent", or "login"
        ]);

        return redirect('http://passport-app.test/oauth/authorize?'.$query);
    });

> [!NOTE]  
> Recuerde, la ruta `/oauth/authorize` ya está definida por Passport. No necesita definir manualmente esta ruta.

<a name="client-credentials-grant-tokens"></a>
## Tokens de Grant de Credenciales de Cliente

El grant de credenciales de cliente es adecuado para la autenticación máquina a máquina. Por ejemplo, puede usar este grant en un trabajo programado que esté realizando tareas de mantenimiento a través de una API.

Antes de que su aplicación pueda emitir tokens a través del grant de credenciales de cliente, necesitará crear un cliente de grant de credenciales de cliente. Puede hacer esto utilizando la opción `--client` del comando Artisan `passport:client`:

```shell
php artisan passport:client --client
```

A continuación, para usar este tipo de grant, registre un alias de middleware para el middleware `CheckClientCredentials`. Puede definir alias de middleware en el archivo `bootstrap/app.php` de su aplicación:

    use Laravel\Passport\Http\Middleware\CheckClientCredentials;

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'client' => CheckClientCredentials::class
        ]);
    })

Luego, adjunte el middleware a una ruta:

    Route::get('/orders', function (Request $request) {
        ...
    })->middleware('client');

Para restringir el acceso a la ruta a scopes específicos, puede proporcionar una lista delimitada por comas de los scopes requeridos al adjuntar el middleware `client` a la ruta:

    Route::get('/orders', function (Request $request) {
        ...
    })->middleware('client:check-status,your-scope');

<a name="retrieving-tokens"></a>
### Recuperando Tokens

Para recuperar un token utilizando este tipo de grant, haga una solicitud al endpoint `oauth/token`:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'client_credentials',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'scope' => 'your-scope',
    ]);

    return $response->json()['access_token'];

<a name="personal-access-tokens"></a>
## Tokens de Acceso Personal

A veces, sus usuarios pueden querer emitir tokens de acceso para sí mismos sin pasar por el flujo típico de redirección de código de autorización. Permitir que los usuarios emitan tokens para sí mismos a través de la interfaz de usuario de su aplicación puede ser útil para permitir que los usuarios experimenten con su API o puede servir como un enfoque más simple para emitir tokens de acceso en general.

> [!NOTE]  
> Si su aplicación utiliza principalmente Passport para emitir tokens de acceso personal, considere usar [Laravel Sanctum](/docs/{{version}}/sanctum), la biblioteca ligera de Laravel para emitir tokens de acceso a la API.

<a name="creating-a-personal-access-client"></a>
### Creando un Cliente de Acceso Personal

Antes de que su aplicación pueda emitir tokens de acceso personal, necesitará crear un cliente de acceso personal. Puede hacer esto ejecutando el comando Artisan `passport:client` con la opción `--personal`. Si ya ha ejecutado el comando `passport:install`, no necesita ejecutar este comando:

```shell
php artisan passport:client --personal
```

Después de crear su cliente de acceso personal, coloque el ID del cliente y el valor de secreto en texto plano en el archivo `.env` de su aplicación:

```ini
PASSPORT_PERSONAL_ACCESS_CLIENT_ID="client-id-value"
PASSPORT_PERSONAL_ACCESS_CLIENT_SECRET="unhashed-client-secret-value"
```

<a name="managing-personal-access-tokens"></a>
### Gestionando Tokens de Acceso Personal

Una vez que haya creado un cliente de acceso personal, puede emitir tokens para un usuario dado utilizando el método `createToken` en la instancia del modelo `App\Models\User`. El método `createToken` acepta el nombre del token como su primer argumento y un array opcional de [scopes](#token-scopes) como su segundo argumento:

    use App\Models\User;

    $user = User::find(1);

    // Creando un token sin scopes...
    $token = $user->createToken('Token Name')->accessToken;

    // Creando un token con scopes...
    $token = $user->createToken('My Token', ['place-orders'])->accessToken;

<a name="personal-access-tokens-json-api"></a>
#### JSON API

Passport también incluye una API JSON para gestionar tokens de acceso personal. Puede emparejar esto con su propio frontend para ofrecer a sus usuarios un panel de control para gestionar tokens de acceso personal. A continuación, revisaremos todos los endpoints de la API para gestionar tokens de acceso personal. Para conveniencia, utilizaremos [Axios](https://github.com/mzabriskie/axios) para demostrar cómo hacer solicitudes HTTP a los endpoints.

La API JSON está protegida por los middleware `web` y `auth`; por lo tanto, solo puede ser llamada desde su propia aplicación. No puede ser llamada desde una fuente externa.

<a name="get-oauthscopes"></a>
#### `GET /oauth/scopes`

Esta ruta devuelve todos los [scopes](#token-scopes) definidos para su aplicación. Puede usar esta ruta para listar los scopes que un usuario puede asignar a un token de acceso personal:

```js
axios.get('/oauth/scopes')
    .then(response => {
        console.log(response.data);
    });
```

<a name="get-oauthpersonal-access-tokens"></a>
#### `GET /oauth/personal-access-tokens`

Esta ruta devuelve todos los tokens de acceso personal que el usuario autenticado ha creado. Esto es principalmente útil para listar todos los tokens del usuario para que puedan editarlos o revocarlos:

```js
axios.get('/oauth/personal-access-tokens')
    .then(response => {
        console.log(response.data);
    });
```

<a name="post-oauthpersonal-access-tokens"></a>
#### `POST /oauth/personal-access-tokens`

Esta ruta crea nuevos tokens de acceso personal. Requiere dos piezas de datos: el `nombre` del token y los `scopes` que deben asignarse al token:

```js
const data = {
    name: 'Token Name',
    scopes: []
};

axios.post('/oauth/personal-access-tokens', data)
    .then(response => {
        console.log(response.data.accessToken);
    })
    .catch (response => {
        // List errors on response...
    });
```

<a name="delete-oauthpersonal-access-tokenstoken-id"></a>
#### `DELETE /oauth/personal-access-tokens/{token-id}`

Esta ruta puede ser utilizada para revocar tokens de acceso personal:

```js
axios.delete('/oauth/personal-access-tokens/' + tokenId);
```

<a name="protecting-routes"></a>
## Protegiendo Rutas

<a name="via-middleware"></a>
### A través de Middleware

Passport incluye un [guard de autenticación](/docs/{{version}}/authentication#adding-custom-guards) que validará los tokens de acceso en las solicitudes entrantes. Una vez que haya configurado el guard `api` para usar el controlador `passport`, solo necesita especificar el middleware `auth:api` en cualquier ruta que deba requerir un token de acceso válido:

    Route::get('/user', function () {
        // ...
    })->middleware('auth:api');

> [!WARNING]  
> Si está utilizando el [grant de credenciales de cliente](#client-credentials-grant-tokens), debe usar [el middleware `client`](#client-credentials-grant-tokens) para proteger sus rutas en lugar del middleware `auth:api`.

<a name="multiple-authentication-guards"></a>
#### Múltiples Guards de Autenticación

Si su aplicación autentica diferentes tipos de usuarios que quizás utilicen modelos Eloquent completamente diferentes, probablemente necesitará definir una configuración de guard para cada tipo de proveedor de usuario en su aplicación. Esto le permite proteger solicitudes destinadas a proveedores de usuario específicos. Por ejemplo, dada la siguiente configuración de guard en el archivo de configuración `config/auth.php`:

    'api' => [
        'driver' => 'passport',
        'provider' => 'users',
    ],

    'api-customers' => [
        'driver' => 'passport',
        'provider' => 'customers',
    ],

La siguiente ruta utilizará el guard `api-customers`, que utiliza el proveedor de usuario `customers`, para autenticar las solicitudes entrantes:

    Route::get('/customer', function () {
        // ...
    })->middleware('auth:api-customers');

> [!NOTE]  
> Para obtener más información sobre el uso de múltiples proveedores de usuario con Passport, consulte la [documentación del grant de contraseña](#customizing-the-user-provider).

<a name="passing-the-access-token"></a>
### Pasando el Token de Acceso

Al llamar a rutas que están protegidas por Passport, los consumidores de la API de su aplicación deben especificar su token de acceso como un token `Bearer` en el encabezado `Authorization` de su solicitud. Por ejemplo, al usar la biblioteca HTTP Guzzle:

    use Illuminate\Support\Facades\Http;

    $response = Http::withHeaders([
        'Accept' => 'application/json',
        'Authorization' => 'Bearer '.$accessToken,
    ])->get('https://passport-app.test/api/user');

    return $response->json();

<a name="token-scopes"></a>
## Scopes de Token

Los scopes permiten a sus clientes de API solicitar un conjunto específico de permisos al solicitar autorización para acceder a una cuenta. Por ejemplo, si está construyendo una aplicación de comercio electrónico, no todos los consumidores de API necesitarán la capacidad de realizar pedidos. En su lugar, puede permitir que los consumidores solo soliciten autorización para acceder a los estados de envío de pedidos. En otras palabras, los scopes permiten a los usuarios de su aplicación limitar las acciones que una aplicación de terceros puede realizar en su nombre.

<a name="defining-scopes"></a>
### Definiendo Scopes

Puede definir los scopes de su API utilizando el método `Passport::tokensCan` en el método `boot` de la clase `App\Providers\AppServiceProvider` de su aplicación. El método `tokensCan` acepta un array de nombres de scope y descripciones de scope. La descripción del scope puede ser cualquier cosa que desee y se mostrará a los usuarios en la pantalla de aprobación de autorización:

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Passport::tokensCan([
            'place-orders' => 'Realizar pedidos',
            'check-status' => 'Verificar estado del pedido',
        ]);
    }

<a name="default-scope"></a>
### Scope Predeterminado

Si un cliente no solicita ningún scope específico, puede configurar su servidor Passport para adjuntar scope(s) predeterminados al token utilizando el método `setDefaultScope`. Típicamente, debe llamar a este método desde el método `boot` de la clase `App\Providers\AppServiceProvider` de su aplicación:

    use Laravel\Passport\Passport;

    Passport::tokensCan([
        'place-orders' => 'Realizar pedidos',
        'check-status' => 'Verificar estado del pedido',
    ]);

    Passport::setDefaultScope([
        'check-status',
        'place-orders',
    ]);

> [!NOTE]  
> Los scopes predeterminados de Passport no se aplican a los tokens de acceso personal que son generados por el usuario.

<a name="assigning-scopes-to-tokens"></a>
### Asignando Scopes a Tokens

<a name="when-requesting-authorization-codes"></a>
#### Al Solicitar Códigos de Autorización

Al solicitar un token de acceso utilizando el grant de código de autorización, los consumidores deben especificar sus scopes deseados como el parámetro de cadena de consulta `scope`. El parámetro `scope` debe ser una lista de scopes delimitada por espacios:

    Route::get('/redirect', function () {
        $query = http_build_query([
            'client_id' => 'client-id',
            'redirect_uri' => 'http://example.com/callback',
            'response_type' => 'code',
            'scope' => 'place-orders check-status',
        ]);

        return redirect('http://passport-app.test/oauth/authorize?'.$query);
    });

<a name="when-issuing-personal-access-tokens"></a>
#### Al Emitir Tokens de Acceso Personal

Si está emitiendo tokens de acceso personal utilizando el método `createToken` del modelo `App\Models\User`, puede pasar el array de scopes deseados como el segundo argumento al método:

    $token = $user->createToken('My Token', ['place-orders'])->accessToken;

<a name="checking-scopes"></a>
### Verificando Scopes

Passport incluye dos middleware que pueden ser utilizados para verificar que una solicitud entrante está autenticada con un token que ha sido otorgado un scope dado. Para comenzar, defina los siguientes alias de middleware en el archivo `bootstrap/app.php` de su aplicación:

    use Laravel\Passport\Http\Middleware\CheckForAnyScope;
    use Laravel\Passport\Http\Middleware\CheckScopes;

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'scopes' => CheckScopes::class,
            'scope' => CheckForAnyScope::class,
        ]);
    })

<a name="check-for-all-scopes"></a>
#### Verificar Todos los Scopes

El middleware `scopes` puede ser asignado a una ruta para verificar que el token de acceso de la solicitud entrante tiene todos los scopes listados:

    Route::get('/orders', function () {
        // El token de acceso tiene tanto los scopes "check-status" como "place-orders"...
    })->middleware(['auth:api', 'scopes:check-status,place-orders']);

```markdown
<a name="check-for-any-scopes"></a>
#### Verificar si hay algún Scope

El middleware `scope` puede asignarse a una ruta para verificar que el token de acceso de la solicitud entrante tenga *al menos uno* de los scopes listados:

    Route::get('/orders', function () {
        // El token de acceso tiene el scope "check-status" o "place-orders"...
    })->middleware(['auth:api', 'scope:check-status,place-orders']);

<a name="checking-scopes-on-a-token-instance"></a>
#### Verificando Scopes en una Instancia de Token

Una vez que una solicitud autenticada con un token de acceso ha ingresado a tu aplicación, aún puedes verificar si el token tiene un scope dado utilizando el método `tokenCan` en la instancia autenticada de `App\Models\User`:

    use Illuminate\Http\Request;

    Route::get('/orders', function (Request $request) {
        if ($request->user()->tokenCan('place-orders')) {
            // ...
        }
    });

<a name="additional-scope-methods"></a>
#### Métodos Adicionales de Scope

El método `scopeIds` devolverá un array de todos los IDs / nombres definidos:

    use Laravel\Passport\Passport;

    Passport::scopeIds();

El método `scopes` devolverá un array de todos los scopes definidos como instancias de `Laravel\Passport\Scope`:

    Passport::scopes();

El método `scopesFor` devolverá un array de instancias de `Laravel\Passport\Scope` que coincidan con los IDs / nombres dados:

    Passport::scopesFor(['place-orders', 'check-status']);

Puedes determinar si un scope dado ha sido definido utilizando el método `hasScope`:

    Passport::hasScope('place-orders');

<a name="consuming-your-api-with-javascript"></a>
## Consumir tu API con JavaScript

Al construir una API, puede ser extremadamente útil poder consumir tu propia API desde tu aplicación JavaScript. Este enfoque para el desarrollo de API permite que tu propia aplicación consuma la misma API que estás compartiendo con el mundo. La misma API puede ser consumida por tu aplicación web, aplicaciones móviles, aplicaciones de terceros y cualquier SDK que puedas publicar en varios administradores de paquetes.

Típicamente, si deseas consumir tu API desde tu aplicación JavaScript, necesitarías enviar manualmente un token de acceso a la aplicación y pasarlo con cada solicitud a tu aplicación. Sin embargo, Passport incluye un middleware que puede manejar esto por ti. Todo lo que necesitas hacer es agregar el middleware `CreateFreshApiToken` al grupo de middleware `web` en el archivo `bootstrap/app.php` de tu aplicación:

    use Laravel\Passport\Http\Middleware\CreateFreshApiToken;

    ->withMiddleware(function (Middleware $middleware) {
        $middleware->web(append: [
            CreateFreshApiToken::class,
        ]);
    })

> [!WARNING]  
> Debes asegurarte de que el middleware `CreateFreshApiToken` sea el último middleware listado en tu pila de middleware.

Este middleware adjuntará una cookie `laravel_token` a tus respuestas salientes. Esta cookie contiene un JWT encriptado que Passport utilizará para autenticar las solicitudes API desde tu aplicación JavaScript. El JWT tiene una duración igual al valor de configuración de `session.lifetime`. Ahora, dado que el navegador enviará automáticamente la cookie con todas las solicitudes subsiguientes, puedes hacer solicitudes a la API de tu aplicación sin pasar explícitamente un token de acceso:

    axios.get('/api/user')
        .then(response => {
            console.log(response.data);
        });

<a name="customizing-the-cookie-name"></a>
#### Personalizando el Nombre de la Cookie

Si es necesario, puedes personalizar el nombre de la cookie `laravel_token` utilizando el método `Passport::cookie`. Típicamente, este método debe ser llamado desde el método `boot` de la clase `App\Providers\AppServiceProvider` de tu aplicación:

    /**
     * Inicializar cualquier servicio de la aplicación.
     */
    public function boot(): void
    {
        Passport::cookie('custom_name');
    }

<a name="csrf-protection"></a>
#### Protección CSRF

Al utilizar este método de autenticación, necesitarás asegurarte de que un encabezado de token CSRF válido esté incluido en tus solicitudes. La estructura predeterminada de JavaScript de Laravel incluye una instancia de Axios, que utilizará automáticamente el valor de la cookie encriptada `XSRF-TOKEN` para enviar un encabezado `X-XSRF-TOKEN` en solicitudes de mismo origen.

> [!NOTE]  
> Si eliges enviar el encabezado `X-CSRF-TOKEN` en lugar de `X-XSRF-TOKEN`, necesitarás utilizar el token no encriptado proporcionado por `csrf_token()`.

<a name="events"></a>
## Eventos

Passport genera eventos al emitir tokens de acceso y tokens de actualización. Puedes [escuchar estos eventos](/docs/{{version}}/events) para podar o revocar otros tokens de acceso en tu base de datos:

| Nombre del Evento |
| --- |
| `Laravel\Passport\Events\AccessTokenCreated` |
| `Laravel\Passport\Events\RefreshTokenCreated` |

<a name="testing"></a>
## Pruebas

El método `actingAs` de Passport puede ser utilizado para especificar al usuario autenticado actualmente así como sus scopes. El primer argumento dado al método `actingAs` es la instancia del usuario y el segundo es un array de scopes que deberían ser otorgados al token del usuario:

```php tab=Pest
use App\Models\User;
use Laravel\Passport\Passport;

test('servers can be created', function () {
    Passport::actingAs(
        User::factory()->create(),
        ['create-servers']
    );

    $response = $this->post('/api/create-server');

    $response->assertStatus(201);
});
```

```php tab=PHPUnit
use App\Models\User;
use Laravel\Passport\Passport;

public function test_servers_can_be_created(): void
{
    Passport::actingAs(
        User::factory()->create(),
        ['create-servers']
    );

    $response = $this->post('/api/create-server');

    $response->assertStatus(201);
}
```

El método `actingAsClient` de Passport puede ser utilizado para especificar al cliente autenticado actualmente así como sus scopes. El primer argumento dado al método `actingAsClient` es la instancia del cliente y el segundo es un array de scopes que deberían ser otorgados al token del cliente:

```php tab=Pest
use Laravel\Passport\Client;
use Laravel\Passport\Passport;

test('orders can be retrieved', function () {
    Passport::actingAsClient(
        Client::factory()->create(),
        ['check-status']
    );

    $response = $this->get('/api/orders');

    $response->assertStatus(200);
});
```

```php tab=PHPUnit
use Laravel\Passport\Client;
use Laravel\Passport\Passport;

public function test_orders_can_be_retrieved(): void
{
    Passport::actingAsClient(
        Client::factory()->create(),
        ['check-status']
    );

    $response = $this->get('/api/orders');

    $response->assertStatus(200);
}
```
```
