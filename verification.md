# Verificación de correo electrónico

- [Introducción](#introduction)
  - [Preparación del Modelo](#model-preparation)
  - [Preparación de la Base de Datos](#database-preparation)
- [Enrutamiento](#verification-routing)
  - [El Aviso de Verificación de Email](#the-email-verification-notice)
  - [El Manejador de Verificación de Email](#the-email-verification-handler)
  - [Reenviando el Email de Verificación](#resending-the-verification-email)
  - [Protegiendo Rutas](#protecting-routes)
- [Personalización](#customization)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Muchas aplicaciones web requieren que los usuarios verifiquen sus direcciones de correo electrónico antes de usar la aplicación. En lugar de obligarte a implementar esta función manualmente para cada aplicación que creas, Laravel ofrece servicios integrados convenientes para enviar y verificar solicitudes de verificación de correo electrónico.
> [!NOTE]
¿Quieres empezar rápido? Instala uno de los [kits de inicio de aplicación Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits) en una nueva aplicación Laravel. Los kits de inicio se encargarán de configurar todo tu sistema de autenticación, incluyendo soporte para verificación de correo electrónico.

<a name="model-preparation"></a>
### Preparación del Modelo

Antes de comenzar, verifica que tu modelo `App\Models\User` implemente el contrato `Illuminate\Contracts\Auth\MustVerifyEmail`:


```php
<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable implements MustVerifyEmail
{
    use Notifiable;

    // ...
}
```
Una vez que esta interfaz se haya añadido a tu modelo, los nuevos usuarios registrados recibirán automáticamente un correo electrónico que contiene un enlace de verificación de correo electrónico. Esto ocurre de manera fluida porque Laravel registra automáticamente el `Illuminate\Auth\Listeners\SendEmailVerificationNotification` [listener](/docs/%7B%7Bversion%7D%7D/events) para el evento `Illuminate\Auth\Events\Registered`.
Si estás implementando el registro manualmente dentro de tu aplicación en lugar de usar [un kit de inicio](/docs/%7B%7Bversion%7D%7D/starter-kits), debes asegurarte de que estás despachando el evento `Illuminate\Auth\Events\Registered` después de que el registro de un usuario sea exitoso:


```php
use Illuminate\Auth\Events\Registered;

event(new Registered($user));
```

<a name="database-preparation"></a>
### Preparación de la Base de Datos

A continuación, tu tabla `users` debe contener una columna `email_verified_at` para almacenar la fecha y hora en que se verificó la dirección de correo electrónico del usuario. Típicamente, esto se incluye en la migración de base de datos predeterminada de Laravel `0001_01_01_000000_create_users_table.php`.

<a name="verification-routing"></a>
## Enrutamiento

Para implementar correctamente la verificación de correo electrónico, se deberán definir tres rutas. Primero, se necesitará una ruta para mostrar un aviso al usuario de que debe hacer clic en el enlace de verificación de correo electrónico en el correo electrónico de verificación que Laravel les envió después del registro.
En segundo lugar, se necesitará una ruta para manejar las solicitudes generadas cuando el usuario hace clic en el enlace de verificación de correo electrónico en el correo.
En tercer lugar, se necesitará una ruta para reenviar un enlace de verificación si el usuario pierde accidentalmente el primer enlace de verificación.

<a name="the-email-verification-notice"></a>
### El Aviso de Verificación de Correo Electrónico

Como se mencionó anteriormente, se debe definir una ruta que devuelva una vista indicando al usuario que haga clic en el enlace de verificación de correo electrónico que Laravel les envió por correo electrónico después del registro. Esta vista se mostrará a los usuarios cuando intenten acceder a otras partes de la aplicación sin verificar primero su dirección de correo electrónico. Recuerda que el enlace se envía automáticamente por correo electrónico al usuario siempre que tu modelo `App\Models\User` implemente la interfaz `MustVerifyEmail`:


```php
Route::get('/email/verify', function () {
    return view('auth.verify-email');
})->middleware('auth')->name('verification.notice');
```
La ruta que devuelve el aviso de verificación de correo electrónico debe llamarse `verification.notice`. Es importante que la ruta tenga este nombre exacto, ya que el middleware `verified` [incluido con Laravel](#protecting-routes) redirigirá automáticamente a este nombre de ruta si un usuario no ha verificado su dirección de correo electrónico.
> [!NOTE]
Al implementar manualmente la verificación de correo electrónico, se requiere que definas el contenido de la vista de aviso de verificación tú mismo. Si deseas un scaffolding que incluya todas las vistas de autenticación y verificación necesarias, consulta los [kits de inicio de aplicaciones de Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits).

<a name="the-email-verification-handler"></a>
### El Manejador de Verificación de Correo Electrónico

A continuación, necesitamos definir una ruta que manejará las solicitudes generadas cuando el usuario haga clic en el enlace de verificación de correo electrónico que se les envió por correo. Esta ruta debe estar nombrada `verification.verify` y asignarse a los middlewares `auth` y `signed`:


```php
use Illuminate\Foundation\Auth\EmailVerificationRequest;

Route::get('/email/verify/{id}/{hash}', function (EmailVerificationRequest $request) {
    $request->fulfill();

    return redirect('/home');
})->middleware(['auth', 'signed'])->name('verification.verify');
```
Antes de continuar, echemos un vistazo más de cerca a esta ruta. Primero, notarás que estamos usando un tipo de solicitud `EmailVerificationRequest` en lugar de la típica instancia `Illuminate\Http\Request`. El `EmailVerificationRequest` es una [solicitud de formulario](/docs/%7B%7Bversion%7D%7D/validation#form-request-validation) que se incluye con Laravel. Esta solicitud se encargará automáticamente de validar los parámetros `id` y `hash` de la solicitud.
A continuación, podemos proceder directamente a llamar al método `fulfill` en la solicitud. Este método llamará al método `markEmailAsVerified` en el usuario autenticado y despachará el evento `Illuminate\Auth\Events\Verified`. El método `markEmailAsVerified` está disponible para el modelo `App\Models\User` por defecto a través de la clase base `Illuminate\Foundation\Auth\User`. Una vez que se haya verificado la dirección de correo electrónico del usuario, puedes redirigirlo a donde desees.

<a name="resending-the-verification-email"></a>
### Reenviando el Correo Electrónico de Verificación

A veces un usuario puede extraviar o eliminar accidentalmente el correo electrónico de verificación de la dirección de correo electrónico. Para acomodar esto, es posible que desees definir una ruta para permitir que el usuario solicite que se reenvíe el correo electrónico de verificación. Luego puedes hacer una solicitud a esta ruta colocando un simple botón de envío de formulario dentro de tu [vista de notificación de verificación](#the-email-verification-notice):


```php
use Illuminate\Http\Request;

Route::post('/email/verification-notification', function (Request $request) {
    $request->user()->sendEmailVerificationNotification();

    return back()->with('message', 'Verification link sent!');
})->middleware(['auth', 'throttle:6,1'])->name('verification.send');
```

<a name="protecting-routes"></a>
### Protegiendo Rutas

[Route middleware](/docs/%7B%7Bversion%7D%7D/middleware) se puede utilizar para permitir solo a usuarios verificados acceder a una ruta dada. Laravel incluye un alias de middleware `verified` [middleware alias](/docs/%7B%7Bversion%7D%7D/middleware#middleware-aliases), que es un alias para la clase de middleware `Illuminate\Auth\Middleware\EnsureEmailIsVerified`. Dado que este alias ya está registrado automáticamente por Laravel, todo lo que necesitas hacer es adjuntar el middleware `verified` a una definición de ruta. Típicamente, este middleware se combina con el middleware `auth`:


```php
Route::get('/profile', function () {
    // Only verified users may access this route...
})->middleware(['auth', 'verified']);
```
Si un usuario no verificado intenta acceder a una ruta que ha sido asignada a este middleware, será redirigido automáticamente a la ruta nombrada `verification.notice` [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes).

<a name="customization"></a>
## Personalización


<a name="verification-email-customization"></a>
#### Personalización del Correo Electrónico de Verificación

Aunque la notificación de verificación de correo electrónico predeterminada debería satisfacer los requisitos de la mayoría de las aplicaciones, Laravel te permite personalizar cómo se construye el mensaje de correo electrónico de verificación.
Para comenzar, pasa una función anónima al método `toMailUsing` proporcionado por la notificación `Illuminate\Auth\Notifications\VerifyEmail`. La función anónima recibirá la instancia del modelo notifiable que está recibiendo la notificación, así como la URL de verificación de correo electrónico firmada que el usuario debe visitar para verificar su dirección de correo electrónico. La función anónima debe devolver una instancia de `Illuminate\Notifications\Messages\MailMessage`. Típicamente, debes llamar al método `toMailUsing` desde el método `boot` de la clase `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    // ...

    VerifyEmail::toMailUsing(function (object $notifiable, string $url) {
        return (new MailMessage)
            ->subject('Verify Email Address')
            ->line('Click the button below to verify your email address.')
            ->action('Verify Email Address', $url);
    });
}
```
> [!NOTA]
Para obtener más información sobre las notificaciones por correo, consulta la [documentación de notificaciones por correo](/docs/%7B%7Bversion%7D%7D/notifications#mail-notifications).

<a name="events"></a>
## Eventos

Al utilizar los [kits de inicio de aplicaciones Laravel](/docs/%7B%7Bversion%7D%7D/starter-kits), Laravel despacha un evento `Illuminate\Auth\Events\Verified` [event](/docs/%7B%7Bversion%7D%7D/events) durante el proceso de verificación de correo electrónico. Si estás manejando la verificación de correo electrónico manualmente para tu aplicación, es posible que desees despachar estos eventos manualmente después de que se complete la verificación.