# Verificación de Correo Electrónico

- [Introducción](#introduction)
    - [Preparación del Modelo](#model-preparation)
    - [Preparación de la Base de Datos](#database-preparation)
- [Ruteo](#verification-routing)
    - [El Aviso de Verificación de Correo Electrónico](#the-email-verification-notice)
    - [El Manejador de Verificación de Correo Electrónico](#the-email-verification-handler)
    - [Reenviando el Correo Electrónico de Verificación](#resending-the-verification-email)
    - [Protegiendo Rutas](#protecting-routes)
- [Personalización](#customization)
- [Eventos](#events)

<a name="introduction"></a>
## Introducción

Muchas aplicaciones web requieren que los usuarios verifiquen sus direcciones de correo electrónico antes de usar la aplicación. En lugar de obligarte a reimplementar esta función manualmente para cada aplicación que creas, Laravel proporciona servicios integrados convenientes para enviar y verificar solicitudes de verificación de correo electrónico.

> [!NOTE]  
> ¿Quieres empezar rápido? Instala uno de los [kits de inicio de aplicaciones de Laravel](/docs/{{version}}/starter-kits) en una nueva aplicación de Laravel. Los kits de inicio se encargarán de la estructura de tu sistema de autenticación completo, incluyendo el soporte para la verificación de correo electrónico.

<a name="model-preparation"></a>
### Preparación del Modelo

Antes de comenzar, verifica que tu modelo `App\Models\User` implemente el contrato `Illuminate\Contracts\Auth\MustVerifyEmail`:

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

Una vez que esta interfaz se haya agregado a tu modelo, los nuevos usuarios registrados recibirán automáticamente un correo electrónico que contiene un enlace de verificación de correo electrónico. Esto sucede sin problemas porque Laravel registra automáticamente el `Illuminate\Auth\Listeners\SendEmailVerificationNotification` [listener](/docs/{{version}}/events) para el evento `Illuminate\Auth\Events\Registered`.

Si estás implementando manualmente el registro dentro de tu aplicación en lugar de usar [un kit de inicio](/docs/{{version}}/starter-kits), debes asegurarte de que estás despachando el evento `Illuminate\Auth\Events\Registered` después de que el registro de un usuario sea exitoso:

    use Illuminate\Auth\Events\Registered;

    event(new Registered($user));

<a name="database-preparation"></a>
### Preparación de la Base de Datos

A continuación, tu tabla `users` debe contener una columna `email_verified_at` para almacenar la fecha y hora en que se verificó la dirección de correo electrónico del usuario. Típicamente, esto se incluye en la migración de base de datos predeterminada `0001_01_01_000000_create_users_table.php` de Laravel.

<a name="verification-routing"></a>
## Ruteo

Para implementar correctamente la verificación de correo electrónico, se necesitarán definir tres rutas. Primero, se necesitará una ruta para mostrar un aviso al usuario de que debe hacer clic en el enlace de verificación de correo electrónico en el correo de verificación que Laravel les envió después del registro.

En segundo lugar, se necesitará una ruta para manejar las solicitudes generadas cuando el usuario hace clic en el enlace de verificación de correo electrónico en el correo.

En tercer lugar, se necesitará una ruta para reenviar un enlace de verificación si el usuario pierde accidentalmente el primer enlace de verificación.

<a name="the-email-verification-notice"></a>
### El Aviso de Verificación de Correo Electrónico

Como se mencionó anteriormente, se debe definir una ruta que devuelva una vista instruyendo al usuario a hacer clic en el enlace de verificación de correo electrónico que se les envió por correo electrónico a través de Laravel después del registro. Esta vista se mostrará a los usuarios cuando intenten acceder a otras partes de la aplicación sin verificar primero su dirección de correo electrónico. Recuerda, el enlace se envía automáticamente por correo electrónico al usuario siempre que tu modelo `App\Models\User` implemente la interfaz `MustVerifyEmail`:

    Route::get('/email/verify', function () {
        return view('auth.verify-email');
    })->middleware('auth')->name('verification.notice');

La ruta que devuelve el aviso de verificación de correo electrónico debe llamarse `verification.notice`. Es importante que la ruta tenga exactamente este nombre, ya que el middleware `verified` [incluido con Laravel](#protecting-routes) redirigirá automáticamente a este nombre de ruta si un usuario no ha verificado su dirección de correo electrónico.

> [!NOTE]  
> Al implementar manualmente la verificación de correo electrónico, se requiere que definas el contenido de la vista del aviso de verificación tú mismo. Si deseas una estructura que incluya todas las vistas de autenticación y verificación necesarias, consulta los [kits de inicio de aplicaciones de Laravel](/docs/{{version}}/starter-kits).

<a name="the-email-verification-handler"></a>
### El Manejador de Verificación de Correo Electrónico

A continuación, necesitamos definir una ruta que manejará las solicitudes generadas cuando el usuario haga clic en el enlace de verificación de correo electrónico que se les envió por correo. Esta ruta debe llamarse `verification.verify` y asignarse los middlewares `auth` y `signed`:

    use Illuminate\Foundation\Auth\EmailVerificationRequest;

    Route::get('/email/verify/{id}/{hash}', function (EmailVerificationRequest $request) {
        $request->fulfill();

        return redirect('/home');
    })->middleware(['auth', 'signed'])->name('verification.verify');

Antes de continuar, echemos un vistazo más de cerca a esta ruta. Primero, notarás que estamos utilizando un tipo de solicitud `EmailVerificationRequest` en lugar de la típica instancia `Illuminate\Http\Request`. El `EmailVerificationRequest` es una [solicitud de formulario](/docs/{{version}}/validation#form-request-validation) que se incluye con Laravel. Esta solicitud se encargará automáticamente de validar los parámetros `id` y `hash` de la solicitud.

A continuación, podemos proceder directamente a llamar al método `fulfill` en la solicitud. Este método llamará al método `markEmailAsVerified` en el usuario autenticado y despachará el evento `Illuminate\Auth\Events\Verified`. El método `markEmailAsVerified` está disponible para el modelo predeterminado `App\Models\User` a través de la clase base `Illuminate\Foundation\Auth\User`. Una vez que se haya verificado la dirección de correo electrónico del usuario, puedes redirigirlo a donde desees.

<a name="resending-the-verification-email"></a>
### Reenviando el Correo Electrónico de Verificación

A veces, un usuario puede extraviar o eliminar accidentalmente el correo electrónico de verificación de la dirección de correo electrónico. Para acomodar esto, es posible que desees definir una ruta que permita al usuario solicitar que se reenvíe el correo electrónico de verificación. Luego, puedes hacer una solicitud a esta ruta colocando un simple botón de envío de formulario dentro de tu [vista de aviso de verificación](#the-email-verification-notice):

    use Illuminate\Http\Request;

    Route::post('/email/verification-notification', function (Request $request) {
        $request->user()->sendEmailVerificationNotification();

        return back()->with('message', '¡Enlace de verificación enviado!');
    })->middleware(['auth', 'throttle:6,1'])->name('verification.send');

<a name="protecting-routes"></a>
### Protegiendo Rutas

[Los middlewares de ruta](/docs/{{version}}/middleware) pueden ser utilizados para permitir solo a los usuarios verificados acceder a una ruta dada. Laravel incluye un `verified` [alias de middleware](/docs/{{version}}/middleware#middleware-alias), que es un alias para la clase de middleware `Illuminate\Auth\Middleware\EnsureEmailIsVerified`. Dado que este alias ya está registrado automáticamente por Laravel, todo lo que necesitas hacer es adjuntar el middleware `verified` a una definición de ruta. Típicamente, este middleware se empareja con el middleware `auth`:

    Route::get('/profile', function () {
        // Solo los usuarios verificados pueden acceder a esta ruta...
    })->middleware(['auth', 'verified']);

Si un usuario no verificado intenta acceder a una ruta que ha sido asignada a este middleware, será redirigido automáticamente a la ruta nombrada `verification.notice` [ruta nombrada](/docs/{{version}}/routing#named-routes).

<a name="customization"></a>
## Personalización

<a name="verification-email-customization"></a>
#### Personalización del Correo Electrónico de Verificación

Aunque la notificación de verificación de correo electrónico predeterminada debería satisfacer los requisitos de la mayoría de las aplicaciones, Laravel te permite personalizar cómo se construye el mensaje de correo electrónico de verificación.

Para comenzar, pasa una función anónima al método `toMailUsing` proporcionado por la notificación `Illuminate\Auth\Notifications\VerifyEmail`. La función anónima recibirá la instancia del modelo notifiable que está recibiendo la notificación, así como la URL de verificación de correo electrónico firmada que el usuario debe visitar para verificar su dirección de correo electrónico. La función anónima debe devolver una instancia de `Illuminate\Notifications\Messages\MailMessage`. Típicamente, deberías llamar al método `toMailUsing` desde el método `boot` de la clase `AppServiceProvider` de tu aplicación:

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
                ->subject('Verificar Dirección de Correo Electrónico')
                ->line('Haz clic en el botón de abajo para verificar tu dirección de correo electrónico.')
                ->action('Verificar Dirección de Correo Electrónico', $url);
        });
    }

> [!NOTE]  
> Para aprender más sobre las notificaciones por correo, consulta la [documentación de notificaciones por correo](/docs/{{version}}/notifications#mail-notifications).

<a name="events"></a>
## Eventos

Al usar los [kits de inicio de aplicaciones de Laravel](/docs/{{version}}/starter-kits), Laravel despacha un `Illuminate\Auth\Events\Verified` [evento](/docs/{{version}}/events) durante el proceso de verificación de correo electrónico. Si estás manejando manualmente la verificación de correo electrónico para tu aplicación, es posible que desees despachar manualmente estos eventos después de que se complete la verificación.
