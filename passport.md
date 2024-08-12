# Laravel Passport

- [Introducción](#introduction)
  - [¿Passport o Sanctum?](#passport-or-sanctum)
- [Instalación](#installation)
  - [Despliegue de Passport](#deploying-passport)
  - [Personalización de la migración](#migration-customization)
  - [Actualización de Passport](#upgrading-passport)
- [Configuración](#configuration)
  - [Cifrado de secretos de cliente](#client-secret-hashing)
  - [Duración de los tokens](#token-lifetimes)
  - [Sobreescribiendo modelos predeterminados](#overriding-default-models)
  - [Sobreescribiendo rutas](#overriding-routes)
- [Emisión de tokens de acceso](#issuing-access-tokens)
  - [Gestión de clientes](#managing-clients)
  - [Solicitud de tokens](#requesting-tokens)
  - [Actualización de tokens](#refreshing-tokens)
  - [Revocación de tokens](#revoking-tokens)
  - [Purga de tokens](#purging-tokens)
- [Concesión de códigos de autorización con PKCE](#code-grant-pkce)
  - [Creación del cliente](#creating-a-auth-pkce-grant-client)
  - [Solicitud de tokens](#requesting-auth-pkce-grant-tokens)
- [Concesión de tokens con contraseña](#password-grant-tokens)
  - [Creación de un cliente de concesión de contraseña](#creating-a-password-grant-client)
  - [Solicitud de tokens](#requesting-password-grant-tokens)
  - [Solicitud de todos los ámbitos](#requesting-all-scopes)
  - [Personalización del proveedor de usuarios](#customizing-the-user-provider)
  - [Personalización del campo de nombre de usuario](#customizing-the-username-field)
  - [Personalización de la validación de contraseña](#customizing-the-password-validation)
- [Concesión implícita de tokens](#implicit-grant-tokens)
- [Concesión de credenciales de cliente](#client-credentials-grant-tokens)
- [Tokens de acceso personal](#personal-access-tokens)
  - [Creación de un cliente de acceso personal](#creating-a-personal-access-client)
  - [Gestión de tokens de acceso personal](#managing-personal-access-tokens)
- [Protección de rutas](#protecting-routes)
  - [Mediante middleware](#via-middleware)
  - [Paso del token de acceso](#passing-the-access-token)
- [Ámbitos de token](#token-scopes)
  - [Definición de ámbitos](#defining-scopes)
  - [Ámbito por defecto](#default-scope)
  - [Asignación de ámbitos a tokens](#assigning-scopes-to-tokens)
  - [Comprobación de ámbitos](#checking-scopes)
- [Consumo de la API con JavaScript](#consuming-your-api-with-javascript)
- [Eventos](#events)
- [Probando](#testing)

<a name="introduction"></a>
## Introducción

[Laravel Passport](https://github.com/laravel/passport) proporciona una implementación completa de servidor OAuth2 para su aplicación Laravel en cuestión de minutos. Passport está construido sobre el [servidor OAuth2 de League](https://github.com/thephpleague/oauth2-server), mantenido por Andy Millington y Simon Hamp.

> **Advertencia**  
> Esta documentación asume que ya estás familiarizado con OAuth2. Si no es así, considera aprender primero sobre la [terminología general](https://oauth2.thephpleague.com/terminology/) y las características de OAuth2 antes de continuar.

<a name="passport-or-sanctum"></a>
### ¿Passport o Sanctum?

Antes de empezar, es recomendable determinar si tu aplicacación realmente necesita Laravel Passport o, si por el contrario, es mejor usar [Laravel Sanctum](/docs/{{version}}/sanctum). Si es absolutamente necesario que tu aplicación soporte OAuth2, entonces deberías utilizar Laravel Passport.

Sin embargo, si usted está tratando de autenticar una aplicación de una sola página, aplicación móvil, o emitir tokens de API, debe utilizar Laravel [Sanctum](/docs/{{version}}/sanctum). Laravel Sanctum no soporta OAuth2; sin embargo, proporciona una experiencia de desarrollo de autenticación de API mucho más simple.

<a name="installation"></a>
## Instalación

Para empezar, instale Passport a través del gestor de paquetes Composer:

```shell
composer require laravel/passport
```

El [proveedor de servicios](/docs/{{version}}/providers) de Passport registra su propio directorio de migración de base de datos, por lo que deberías migrar tu base de datos después de instalar el paquete. Las migraciones de Passport crearán las tablas que tu aplicación necesita para almacenar clientes OAuth2 y tokens de acceso:

```shell
php artisan migrate
```

Luego, debes ejecutar el comando `passport:install` Artisan. Este comando creará las claves de encriptación necesarias para generar tokens de acceso seguros. Además, el comando creará clientes de "acceso personal" y "concesión de contraseña" que serán utilizados para generar tokens de acceso:

```shell
php artisan passport:install
```

> **Nota**  
> Si desea utilizar UUID como valor de clave principal del modelo `Client` Passport en lugar de números enteros autoincrementados, instale Passport utilizando [la opción `uuids`](#client-uuids).

Después de ejecutar el comando `passport:install`, añada el trait `Laravel\Passport\HasApiTokens` a su modelo `App\Models\User`. Este trait proporcionará algunos métodos de ayuda a su modelo que le permitirán inspeccionar el token y los scopes del usuario autenticado. Si su modelo ya utiliza el trait `Laravel\Sanctum\HasApiTokens`, puede eliminar ese trait:

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

Finalmente, en el archivo de configuración `config/auth.php` de tu aplicación, debes definir una guarda de autenticación `api` y establecer la opción `driver` a `passport`. Esto le indicará a tu aplicación que use el `TokenGuard` de Passport cuando autentique las solicitudes API entrantes:

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

<a name="client-uuids"></a>
#### UUID de cliente

También puede ejecutar el comando `passport:install` con la opción `--uuids` presente. Esta opción indicará a Passport que desea utilizar UUID en lugar de números enteros autoincrementados como valores de clave primaria del modelo `Client` de Passport. Después de ejecutar el comando `passport:install` con la opción `--uuids`, recibirá instrucciones adicionales para desactivar las migraciones predeterminadas de Passport:

```shell
php artisan passport:install --uuids
```

<a name="deploying-passport"></a>
### Despliegue de Passport

Al desplegar Passport en los servidores de su aplicación por primera vez, es probable que necesite ejecutar el comando `passport:keys`. Este comando genera las claves de cifrado que Passport necesita para generar los tokens de acceso. Normalmente, las claves generadas no se guardan en el control de código fuente:

```shell
php artisan passport:keys
```

Si es necesario, puede definir la ruta desde donde se cargarán las claves de Passport. Para ello puede utilizar el método `Passport::loadKeysFrom`. Típicamente, este método debería ser llamado desde el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación:

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::loadKeysFrom(__DIR__.'/../secrets/oauth');
    }

<a name="loading-keys-from-the-environment"></a>
#### Carga de claves del entorno

De manera alternativa, puede publicar el archivo de configuración de Passport utilizando el comando `vendor:publish` Artisan:

```shell
php artisan vendor:publish --tag=passport-config
```

Una vez publicado el fichero de configuración, puedes cargar las claves de encriptación de tu aplicación definiéndolas como variables de entorno:

```ini
PASSPORT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
<private key here>
-----END RSA PRIVATE KEY-----"

PASSPORT_PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
<public key here>
-----END PUBLIC KEY-----"
```

<a name="migration-customization"></a>
### Personalización de la migración

Si no va a utilizar las migraciones por defecto de Passport, debe llamar al método `Passport::ignoreMigrations` en el método `register` de su clase `AppProviders\AppServiceProvider`. Puede exportar las migraciones por defecto utilizando el comando `vendor:publish` de Artisan:

```shell
php artisan vendor:publish --tag=passport-migrations
```

<a name="upgrading-passport"></a>
### Actualización de Passport

Cuando actualice a una nueva versión de Passport, es importante que revise cuidadosamente [la guía de actualización](https://github.com/laravel/passport/blob/master/UPGRADE.md).

<a name="configuration"></a>
## Configuración

<a name="client-secret-hashing"></a>
### Cifrado de los `Secrets` de Cliente

Si desea que las claves secretas de su cliente sean cifrados (mediante hash) cuando se almacenen en su base de datos, debe llamar al método `Passport::hashClientSecrets` en el método `boot` de su clase `App\Providers\AuthServiceProvider`:

    use Laravel\Passport\Passport;

    Passport::hashClientSecrets();

Una vez habilitadas, todas tus claves secretas de cliente sólo podrán ser visualizados por el usuario inmediatamente después de ser creados. Dado que el valor del secreto de cliente en texto plano nunca se almacena en la base de datos, no es posible recuperar el valor del secreto si se pierde.

<a name="token-lifetimes"></a>
### Duración de los tokens

Por defecto, Passport emite tokens de acceso de larga duración que caducan al cabo de un año. Si desea configurar una duración de token más larga o más corta, puede utilizar los métodos `tokensExpireIn`, `refreshTokensExpireIn` y `personalAccessTokensExpireIn`. Estos métodos deben ser llamados desde el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación:

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::tokensExpireIn(now()->addDays(15));
        Passport::refreshTokensExpireIn(now()->addDays(30));
        Passport::personalAccessTokensExpireIn(now()->addMonths(6));
    }

> **Advertencia**  
> Las columnas `expires_at` de las tablas de la base de datos de Passport son de sólo lectura y de visualización. Al emitir tokens, Passport almacena la información de caducidad dentro de los tokens firmados y cifrados. Si necesita invalidar un token, deberá [revocarlo](#revoking-tokens).

<a name="overriding-default-models"></a>
### Sobreescribiendo modelos predeterminados

Puede ampliar los modelos utilizados internamente por Passport definiendo su propio modelo y ampliando el modelo correspondiente de Passport:

    use Laravel\Passport\Client as PassportClient;

    class Client extends PassportClient
    {
        // ...
    }

Tras definir su modelo, puede indicar a Passport que utilice su modelo personalizado a través de la clase `Laravel\Passport\Passport`. Normalmente, debería informar a Passport sobre sus modelos personalizados en el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación:

    use App\Models\Passport\AuthCode;
    use App\Models\Passport\Client;
    use App\Models\Passport\PersonalAccessClient;
    use App\Models\Passport\Token;

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::useTokenModel(Token::class);
        Passport::useClientModel(Client::class);
        Passport::useAuthCodeModel(AuthCode::class);
        Passport::usePersonalAccessClientModel(PersonalAccessClient::class);
    }

<a name="overriding-routes"></a>
### Sobreescribiendo rutas

A veces puede que desee personalizar las rutas definidas por Passport. Para lograr esto, primero necesitas ignorar las rutas registradas por Passport agregando `Passport::ignoreRoutes` al método `register` del `AppServiceProvider` de tu aplicación:

    use Laravel\Passport\Passport;

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        Passport::ignoreRoutes();
    }

A continuación, puede copiar las rutas definidas por Passport en [su archivo routes](https://github.com/laravel/passport/blob/11.x/routes/web.php) al archivo `routes/web.php`  de su aplicación y modificarlas a su gusto:

    Route::group([
        'as' => 'passport.',
        'prefix' => config('passport.path', 'oauth'),
        'namespace' => 'Laravel\Passport\Http\Controllers',
    ], function () {
        // Passport routes...
    });

<a name="issuing-access-tokens"></a>
## Emisión de tokens de acceso

El uso de OAuth2 a través de códigos de autorización es la forma en que la mayoría de los desarrolladores están familiarizados con OAuth2. Al utilizar códigos de autorización, una aplicación cliente redirigirá a un usuario a su servidor, donde aprobará o denegará la solicitud para emitir un token de acceso al cliente.

<a name="managing-clients"></a>
### Gestión de clientes

En primer lugar, los desarrolladores que creen aplicaciones que necesiten interactuar con la API de tu aplicación tendrán que registrar su aplicación con la tuya creando un "cliente". Normalmente, esto consiste en proporcionar el nombre de su aplicación y una URL a la que tu aplicación pueda redirigir después de que los usuarios aprueben su solicitud de autorización.

<a name="the-passportclient-command"></a>
#### El comando `passport:client`

La forma más sencilla de crear un cliente es utilizando el comando `passport:client` de Artisan. Este comando puede ser utilizado para crear tus propios clientes para probar tu funcionalidad OAuth2. Cuando ejecutes el comando `client`, Passport te pedirá más información sobre tu cliente y te proporcionará un ID de cliente y un secreto:

```shell
php artisan passport:client
```

**Redirección de URL**

Si desea permitir varias URL de redirección para su cliente, puede especificarlas utilizando una lista delimitada por comas cuando el comando `passport:client`  le pida la URL. Cualquier URL que contenga comas debe codificarse como URL:

```shell
http://example.com/callback,http://examplefoo.com/callback
```

<a name="clients-json-api"></a>
#### API JSON

Dado que los usuarios de su aplicación no podrán utilizar el comando `client`, Passport proporciona una API JSON que puede utilizar para crear clientes. Esto le ahorra la molestia de tener que codificar manualmente los controladores para crear, actualizar y eliminar clientes.

Sin embargo, necesitará emparejar la API JSON de Passport con su propio frontend para proporcionar un panel de control para que sus usuarios gestionen sus clientes. A continuación, revisaremos todos los puntos finales de la API para gestionar clientes. Por comodidad, utilizaremos [Axios](https://github.com/axios/axios) para mostrar cómo realizar solicitudes HTTP a los endpoints.

La API JSON está protegida por el middleware `web` y `auth`; por lo tanto, sólo puede invocarse desde su propia aplicación. No se puede llamar desde una fuente externa.

<a name="get-oauthclients"></a>
#### `GET /oauth/clients`

Esta ruta devuelve todos los clientes del usuario autenticado. Esto es útil principalmente para listar todos los clientes del usuario para que, por ejemplo, puedan ser editados o eliminados:

```js
axios.get('/oauth/clients')
    .then(response => {
        console.log(response.data);
    });
```

<a name="post-oauthclients"></a>
#### `POST /oauth/clients`

Esta ruta se utiliza para crear nuevos clientes. Requiere dos datos: el `name` del cliente y una URL de `redirect`. La URL de `redirect` es donde el usuario será redirigido después de aprobar o denegar una solicitud de autorización.

Cuando se crea un cliente, se le asigna un ID de cliente y una clave secreta. Estos valores se utilizarán cuando solicite tokens de acceso a su aplicación. La ruta de creación de cliente devolverá la nueva instancia de cliente:

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

Esta ruta se utiliza para actualizar clientes. Requiere dos datos: el `name` del cliente y una URL de `redirect`. La URL de `redirect` es a la que se redirigirá al usuario tras aprobar o denegar una solicitud de autorización. La ruta devolverá la instancia de cliente actualizada:

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
        //
    });
```

<a name="requesting-tokens"></a>
### Solicitud de tokens

<a name="requesting-tokens-redirecting-for-authorization"></a>
#### Redireccionamiento para autorización

Una vez un cliente ha sido creado, los desarrolladores pueden utilizar su ID de cliente y su clave secreta para solicitar un código de autorización y un token de acceso a su aplicación. En primer lugar, la aplicación consumidora debe realizar una solicitud de redirección a la ruta `/oauth/authorize` de su aplicación, como se indica a continuación:

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

El parámetro `prompt` puede utilizarse para especificar el comportamiento de autenticación de la aplicación Passport.

Si el valor de `prompt` es `none`, Passport siempre lanzará un error de autenticación si el usuario no está ya autenticado con la aplicación Passport. Si el valor es `consent`, Passport siempre mostrará la pantalla de aprobación de autorización, incluso si previamente todos los ámbitos ya han concedidos a la aplicación consumidora. Si el valor es `login`, la aplicación Passport siempre pedirá al usuario que vuelva a iniciar sesión en la aplicación, incluso si ya tiene una sesión existente.

Si no se indica ningún valor para `prompt`, sólo se solicitará autorización al usuario si éste no ha autorizado previamente el acceso a la aplicación de consumo para los ámbitos solicitados.

> **Nota**  
> Recuerde que la ruta `/oauth/authorize` ya está definida por Passport. No es necesario definir manualmente esta ruta.

<a name="approving-the-request"></a>
#### Aprobación de la solicitud

Al recibir solicitudes de autorización, Passport responderá automáticamente basándose en el valor del parámetro `prompt` (si está presente) y puede mostrar una plantilla al usuario permitiéndole aprobar o denegar la solicitud de autorización. Si aprueban la solicitud, serán redirigidos de vuelta a la `redirect_uri` especificada por la aplicación consumidora. La `redirect_uri` debe coincidir con la URL de `redirección` que se especificó cuando se creó el cliente.

Si desea personalizar la pantalla de aprobación de autorizaciones, puede publicar las vistas de Passport utilizando el comando `vendor:publish` Artisan. Las vistas publicadas se colocarán en el directorio `resources/views/vendor/passport`:

```shell
php artisan vendor:publish --tag=passport-views
```

A veces es posible que desee omitir la solicitud de autorización, como cuando se autoriza a un cliente de origen. Puedes conseguirlo [extendiendo el modelo `Client`](#overriding-default-models) y definiendo un método `skipsAuthorization`. Si `skipsAuthorization` devuelve `true`, el cliente será aprobado y el usuario será redirigido de vuelta a la `redirect_uri` inmediatamente, a menos que la aplicación consumidora haya establecido explícitamente el parámetro `prompt` al redirigir para autorización:

    <?php

    namespace App\Models\Passport;

    use Laravel\Passport\Client as BaseClient;

    class Client extends BaseClient
    {
        /**
         * Determine if the client should skip the authorization prompt.
         *
         * @return bool
         */
        public function skipsAuthorization()
        {
            return $this->firstParty();
        }
    }

<a name="requesting-tokens-converting-authorization-codes-to-access-tokens"></a>
#### Conversión de códigos de autorización en tokens de acceso

Si el usuario aprueba la solicitud de autorización, será redirigido de vuelta a la aplicación consumidora. El consumidor debe comprobar primero el parámetro de `state` comparándolo con el valor almacenado antes de la redirección. Si el parámetro de estado coincide, el consumidor debe enviar una petición `POST` a su aplicación para solicitar un token de acceso. La petición debe incluir el código de autorización que fue emitido por tu aplicación cuando el usuario aprobó la petición de autorización:

    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Http;

    Route::get('/callback', function (Request $request) {
        $state = $request->session()->pull('state');

        throw_unless(
            strlen($state) > 0 && $state === $request->state,
            InvalidArgumentException::class
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

La ruta `/oauth/token` devolverá una respuesta JSON que contiene los atributos `access_token`, `refresh_token` y `expires_in`. El atributo `expires_in` contiene el número de segundos que faltan para que caduque el token de acceso.

> **Nota**  
> Al igual que la ruta `/oauth/authorize`, la ruta `/oauth/token` es definida por Passport. No es necesario definir manualmente esta ruta.

<a name="tokens-json-api"></a>
#### API JSON

Passport también incluye una API JSON para gestionar tokens de acceso autorizados. Puede emparejar esto con su propio frontend para ofrecer a sus usuarios un panel de control para gestionar los tokens de acceso. Por comodidad, utilizaremos [Axios](https://github.com/mzabriskie/axios) para mostrar cómo realizar solicitudes HTTP a los puntos finales. La API JSON está protegida por el middleware `web` y `auth`; por lo tanto, sólo puede ser llamada desde tu propia aplicación.

<a name="get-oauthtokens"></a>
#### `GET /oauth/tokens`

Esta ruta devuelve todos los tokens de acceso autorizados que el usuario autenticado ha creado. Esto es útil principalmente para listar todos los tokens del usuario para que, por ejemplo, pueda revocarlos:

```js
axios.get('/oauth/tokens')
    .then(response => {
        console.log(response.data);
    });
```

<a name="delete-oauthtokenstoken-id"></a>
#### `DELETE /oauth/tokens/{token-id}`

Esta ruta se puede utilizar para revocar los tokens de acceso autorizados y sus tokens de actualización relacionados:

```js
axios.delete('/oauth/tokens/' + tokenId);
```

<a name="refreshing-tokens"></a>
### Actualización de tokens

Si su aplicación emite tokens de acceso de corta duración, los usuarios tendrán que actualizar sus tokens de acceso a través del token de actualización que se les proporcionó cuando se emitió el token de acceso:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'refresh_token',
        'refresh_token' => 'the-refresh-token',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'scope' => '',
    ]);

    return $response->json();

La ruta `/oauth/token` devolverá una respuesta JSON con los atributos `access_token`, `refresh_token` y `expires_in`. El atributo `expires_in` contiene el número de segundos que faltan para que caduque el token de acceso.

<a name="revoking-tokens"></a>
### Revocación de tokens

Puedes revocar un token usando el método `revokeAccessToken` de `Laravel\Passport\TokenRepository`. Puedes revocar los tokens de refresco de un token usando el método `revokeRefreshTokensByAccessTokenId` de `Laravel\Passport\RefreshTokenRepository`. Estas clases pueden resolverse utilizando el [contenedor de servicios](/docs/{{version}}/container) de Laravel:

    use Laravel\Passport\TokenRepository;
    use Laravel\Passport\RefreshTokenRepository;

    $tokenRepository = app(TokenRepository::class);
    $refreshTokenRepository = app(RefreshTokenRepository::class);

    // Revoke an access token...
    $tokenRepository->revokeAccessToken($tokenId);

    // Revoke all of the token's refresh tokens...
    $refreshTokenRepository->revokeRefreshTokensByAccessTokenId($tokenId);

<a name="purging-tokens"></a>
### Borrar tokens

Cuando los tokens han sido revocados o han caducado, es posible que desee borrarlos de la base de datos. El comando `passport:purge` Artisan incluido en Passport puede hacerlo por ti:

```shell
# Purge revoked and expired tokens and auth codes...
php artisan passport:purge

# Only purge revoked tokens and auth codes...
php artisan passport:purge --revoked

# Only purge expired tokens and auth codes...
php artisan passport:purge --expired
```

También puede configurar un [trabajo programado](/docs/{{version}}/scheduling) en la clase `App\Console\Kernel` de su aplicación para borrar automáticamente sus tokens:

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command('passport:purge')->hourly();
    }

<a name="code-grant-pkce"></a>
## Concesión de códigos de autorización con PKCE

La concesión de Código de Autorización con "Proof Key for Code Exchange" (PKCE) es una forma segura de autenticar aplicaciones de una sola página o aplicaciones nativas para acceder a su API. Esta concesión debe utilizarse cuando no pueda garantizar que la clave secreta del cliente se almacenará de forma confidencial o para mitigar la amenaza de que un atacante intercepte el código de autorización. Una combinación de un "verificador de código" y un "desafío de código" sustituye a la clave secreta del cliente cuando se intercambia el código de autorización por un token de acceso.

<a name="creating-a-auth-pkce-grant-client"></a>
### Creación del cliente

Antes de que tu aplicación pueda emitir tokens a través de la concesión de código de autorización con PKCE, necesitarás crear un cliente habilitado para PKCE. Usted puede hacer esto usando el comando Artisan `passport:client` con la opción `--public`:

```shell
php artisan passport:client --public
```

<a name="requesting-auth-pkce-grant-tokens"></a>
### Solicitud de tokens

<a name="code-verifier-code-challenge"></a>
#### Verificador de Código y Desafío de Código

Como esta concesión de autorización no proporciona una clave secreta de cliente, los desarrolladores tendrán que generar una combinación de verificador de código y desafío de código para solicitar un token.

El verificador de código debe ser una cadena aleatoria de entre 43 y 128 caracteres que contenga letras, números y caracteres `"-"`, `"."`, `"_"`, `"~"`, tal y como se define en la [especificación RFC 7636](https://tools.ietf.org/html/rfc7636).

El desafío de código debe ser una cadena codificada en Base64 con URL y caracteres seguros de nombre de archivo. Los caracteres `'='` finales deben ser eliminados y no debe haber saltos de línea, espacios en blanco u otros caracteres adicionales.

    $encoded = base64_encode(hash('sha256', $code_verifier, true));

    $codeChallenge = strtr(rtrim($encoded, '='), '+/', '-_');

<a name="code-grant-pkce-redirecting-for-authorization"></a>
#### Redireccionamiento para autorización

Una vez creado un cliente, puede utilizar el ID del cliente, el verificador de código y el desafío de código generados para solicitar un código de autorización y un token de acceso a su aplicación. Primero, la aplicación consumidora debe hacer una petición de redirección a la ruta `/oauth/authorize` de tu aplicación:

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
#### Conversión de códigos de autorización en tokens de acceso

Si el usuario aprueba la solicitud de autorización, será redirigido de vuelta a la aplicación consumidora. El consumidor debe verificar el parámetro de `state` contra el valor que fue almacenado antes de la redirección, como en la concesión estándar del código de autorización.

Si el parámetro `state` coincide, el consumidor debe emitir una petición `POST` a su aplicación para solicitar un token de acceso. La solicitud debe incluir el código de autorización que fue emitido por su aplicación cuando el usuario aprobó la solicitud de autorización junto con el verificador de código generado originalmente:

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
## Concesión de tokens con contraseña

> **Advertencia**  
> Ya no recomendamos el uso de tokens de concesión de contraseña. En su lugar, deberías elegir [un tipo de concesión que esté actualmente recomendado por OAuth2 Server](https://oauth2.thephpleague.com/authorization-server/which-grant/).

La concesión de contraseña OAuth2 permite a sus otros clientes "first-party", como una aplicación móvil, obtener un token de acceso utilizando una dirección de correo electrónico / nombre de usuario y contraseña. Esto le permite emitir tokens de acceso de forma segura a sus clientes "first-party" sin necesidad de que sus usuarios pasen por todo el flujo de redirección de código de autorización OAuth2.

<a name="creating-a-password-grant-client"></a>
### Creación de un cliente de concesión de contraseña

Antes de que su aplicación pueda emitir tokens a través de la concesión de contraseña, necesitará crear un cliente de concesión de contraseña. Puedes hacerlo utilizando el comando Artisan `passport:client` con la opción `--password`. **Si ya ha ejecutado el comando `passport:install`, no necesita ejecutar este comando:**

```shell
php artisan passport:client --password
```

<a name="requesting-password-grant-tokens"></a>
### Solicitud de tokens

Una vez que haya creado un cliente de concesión de contraseña, puede solicitar un token de acceso emitiendo una solicitud `POST` a la ruta `/oauth/token` con la dirección de correo electrónico y la contraseña del usuario. Recuerde que esta ruta ya está registrada por Passport, por lo que no es necesario definirla manualmente. Si la solicitud tiene éxito, recibirá un `access_token` y un `refresh_token` en la respuesta JSON del servidor:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'password',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'username' => 'taylor@laravel.com',
        'password' => 'my-password',
        'scope' => '',
    ]);

    return $response->json();

> **Nota**  
> Recuerda, los tokens de acceso son de larga duración por defecto. Sin embargo, eres libre de [configurar](#configuration) la duración máxima de tu token de acceso si es necesario.

<a name="requesting-all-scopes"></a>
### Solicitud de todos los ámbitos

Cuando utilice la concesión de contraseña o la concesión de credenciales de cliente, es posible que desee autorizar el token para todos los ámbitos admitidos por su aplicación. Puede hacerlo solicitando el ámbito `*`. Si solicita el ámbito `*`, el método `can` de la instancia del token siempre devolverá `true`. Este ámbito sólo puede asignarse a un token que se emita utilizando la concesión `password` o `client_credentials`:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'password',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'username' => 'taylor@laravel.com',
        'password' => 'my-password',
        'scope' => '*',
    ]);

<a name="customizing-the-user-provider"></a>
### Personalización del Proveedor de Usuario

Si su aplicación utiliza más de un [proveedor de usuario de autenticación](/docs/{{version}}/authentication#introduction), puede especificar qué proveedor de usuario utiliza el cliente de concesión de contraseña proporcionando una opción `--provider` al crear el cliente mediante el comando `artisan passport:client --password`. El nombre del proveedor dado debe coincidir con un proveedor válido definido en el archivo de configuración `config/auth.php`  de su aplicación. A continuación, puede [proteger su ruta utilizando middleware](#via-middleware) para asegurarse de que sólo los usuarios del proveedor especificado en la guarda están autorizados.

<a name="customizing-the-username-field"></a>
### Personalización del campo de nombre de usuario

Cuando se autentique utilizando la concesión de contraseña, Passport utilizará el atributo de `email` de su modelo autenticable como "nombre de usuario". Sin embargo, puede personalizar este comportamiento definiendo un método `findForPassport` en su modelo:

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
         *
         * @param  string  $username
         * @return \App\Models\User
         */
        public function findForPassport($username)
        {
            return $this->where('username', $username)->first();
        }
    }

<a name="customizing-the-password-validation"></a>
### Personalización de la validación de contraseña

Cuando se autentique utilizando la concesión de contraseña, Passport utilizará el atributo `password` de su modelo para validar la contraseña dada. Si su modelo no tiene un atributo de `password` o desea personalizar la lógica de validación de la contraseña, puede definir un método `validateForPassportPasswordGrant` en su modelo:

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
         *
         * @param  string  $password
         * @return bool
         */
        public function validateForPassportPasswordGrant($password)
        {
            return Hash::check($password, $this->password);
        }
    }

<a name="implicit-grant-tokens"></a>
## Tokens de Concesión Implícitos

> **Advertencia**  
> Ya no recomendamos el uso de tokens de concesión implícitos. En su lugar, deberías elegir [un tipo de grant que actualmente es recomendado por OAuth2 Server](https://oauth2.thephpleague.com/authorization-server/which-grant/).

La concesión implícita es similar a la concesión de código de autorización; sin embargo, el token se devuelve al cliente sin intercambiar un código de autorización. Esta concesión se utiliza más comúnmente para JavaScript o aplicaciones móviles donde las credenciales del cliente no se pueden almacenar de forma segura. Para habilitar la concesión, llame al método `enableImplicitGrant` en el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación:

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::enableImplicitGrant();
    }

Una vez habilitada la concesión, los desarrolladores pueden utilizar su ID de cliente para solicitar un token de acceso a su aplicación. La aplicación consumidora debería hacer una petición de redirección a la ruta `/oauth/authorize` de tu aplicación de esta forma:

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

> **Nota**  
> Recuerde que la ruta `/oauth/authorize` ya está definida por Passport. No es necesario definir manualmente esta ruta.

<a name="client-credentials-grant-tokens"></a>
## Concesión de credenciales de cliente

La concesión de credenciales de cliente es adecuada para la autenticación de máquina a máquina. Por ejemplo, puede utilizar esta concesión en un trabajo programado que realice tareas de mantenimiento a través de una API.

Antes de que tu aplicación pueda emitir tokens a través de la concesión de credenciales de cliente, necesitarás crear un cliente de concesión de credenciales de cliente. Puedes hacer esto usando la opción `--client` del comando `passport:client` de Artisan:

```shell
php artisan passport:client --client
```

Luego, para usar este tipo de concesión, necesitas agregar el middleware `CheckClientCredentials` a la propiedad `$routeMiddleware` de tu archivo `app/Http/Kernel.php`:

    use Laravel\Passport\Http\Middleware\CheckClientCredentials;

    protected $routeMiddleware = [
        'client' => CheckClientCredentials::class,
    ];

A continuación, adjunte el middleware a una ruta:

    Route::get('/orders', function (Request $request) {
        ...
    })->middleware('client');

Para restringir el acceso a la ruta a ámbitos específicos, puede proporcionar una lista delimitada por comas de los ámbitos requeridos al adjuntar el middleware `client` a la ruta:

    Route::get('/orders', function (Request $request) {
        ...
    })->middleware('client:check-status,your-scope');

<a name="retrieving-tokens"></a>
### Recuperación de tokens

Para recuperar un token utilizando este tipo de concesión, realice una solicitud al endpoint `oauth/token`:

    use Illuminate\Support\Facades\Http;

    $response = Http::asForm()->post('http://passport-app.test/oauth/token', [
        'grant_type' => 'client_credentials',
        'client_id' => 'client-id',
        'client_secret' => 'client-secret',
        'scope' => 'your-scope',
    ]);

    return $response->json()['access_token'];

<a name="personal-access-tokens"></a>
## Tokens de acceso personal

A veces, sus usuarios pueden querer emitir tokens de acceso a sí mismos sin pasar por el típico flujo de redirección de código de autorización. Permitir a los usuarios emitir tokens a través de la interfaz de usuario de su aplicación puede ser útil para permitir a los usuarios experimentar con su API o puede servir como un enfoque más simple para la emisión de tokens de acceso en general.

> **Nota**  
> Si tu aplicación utiliza principalmente Passport para emitir tokens de acceso personal, considera el uso de [Laravel Sanctum](/docs/{{version}}/sanctum), la librería ligera de Laravel para la emisión de tokens de acceso a la API.

<a name="creating-a-personal-access-client"></a>
### Creación de un cliente de acceso personal

Antes de que su aplicación pueda emitir tokens de acceso personal, necesitará crear un cliente de acceso personal. Puedes hacer esto ejecutando el comando `passport:client` de Artisan con la opción `--personal`. Si ya ha ejecutado el comando `passport:install`, no necesita ejecutar este comando:

```shell
php artisan passport:client --personal
```

Después de crear tu cliente de acceso personal, coloca el ID del cliente y el valor del secreto en texto plano en el archivo `.env` de tu aplicación:

```ini
PASSPORT_PERSONAL_ACCESS_CLIENT_ID="client-id-value"
PASSPORT_PERSONAL_ACCESS_CLIENT_SECRET="unhashed-client-secret-value"
```

<a name="managing-personal-access-tokens"></a>
### Gestión de tokens de acceso personal

Una vez que haya creado un cliente de acceso personal, puede emitir tokens para un usuario determinado utilizando el método `createToken` en la instancia del modelo `App\Models\User`. El método `createToken` acepta el nombre del token como primer argumento y una array opcional de [ámbitos](#token-scopes) como segundo argumento:

    use App\Models\User;

    $user = User::find(1);

    // Creating a token without scopes...
    $token = $user->createToken('Token Name')->accessToken;

    // Creating a token with scopes...
    $token = $user->createToken('My Token', ['place-orders'])->accessToken;

<a name="personal-access-tokens-json-api"></a>
#### API JSON

Passport también incluye una API JSON para gestionar tokens de acceso personales. Puede emparejarlo con su propio frontend para ofrecer a sus usuarios un panel de control para gestionar los tokens de acceso personales. A continuación, revisaremos todas las rutas de la API para gestionar los tokens de acceso personal. Para mayor comodidad, utilizaremos [Axios](https://github.com/mzabriskie/axios) para mostrar cómo realizar solicitudes HTTP a los endpoints.

La API JSON está protegida por el middleware `web` y `auth`; por lo tanto, sólo puede ser invocada desde su propia aplicación. No se puede llamar desde una fuente externa.

<a name="get-oauthscopes"></a>
#### `GET /oauth/scopes`

Esta ruta devuelve todos los [ámbitos](#token-scopes) definidos para su aplicación. Puede utilizar esta ruta para listar los ámbitos que un usuario puede asignar a un token de acceso personal:

```js
axios.get('/oauth/scopes')
    .then(response => {
        console.log(response.data);
    });
```

<a name="get-oauthpersonal-access-tokens"></a>
#### `GET /oauth/personal-access-tokens`

Esta ruta devuelve todos los tokens de acceso personal que el usuario autenticado ha creado. Esto es útil principalmente para listar todos los tokens del usuario para que, por ejemplo, pueda editarlos o revocarlos:

```js
axios.get('/oauth/personal-access-tokens')
    .then(response => {
        console.log(response.data);
    });
```

<a name="post-oauthpersonal-access-tokens"></a>
#### `POST /oauth/personal-access-tokens`

Esta ruta crea nuevos tokens de acceso personal. Requiere dos datos: el `name` del token y los `scopes (ámbitos)`  que deben asignarse al token:

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

Esta ruta puede utilizarse para revocar tokens de acceso personal:

```js
axios.delete('/oauth/personal-access-tokens/' + tokenId);
```

<a name="protecting-routes"></a>
## Protección de rutas

<a name="via-middleware"></a>
### Mediante middleware

Passport incluye una [guarda de autenticación](/docs/{{version}}/authentication#adding-custom-guards) que validará los tokens de acceso en las peticiones entrantes. Una vez configurado la guarda `api` para utilizar el controlador `passport`, sólo es necesario especificar el middleware `auth:api` en cualquier ruta que requiera un token de acceso válido:

    Route::get('/user', function () {
        //
    })->middleware('auth:api');

> **Advertencia**  
> Si estás utilizando la concesión de [credenciales de cliente](#client-credentials-grant-tokens), debes utilizar [el middleware de `cliente`](#client-credentials-grant-tokens) para proteger tus rutas en lugar del middleware `auth:api`.

<a name="multiple-authentication-guards"></a>
#### Guardas de autenticación múltiple

Si tu aplicación autentica diferentes tipos de usuarios que quizás utilicen modelos de Eloquent completamente diferentes, es probable que necesites definir una configuración de guarda para cada tipo de proveedor de usuario en tu aplicación. Esto le permite proteger peticiones destinadas a proveedores de usuario específicos. Por ejemplo, dada la siguiente configuración de guarda, el archivo de configuración `config/auth.php`::

    'api' => [
        'driver' => 'passport',
        'provider' => 'users',
    ],

    'api-customers' => [
        'driver' => 'passport',
        'provider' => 'customers',
    ],

La siguiente ruta utilizará la guarda `api-customers`, que utiliza el proveedor de usuario `customers`, para autenticar las peticiones entrantes:

    Route::get('/customer', function () {
        //
    })->middleware('auth:api-customers');

> **Nota**  
> Para más información sobre el uso de proveedores de usuarios múltiples con Passport, consulte la [documentación](#customizing-the-user-provider) sobre concesión de contraseñas.

<a name="passing-the-access-token"></a>
### Paso del token de acceso

Al llamar a rutas protegidas por Passport, los consumidores de la API de tu aplicación deben especificar su token de acceso como token `Bearer` en la cabecera `Authorization` de su petición. Por ejemplo, al utilizar la biblioteca HTTP Guzzle:

    use Illuminate\Support\Facades\Http;

    $response = Http::withHeaders([
        'Accept' => 'application/json',
        'Authorization' => 'Bearer '.$accessToken,
    ])->get('https://passport-app.test/api/user');

    return $response->json();

<a name="token-scopes"></a>
## Ámbitos de token

Los ámbitos permiten a sus clientes API solicitar un conjunto específico de permisos cuando solicitan autorización para acceder a una cuenta. Por ejemplo, si está creando una aplicación de comercio electrónico, no todos los consumidores de la API necesitarán la capacidad de realizar pedidos. En su lugar, puede permitir que los consumidores sólo soliciten autorización para acceder a los estados de envío de los pedidos. En otras palabras, los ámbitos permiten a los usuarios de su aplicación limitar las acciones que una aplicación de terceros puede realizar en su nombre.

<a name="defining-scopes"></a>
### Definición de ámbitos

Puede definir los ámbitos de su API utilizando el método `Passport::tokensCan` en el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación. El método `tokensCan` acepta una array de nombres de ámbito y descripciones de ámbito. La descripción del ámbito puede ser cualquier cosa que desee y se mostrará a los usuarios en la pantalla de aprobación de autorización:

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::tokensCan([
            'place-orders' => 'Place orders',
            'check-status' => 'Check order status',
        ]);
    }

<a name="default-scope"></a>
### Ámbito predeterminado

Si un cliente no solicita ningún ámbito específico, puede configurar el servidor Passport para que adjunte ámbitos predeterminados al token mediante el método `setDefaultScope`. Normalmente, debe llamar a este método desde el método `boot` de la clase `App\Providers\AuthServiceProvider` de su aplicación:

    use Laravel\Passport\Passport;

    Passport::tokensCan([
        'place-orders' => 'Place orders',
        'check-status' => 'Check order status',
    ]);

    Passport::setDefaultScope([
        'check-status',
        'place-orders',
    ]);

> **Nota**
> Los ámbitos predeterminados de **Passport** no se aplican a los tokens de acceso personales generados por el usuario.

<a name="assigning-scopes-to-tokens"></a>
### Asignación de ámbitos a tokens

<a name="when-requesting-authorization-codes"></a>
#### Al solicitar códigos de autorización

Al solicitar un token de acceso utilizando la concesión de código de autorización, los consumidores deben especificar los ámbitos deseados como parámetro de la cadena de consulta `scope`. El parámetro de `scope` debe ser una lista de ámbitos delimitada por espacios:

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
#### Al expedir tokens de acceso personal

Si está emitiendo tokens de acceso personal utilizando el método `createToken` del modelo `App\Models\User`, puede pasar el array de ámbitos deseados como segundo argumento al método:

    $token = $user->createToken('My Token', ['place-orders'])->accessToken;

<a name="checking-scopes"></a>
### Comprobación de ámbitos

Passport incluye dos middleware que pueden utilizarse para verificar que una solicitud entrante está autenticada con un token al que se ha concedido un ámbito determinado. Para empezar, añada el siguiente middleware a la propiedad `$routeMiddleware` de su archivo `app/Http/Kernel.php`:

    'scopes' => \Laravel\Passport\Http\Middleware\CheckScopes::class,
    'scope' => \Laravel\Passport\Http\Middleware\CheckForAnyScope::class,

<a name="check-for-all-scopes"></a>
#### Comprobar todos los ámbitos

El middleware `scopes` puede ser asignado a una ruta para verificar que el token de acceso de la petición entrante tiene todos los ámbitos listados:

    Route::get('/orders', function () {
        // Access token has both "check-status" and "place-orders" scopes...
    })->middleware(['auth:api', 'scopes:check-status,place-orders']);

<a name="check-for-any-scopes"></a>
#### Comprobar todos los ámbitos

El middleware `scopes` puede asignarse a una ruta para verificar que el token de acceso de la solicitud entrante tiene *al menos uno* de los ámbitos enumerados:

    Route::get('/orders', function () {
        // Access token has either "check-status" or "place-orders" scope...
    })->middleware(['auth:api', 'scope:check-status,place-orders']);

<a name="checking-scopes-on-a-token-instance"></a>
#### Comprobación de ámbitos en una instancia de token

Una vez que una solicitud autenticada con un token de acceso ha entrado en su aplicación, puede comprobar si el token tiene un ámbito determinado utilizando el método `tokenCan` en la instancia autenticada de `App\Models\User`:

    use Illuminate\Http\Request;

    Route::get('/orders', function (Request $request) {
        if ($request->user()->tokenCan('place-orders')) {
            //
        }
    });

<a name="additional-scope-methods"></a>
#### Métodos de ámbito adicionales

El método `scopeIds` devolverá un array de todos los IDs / nombres definidos:

    use Laravel\Passport\Passport;

    Passport::scopeIds();

El método `scopes` devolverá un array de todos los scopes definidos como instancias de `Laravel\Passport\Scope`:

    Passport::scopes();

El método `scopesFor` devolverá un array de instancias de `Laravel\Passport\Scope` que coincidan con los IDs / nombres dados:

    Passport::scopesFor(['place-orders', 'check-status']);

Puede determinar si un ámbito dado ha sido definido utilizando el método `hasScope`:

    Passport::hasScope('place-orders');

<a name="consuming-your-api-with-javascript"></a>
## Uso de la API con JavaScript

Cuando se construye una API, puede ser extremadamente útil poder consumir su propia API desde su aplicación JavaScript. Este enfoque del desarrollo de API permite que su propia aplicación consuma la misma API que está compartiendo con el mundo. La misma API puede ser consumida por tu aplicación web, aplicaciones móviles, aplicaciones de terceros y cualquier SDK que puedas publicar en varios gestores de paquetes.

Normalmente, si desea consumir su API desde su aplicación JavaScript, tendría que enviar manualmente un token de acceso a la aplicación y pasarlo con cada solicitud a su aplicación. Sin embargo, Passport incluye un middleware que puede gestionar esto por usted. Todo lo que tiene que hacer es añadir el middleware `CreateFreshApiToken` a su grupo middleware `web` en su archivo `app/Http/Kernel.php` :

    'web' => [
        // Other middleware...
        \Laravel\Passport\Http\Middleware\CreateFreshApiToken::class,
    ],

> **Advertencia**  
> Debes asegurarte de que el middleware `CreateFreshApiToken` es el último middleware listado en tu pila de middleware.

Este middleware adjuntará una cookie `laravel_token` a tus respuestas salientes. Esta cookie contiene un JWT cifrado que Passport utilizará para autenticar las solicitudes de API de su aplicación JavaScript. El JWT tiene un tiempo de vida igual a tu valor de configuración `session.lifetime` . Ahora, dado que el navegador enviará automáticamente la cookie con todas las solicitudes posteriores, puede realizar solicitudes a la API de su aplicación sin pasar explícitamente un token de acceso:

    axios.get('/api/user')
        .then(response => {
            console.log(response.data);
        });

<a name="customizing-the-cookie-name"></a>
#### Personalizar el nombre de la cookie

Si es necesario, puede personalizar el nombre de la cookie `laravel_token` utilizando el método `Passport::cookie`. Normalmente, este método debe ser llamado desde el método de `boot` de la clase `AppProviders\AuthServiceProvider` de su aplicación:

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::cookie('custom_name');
    }

<a name="csrf-protection"></a>
#### Protección CSRF

Cuando se utiliza este método de autenticación, usted tendrá que asegurarse de que un encabezado token CSRF válido se incluye en sus peticiones. El andamiaje JavaScript predeterminado de Laravel incluye una instancia de Axios, que utilizará automáticamente el valor cifrado de la cookie `XSRF-TOKEN` para enviar una cabecera `X-XSRF-TOKEN` en las peticiones del mismo origen.

> **Nota**  
> Si decide enviar la cabecera `X-CSRF-TOKEN` en lugar de `X-XSRF-TOKEN`, tendrá que utilizar el token sin cifrar proporcionado por `csrf_token()`.

<a name="events"></a>
## Eventos

Passport genera eventos cuando emite tokens de acceso y tokens de actualización. Puede utilizar estos eventos para borrar o revocar otros tokens de acceso en su base de datos. Si lo desea, puede adjuntar oyentes a estos eventos en la clase `AppProviders\EventServiceProvider` de su aplicación:

    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        'Laravel\Passport\Events\AccessTokenCreated' => [
            'App\Listeners\RevokeOldTokens',
        ],

        'Laravel\Passport\Events\RefreshTokenCreated' => [
            'App\Listeners\PruneOldTokens',
        ],
    ];

<a name="testing"></a>
## Testing

El método `actingAs` de Passport puede utilizarse para especificar el usuario autenticado actualmente, así como sus ámbitos. El primer argumento dado al método `actingAs` es la instancia del usuario y el segundo es una array de ámbitos que deberían concederse al token del usuario:

    use App\Models\User;
    use Laravel\Passport\Passport;

    public function test_servers_can_be_created()
    {
        Passport::actingAs(
            User::factory()->create(),
            ['create-servers']
        );

        $response = $this->post('/api/create-server');

        $response->assertStatus(201);
    }

El método `actingAsClient` de Passport puede utilizarse para especificar el cliente autenticado actualmente, así como sus ámbitos. El primer argumento dado al método `actingAsClient` es la instancia del cliente y el segundo es un array de ámbitos que deben concederse al token del cliente:

    use Laravel\Passport\Client;
    use Laravel\Passport\Passport;

    public function test_orders_can_be_retrieved()
    {
        Passport::actingAsClient(
            Client::factory()->create(),
            ['check-status']
        );

        $response = $this->get('/api/orders');

        $response->assertStatus(200);
    }
