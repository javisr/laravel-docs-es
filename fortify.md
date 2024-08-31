# Laravel Fortify

- [Introducción](#introduction)
  - [¿Qué es Fortify?](#what-is-fortify)
  - [¿Cuándo debo usar Fortify?](#when-should-i-use-fortify)
- [Instalación](#installation)
  - [Características de Fortify](#fortify-features)
  - [Deshabilitar Vistas](#disabling-views)
- [Autenticación](#authentication)
  - [Personalizando la Autenticación de Usuario](#customizing-user-authentication)
  - [Personalizando el Pipeline de Autenticación](#customizing-the-authentication-pipeline)
  - [Personalizando Redireccionamientos](#customizing-authentication-redirects)
- [Autenticación de Dos Factores](#two-factor-authentication)
  - [Habilitar Autenticación de Dos Factores](#enabling-two-factor-authentication)
  - [Autenticación con Autenticación de Dos Factores](#authenticating-with-two-factor-authentication)
  - [Deshabilitar Autenticación de Dos Factores](#disabling-two-factor-authentication)
- [Registro](#registration)
  - [Personalizando el Registro](#customizing-registration)
- [Restablecimiento de Contraseña](#password-reset)
  - [Solicitar un Enlace para Restablecer la Contraseña](#requesting-a-password-reset-link)
  - [Restablecer la Contraseña](#resetting-the-password)
  - [Personalizando Restablecimientos de Contraseña](#customizing-password-resets)
- [Verificación de Email](#email-verification)
  - [Protegiendo Rutas](#protecting-routes)
- [Confirmación de Contraseña](#password-confirmation)

<a name="introduction"></a>
## Introducción

[Laravel Fortify](https://github.com/laravel/fortify) es una implementación de backend de autenticación agnóstica al frontend para Laravel. Fortify registra las rutas y controladores necesarios para implementar todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y más. Después de instalar Fortify, puedes ejecutar el comando Artisan `route:list` para ver las rutas que ha registrado Fortify.
Dado que Fortify no proporciona su propia interfaz de usuario, está diseñado para combinarse con tu propia interfaz de usuario que realiza solicitudes a las rutas que registra. Discutiremos exactamente cómo hacer solicitudes a estas rutas en el resto de esta documentación.
> [!NOTE]
Recuerda que Fortify es un paquete que está diseñado para darte una ventaja al implementar las características de autenticación de Laravel. **No estás obligado a usarlo.** Siempre puedes interactuar manualmente con los servicios de autenticación de Laravel siguiendo la documentación disponible en la [autenticación](/docs/%7B%7Bversion%7D%7D/authentication), [restablecimiento de contraseña](/docs/%7B%7Bversion%7D%7D/passwords) y [verificación de correo electrónico](/docs/%7B%7Bversion%7D%7D/verification) documentación.

<a name="what-is-fortify"></a>
### ¿Qué es Fortify?

Como se mencionó anteriormente, Laravel Fortify es una implementación de backend de autenticación independiente del frontend para Laravel. Fortify registra las rutas y controladores necesarios para implementar todas las características de autenticación de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y más.
**No es necesario usar Fortify para utilizar las funciones de autenticación de Laravel.** Siempre puedes interactuar manualmente con los servicios de autenticación de Laravel siguiendo la documentación disponible en la [autenticación](/docs/%7B%7Bversion%7D%7D/authentication), [restablecimiento de contraseña](/docs/%7B%7Bversion%7D%7D/passwords) y [verificación de correo electrónico](/docs/%7B%7Bversion%7D%7D/verification).
Si eres nuevo en Laravel, es posible que desees explorar el kit de herramientas para aplicaciones [Laravel Breeze](/docs/%7B%7Bversion%7D%7D/starter-kits) antes de intentar usar Laravel Fortify. Laravel Breeze proporciona un andamiaje de autenticación para tu aplicación que incluye una interfaz de usuario construida con [Tailwind CSS](https://tailwindcss.com). A diferencia de Fortify, Breeze publica sus rutas y controladores directamente en tu aplicación. Esto te permite estudiar y familiarizarte con las características de autenticación de Laravel antes de permitir que Laravel Fortify implemente estas características por ti.
Laravel Fortify esencialmente toma las rutas y controladores de Laravel Breeze y los ofrece como un paquete que no incluye una interfaz de usuario. Esto te permite seguir configurando rápidamente la implementación del backend de la capa de autenticación de tu aplicación sin estar vinculado a ninguna opinión particular del frontend.

<a name="when-should-i-use-fortify"></a>
### ¿Cuándo debo usar Fortify?

Es posible que te estés preguntando cuándo es apropiado usar Laravel Fortify. Primero, si estás utilizando uno de los [kits de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits) de Laravel, no necesitas instalar Laravel Fortify, ya que todos los kits de inicio de aplicación de Laravel ya proporcionan una implementación completa de autenticación.
Si no estás utilizando un kit de inicio de aplicación y tu aplicación necesita características de autenticación, tienes dos opciones: implementar manualmente las características de autenticación de tu aplicación o usar Laravel Fortify para proporcionar la implementación backend de estas características.
Si decides instalar Fortify, tu interfaz de usuario hará solicitudes a las rutas de autenticación de Fortify que se detallan en esta documentación para autenticar y registrar usuarios.
Si decides interactuar manualmente con los servicios de autenticación de Laravel en lugar de usar Fortify, puedes hacerlo siguiendo la documentación disponible en la [autenticación](/docs/%7B%7Bversion%7D%7D/authentication), [restablecimiento de contraseña](/docs/%7B%7Bversion%7D%7D/passwords) y [verificación de correo electrónico](/docs/%7B%7Bversion%7D%7D/verification).

<a name="laravel-fortify-and-laravel-sanctum"></a>
#### Laravel Fortify y Laravel Sanctum

Algunos desarrolladores se confunden respecto a la diferencia entre [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) y Laravel Fortify. Debido a que los dos paquetes resuelven dos problemas diferentes pero relacionados, Laravel Fortify y Laravel Sanctum no son paquetes excluyentes o competidores.
Laravel Sanctum solo se ocupa de la gestión de tokens API y la autenticación de usuarios existentes utilizando cookies de sesión o tokens. Sanctum no proporciona rutas que manejen el registro de usuarios, restablecimiento de contraseña, etc.
Si estás intentando construir manualmente la capa de autenticación para una aplicación que ofrece una API o que sirve como el backend para una aplicación de una sola página, es completamente posible que utilices tanto Laravel Fortify (para el registro de usuarios, restablecimiento de contraseña, etc.) como Laravel Sanctum (gestión de tokens API, autenticación de sesiones).

<a name="installation"></a>
## Instalación

Para empezar, instala Fortify utilizando el gestor de paquetes Composer:


```shell
composer require laravel/fortify

```
A continuación, publica los recursos de Fortify utilizando el comando Artisan `fortify:install`:


```shell
php artisan fortify:install

```
Este comando publicará las acciones de Fortify en tu directorio `app/Actions`, que se creará si no existe. Además, se publicará el `FortifyServiceProvider`, el archivo de configuración y todas las migraciones de base de datos necesarias.
A continuación, deberás migrar tu base de datos:


```shell
php artisan migrate

```

<a name="fortify-features"></a>
### Características de Fortify

El archivo de configuración `fortify` contiene un array de configuración `features`. Este array define qué rutas / funcionalidades del backend expondrá Fortify de manera predeterminada. Si no estás utilizando Fortify en combinación con [Laravel Jetstream](https://jetstream.laravel.com), te recomendamos que solo habilites las siguientes funciones, que son las características de autenticación básicas proporcionadas por la mayoría de las aplicaciones Laravel:


```php
'features' => [
    Features::registration(),
    Features::resetPasswords(),
    Features::emailVerification(),
],

```

<a name="disabling-views"></a>
### Desactivando Vistas

Por defecto, Fortify define rutas que están destinadas a devolver vistas, como una pantalla de inicio de sesión o una pantalla de registro. Sin embargo, si estás construyendo una aplicación de una sola página impulsada por JavaScript, es posible que no necesites estas rutas. Por esa razón, puedes desactivar estas rutas por completo configurando el valor de configuración `views` dentro del archivo de configuración `config/fortify.php` de tu aplicación a `false`:


```php
'views' => false,

```

<a name="disabling-views-and-password-reset"></a>
#### Deshabilitando Vistas y Restablecimiento de Contraseña

Si decides desactivar las vistas de Fortify y vas a implementar características de restablecimiento de contraseña para tu aplicación, aún debes definir una ruta llamada `password.reset` que sea responsable de mostrar la vista de "restablecer contraseña" de tu aplicación. Esto es necesario porque la notificación `Illuminate\Auth\Notifications\ResetPassword` de Laravel generará la URL de restablecimiento de contraseña a través de la ruta nombrada `password.reset`.

<a name="authentication"></a>
## Autenticación

Para comenzar, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de "inicio de sesión". Recuerda que Fortify es una biblioteca de autenticación headless. Si deseas una implementación frontend de las características de autenticación de Laravel que ya están completas para ti, deberías usar un [kit de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits).
Toda la lógica de renderizado de la vista de autenticación puede personalizarse utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, debes llamar a este método desde el método `boot` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación. Fortify se encargará de definir la ruta `/login` que devuelve esta vista:


```php
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
```
Tu plantilla de inicio de sesión debe incluir un formulario que realice una solicitud POST a `/login`. El endpoint `/login` espera un `email` / `username` como cadena y una `password`. El nombre del campo de email / nombre de usuario debe coincidir con el valor `username` dentro del archivo de configuración `config/fortify.php`. Además, se puede proporcionar un campo booleano `remember` para indicar que el usuario desea utilizar la funcionalidad de "recordarme" proporcionada por Laravel.
Si el intento de inicio de sesión es exitoso, Fortify te redirigirá a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud de inicio de sesión fue una solicitud XHR, se devolverá una respuesta HTTP 200.
Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla de inicio de sesión y los errores de validación estarán disponibles para ti a través de la variable de plantilla Blade compartida `$errors` [(/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors)]. O, en el caso de una solicitud XHR, los errores de validación se devolverán con la respuesta HTTP 422.

<a name="customizing-user-authentication"></a>
### Personalizando la Autenticación de Usuarios

Fortify recuperará y autenticará automáticamente al usuario en función de las credenciales proporcionadas y el guardia de autenticación que está configurado para tu aplicación. Sin embargo, a veces es posible que desees tener una personalización completa sobre cómo se autentican las credenciales de inicio de sesión y se recuperan los usuarios. Afortunadamente, Fortify te permite lograr esto fácilmente utilizando el método `Fortify::authenticateUsing`.
Este método acepta una función anónima que recibe la solicitud HTTP entrante. La función anónima es responsable de validar las credenciales de inicio de sesión adjuntas a la solicitud y devolver la instancia de usuario asociada. Si las credenciales son inválidas o no se puede encontrar un usuario, se debe devolver `null` o `false` por parte de la función anónima. Típicamente, este método debe ser llamado desde el método `boot` de tu `FortifyServiceProvider`:


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

Puedes personalizar el guardia de autenticación utilizado por Fortify dentro del archivo de configuración `fortify` de tu aplicación. Sin embargo, debes asegurarte de que el guardia configurado sea una implementación de `Illuminate\Contracts\Auth\StatefulGuard`. Si estás intentando usar Laravel Fortify para autenticar una SPA, debes usar el guardia `web` predeterminado de Laravel en combinación con [Laravel Sanctum](/docs/sanctum).

<a name="customizing-the-authentication-pipeline"></a>
### Personalizando el Pipeline de Autenticación

Laravel Fortify autentica las solicitudes de inicio de sesión a través de un pipeline de clases invocables. Si lo desea, puede definir un pipeline personalizado de clases por las que deben pasar las solicitudes de inicio de sesión. Cada clase debe tener un método `__invoke` que reciba la instancia de `Illuminate\Http\Request` entrante y, al igual que [middleware](/docs/%7B%7Bversion%7D%7D/middleware), una variable `$next` que se invoca para pasar la solicitud a la siguiente clase en el pipeline.
Para definir tu pipeline personalizado, puedes usar el método `Fortify::authenticateThrough`. Este método acepta una función anónima que debe devolver el array de clases por las que se canalizará la solicitud de inicio de sesión. Típicamente, este método debe llamarse desde el método `boot` de tu clase `App\Providers\FortifyServiceProvider`.
El ejemplo a continuación contiene la definición de pipeline por defecto que puedes usar como punto de partida al realizar tus propias modificaciones:


```php
use Laravel\Fortify\Actions\AttemptToAuthenticate;
use Laravel\Fortify\Actions\CanonicalizeUsername;
use Laravel\Fortify\Actions\EnsureLoginIsNotThrottled;
use Laravel\Fortify\Actions\PrepareAuthenticatedSession;
use Laravel\Fortify\Actions\RedirectIfTwoFactorAuthenticatable;
use Laravel\Fortify\Features;
use Laravel\Fortify\Fortify;
use Illuminate\Http\Request;

Fortify::authenticateThrough(function (Request $request) {
    return array_filter([
            config('fortify.limiters.login') ? null : EnsureLoginIsNotThrottled::class,
            config('fortify.lowercase_usernames') ? CanonicalizeUsername::class : null,
            Features::enabled(Features::twoFactorAuthentication()) ? RedirectIfTwoFactorAuthenticatable::class : null,
            AttemptToAuthenticate::class,
            PrepareAuthenticatedSession::class,
    ]);
});

```
#### Limitación de Autenticación

Por defecto, Fortify limitará los intentos de autenticación utilizando el middleware `EnsureLoginIsNotThrottled`. Este middleware limita los intentos que son únicos para una combinación de nombre de usuario y dirección IP.
Algunas aplicaciones pueden requerir un enfoque diferente para limitar los intentos de autenticación, como limitar solo por dirección IP. Por lo tanto, Fortify te permite especificar tu propio [limitador de tasa](/docs/%7B%7Bversion%7D%7D/routing#rate-limiting) a través de la opción de configuración `fortify.limiters.login`. Por supuesto, esta opción de configuración se encuentra en el archivo de configuración `config/fortify.php` de tu aplicación.
> [!NOTE]
Utilizar una mezcla de limitación, [autenticación de dos factores](/docs/%7B%7Bversion%7D%7D/fortify#two-factor-authentication) y un firewall de aplicación web (WAF) externo proporcionará la defensa más robusta para tus usuarios de aplicación legítimos.

<a name="customizing-authentication-redirects"></a>
### Personalizando Redirecciones

Si el intento de inicio de sesión es exitoso, Fortify te redirigirá a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud de inicio de sesión fue una solicitud XHR, se devolverá una respuesta HTTP 200. Después de que un usuario cierre sesión en la aplicación, el usuario será redirigido a la URI `/`.
Si necesitas una personalización avanzada de este comportamiento, puedes enlazar las implementaciones de los contratos `LoginResponse` y `LogoutResponse` en el [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel. Típicamente, esto se debe hacer dentro del método `register` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación:


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

Cuando se activa la función de autenticación de dos factores de Fortify, se requiere que el usuario ingrese un token numérico de seis dígitos durante el proceso de autenticación. Este token se genera utilizando una contraseña de un solo uso basada en el tiempo (TOTP) que se puede recuperar de cualquier aplicación de autenticación móvil compatible con TOTP, como Google Authenticator.
Antes de comenzar, primero debes asegurarte de que el modelo `App\Models\User` de tu aplicación utilice el rasgo `Laravel\Fortify\TwoFactorAuthenticatable`:


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
A continuación, debes construir una pantalla dentro de tu aplicación donde los usuarios puedan gestionar sus configuraciones de autenticación de dos factores. Esta pantalla debería permitir al usuario habilitar y deshabilitar la autenticación de dos factores, así como regenerar sus códigos de recuperación de autenticación de dos factores.
> Por defecto, el array `features` del archivo de configuración `fortify` indica que la configuración de autenticación de dos factores de Fortify requiere confirmación de contraseña antes de la modificación. Por lo tanto, tu aplicación debe implementar la función de [confirmación de contraseña](#password-confirmation) de Fortify antes de continuar.

<a name="enabling-two-factor-authentication"></a>
### Habilitando la Autenticación de Dos Factores

Para comenzar a habilitar la autenticación de dos factores, tu aplicación debe hacer una solicitud POST al endpoint `/user/two-factor-authentication` definido por Fortify. Si la solicitud tiene éxito, el usuario será redirigido de vuelta a la URL anterior y la variable de sesión `status` se establecerá en `two-factor-authentication-enabled`. Puedes detectar esta variable de sesión `status` dentro de tus plantillas para mostrar el mensaje de éxito apropiado. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP `200`.
Después de elegir habilitar la autenticación de dos factores, el usuario aún debe "confirmar" su configuración de autenticación de dos factores proporcionando un código de autenticación de dos factores válido. Así que tu mensaje de "éxito" debe instruir al usuario que aún se requiere la confirmación de la autenticación de dos factores:


```html
@if (session('status') == 'two-factor-authentication-enabled')
    <div class="mb-4 font-medium text-sm">
        Please finish configuring two factor authentication below.
    </div>
@endif

```
A continuación, deberías mostrar el código QR de autenticación de dos factores para que el usuario lo escanee en su aplicación de autenticación. Si estás utilizando Blade para renderizar el frontend de tu aplicación, puedes recuperar el SVG del código QR utilizando el método `twoFactorQrCodeSvg` disponible en la instancia del usuario:


```php
$request->user()->twoFactorQrCodeSvg();

```
Si estás construyendo un frontend impulsado por JavaScript, puedes hacer una solicitud XHR GET al endpoint `/user/two-factor-qr-code` para recuperar el código QR de autenticación de dos factores del usuario. Este endpoint devolverá un objeto JSON que contiene una clave `svg`.

<a name="confirming-two-factor-authentication"></a>
#### Confirmando la Autenticación de Dos Factores

Además de mostrar el código QR de autenticación de dos factores del usuario, debes proporcionar un campo de entrada de texto donde el usuario pueda suministrar un código de autenticación válido para "confirmar" su configuración de autenticación de dos factores. Este código debe ser enviado a la aplicación Laravel mediante una solicitud POST al endpoint `/user/confirmed-two-factor-authentication` definido por Fortify.
Si la solicitud tiene éxito, el usuario será redirigido de vuelta a la URL anterior y la variable de sesión `status` se establecerá en `two-factor-authentication-confirmed`:


```html
@if (session('status') == 'two-factor-authentication-confirmed')
    <div class="mb-4 font-medium text-sm">
        Two factor authentication confirmed and enabled successfully.
    </div>
@endif

```
Si la solicitud al endpoint de confirmación de autenticación de dos factores se realizó a través de una solicitud XHR, se devolverá una respuesta HTTP `200`.

<a name="displaying-the-recovery-codes"></a>
#### Mostrando los Códigos de Recuperación

También deberías mostrar los códigos de recuperación de dos factores del usuario. Estos códigos de recuperación permiten al usuario autenticarse si pierde el acceso a su dispositivo móvil. Si estás utilizando Blade para renderizar el frontend de tu aplicación, puedes acceder a los códigos de recuperación a través de la instancia del usuario autenticado:


```php
(array) $request->user()->recoveryCodes()

```
Si estás construyendo un frontend impulsado por JavaScript, puedes hacer una solicitud XHR GET al endpoint `/user/two-factor-recovery-codes`. Este endpoint devolverá un array JSON que contiene los códigos de recuperación del usuario.
Para regenerar los códigos de recuperación del usuario, tu aplicación debe realizar una solicitud POST al endpoint `/user/two-factor-recovery-codes`.

<a name="authenticating-with-two-factor-authentication"></a>
### Autenticación con Autenticación de Dos Factores

Durante el proceso de autenticación, Fortify redirigirá automáticamente al usuario a la pantalla de desafío de autenticación de dos factores de tu aplicación. Sin embargo, si tu aplicación está realizando una solicitud de inicio de sesión XHR, la respuesta JSON devuelta después de un intento de autenticación exitoso contendrá un objeto JSON que tiene una propiedad boolean `two_factor`. Debes inspeccionar este valor para saber si debes redirigir a la pantalla de desafío de autenticación de dos factores de tu aplicación.
Para comenzar a implementar la funcionalidad de autenticación de dos factores, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de desafío de autenticación de dos factores. Toda la lógica de renderizado de vistas de autenticación de Fortify se puede personalizar utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, debes llamar a este método desde el método `boot` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación:


```php
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::twoFactorChallengeView(function () {
        return view('auth.two-factor-challenge');
    });

    // ...
}

```
Fortify se encargará de definir la ruta `/two-factor-challenge` que devuelve esta vista. tu plantilla `two-factor-challenge` debe incluir un formulario que realice una solicitud POST al endpoint `/two-factor-challenge`. La acción `/two-factor-challenge` espera un campo `code` que contenga un token TOTP válido o un campo `recovery_code` que contenga uno de los códigos de recuperación del usuario.
Si el intento de inicio de sesión es exitoso, Fortify redirigirá al usuario a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud de inicio de sesión fue una solicitud XHR, se devolverá una respuesta HTTP 204.
Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla del desafío de dos factores y los errores de validación estarán disponibles para ti a través de la variable de plantilla `$errors` [Blade](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors). O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.

<a name="disabling-two-factor-authentication"></a>
### Deshabilitando la Autenticación de Dos Factores

Para desactivar la autenticación de dos factores, tu aplicación debe realizar una solicitud DELETE al endpoint `/user/two-factor-authentication`. Recuerda que los endpoints de autenticación de dos factores de Fortify requieren [confirmación de contraseña](#password-confirmation) antes de ser llamados.

<a name="registration"></a>
## Registro

Para comenzar a implementar la funcionalidad de registro de nuestra aplicación, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de "registro". Recuerda que Fortify es una biblioteca de autenticación sin cabeza. Si deseas una implementación frontend de las características de autenticación de Laravel que ya estén completadas para ti, deberías usar un [kit de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits).
Toda la lógica de renderizado de vistas de Fortify puede personalizarse utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, deberías llamar a este método desde el método `boot` de tu clase `App\Providers\FortifyServiceProvider`:


```php
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::registerView(function () {
        return view('auth.register');
    });

    // ...
}

```
Fortify se encargará de definir la ruta `/register` que devuelve esta vista. Tu plantilla `register` debe incluir un formulario que realice una solicitud POST al endpoint `/register` definido por Fortify.
El endpoint `/register` espera un campo de cadena `name`, dirección de correo electrónico / nombre de usuario de cadena, campos `password` y `password_confirmation`. El nombre del campo de correo electrónico / nombre de usuario debe coincidir con el valor de configuración `username` definido dentro del archivo de configuración `fortify` de tu aplicación.
Si el intento de registro es exitoso, Fortify redirigirá al usuario a la URI configurada a través de la opción de configuración `home` dentro del archivo de configuración `fortify` de tu aplicación. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP 201.
Si la solicitud no fue exitosa, el usuario será redirigido de regreso a la pantalla de registro y los errores de validación estarán disponibles para ti a través de la variable de plantilla Blade compartida `$errors` [variable de plantilla Blade](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors). O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.

<a name="customizing-registration"></a>
### Personalizando el Registro

El proceso de validación y creación de usuarios puede personalizarse modificando la acción `App\Actions\Fortify\CreateNewUser` que se generó cuando instalaste Laravel Fortify.

<a name="password-reset"></a>
## Restablecimiento de Contraseña


<a name="requesting-a-password-reset-link"></a>
### Solicitando un Enlace para Restablecer la Contraseña

Para comenzar a implementar la funcionalidad de restablecimiento de contraseña de nuestra aplicación, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de "olvidé mi contraseña". Recuerda que Fortify es una biblioteca de autenticación sin cabeza. Si deseas una implementación frontend de las características de autenticación de Laravel que ya están completas para ti, deberías usar un [kit de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits).


```php
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::requestPasswordResetLinkView(function () {
        return view('auth.forgot-password');
    });

    // ...
}

```
Fortify se encargará de definir el endpoint `/forgot-password` que devuelve esta vista. Tu plantilla `forgot-password` debe incluir un formulario que realice una solicitud POST al endpoint `/forgot-password`.
El endpoint `/forgot-password` espera un campo `email` de tipo cadena. El nombre de este campo / columna de base de datos debe coincidir con el valor de configuración `email` dentro del archivo de configuración `fortify` de tu aplicación.

<a name="handling-the-password-reset-link-request-response"></a>
#### Manejo de la Respuesta de Solicitud del Enlace de Restablecimiento de Contraseña

Si la solicitud de restablecimiento de contraseña fue exitosa, Fortify redirigirá al usuario de vuelta al endpoint `/forgot-password` y enviará un correo electrónico al usuario con un enlace seguro que pueden usar para restablecer su contraseña. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP 200.
Después de ser redirigido de nuevo al endpoint `/forgot-password` tras una solicitud exitosa, la variable de sesión `status` puede utilizarse para mostrar el estado del intento de solicitud del enlace de restablecimiento de contraseña.
El valor de la variable de sesión `$status` coincidirá con una de las cadenas de traducción definidas dentro del archivo de idioma `passwords` de tu aplicación. Si deseas personalizar este valor y no has publicado los archivos de idioma de Laravel, puedes hacerlo a través del comando Artisan `lang:publish`:


```html
@if (session('status'))
    <div class="mb-4 font-medium text-sm text-green-600">
        {{ session('status') }}
    </div>
@endif

```
Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla del enlace para restablecer la contraseña de la solicitud y los errores de validación estarán disponibles a través de la variable de plantilla compartida `$errors` [variable de plantilla Blade](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors). O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.

<a name="resetting-the-password"></a>
### Restableciendo la Contraseña

Para terminar de implementar la funcionalidad de restablecimiento de contraseña de nuestra aplicación, necesitamos instruir a Fortify sobre cómo devolver nuestra vista de "restablecer contraseña".


```php
use Laravel\Fortify\Fortify;
use Illuminate\Http\Request;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::resetPasswordView(function (Request $request) {
        return view('auth.reset-password', ['request' => $request]);
    });

    // ...
}

```
Fortify se encargará de definir la ruta para mostrar esta vista. Tu plantilla `reset-password` debe incluir un formulario que realice una solicitud POST a `/reset-password`.
El endpoint `/reset-password` espera un campo de cadena `email`, un campo `password`, un campo `password_confirmation` y un campo oculto llamado `token` que contiene el valor de `request()->route('token')`. El nombre del campo "email" / columna de base de datos debe coincidir con el valor de configuración `email` definido dentro del archivo de configuración `fortify` de tu aplicación.

<a name="handling-the-password-reset-response"></a>
#### Manejo de la Respuesta de Restablecimiento de Contraseña

Si la solicitud de restablecimiento de contraseña fue exitosa, Fortify redirigirá de vuelta a la ruta `/login` para que el usuario pueda iniciar sesión con su nueva contraseña. Además, se establecerá una variable de sesión `status` para que puedas mostrar el estado exitoso del restablecimiento en tu pantalla de inicio de sesión:


```blade
@if (session('status'))
    <div class="mb-4 font-medium text-sm text-green-600">
        {{ session('status') }}
    </div>
@endif

```
Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP 200.
Si la solicitud no fue exitosa, el usuario será redirigido de vuelta a la pantalla de restablecimiento de contraseña y los errores de validación estarán disponibles a través de la variable de plantilla `$errors` [Blade](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors). O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.

<a name="customizing-password-resets"></a>
### Personalizando Restablecimientos de Contraseña

El proceso de restablecimiento de contraseña se puede personalizar modificando la acción `App\Actions\ResetUserPassword` que se generó cuando instalaste Laravel Fortify.

<a name="email-verification"></a>
## Verificación de correo electrónico

Después del registro, puede que desees que los usuarios verifiquen su dirección de correo electrónico antes de continuar accediendo a tu aplicación. Para comenzar, asegúrate de que la función `emailVerification` esté habilitada en el array `features` del archivo de configuración `fortify`. A continuación, debes asegurarte de que tu clase `App\Models\User` implemente la interfaz `Illuminate\Contracts\Auth\MustVerifyEmail`.
Una vez que estos dos pasos de configuración se hayan completado, los nuevos usuarios registrados recibirán un correo electrónico que les solicitará verificar la propiedad de su dirección de correo electrónico. Sin embargo, necesitamos informar a Fortify cómo mostrar la pantalla de verificación de correo electrónico, que informa al usuario que debe hacer clic en el enlace de verificación en el correo electrónico.
Toda la lógica de renderización de las vistas de Fortify puede personalizarse utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, debes llamar a este método desde el método `boot` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación:


```php
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Fortify::verifyEmailView(function () {
        return view('auth.verify-email');
    });

    // ...
}

```
Fortify se encargará de definir la ruta que muestra esta vista cuando un usuario es redirigido al endpoint `/email/verify` mediante el middleware `verified` incorporado de Laravel.
Tu plantilla `verify-email` debería incluir un mensaje informativo que indique al usuario que haga clic en el enlace de verificación de correo electrónico que fue enviado a su dirección de correo electrónico.

<a name="resending-email-verification-links"></a>
#### Reenviando Enlaces de Verificación de Correo Electrónico

Si lo deseas, puedes añadir un botón a la plantilla `verify-email` de tu aplicación que active una solicitud POST al endpoint `/email/verification-notification`. Cuando este endpoint recibe una solicitud, se enviará un nuevo enlace de correo electrónico de verificación al usuario, lo que permitirá al usuario obtener un nuevo enlace de verificación si el anterior fue eliminado o perdido accidentalmente.
Si la solicitud para reenviar el correo electrónico del enlace de verificación fue exitosa, Fortify redirigirá al usuario de vuelta al endpoint `/email/verify` con una variable de sesión `status`, lo que te permitirá mostrar un mensaje informativo al usuario informándole que la operación fue exitosa. Si la solicitud fue una solicitud XHR, se devolverá una respuesta HTTP 202:


```blade
@if (session('status') == 'verification-link-sent')
    <div class="mb-4 font-medium text-sm text-green-600">
        A new email verification link has been emailed to you!
    </div>
@endif

```

<a name="protecting-routes"></a>
### Protegiendo Rutas

Para especificar que una ruta o un grupo de rutas requiere que el usuario haya verificado su dirección de correo electrónico, debes adjuntar el middleware `verified` incorporado de Laravel a la ruta. El alias de middleware `verified` es registrado automáticamente por Laravel y sirve como un alias para el middleware `Illuminate\Auth\Middleware\EnsureEmailIsVerified`:


```php
Route::get('/dashboard', function () {
    // ...
})->middleware(['verified']);

```

<a name="password-confirmation"></a>
## Confirmación de Contraseña

Mientras construyes tu aplicación, es posible que ocasionalmente tengas acciones que requieran que el usuario confirme su contraseña antes de que se realice la acción. Típicamente, estas rutas están protegidas por el middleware `password.confirm` incorporado de Laravel.
Para comenzar a implementar la funcionalidad de confirmación de contraseña, necesitamos instruir a Fortify sobre cómo devolver la vista de "confirmación de contraseña" de nuestra aplicación. Recuerda que Fortify es una biblioteca de autenticación sin cabeza. Si deseas una implementación frontal de las características de autenticación de Laravel que ya están completadas para ti, deberías usar un [kit de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits).
Toda la lógica de renderizado de vistas de Fortify puede personalizarse utilizando los métodos apropiados disponibles a través de la clase `Laravel\Fortify\Fortify`. Típicamente, debes llamar a este método desde el método `boot` de la clase `App\Providers\FortifyServiceProvider` de tu aplicación:


```php
use Laravel\Fortify\Fortify;

/**
 * Bootstrap any application services.
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
Si la solicitud no fue exitosa, el usuario será redirigido de regreso a la pantalla de confirmación de contraseña y los errores de validación estarán disponibles a través de la variable de plantilla Blade compartida `$errors`. O, en el caso de una solicitud XHR, los errores de validación se devolverán con una respuesta HTTP 422.