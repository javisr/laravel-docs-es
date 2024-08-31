# Restableciendo Contraseñas

- [Introducción](#introduction)
  - [Preparación del Modelo](#model-preparation)
  - [Preparación de la Base de Datos](#database-preparation)
  - [Configurando Hosts de Confianza](#configuring-trusted-hosts)
- [Enrutamiento](#routing)
  - [Solicitar el Enlace para Restablecer la Contraseña](#requesting-the-password-reset-link)
  - [Restableciendo la Contraseña](#resetting-the-password)
- [Eliminando Tokens Expirados](#deleting-expired-tokens)
- [Personalización](#password-customization)

<a name="introduction"></a>
## Introducción

La mayoría de las aplicaciones web ofrecen una manera para que los usuarios restablezcan sus contraseñas olvidadas. En lugar de obligarte a reimplementar esto manualmente para cada aplicación que crees, Laravel proporciona servicios convenientes para enviar enlaces de restablecimiento de contraseña y restablecer contraseñas de forma segura.
> [!NOTA]
¿Quieres comenzar rápido? Instala un [kit de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits) en una nueva aplicación Laravel. Los kits de inicio de Laravel se encargarán de crear toda tu sistema de autenticación, incluyendo la recuperación de contraseñas olvidadas.

<a name="model-preparation"></a>
### Preparación del Modelo

Antes de usar las funciones de restablecimiento de contraseña de Laravel, el modelo `App\Models\User` de tu aplicación debe usar el rasgo `Illuminate\Notifications\Notifiable`. Típicamente, este rasgo ya está incluido en el modelo `App\Models\User` predeterminado que se crea con nuevas aplicaciones Laravel.
A continuación, verifica que tu modelo `App\Models\User` implemente el contrato `Illuminate\Contracts\Auth\CanResetPassword`. El modelo `App\Models\User` incluido con el framework ya implementa esta interfaz y utiliza el trait `Illuminate\Auth\Passwords\CanResetPassword` para incluir los métodos necesarios para implementar la interfaz.

<a name="database-preparation"></a>
### Preparación de la Base de Datos

Se debe crear una tabla para almacenar los tokens de restablecimiento de contraseña de tu aplicación. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000000_create_users_table.php`.

<a name="configuring-trusted-hosts"></a>
### Configurando Hosts Confiables

Por defecto, Laravel responderá a todas las solicitudes que reciba, independientemente del contenido del encabezado `Host` de la solicitud HTTP. Además, el valor del encabezado `Host` se utilizará al generar URLs absolutas a tu aplicación durante una solicitud web.
Típicamente, debes configurar tu servidor web, como Nginx o Apache, para que solo envíe solicitudes a tu aplicación que coincidan con un hostname dado. Sin embargo, si no tienes la capacidad de personalizar tu servidor web directamente y necesitas instruir a Laravel para que solo responda a ciertos hostnames, puedes hacerlo utilizando el método `trustHosts` del middleware en el archivo `bootstrap/app.php` de tu aplicación. Esto es especialmente importante cuando tu aplicación ofrece funcionalidad de restablecimiento de contraseña.
Para obtener más información sobre este método de middleware, consulta la [documentación del middleware `TrustHosts`](/docs/%7B%7Bversion%7D%7D/requests#configuring-trusted-hosts).

<a name="routing"></a>
## Enrutamiento

Para implementar correctamente el soporte para permitir que los usuarios restablezcan sus contraseñas, necesitaremos definir varias rutas. Primero, necesitaremos un par de rutas para manejar la solicitud del usuario de un enlace de restablecimiento de contraseña a través de su dirección de correo electrónico. En segundo lugar, necesitaremos un par de rutas para manejar el restablecimiento real de la contraseña una vez que el usuario visite el enlace de restablecimiento de contraseña que se le envió por correo y complete el formulario de restablecimiento de contraseña.

<a name="requesting-the-password-reset-link"></a>
### Solicitando el Enlace de Restablecimiento de Contraseña


<a name="the-password-reset-link-request-form"></a>
#### El formulario de solicitud de enlace de restablecimiento de contraseña

Primero, definiremos las rutas que son necesarias para solicitar enlaces de restablecimiento de contraseña. Para comenzar, definiremos una ruta que devuelve una vista con el formulario de solicitud de enlace de restablecimiento de contraseña:


```php
Route::get('/forgot-password', function () {
    return view('auth.forgot-password');
})->middleware('guest')->name('password.request');
```
La vista que devuelve esta ruta debe tener un formulario que contenga un campo `email`, que permitirá al usuario solicitar un enlace para restablecer la contraseña para una dirección de correo electrónico dada.

<a name="password-reset-link-handling-the-form-submission"></a>
A continuación, definiremos una ruta que maneja la solicitud de envío del formulario desde la vista "olvidé mi contraseña". Esta ruta será responsable de validar la dirección de correo electrónico y enviar la solicitud de restablecimiento de contraseña al usuario correspondiente:


```php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;

Route::post('/forgot-password', function (Request $request) {
    $request->validate(['email' => 'required|email']);

    $status = Password::sendResetLink(
        $request->only('email')
    );

    return $status === Password::RESET_LINK_SENT
                ? back()->with(['status' => __($status)])
                : back()->withErrors(['email' => __($status)]);
})->middleware('guest')->name('password.email');
```
Antes de continuar, examinemos esta ruta en más detalle. Primero, se valida el atributo `email` de la solicitud. A continuación, utilizaremos el "broker de contraseñas" incorporado de Laravel (a través de la facade `Password`) para enviar un enlace de restablecimiento de contraseña al usuario. El broker de contraseñas se encargará de recuperar al usuario por el campo dado (en este caso, la dirección de correo electrónico) y enviar al usuario un enlace de restablecimiento de contraseña a través del [sistema de notificaciones](/docs/%7B%7Bversion%7D%7D/notifications) incorporado de Laravel.
El método `sendResetLink` devuelve un slug de "estado". Este estado puede ser traducido utilizando los helpers de [localización](/docs/%7B%7Bversion%7D%7D/localization) de Laravel para mostrar un mensaje amigable al usuario sobre el estado de su solicitud. La traducción del estado de restablecimiento de contraseña se determina por el archivo de idioma `lang/{lang}/passwords.php` de tu aplicación. Una entrada para cada posible valor del slug de estado se encuentra dentro del archivo de idioma `passwords`.
> [!NOTA]
Por defecto, el esqueleto de la aplicación Laravel no incluye el directorio `lang`. Si deseas personalizar los archivos de idioma de Laravel, puedes publicarlos a través del comando Artisan `lang:publish`.
Es posible que te estés preguntando cómo sabe Laravel recuperar el registro de usuario de la base de datos de tu aplicación al llamar al método `sendResetLink` de la fachada `Password`. El broker de contraseñas de Laravel utiliza los "proveedores de usuarios" de tu sistema de autenticación para recuperar los registros de la base de datos. El proveedor de usuarios utilizado por el broker de contraseñas se configura dentro del array de configuración `passwords` de tu archivo de configuración `config/auth.php`. Para obtener más información sobre cómo escribir proveedores de usuarios personalizados, consulta la [documentación de autenticación](/docs/%7B%7Bversion%7D%7D/authentication#adding-custom-user-providers).
> [!NOTE]
Al implementar restablecimientos de contraseña manualmente, se te exige definir el contenido de las vistas y rutas tú mismo. Si deseas un scaffold que incluya toda la lógica de autenticación y verificación necesaria, consulta los [kits de inicio de aplicación de Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits).

<a name="resetting-the-password"></a>
### Restableciendo la Contraseña


<a name="the-password-reset-form"></a>
#### El Formulario de Restablecimiento de Contraseña

A continuación, definiremos las rutas necesarias para restablecer la contraseña una vez que el usuario haga clic en el enlace de restablecimiento de contraseña que se les ha enviado por correo y proporcione una nueva contraseña. Primero, definamos la ruta que mostrará el formulario de restablecimiento de contraseña que se muestra cuando el usuario hace clic en el enlace de restablecimiento de contraseña. Esta ruta recibirá un parámetro `token` que utilizaremos más adelante para verificar la solicitud de restablecimiento de contraseña:


```php
Route::get('/reset-password/{token}', function (string $token) {
    return view('auth.reset-password', ['token' => $token]);
})->middleware('guest')->name('password.reset');
```
La vista que devuelve esta ruta debería mostrar un formulario que contenga un campo `email`, un campo `password`, un campo `password_confirmation` y un campo `token` oculto, que debe contener el valor del secreto `$token` recibido por nuestra ruta.

<a name="password-reset-handling-the-form-submission"></a>
#### Manejo de la Envío del Formulario

Por supuesto, necesitamos definir una ruta para manejar realmente la presentación del formulario de restablecimiento de contraseña. Esta ruta será responsable de validar la solicitud entrante y actualizar la contraseña del usuario en la base de datos:


```php
use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

Route::post('/reset-password', function (Request $request) {
    $request->validate([
        'token' => 'required',
        'email' => 'required|email',
        'password' => 'required|min:8|confirmed',
    ]);

    $status = Password::reset(
        $request->only('email', 'password', 'password_confirmation', 'token'),
        function (User $user, string $password) {
            $user->forceFill([
                'password' => Hash::make($password)
            ])->setRememberToken(Str::random(60));

            $user->save();

            event(new PasswordReset($user));
        }
    );

    return $status === Password::PASSWORD_RESET
                ? redirect()->route('login')->with('status', __($status))
                : back()->withErrors(['email' => [__($status)]]);
})->middleware('guest')->name('password.update');
```
Antes de continuar, examinemos esta ruta en más detalle. Primero, se validan los atributos `token`, `email` y `password` de la solicitud. A continuación, utilizaremos el "broker de contraseñas" incorporado de Laravel (a través de la fachada `Password`) para validar las credenciales de la solicitud de restablecimiento de contraseña.
Si el token, la dirección de correo electrónico y la contraseña dados al broker de contraseñas son válidos, la función anónima pasada al método `reset` será invocada. Dentro de esta función anónima, que recibe la instancia del usuario y la contraseña en texto plano proporcionada al formulario de restablecimiento de contraseña, podemos actualizar la contraseña del usuario en la base de datos.
El método `reset` devuelve un slug de "estado". Este estado puede ser traducido utilizando los ayudantes de [localización](/docs/%7B%7Bversion%7D%7D/localization) de Laravel para mostrar un mensaje amigable al usuario sobre el estado de su solicitud. La traducción del estado de restablecimiento de contraseña se determina por el archivo de idioma `lang/{lang}/passwords.php` de tu aplicación. Una entrada para cada posible valor del slug de estado se encuentra dentro del archivo de idioma `passwords`. Si tu aplicación no contiene un directorio `lang`, puedes crearlo utilizando el comando Artisan `lang:publish`.
Antes de continuar, es posible que te estés preguntando cómo Laravel sabe cómo recuperar el registro del usuario de la base de datos de tu aplicación al llamar al método `reset` de la fachada `Password`. El broker de contraseñas de Laravel utiliza los "proveedores de usuarios" de tu sistema de autenticación para recuperar registros de la base de datos. El proveedor de usuarios utilizado por el broker de contraseñas se configura dentro del array de configuración `passwords` de tu archivo de configuración `config/auth.php`. Para obtener más información sobre cómo escribir proveedores de usuarios personalizados, consulta la [documentación de autenticación](/docs/{{version}}/authentication#adding-custom-user-providers).

<a name="deleting-expired-tokens"></a>
## Eliminando Tokens Expirados

Los tokens de restablecimiento de contraseña que han expirado seguirán presentes en tu base de datos. Sin embargo, puedes eliminar fácilmente estos registros utilizando el comando Artisan `auth:clear-resets`:


```shell
php artisan auth:clear-resets

```
Si deseas automatizar este proceso, considera añadir el comando al [programador](/docs/%7B%7Bversion%7D%7D/scheduling) de tu aplicación:


```php
use Illuminate\Support\Facades\Schedule;

Schedule::command('auth:clear-resets')->everyFifteenMinutes();
```

<a name="password-customization"></a>
## Personalización


<a name="reset-link-customization"></a>
#### Personalización del enlace de restablecimiento

Puedes personalizar la URL del enlace de restablecimiento de contraseña utilizando el método `createUrlUsing` proporcionado por la clase de notificación `ResetPassword`. Este método acepta una `función anónima` que recibe la instancia del usuario que está recibiendo la notificación, así como el token del enlace de restablecimiento de contraseña. Típicamente, debes llamar a este método desde el método `boot` del proveedor de servicios `App\Providers\AppServiceProvider`:


```php
use App\Models\User;
use Illuminate\Auth\Notifications\ResetPassword;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    ResetPassword::createUrlUsing(function (User $user, string $token) {
        return 'https://example.com/reset-password?token='.$token;
    });
}
```

<a name="reset-email-customization"></a>
#### Personalización del Correo Electrónico de Restablecimiento

Puedes modificar fácilmente la clase de notificación utilizada para enviar el enlace de restablecimiento de contraseña al usuario. Para comenzar, sobrescribe el método `sendPasswordResetNotification` en tu modelo `App\Models\User`. Dentro de este método, puedes enviar la notificación utilizando cualquier [clase de notificación](/docs/%7B%7Bversion%7D%7D/notifications) de tu propia creación. El `$token` de restablecimiento de contraseña es el primer argumento que recibe el método. Puedes usar este `$token` para construir la URL de restablecimiento de contraseña de tu elección y enviar tu notificación al usuario:


```php
use App\Notifications\ResetPasswordNotification;

/**
 * Send a password reset notification to the user.
 *
 * @param  string  $token
 */
public function sendPasswordResetNotification($token): void
{
    $url = 'https://example.com/reset-password?token='.$token;

    $this->notify(new ResetPasswordNotification($url));
}
```