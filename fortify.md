# Laravel Fortify

- [Laravel Fortify](#laravel-fortify)
  - [Introducción](#introducción)
    - [¿Qué es Fortify?](#qué-es-fortify)
    - [¿Cuándo debo usar Fortify?](#cuándo-debo-usar-fortify)
      - [Laravel Fortify y Laravel Sanctum](#laravel-fortify-y-laravel-sanctum)
  - [Instalación](#instalación)
    - [Características de Fortify](#características-de-fortify)
    - [Deshabilitar Vistas](#deshabilitar-vistas)
      - [Deshabilitar Vistas y Restablecimiento de Contraseña](#deshabilitar-vistas-y-restablecimiento-de-contraseña)
  - [Autenticación](#autenticación)
    - [Personalizando la Autenticación de Usuarios](#personalizando-la-autenticación-de-usuarios)
      - [Guard de Autenticación](#guard-de-autenticación)
    - [Personalizando el Pipeline de Autenticación](#personalizando-el-pipeline-de-autenticación)
      - [Limitación de Autenticación](#limitación-de-autenticación)
    - [Personalizando Redirecciones](#personalizando-redirecciones)
  - [Autenticación de Dos Factores](#autenticación-de-dos-factores)
    - [Enabling Two Factor Authentication](#enabling-two-factor-authentication)
      - [Confirming Two Factor Authentication](#confirming-two-factor-authentication)
      - [Displaying the Recovery Codes](#displaying-the-recovery-codes)
    - [Authenticating With Two Factor Authentication](#authenticating-with-two-factor-authentication)
    - [Disabling Two Factor Authentication](#disabling-two-factor-authentication)
  - [Registration](#registration)
    - [Customizing Registration](#customizing-registration)
  - [Password Reset](#password-reset)
    - [Requesting a Password Reset Link](#requesting-a-password-reset-link)
      - [Handling the Password Reset Link Request Response](#handling-the-password-reset-link-request-response)
    - [Resetting the Password](#resetting-the-password)
      - [Handling the Password Reset Response](#handling-the-password-reset-response)
    - [Customizing Password Resets](#customizing-password-resets)
  - [Email Verification](#email-verification)
      - [Resending Email Verification Links](#resending-email-verification-links)
    - [Protecting Routes](#protecting-routes)
  - [Password Confirmation](#password-confirmation)

<a name="introduction"></a>
## Introducción

[Laravel Fortify](https://github.com/laravel/fortify) es una implementación de backend de autenticación independiente del frontend para Laravel. Fortify registra las rutas y controladores necesarios para implementar todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico, y más. Después de instalar Fortify, puedes ejecutar el comando Artisan `route:list` para ver las rutas que Fortify ha registrado.

Dado que Fortify no proporciona su propia interfaz de usuario, está destinado a ser emparejado con tu propia interfaz de usuario que realiza solicitudes a las rutas que registra. Discutiremos exactamente cómo hacer solicitudes a estas rutas en el resto de esta documentación.

> [!NOTE]  
> Recuerda, Fortify es un paquete que está destinado a darte una ventaja al implementar las características de autenticación de Laravel. **No estás obligado a usarlo.** Siempre eres libre de interactuar manualmente con los servicios de autenticación de Laravel siguiendo la documentación disponible en la [autenticación](/docs/{{version}}/authentication), [restablecimiento de contraseña](/docs/{{version}}/passwords), y [verificación de correo electrónico](/docs/{{version}}/verification).

<a name="what-is-fortify"></a>
### ¿Qué es Fortify?

Como se mencionó anteriormente, Laravel Fortify es una implementación de backend de autenticación independiente del frontend para Laravel. Fortify registra las rutas y controladores necesarios para implementar todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico, y más.

**No estás obligado a usar Fortify para utilizar las características de autenticación de Laravel.** Siempre eres libre de interactuar manualmente con los servicios de autenticación de Laravel siguiendo la documentación disponible en la [autenticación](/docs/{{version}}/authentication), [restablecimiento de contraseña](/docs/{{version}}/passwords), y [verificación de correo electrónico](/docs/{{version}}/verification).

Si eres nuevo en Laravel, puede que desees explorar el kit de inicio de aplicación [Laravel Breeze](/docs/{{version}}/starter-kits) antes de intentar usar Laravel Fortify. Laravel Breeze proporciona un andamiaje de autenticación para tu aplicación que incluye una interfaz de usuario construida con [Tailwind CSS](https://tailwindcss.com). A diferencia de Fortify, Breeze publica sus rutas y controladores directamente en tu aplicación. Esto te permite estudiar y familiarizarte con las características de autenticación de Laravel antes de permitir que Laravel Fortify implemente estas características por ti.

Laravel Fortify esencialmente toma las rutas y controladores de Laravel Breeze y los ofrece como un paquete que no incluye una interfaz de usuario. Esto te permite aún así crear rápidamente la implementación de backend de la capa de autenticación de tu aplicación sin estar atado a ninguna opinión de frontend en particular.

<a name="when-should-i-use-fortify"></a>
### ¿Cuándo debo usar Fortify?

Puede que te estés preguntando cuándo es apropiado usar Laravel Fortify. Primero, si estás utilizando uno de los [kits de inicio de aplicación](/docs/{{version}}/starter-kits) de Laravel, no necesitas instalar Laravel Fortify ya que todos los kits de inicio de aplicación de Laravel ya proporcionan una implementación completa de autenticación.

Si no estás utilizando un kit de inicio de aplicación y tu aplicación necesita características de autenticación, tienes dos opciones: implementar manualmente las características de autenticación de tu aplicación o usar Laravel Fortify para proporcionar la implementación de backend de estas características.

Si eliges instalar Fortify, tu interfaz de usuario realizará solicitudes a las rutas de autenticación de Fortify que se detallan en esta documentación para autenticar y registrar usuarios.

Si eliges interactuar manualmente con los servicios de autenticación de Laravel en lugar de usar Fortify, puedes hacerlo siguiendo la documentación disponible en la [autenticación](/docs/{{version}}/authentication), [restablecimiento de contraseña](/docs/{{version}}/passwords), y [verificación de correo electrónico](/docs/{{version}}/verification).

<a name="laravel-fortify-and-laravel-sanctum"></a>
#### Laravel Fortify y Laravel Sanctum

Algunos desarrolladores se confunden respecto a la diferencia entre [Laravel Sanctum](/docs/{{version}}/sanctum) y Laravel Fortify. Debido a que los dos paquetes resuelven problemas diferentes pero relacionados, Laravel Fortify y Laravel Sanctum no son paquetes mutuamente excluyentes o competidores.

Laravel Sanctum solo se ocupa de gestionar tokens de API y autenticar usuarios existentes utilizando cookies de sesión o tokens. Sanctum no proporciona ninguna ruta que maneje el registro de usuarios, restablecimiento de contraseña, etc.

Si estás intentando construir manualmente la capa de autenticación para una aplicación que ofrece una API o sirve como backend para una aplicación de una sola página, es completamente posible que utilices tanto Laravel Fortify (para registro de usuarios, restablecimiento de contraseña, etc.) como Laravel Sanctum (gestión de tokens de API, autenticación de sesión).

<a name="installation"></a>
## Instalación

Para comenzar, instala Fortify usando el gestor de paquetes Composer:

```shell
composer require laravel/fortify
```

A continuación, publica los recursos de Fortify usando el comando Artisan `fortify:install`:

```shell
php artisan fortify:install
```

Este comando publicará las acciones de Fortify en tu directorio `app/Actions`, que se creará si no existe. Además, se publicará el `FortifyServiceProvider`, el archivo de configuración y todas las migraciones de base de datos necesarias.

A continuación, debes migrar tu base de datos:

```shell
php artisan migrate
```

<a name="fortify-features"></a>
### Características de Fortify

El archivo de configuración `fortify` contiene un arreglo de configuración `features`. Este arreglo define qué rutas / características de backend expondrá Fortify por defecto. Si no estás utilizando Fortify en combinación con [Laravel Jetstream](https://jetstream.laravel.com), te recomendamos que solo habilites las siguientes características, que son las características básicas de autenticación proporcionadas por la mayoría de las aplicaciones Laravel:

```php
'features' => [
    Features::registration(),
    Features::resetPasswords(),
    Features::emailVerification(),
],
```

<a name="disabling-views"></a>
### Deshabilitar Vistas

Por defecto, Fortify define rutas que están destinadas a devolver vistas, como una pantalla de inicio de sesión o una pantalla de registro. Sin embargo, si estás construyendo una aplicación de una sola página impulsada por JavaScript, es posible que no necesites estas rutas. Por esa razón, puedes deshabilitar estas rutas completamente configurando el valor de configuración `views` dentro del archivo de configuración `config/fortify.php` de tu aplicación a `false`:

```php
'views' => false,
```

<a name="disabling-views-and-password-reset"></a>
#### Deshabilitar Vistas y Restablecimiento de Contraseña

Si eliges deshabilitar las vistas de Fortify y vas a implementar características de restablecimiento de contraseña para tu aplicación, aún debes definir una ruta llamada `password.reset` que sea responsable de mostrar la vista de "restablecer contraseña" de tu aplicación. Esto es necesario porque la notificación `Illuminate\Auth\Notifications\ResetPassword` de Laravel generará la URL de restablecimiento de contraseña a través de la ruta nombrada `password.reset`.

<a name="authentication"></a>
## Autenticación

Para comenzar, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de "inicio de sesión". Recuerda, Fortify es una biblioteca de autenticación headless. Si deseas una implementación de frontend de las características de autenticación de Laravel que ya estén completadas para ti, deberías usar un [kit de inicio de aplicación](/docs/{{version}}/starter-kits).

Toda la lógica de renderizado de la vista de autenticación puede ser personalizada utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, deberías llamar a este método desde el método `boot` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación. Fortify se encargará de definir la ruta `/login` que devuelve esta vista:

    use Laravel\Fortify\Fortify;

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Fortify::loginView(function () {
            return view('auth.login');
        });

        // ...
    }

Tu plantilla de inicio de sesión debe incluir un formulario que realice una solicitud POST a `/login`. El endpoint `/login` espera un `email` / `username` y una `password`. El nombre del campo de email / username debe coincidir con el valor `username` dentro del archivo de configuración `config/fortify.php`. Además, se puede proporcionar un campo booleano `remember` para indicar que el usuario desea utilizar la funcionalidad de "recordarme" proporcionada por Laravel.

Si el intento de inicio de sesión es exitoso, Fortify te redirigirá a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud de inicio de sesión fue una solicitud XHR, se devolverá una respuesta HTTP 200.

Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla de inicio de sesión y los errores de validación estarán disponibles para ti a través de la variable de plantilla compartida `$errors` [Blade template variable](/docs/{{version}}/validation#quick-displaying-the-validation-errors). O, en el caso de una solicitud XHR, los errores de validación se devolverán con la respuesta HTTP 422.

<a name="customizing-user-authentication"></a>
### Personalizando la Autenticación de Usuarios

Fortify recuperará y autentificará automáticamente al usuario basado en las credenciales proporcionadas y el guard de autenticación que está configurado para tu aplicación. Sin embargo, a veces puede que desees tener una personalización completa sobre cómo se autentican las credenciales de inicio de sesión y se recuperan los usuarios. Afortunadamente, Fortify te permite lograr esto fácilmente utilizando el método `Fortify::authenticateUsing`.

Este método acepta una función anónima que recibe la solicitud HTTP entrante. La función anónima es responsable de validar las credenciales de inicio de sesión adjuntas a la solicitud y devolver la instancia de usuario asociada. Si las credenciales son inválidas o no se puede encontrar un usuario, `null` o `false` deben ser devueltos por la función anónima. Típicamente, este método debe ser llamado desde el método `boot` de tu `FortifyServiceProvider`:

```php
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::authenticateUsing(function (Request $request) {
        $user = User::where('email', $request->email)->first();

        if ($user &&
            Hash::check($request->password, $user->password)) {
            return $user;
        }
    });

    // ...
}
```

<a name="authentication-guard"></a>
#### Guard de Autenticación

Puedes personalizar el guard de autenticación utilizado por Fortify dentro del archivo de configuración `fortify` de tu aplicación. Sin embargo, debes asegurarte de que el guard configurado sea una implementación de `Illuminate\Contracts\Auth\StatefulGuard`. Si estás intentando usar Laravel Fortify para autenticar un SPA, deberías usar el guard `web` por defecto de Laravel en combinación con [Laravel Sanctum](docs/sanctum).

<a name="customizing-the-authentication-pipeline"></a>
### Personalizando el Pipeline de Autenticación

Laravel Fortify autentica las solicitudes de inicio de sesión a través de un pipeline de clases invocables. Si lo deseas, puedes definir un pipeline personalizado de clases por las que deberían pasar las solicitudes de inicio de sesión. Cada clase debe tener un método `__invoke` que recibe la instancia de `Illuminate\Http\Request` entrante y, al igual que [middleware](/docs/{{version}}/middleware), una variable `$next` que se invoca para pasar la solicitud a la siguiente clase en el pipeline.

Para definir tu pipeline personalizado, puedes usar el método `Fortify::authenticateThrough`. Este método acepta una función anónima que debe devolver el arreglo de clases por las que se debe pasar la solicitud de inicio de sesión. Típicamente, este método debe ser llamado desde el método `boot` de tu clase `App\Providers\FortifyServiceProvider`.

El siguiente ejemplo contiene la definición de pipeline por defecto que puedes usar como punto de partida al hacer tus propias modificaciones:

```php
use Laravel\Fortify\Actions\AttemptToAuthenticate;
use Laravel\Fortify\Actions\EnsureLoginIsNotThrottled;
use Laravel\Fortify\Actions\PrepareAuthenticatedSession;
use Laravel\Fortify\Actions\RedirectIfTwoFactorAuthenticatable;
use Laravel\Fortify\Fortify;
use Illuminate\Http\Request;

Fortify::authenticateThrough(function (Request $request) {
    return array_filter([
            config('fortify.limiters.login') ? null : EnsureLoginIsNotThrottled::class,
            Features::enabled(Features::twoFactorAuthentication()) ? RedirectIfTwoFactorAuthenticatable::class : null,
            AttemptToAuthenticate::class,
            PrepareAuthenticatedSession::class,
    ]);
});
```

#### Limitación de Autenticación

Por defecto, Fortify limitará los intentos de autenticación utilizando el middleware `EnsureLoginIsNotThrottled`. Este middleware limita los intentos que son únicos para una combinación de nombre de usuario y dirección IP.

Algunas aplicaciones pueden requerir un enfoque diferente para limitar los intentos de autenticación, como limitar solo por dirección IP. Por lo tanto, Fortify te permite especificar tu propio [limitador de tasa](/docs/{{version}}/routing#rate-limiting) a través de la opción de configuración `fortify.limiters.login`. Por supuesto, esta opción de configuración se encuentra en el archivo de configuración `config/fortify.php` de tu aplicación.

> [!NOTE]  
> Utilizar una mezcla de limitación, [autenticación de dos factores](/docs/{{version}}/fortify#two-factor-authentication), y un firewall de aplicación web (WAF) externo proporcionará la defensa más robusta para tus usuarios legítimos de la aplicación.

<a name="customizing-authentication-redirects"></a>
### Personalizando Redirecciones

Si el intento de inicio de sesión es exitoso, Fortify te redirigirá a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud de inicio de sesión fue una solicitud XHR, se devolverá una respuesta HTTP 200. Después de que un usuario cierre sesión de la aplicación, el usuario será redirigido a la URI `/`.

Si necesitas una personalización avanzada de este comportamiento, puedes vincular implementaciones de los contratos `LoginResponse` y `LogoutResponse` en el [contenedor de servicios](/docs/{{version}}/container) de Laravel. Típicamente, esto debería hacerse dentro del método `register` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación:

```php
use Laravel\Fortify\Contracts\LogoutResponse;

/**
 * Register any application services.
 */
public function register(): void
{
    $this->app->instance(LogoutResponse::class, new class implements LogoutResponse {
        public function toResponse($request)
        {
            return redirect('/');
        }
    });
}
```

<a name="two-factor-authentication"></a>
## Autenticación de Dos Factores

Cuando la característica de autenticación de dos factores de Fortify está habilitada, se requiere que el usuario ingrese un token numérico de seis dígitos durante el proceso de autenticación. Este token se genera utilizando una contraseña de un solo uso basada en tiempo (TOTP) que se puede recuperar de cualquier aplicación de autenticación móvil compatible con TOTP, como Google Authenticator.

Antes de comenzar, primero debes asegurarte de que el modelo `App\Models\User` de tu aplicación use el trait `Laravel\Fortify\TwoFactorAuthenticatable`:

```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;

class User extends Authenticatable
{
    use Notifiable, TwoFactorAuthenticatable;
}
 ```

Next, you should build a screen within your application where users can manage their two factor authentication settings. This screen should allow the user to enable and disable two factor authentication, as well as regenerate their two factor authentication recovery codes.

> By default, the `features` array of the `fortify` configuration file instructs Fortify's two factor authentication settings to require password confirmation before modification. Therefore, your application should implement Fortify's [password confirmation](#password-confirmation) feature before continuing.

<a name="enabling-two-factor-authentication"></a>
### Enabling Two Factor Authentication

To begin enabling two factor authentication, your application should make a POST request to the `/user/two-factor-authentication` endpoint defined by Fortify. If the request is successful, the user will be redirected back to the previous URL and the `status` session variable will be set to `two-factor-authentication-enabled`. You may detect this `status` session variable within your templates to display the appropriate success message. If the request was an XHR request, `200` HTTP response will be returned.

After choosing to enable two factor authentication, the user must still "confirm" their two factor authentication configuration by providing a valid two factor authentication code. So, your "success" message should instruct the user that two factor authentication confirmation is still required:

```html
@if (session('status') == 'two-factor-authentication-enabled')
    <div class="mb-4 font-medium text-sm">
        Por favor, termina de configurar la autenticación de dos factores a continuación.
    </div>
@endif
```

Next, you should display the two factor authentication QR code for the user to scan into their authenticator application. If you are using Blade to render your application's frontend, you may retrieve the QR code SVG using the `twoFactorQrCodeSvg` method available on the user instance:

```php
$request->user()->twoFactorQrCodeSvg();
```
If you are building a JavaScript powered frontend, you may make an XHR GET request to the `/user/two-factor-qr-code` endpoint to retrieve the user's two factor authentication QR code. This endpoint will return a JSON object containing an `svg` key.

<a name="confirming-two-factor-authentication"></a>
#### Confirming Two Factor Authentication

In addition to displaying the user's two factor authentication QR code, you should provide a text input where the user can supply a valid authentication code to "confirm" their two factor authentication configuration. This code should be provided to the Laravel application via a POST request to the `/user/confirmed-two-factor-authentication` endpoint defined by Fortify.

If the request is successful, the user will be redirected back to the previous URL and the `status` session variable will be set to `two-factor-authentication-confirmed`:

```html
@if (session('status') == 'two-factor-authentication-confirmed')
    <div class="mb-4 font-medium text-sm">
        La autenticación de dos factores ha sido confirmada y habilitada con éxito.
    </div>
@endif
```

If the request to the two factor authentication confirmation endpoint was made via an XHR request, a `200` HTTP response will be returned.

<a name="displaying-the-recovery-codes"></a>
#### Displaying the Recovery Codes

You should also display the user's two factor recovery codes. These recovery codes allow the user to authenticate if they lose access to their mobile device. If you are using Blade to render your application's frontend, you may access the recovery codes via the authenticated user instance:

```php
(array) $request->user()->recoveryCodes()
```

If you are building a JavaScript powered frontend, you may make an XHR GET request to the `/user/two-factor-recovery-codes` endpoint. This endpoint will return a JSON array containing the user's recovery codes.

To regenerate the user's recovery codes, your application should make a POST request to the `/user/two-factor-recovery-codes` endpoint.

<a name="authenticating-with-two-factor-authentication"></a>
### Authenticating With Two Factor Authentication

During the authentication process, Fortify will automatically redirect the user to your application's two factor authentication challenge screen. However, if your application is making an XHR login request, the JSON response returned after a successful authentication attempt will contain a JSON object that has a `two_factor` boolean property. You should inspect this value to know whether you should redirect to your application's two factor authentication challenge screen.

To begin implementing two factor authentication functionality, we need to instruct Fortify how to return our two factor authentication challenge view. All of Fortify's authentication view rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your application's `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::twoFactorChallengeView(function () {
        return view('auth.two-factor-challenge');
    });

    // ...
}
```

Fortify will take care of defining the `/two-factor-challenge` route that returns this view. Your `two-factor-challenge` template should include a form that makes a POST request to the `/two-factor-challenge` endpoint. The `/two-factor-challenge` action expects a `code` field that contains a valid TOTP token or a `recovery_code` field that contains one of the user's recovery codes.

If the login attempt is successful, Fortify will redirect the user to the URI configured via the `home` configuration option within your application's `fortify` configuration file. If the login request was an XHR request, a 204 HTTP response will be returned.

If the request was not successful, the user will be redirected back to the two factor challenge screen and the validation errors will be available to you via the shared `$errors` [Blade template variable](/docs/{{version}}/validation#quick-displaying-the-validation-errors). Or, in the case of an XHR request, the validation errors will be returned with a 422 HTTP response.

<a name="disabling-two-factor-authentication"></a>
### Disabling Two Factor Authentication

To disable two factor authentication, your application should make a DELETE request to the `/user/two-factor-authentication` endpoint. Remember, Fortify's two factor authentication endpoints require [password confirmation](#password-confirmation) prior to being called.

<a name="registration"></a>
## Registration

To begin implementing our application's registration functionality, we need to instruct Fortify how to return our "register" view. Remember, Fortify is a headless authentication library. If you would like a frontend implementation of Laravel's authentication features that are already completed for you, you should use an [application starter kit](/docs/{{version}}/starter-kits).

All of Fortify's view rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::registerView(function () {
        return view('auth.register');
    });

    // ...
}
```

Fortify will take care of defining the `/register` route that returns this view. Your `register` template should include a form that makes a POST request to the `/register` endpoint defined by Fortify.

The `/register` endpoint expects a string `name`, string email address / username, `password`, and `password_confirmation` fields. The name of the email / username field should match the `username` configuration value defined within your application's `fortify` configuration file.

If the registration attempt is successful, Fortify will redirect the user to the URI configured via the `home` configuration option within your application's `fortify` configuration file. If the request was an XHR request, a 201 HTTP response will be returned.

If the request was not successful, the user will be redirected back to the registration screen and the validation errors will be available to you via the shared `$errors` [Blade template variable](/docs/{{version}}/validation#quick-displaying-the-validation-errors). Or, in the case of an XHR request, the validation errors will be returned with a 422 HTTP response.

<a name="customizing-registration"></a>
### Customizing Registration

The user validation and creation process may be customized by modifying the `App\Actions\Fortify\CreateNewUser` action that was generated when you installed Laravel Fortify.

<a name="password-reset"></a>
## Password Reset

<a name="requesting-a-password-reset-link"></a>
### Requesting a Password Reset Link

To begin implementing our application's password reset functionality, we need to instruct Fortify how to return our "forgot password" view. Remember, Fortify is a headless authentication library. If you would like a frontend implementation of Laravel's authentication features that are already completed for you, you should use an [application starter kit](/docs/{{version}}/starter-kits).

All of Fortify's view rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your application's `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::requestPasswordResetLinkView(function () {
        return view('auth.forgot-password');
    });

    // ...
}
```

Fortify will take care of defining the `/forgot-password` endpoint that returns this view. Your `forgot-password` template should include a form that makes a POST request to the `/forgot-password` endpoint.

The `/forgot-password` endpoint expects a string `email` field. The name of this field / database column should match the `email` configuration value within your application's `fortify` configuration file.

<a name="handling-the-password-reset-link-request-response"></a>
#### Handling the Password Reset Link Request Response

If the password reset link request was successful, Fortify will redirect the user back to the `/forgot-password` endpoint and send an email to the user with a secure link they can use to reset their password. If the request was an XHR request, a 200 HTTP response will be returned.

After being redirected back to the `/forgot-password` endpoint after a successful request, the `status` session variable may be used to display the status of the password reset link request attempt.

The value of the `$status` session variable will match one of the translation strings defined within your application's `passwords` [language file](/docs/{{version}}/localization). If you would like to customize this value and have not published Laravel's language files, you may do so via the `lang:publish` Artisan command:

```html
@if (session('status'))
    <div class="mb-4 font-medium text-sm text-green-600">
        {{ session('status') }}
    </div>
@endif
```

If the request was not successful, the user will be redirected back to the request password reset link screen and the validation errors will be available to you via the shared `$errors` [Blade template variable](/docs/{{version}}/validation#quick-displaying-the-validation-errors). Or, in the case of an XHR request, the validation errors will be returned with a 422 HTTP response.

<a name="resetting-the-password"></a>
### Resetting the Password

To finish implementing our application's password reset functionality, we need to instruct Fortify how to return our "reset password" view.

All of Fortify's view rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your application's `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;
use Illuminate\Http\Request;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::resetPasswordView(function (Request $request) {
        return view('auth.reset-password', ['request' => $request]);
    });

    // ...
}
```

Fortify will take care of defining the route to display this view. Your `reset-password` template should include a form that makes a POST request to `/reset-password`.

The `/reset-password` endpoint expects a string `email` field, a `password` field, a `password_confirmation` field, and a hidden field named `token` that contains the value of `request()->route('token')`. The name of the "email" field / database column should match the `email` configuration value defined within your application's `fortify` configuration file.

<a name="handling-the-password-reset-response"></a>
#### Handling the Password Reset Response

If the password reset request was successful, Fortify will redirect back to the `/login` route so that the user can log in with their new password. In addition, a `status` session variable will be set so that you may display the successful status of the reset on your login screen:

```blade
@if (session('status'))
    <div class="mb-4 font-medium text-sm text-green-600">
        {{ session('status') }}
    </div>
@endif
```

If the request was an XHR request, a 200 HTTP response will be returned.

If the request was not successful, the user will be redirected back to the reset password screen and the validation errors will be available to you via the shared `$errors` [Blade template variable](/docs/{{version}}/validation#quick-displaying-the-validation-errors). Or, in the case of an XHR request, the validation errors will be returned with a 422 HTTP response.

<a name="customizing-password-resets"></a>
### Customizing Password Resets

The password reset process may be customized by modifying the `App\Actions\ResetUserPassword` action that was generated when you installed Laravel Fortify.

<a name="email-verification"></a>
## Email Verification

After registration, you may wish for users to verify their email address before they continue accessing your application. To get started, ensure the `emailVerification` feature is enabled in your `fortify` configuration file's `features` array. Next, you should ensure that your `App\Models\User` class implements the `Illuminate\Contracts\Auth\MustVerifyEmail` interface.

Once these two setup steps have been completed, newly registered users will receive an email prompting them to verify their email address ownership. However, we need to inform Fortify how to display the email verification screen which informs the user that they need to go click the verification link in the email.

All of Fortify's view's rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your application's `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::verifyEmailView(function () {
        return view('auth.verify-email');
    });

    // ...
}
```

Fortify will take care of defining the route that displays this view when a user is redirected to the `/email/verify` endpoint by Laravel's built-in `verified` middleware.

Your `verify-email` template should include an informational message instructing the user to click the email verification link that was sent to their email address.

<a name="resending-email-verification-links"></a>
#### Resending Email Verification Links

If you wish, you may add a button to your application's `verify-email` template that triggers a POST request to the `/email/verification-notification` endpoint. When this endpoint receives a request, a new verification email link will be emailed to the user, allowing the user to get a new verification link if the previous one was accidentally deleted or lost.

If the request to resend the verification link email was successful, Fortify will redirect the user back to the `/email/verify` endpoint with a `status` session variable, allowing you to display an informational message to the user informing them the operation was successful. If the request was an XHR request, a 202 HTTP response will be returned:

```blade
@if (session('status') == 'verification-link-sent')
    <div class="mb-4 font-medium text-sm text-green-600">
        ¡Un nuevo enlace de verificación de correo electrónico ha sido enviado a tu correo!
    </div>
@endif
```

<a name="protecting-routes"></a>
### Protecting Routes

To specify that a route or group of routes requires that the user has verified their email address, you should attach Laravel's built-in `verified` middleware to the route. The `verified` middleware alias is automatically registered by Laravel and serves as an alias for the `Illuminate\Routing\Middleware\ValidateSignature` middleware:

```php
Route::get('/dashboard', function () {
    // ...
})->middleware(['verified']);
```

<a name="password-confirmation"></a>
## Password Confirmation

While building your application, you may occasionally have actions that should require the user to confirm their password before the action is performed. Typically, these routes are protected by Laravel's built-in `password.confirm` middleware.

To begin implementing password confirmation functionality, we need to instruct Fortify how to return our application's "password confirmation" view. Remember, Fortify is a headless authentication library. If you would like a frontend implementation of Laravel's authentication features that are already completed for you, you should use an [application starter kit](/docs/{{version}}/starter-kits).

All of Fortify's view rendering logic may be customized using the appropriate methods available via the `Laravel\Fortify\Fortify` class. Typically, you should call this method from the `boot` method of your application's `App\Providers\FortifyServiceProvider` class:

```php
use Laravel\Fortify\Fortify;

/**
 * Inicializa cualquier servicio de la aplicación.
 */
public function boot(): void
{
    Fortify::confirmPasswordView(function () {
        return view('auth.confirm-password');
    });

    // ...
}
```

Fortify se encargará de definir el endpoint `/user/confirm-password` que devuelve esta vista. Tu plantilla `confirm-password` debe incluir un formulario que realice una solicitud POST al endpoint `/user/confirm-password`. El endpoint `/user/confirm-password` espera un campo `password` que contenga la contraseña actual del usuario.

Si la contraseña coincide con la contraseña actual del usuario, Fortify redirigirá al usuario a la ruta que intentaba acceder. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP 201.

Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla de confirmación de contraseña y los errores de validación estarán disponibles a través de la variable de plantilla Blade compartida `$errors`. O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.
